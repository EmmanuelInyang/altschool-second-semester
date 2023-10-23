#!/bin/bash

# Laravel Application Configuration
# Define variables for the Laravel application installation and setup.
laravel_app_directory="/var/www/html/laravel"      # Specify the Laravel application directory
laravel_owner="altschool"                          # Owner for Laravel files
laravel_owner_group="altschool"                    # Owner group for Laravel files
laravel_app_repo="https://github.com/laravel/laravel.git"  # Laravel application repository URL

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
