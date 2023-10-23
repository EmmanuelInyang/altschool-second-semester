#!/bin/bash

# Vagrant Configuration
# Define variables for Vagrant box names, VM names, user names, and memory settings.
box_name="ubuntu/focal64"     # Vagrant box name, can be customized to desired box
master_vm="master"           # Name of the master VM
slave_vm="slave"             # Name of the slave VM
master_user="altschool"      # Username for the master VM
slave_user="slave"           # Username for the slave VM
vb_memory="1024"             # Memory allocation for VMs (in MB)

# Laravel Application Configuration
# Define variables for the Laravel application installation and setup.
laravel_app_directory="/var/www/html/laravel"      # Specify the Laravel application directory
laravel_owner="www-data"                          # Owner for Laravel files
laravel_owner_group="www-data"                    # Owner group for Laravel files
laravel_app_repo="https://github.com/laravel/laravel.git"  # Laravel application repository URL


# Generate Vagrant Configuration
# This code generates a Vagrantfile that defines the configuration for both the Master and Slave nodes.
cat <<EOL > Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.define "$master_vm" do |master|
    master.vm.box = "$box_name"
    master.vm.network "private_network", type: "dhcp"
    master.vm.network "forwarded_port", guest: 22, host: 8080
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "$vb_memory" # Adjust memory as needed
    end
  end

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

# Initialize and Provision Vagrant Nodes
# This code starts the Vagrant virtual machines. It then SSHs into the Master node and performs the following tasks:
# - Creates a user with a specified password.
# - Grants the user root privileges.
# - Sets an environment variable to identify the node type.
# - Generates an SSH key pair for the user if one doesn't exist.
vagrant up
# SSH into the Master node
vagrant ssh "$master_vm" << ENDSSH
  # Create a user
  sudo useradd -m -d "/home/$master_user" -s /bin/bash "$master_user"

  # Set password for the user (change 'password' to your desired password)
  echo "$master_user:password" | sudo chpasswd

  # Add the user to the sudo group to grant root privileges
  sudo usermod -aG sudo "$master_user"

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

  sudo chmod 700 /home/"$master_user"/.ssh
  sudo chmod 644 /home/"$master_user"/.ssh/id_rsa.pub
ENDSSH

# Provision User and SSH Configuration on Slave Node
# This code SSHs into the Slave node and performs the following tasks:
# - Creates a user with a specified password.
# - Grants the user root privileges.
# - Sets an environment variable to identify the node type.
# - Ensures the existence of the .ssh directory and authorized_keys file for SSH access.
# - Sets proper ownership and permissions for SSH-related files.
vagrant ssh "$slave_vm" << ENDSSH
  # Create a user
  sudo useradd -m -d /home/"$slave_user" -s /bin/bash "$slave_user"

  # Set password for the user (change 'password' to your desired password)
  echo "$slave_user:password" | sudo chpasswd

  # Add the user to the sudo group to grant root privileges
  sudo usermod -aG sudo "$slave_user"

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

  # Ensure proper ownership and permissions
  sudo chown -R "$slave_user:$slave_user" /home/"$slave_user"/.ssh
  sudo chmod 700 /home/"$slave_user"/.ssh
  sudo chmod 600 /home/"$slave_user"/.ssh/authorized_keys
ENDSSH

# Securely Copy SSH Public Key from Master to Slave
# This code establishes secure SSH key authentication between the Master and Slave nodes.
# It does the following:
# - Creates a temporary file to hold the Master's public SSH key.
# - Retrieves the Master's public key from the Master node.
# - Appends the Master's public key to the authorized_keys file on the Slave node, enabling secure SSH access.
touch /tmp/master_public_key.pub
vagrant ssh "$master_vm" -c "sudo cat /home/$master_user/.ssh/id_rsa.pub" > /tmp/master_public_key.pub
vagrant ssh "$slave_vm" -c "sudo tee -a /home/$slave_user/.ssh/authorized_keys" < /tmp/master_public_key.pub

# Get IP Addresses of Master and Slave Nodes
# These commands obtain the IP addresses of the Master and Slave nodes.
master_ip=$(vagrant ssh $master_vm -c "hostname -I | awk '{print \$2}'" | tr -d '\r')
slave_ip=$(vagrant ssh "$slave_vm" -c "hostname -I | awk '{print \$2}'" | tr -d '\r')

# LAMP Stack Deployment

# This code deploys the LAMP (Linux, Apache, MySQL, PHP) stack on both nodes.
# It includes the following steps:
# - Updating the package list and upgrading installed packages.
# - Installing and configuring the Apache web server.
# - Installing and configuring MySQL Server with secure installation settings.

vagrant ssh "$master_vm" << 'ENDSSH'
  # Update the package list and upgrade installed packages
  sudo apt update
  sudo apt upgrade -y

  # Install and configure Apache web server
  sudo apt install apache2 -y               # Install Apache web server
  sudo systemctl enable apache2             # Enable Apache to start on boot
  sudo systemctl start apache2              # Start the Apache service

  # Install and configure MySQL Server
  sudo apt install mysql-server -y          # Install MySQL Server

  # Secure MySQL installation (use default settings)
  sudo mysql_secure_installation <<EOF
    password
    Y
    Y
    Y
    Y
    Y
  EOF
ENDSSH

# Install PHP and Required Modules on Master Node
# This code installs PHP and its required modules on the "master_vm" node, which is part of the LAMP stack deployment.
# It includes the installation of the Apache PHP module, PHP Command Line Interface (CLI), PHP CGI for running PHP scripts without Apache,
# and PHP support for MySQL. After installation, it restarts Apache to apply the changes and provides an installation completion message.
vagrant ssh "$master_vm" << ENDSSH
  sudo apt install php libapache2-mod-php -y    # Install Apache PHP module.
  sudo apt install php-cli -y                   # Install PHP Command Line Interface (CLI).
  sudo apt install php-cgi -y                   # Install PHP CGI (for running PHP scripts without Apache).
  sudo apt install php-mysql -y                 # Install PHP support for MySQL.
  sudo systemctl restart apache2                # Restart Apache to apply changes
  echo "LAMP stack installation on '$master_vm' completed."  # Display installation completion message
ENDSSH

# LARAVEL Application Installation
# This code installs the Laravel application, creates the necessary folders, and sets the permissions.
vagrant ssh "$master_vm" << ENDSSH
  # Create the folder that will hold the application
  sudo mkdir -p "$laravel_app_directory" && cd "$laravel_app_directory"
  sudo chown -R "$laravel_owner:$laravel_owner_group" "$laravel_app_directory"

  # Clone the Laravel application
  sudo apt-get update
  sudo apt-get install git composer -y
  sudo -u "$laravel_owner" git clone "$laravel_app_repo" "$laravel_app_directory"
  sudo chown -R $USER "$laravel_app_directory"
  cd "$laravel_app_directory"
  composer install --no-dev

  # Display a completion message
  echo "Laravel application installed in '$laravel_app_directory'."
ENDSSH

# Create PHP Info File for Testing on Master Node
# This code creates a PHP info file for testing the setup on the "master_vm" node.
# It includes the following tasks:
# - Creating a directory for the web server.
# - Creating a PHP file that displays PHP information.
# - Displaying a message indicating the PHP test file creation.
# - Restarting Apache to apply changes.
vagrant ssh "$master_vm" << ENDSSH
  sudo mkdir -p /var/www/html
  echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/test-php-file.php
  echo "PHP test file created on the $master_vm"
  sudo systemctl restart apache2                # Restart Apache to apply changes
ENDSSH
