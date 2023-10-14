#!/bin/bash

# -------------VARAIBLES------------------
box_name="ubuntu/focal64" # You can set this to the desired box name
master_vm="master"
slave_vm="slave"
master_user="altschool"
slave_user="slave"
vb_memory="1024"
slave_target_dir="/home/$slave_user/mnt/$master_user/$slave_user" # Define the target directory on the slave node
master_target_dir="/home/$master_user/mnt/$master_user" # Define the source directory on the master node

# --------VAGRANT FILE CONFIGURATION---------
# Define the Vagrantfile for the Master node
cat <<EOL > Vagrantfile
# Define the Vagrantfile for the Master node
Vagrant.configure("2") do |config|
  config.vm.define "$master_vm" do |master|
    master.vm.box = "$box_name"
    master.vm.network "private_network", type: "dhcp"
    master.vm.network "forwarded_port", guest: 22, host: 8080
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "$vb_memory" # Adjust memory as needed
    end
  end

  # Define the Vagrantfile for the Slave node
  config.vm.define "$slave_vm" do |slave|
    slave.vm.box = "$box_name"
    slave.vm.network "private_network", type: "dhcp"
    slave.vm.network "forwarded_port", guest: 22, host: 2200
    slave.vm.provider "virtualbox" do |vb|
      vb.memory = "$vb_memory" # Adjust memory as needed
    end
  end
end
EOL

#---SETTING UP THE VIRTUAL MACHINES/INFRASTRUCTURE CONFIGURATION---
# Create and provision the Master and Slave nodes
vagrant up

# SSH into the Master node
vagrant ssh "$master_vm" << ENDSSH
  # Create a user
  sudo useradd -m -d "/home/$master_user" -s /bin/bash "$master_user"

  # Set password for the user (change 'password' to your desired password)
  echo "$master_user:password" | sudo chpasswd

  # Add the user to the sudo group to grant root privileges
  sudo usermod -aG sudo "$master_user"

  if [ "$NODE_TYPE" == "$master_user" ]; then
    echo "You are on the $master_vm node."
  else
    echo "export NODE_TYPE=$master_user" >> ~/.bashrc
    source ~/.bashrc
    echo "You are on the $master_vm node."
  fi

  # Generate an SSH key pair if one doesn't exist already (skip if you have an existing key)
  if [ ! -f "/home/$master_user/.ssh/id_rsa.pub" ];
  then
    sudo -u "$master_user" ssh-keygen -t rsa -b 2048 -N "" -f "/home/$master_user/.ssh/id_rsa"
  fi

  sudo chmod 700 /home/"$master_user"/.ssh
  sudo chmod 644 /home/"$master_user"/.ssh/id_rsa.pub
ENDSSH

vagrant ssh "$slave_vm" << ENDSSH
  # Create a user
  sudo useradd -m -d /home/"$slave_user" -s /bin/bash "$slave_user"

  # Set password for the user (change 'password' to your desired password)
  echo "$slave_user:password" | sudo chpasswd

  # Add the user to the sudo group to grant root privileges
  sudo usermod -aG sudo "$slave_user"

  if [ "$NODE_TYPE" == "$slave_user" ]; then
    echo "You are on the $slave_vm node."
  else
    echo "export NODE_TYPE=$slave_user" >> ~/.bashrc
    source ~/.bashrc
    echo "You are on the $slave_vm node."
  fi

  # Create the .ssh directory if it doesn't exist
  sudo mkdir -p /home/"$slave_user"/.ssh

  # Create an empty authorized_keys file if it doesn't exist
  sudo touch /home/"$slave_user"/.ssh/authorized_keys

  # Ensure proper ownership and permissions
  sudo chown -R "$slave_user:$slave_user" /home/"$slave_user"/.ssh
  sudo chmod 700 /home/"$slave_user"/.ssh
  sudo chmod 600 /home/"$slave_user"/.ssh/authorized_keys
ENDSSH

#------SETTING UP INTER-NODE CONNECTION--------
# Copy the SSH public key from the master node to a temporary file
touch /tmp/master_public_key.pub
vagrant ssh "$master_vm" -c "sudo cat /home/$master_user/.ssh/id_rsa.pub" > /tmp/master_public_key.pub
vagrant ssh "$slave_vm" -c "sudo tee -a /home/$slave_user/.ssh/authorized_keys" < /tmp/master_public_key.pub

