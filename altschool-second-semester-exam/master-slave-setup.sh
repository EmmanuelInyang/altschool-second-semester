#!/bin/bash

# -- VARIABLES --
# Define Vagrant box name, memory allocation, VM names, and user settings.
box_name="ubuntu/focal64"       # Vagrant box name, can be customized to desired box.
vb_memory="1024"                # Allocate memory for VMs in megabytes (MB).
master_vm="master"              # Name of the master VM.
master_user="altschool"         # Username for the master VM.
master_user_password="password" # Password for the master VM.
slave_vm="slave"                # Name of the slave VM.
slave_user="altschool"          # Username for the slave VM.
slave_user_password="password"  # Password for the slave VM.
slave_vm_group="slaveserver" # Group name for the slave VM.

# Define the location of the SSH key file.
ssh_key_file=/home/altschool/.ssh/id_rsa

# Create Ansible configuration content.
ansible_cfg="[defaults]\ninventory = myhosts 
remote_user = $master_user 
host_key_checking = false\n
[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ack_pass = false"

# -- GENERATE VAGRANT CONFIGURATION --
# This code generates a Vagrantfile that defines the configuration for both the Master and Slave virtual machines.
# It sets the Vagrant box name, network settings, port forwarding, and memory allocation for each VM.
cat <<EOL > Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.define "$master_vm" do |master|
    master.vm.box = "$box_name" # Set the Vagrant box name.
    master.vm.network "private_network", type: "dhcp" # Configure a private network with DHCP.
    master.vm.network "forwarded_port", guest: 22, host: 8080 # Forward SSH port for remote access.
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "$vb_memory" # Adjust memory allocation as needed.
    end
  end

  config.vm.define "$slave_vm" do |slave|
    slave.vm.box = "$box_name" # Set the Vagrant box name.
    slave.vm.network "private_network", type: "dhcp" # Configure a private network with DHCP.
    slave.vm.network "forwarded_port", guest: 22, host: 2200 # Forward SSH port for remote access.
    slave.vm.provider "virtualbox" do |vb|
      vb.memory = "$vb_memory"  # Adjust memory allocation as needed.
    end
  end
end
EOL

# -- INITIALIZE AND PROVISION VAGRANT NODES --
# This section of the script manages the setup of Vagrant virtual machines.

# Start the Vagrant virtual machines
vagrant up 

# Provision User and SSH Configuration on Master Node
# This code SSHs into the Master node and performs the following tasks:
# - Creates a user with a specified password.
# - Grants the user root privileges.
# - Sets an environment variable to identify the node type.
# - Generates an SSH key pair for the user if it doesn't already exist.
# - Ensures proper ownership and permissions for SSH-related files.

# SSH into the Master node
vagrant ssh "$master_vm" << ENDSSH
  # Create a user
  sudo useradd -m -d "/home/$master_user" -s /bin/bash "$master_user"

  # Set password for the user (change 'password' to your desired password)
  echo "$master_user:$master_user_password" | sudo chpasswd

  # Add the user to the sudo group to grant root privileges
  sudo usermod -aG sudo "$master_user"

  # Set an environment variable to identify the node type
  if [ "$NODE_TYPE" == "$master_vm" ]; then
    echo "You are on the $master_vm node."
  else
    echo "export NODE_TYPE=$master_vm" >> ~/.bashrc
    source ~/.bashrc
    echo "You are on the $master_vm node."
  fi

  # Generate an SSH key pair if one doesn't exist already (skip if you have an existing key)
  if [ ! -f "/home/$master_user/.ssh/id_rsa.pub" ];
  then
    sudo -u "$master_user" ssh-keygen -t rsa -b 2048 -N "" -f "/home/$master_user/.ssh/id_rsa"
  fi

  # Ensure proper ownership and permissions for SSH-related files
  sudo chown -R "$master_user:$master_user" /home/"$master_user"/.ssh
  sudo chmod 700 /home/"$master_user"/.ssh
  sudo chmod 644 /home/"$master_user"/.ssh/id_rsa.pub
ENDSSH

# Provision User and SSH Configuration on Slave Node
# This part SSHs into the Slave node and performs similar tasks as on the Master node.
vagrant ssh "$slave_vm" << ENDSSH
  # Create a user
  sudo useradd -m -d /home/"$slave_user" -s /bin/bash "$slave_user"

  # Set password for the user (change 'password' to your desired password)
  echo "$slave_user:$slave_user_password" | sudo chpasswd

  # Add the user to the sudo group to grant root privileges
  sudo usermod -aG sudo "$slave_user"

  # Set an environment variable to identify the node type
  if [ "$NODE_TYPE" == "$slave_vm" ]; then
    echo "You are on the $slave_vm node."
  else
    echo "export NODE_TYPE=$slave_vm" >> ~/.bashrc
    source ~/.bashrc
    echo "You are on the $slave_vm node."
  fi

  # Create the .ssh directory if it doesn't exist
  sudo mkdir -p /home/"$slave_user"/.ssh

  # Create an empty authorized_keys file if it doesn't exist
  sudo touch /home/"$slave_user"/.ssh/authorized_keys

  # Ensure proper ownership and permissions for SSH-related files
  sudo chown -R "$slave_user:$slave_user" /home/"$slave_user"/.ssh
  sudo chmod 700 /home/"$slave_user"/.ssh
  sudo chmod 600 /home/"$slave_user"/.ssh/authorized_keys
ENDSSH

# Establish secure SSH key authentication from the Master to the Slave node.
# This code copies the Master's SSH public key to the Slave's authorized_keys file.
touch /tmp/master_public_key.pub
vagrant ssh "$master_vm" -c "sudo cat /home/$master_user/.ssh/id_rsa.pub" > /tmp/master_public_key.pub
vagrant ssh "$slave_vm" -c "sudo tee -a /home/$slave_user/.ssh/authorized_keys" < /tmp/master_public_key.pub

# -- INSTALL ANSIBLE --
# Install Ansible on the master VM, configure the inventory file, and set up the Ansible configuration.

# Get the IP address of the slave VM
slave_ip=$(vagrant ssh "$slave_vm" -c "hostname -I | awk '{print \$2}'"| tr -d '\r') 

# Define the inventory file content
inventory_file="[$slave_vm_group]
slave ansible_host=$slave_ip ansible_user=$slave_user ansible_become_pass=$slave_user_password ansible_ssh_private_key_file=$ssh_key_file"

# Add Ansible repository and install Ansible on the master VM.
vagrant ssh "$master_vm" << ENDSSH
    sudo apt-add-repository --yes --update ppa:ansible/ansible-2.9
    sudo apt-get -y install ansible
ENDSSH

# Create a directory for Ansible playbooks and set permissions 
vagrant ssh "$master_vm" << ENDSSH
    sudo mkdir /home/"$master_user"/plays
    sudo chown -R "$master_user:$master_user" /home/"$master_user"/plays
    sudo chmod 700 /home/"$master_user"/plays   
ENDSSH

# Create and configure the inventory file
vagrant ssh "$master_vm" << ENDSSH
    sudo touch /home/"$master_user"/plays/myhosts
    sudo chmod 600 /home/"$master_user"/plays/myhosts
    sudo chown -R "$master_user:$master_user" /home/"$master_user"/plays/myhosts
    echo -e "$inventory_file" | sudo tee -a /home/"$master_user"/plays/myhosts
    echo "Content added to myhosts"
ENDSSH

# Set up the Ansible configuration file
vagrant ssh "$master_vm" << ENDSSH
    sudo touch /home/"$master_user"/plays/ansible.cfg
    sudo chmod 600 /home/"$master_user"/plays/ansible.cfg
    sudo chown -R "$master_user:$master_user" /home/"$master_user"/plays/ansible.cfg
    echo -e "$ansible_cfg" | sudo tee -a /home/"$master_user"/plays/ansible.cfg
    echo "Content added to ansible.cfg"
ENDSSH



