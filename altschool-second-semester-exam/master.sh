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

# Configure PHP
# Ensure that the package lists on your Ubuntu system are up to date to have access to the latest package information.
sudo apt update
# Install necessary prerequisites, including 'curl' for downloading files, 'php-zip' for handling ZIP archives,
# and 'unzip' for extracting ZIP files. The '-y' flag automatically answers "yes" to
# any installation prompts, streamlining the process.
sudo apt install curl php-zip unzip -y
# Download the Composer installation script from getcomposer.org and execute it. This script downloads Composer and installs
# it in the /usr/local/bin directory with the name 'composer'. After installation, the setup script is removed.
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"

# Configure Apache Virtual Host
# The following code appends a VirtualHost configuration to the specified Apache site file.
# It defines the server administrator's email, server name or IP address, document root,
# directory options, and log file locations for Apache.
sudo tee -a /etc/apache2/sites-available/{{ apache_virtual_host_name }} <<EOF
<VirtualHost *:80>
     ServerAdmin {{ server_admin_email }}
     ServerName {{ server_name }}
     DocumentRoot {{ document_root }}

     <Directory {{ document_root }}>
        Options Indexes Multiviews FollowSymlinks
        AllowOverride All
        Require all granted
     </Directory>

     ErrorLog {{ apache_log_dir }}/error.log
     CustomLog {{ apache_log_dir }}/access.log combined
 </VirtualHost>
EOF

# Enable Apache Rewrite Module and Virtual Host Configuration.
# Activate the Apache rewrite module to enable URL rewriting, which is often used by web applications.
sudo a2enmod rewrite              
# Enable the Apache virtual host configuration for your web application.
# This makes the web application accessible through the specified server name or IP address.                  
sudo a2ensite {{ apache_virtual_host_name }}  
# Disable the default Apache virtual host (usually named '000-default') if it's enabled.
# This step ensures that your web application's virtual host takes precedence.     
sudo a2dissite 000-default   
# Restart Apache to apply changes.                       
sudo systemctl restart apache2   

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
  cd "$laravel_app_directory"
  composer install --no-dev

  # Display a completion message
  echo "Laravel application installed in '$laravel_app_directory'."
ENDSSH