#------SETTING UP DATA MANAGEMENT AND TRANSFER ON INITIATION---------
slave_ip=$(vagrant ssh "$slave_vm" -c "hostname -I | awk '{print \$2}'"| tr -d '\r') # Getting the slave ip address

vagrant ssh "$slave_vm" << ENDSSH
    sudo mkdir -p /home/$slave_user/mnt/$master_user/$slave_user
    sudo chown -R "$slave_user:$slave_user" /home/$slave_user/mnt/$master_user/$slave_user
    sudo chmod -R 700 /home/$slave_user/mnt/$master_user/$slave_user
ENDSSH

vagrant ssh "$master_vm" << ENDSSH
    sudo mkdir -p /home/$master_user/mnt/$master_user
    sudo touch /home/$master_user/mnt/$master_user/yes
    sudo chown -R "$master_user:$master_user" /home/$master_user/mnt/$master_user
    sudo chmod -R 700 /home/$master_user/mnt/$master_user
    sudo -u "$master_user" rsync -avz -e "ssh -i /home/$master_user/.ssh/id_rsa -o StrictHostKeyChecking=no" "$master_target_dir" "$slave_vm@$slave_ip:$slave_target_dir"
ENDSSH

# ------------PROCESS MONITORING-------------
# Display overview of Linux process management on 'Master'
echo "Overview of Linux process management on '$master_vm':"
vagrant ssh "$master_vm" << ENDSSH
    ps aux
ENDSSH

# ----------LAMP STACK DEPLOYMENT------------
# Install LAMP stack on both nodes
vagrant ssh "$master_vm" << 'ENDSSH'
  # Update the package list and upgrade installed packages
  sudo apt update
  sudo apt upgrade -y

  # Install Apache web server
  sudo apt install apache2 -y

  # Enable Apache to start on boot
  sudo systemctl enable apache2

  # Start the Apache service
  sudo systemctl start apache2

  # Install MySQL Server
  sudo apt install mysql-server -y

  # Secure MySQL installation
  sudo mysql_secure_installation <<EOF

    # Set the MySQL root password
    password

    # Remove anonymous users
    Y

    # Disallow root login remotely
    Y

    # Remove the test database
    Y

    # Remove the privileges on the test database
    Y

    # Reload privilege tables
    Y
  EOF

  # Install PHP and required modules
  sudo apt install php libapache2-mod-php php-mysql -y

  # Create a PHP info file to test the setup
  sudo touch /var/www/html/test-php-file.php
  sudo chmod 600 /var/www/html/test-php-file.php
  echo "<?php phpinfo(); ?>" > /var/www/html/test-php-file.php

  echo "PHP test file created on the $msater_vm"

  # Restart Apache to apply changes
  sudo systemctl restart apache2

  # Cleanup
  sudo apt autoremove -y
  sudo apt clean

  # Display installation completion message
  echo "LAMP stack installation on '$master_vm' completed."
ENDSSH

vagrant ssh "$slave_vm" << ENDSSH
  # Update the package list and upgrade installed packages
  sudo apt update
  sudo apt upgrade -y

  # Install Apache web server
  sudo apt install apache2 -y

  # Enable Apache to start on boot
  sudo systemctl enable apache2

  # Start the Apache service
  sudo systemctl start apache2

  # Install MySQL Server
  sudo apt install mysql-server -y

  # Secure MySQL installation
  sudo mysql_secure_installation <<EOF

    # Set the MySQL root password
    YourRootPasswordHere

    # Remove anonymous users
    Y

    # Disallow root login remotely
    Y

    # Remove the test database
    Y

    # Remove the privileges on the test database
    Y

    # Reload privilege tables
    Y
  EOF

  # Install PHP and required modules
  sudo apt install php libapache2-mod-php php-mysql -y

  # Restart Apache to apply changes
  sudo systemctl restart apache2

  # Cleanup
  sudo apt autoremove -y
  sudo apt clean

  # Display installation completion message
  echo "LAMP stack installation on '$slave_vm' completed."
ENDSSH

# Get IP addresses for testing php on 'Master' and 'Slave' VMs
master_ip=$(vagrant ssh $master_vm -c "hostname -I | awk '{print \$2}'"| tr -d '\r')
# The slave IP was gotten in line 109 and stored as $slave_ip.

echo "Deployment completed!"
echo "Visit: http://$master_ip/test-php-file.php to validate the '$master_vm' PHP setup"
echo "Visit: http://$slave_ip/info.php to validate the '$slave_vm' PHP setup"