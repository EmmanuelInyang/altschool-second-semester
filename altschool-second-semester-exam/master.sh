#!/bin/bash

# -- VARIABLES --
# Define essential variables used for configuring the Laravel application, Apache web server, and the database.

# Virtual Machine
master_vm="master" # - This variable stores the name of the virtual machine.

# Laravel Application Configuration
project_name=laravel
# - The name of the Laravel project.
laravel_app_directory="/var/www/html/$project_name"
# - This specifies the directory where the Laravel application will be installed.
laravel_owner="www-data"
# - This variable represents the owner of the Laravel application files.
laravel_owner_group="www-data"
# - The owner group for the Laravel application files.
laravel_app_repo="https://github.com/laravel/laravel.git"
# - The URL of the Laravel application's Git repository.

# Apache Web Server Configuration
apache_log_dir="/var/log/apache2"
# - The directory where Apache web server logs are stored.
document_root="/var/www/html/$project_name/public"
# - The document root for the Apache web server, which points to the Laravel application's public directory.
server_admin_email="inyang156@gmail.com"
# - The email address for the server administrator.
server_name="$project_name.local"
# - The server name, typically the IP address, determined dynamically within the Vagrant environment.
apache_virtual_host_name="$project_name.conf" 
# - The name of the Apache virtual host configuration file.
apache_virtual_host_location="/etc/apache2/sites-available"
# - The location of the Apache virtual host configuration file.

# Database Configuration For Laravel Application
db_name=$project_name # - The name of the database used by the Laravel application.
db_password="password" # - The password for the database user.
db_user="$project_name" # - The username for connecting to the database.
ip_address=$(vagrant ssh "$master_vm" -c "hostname -I | awk '{print \$2}'"| tr -d '\r') # For virtualization.


# -- UPDATE PACKAGE LIST AND UPGRADE INSTALLED PACKAGES --
# The following code updates the package list to the latest available version of software packages.
# It then upgrades the installed packages to their latest versions, applying any available updates.
vagrant ssh "$master_vm" << ENDSSH
    sudo apt-get update
    sudo apt-get upgrade -y
ENDSSH

# -- INSTALL AND CONFIGURE APACHE WEB SERVER -- 
# The following code installs the Apache web server, enables it to start automatically on system boot,
# and starts the Apache service.
vagrant ssh "$master_vm" << ENDSSH
    sudo apt install apache2 -y
    sudo systemctl enable apache2
    sudo systemctl start apache2
ENDSSH

# -- INSTALL AND CONFIGURE MYSQL SERVER --
# This code updates package information, installs MySQL Server, starts the MySQL service,
# and configures it to start automatically on system boot.
vagrant ssh "$master_vm" << ENDSSH
    sudo apt-get update -y
    sudo apt install mysql-server -y
    sudo systemctl start mysql
    sudo systemctl enable mysql
ENDSSH

# -- INSTALL PHP AND REQUIRED MODULES --
# This script installs PHP 8.1 and related modules, following a structured process. Each step is executed in
# separate SSH sessions for better isolation and clarity.

# Updates the system's package list and upgrades installed packages.
vagrant ssh "$master_vm" -c "sudo apt update"
vagrant ssh "$master_vm" -c "sudo apt -y upgrade"

# Reboots the system to apply any necessary updates.
vagrant ssh "$master_vm" -c "sudo systemctl reboot"

# Installs common utilities like lsb-release, ca-certificates, apt-transport-https, and software-properties-common.
vagrant ssh "$master_vm" -c "sudo apt install lsb-release -y"
vagrant ssh "$master_vm" -c "sudo apt install ca-certificates -y"
vagrant ssh "$master_vm" -c "sudo apt install apt-transport-https -y"
vagrant ssh "$master_vm" -c "sudo apt install software-properties-common -y"

# Adds the Ondřej Surý PPA repository for PHP.
vagrant ssh "$master_vm" -c "echo | sudo add-apt-repository ppa:ondrej/php"

# Updates the package list again to include packages from the newly added repository.
vagrant ssh "$master_vm" -c "sudo apt update"

# Installs PHP version 8.1 along with related modules:
vagrant ssh "$master_vm" -c "sudo apt install php8.1 -y"
#  - libapache2-mod-php: Apache PHP module for web server integration.
vagrant ssh "$master_vm" -c "sudo apt install php libapache2-mod-php -y"
#  - php-cli: PHP Command Line Interface (CLI) for executing PHP scripts from the command line.
vagrant ssh "$master_vm" -c "sudo apt install php-cli -y"
#  - php-cgi: PHP CGI for running PHP scripts independently of Apache.
vagrant ssh "$master_vm" -c "udo apt install php-cgi -y"
#  - php-mysql: PHP support for MySQL databases.
vagrant ssh "$master_vm" -c "sudo apt install php-mysql -y"

# Restart the Apache web server to apply any configuration changes.
vagrant ssh "$master_vm" -c "sudo systemctl restart apache2"

# -- CONFIGURE PHP --
# Update the package list for PHP configuration.
vagrant ssh "$master_vm" -c "sudo apt update"

# Install necessary prerequisites for PHP configuration.
vagrant ssh "$master_vm" -c "sudo apt install php-curl -y"
vagrant ssh "$master_vm" -c "sudo apt install php-xml -y"
vagrant ssh "$master_vm" -c "sudo apt install php-zip -y"

# -- CREATING THE LARAVEL APP DIRECTORY AND SETTING PERMISSIONS --
# This code creates the directory to store the Laravel application files and
# sets the necessary ownership and permissions for the directory. Proper
# permissions are essential to ensure that the web server (e.g., Apache) can
# read and write to the Laravel files.
vagrant ssh "$master_vm" << ENDSSH
    # Create the directory.
    sudo mkdir -p "$laravel_app_directory" 

    # Set ownership and permissions.          
    sudo chown -R "$laravel_owner:$laravel_owner_group" "$laravel_app_directory"
    sudo chmod -R 755 "$laravel_app_directory"
ENDSSH

# -- CLONE AND SET UP THE LARAVEL APPLICATION --
# Update system packages to ensure the availability of required tools.
vagrant ssh "$master_vm" -c "sudo apt update"
# Install Git, essential for managing and deploying the Laravel application.
vagrant ssh "$master_vm" -c "sudo apt-get install git -y"

# Clone the Laravel application repository and handle errors.
vagrant ssh "$master_vm" << ENDSSH
    set -e
    sudo git clone "$laravel_app_repo" "$laravel_app_directory"
ENDSSH

# -- GRANT APACHE USER OWNERSHIP OF LARAVEL DIRECTORY --
# Set the ownership and permissions of the Laravel application directory to ensure that the web server (e.g., Apache)
# can read and write to specific subdirectories where application files and caches are stored.
vagrant ssh "$master_vm" << ENDSSH    
    # Grant ownership to the Apache user and group for the 'storage' directory within the Laravel application.
    sudo chown -R "$laravel_owner:$laravel_owner_group" $laravel_app_directory/storage/* 
    sudo chmod -R 775 "$laravel_app_directory/storage"

    # Grant ownership to the Apache user and group for the 'bootstrap' directory within the Laravel application.
    sudo chown -R "$laravel_owner:$laravel_owner_group" $laravel_app_directory/bootstrap/*
    sudo chmod -R 775 "$laravel_app_directory/bootstrap"    
    
    # Grant ownership to the Apache user and group for the 'bootstrap/cache' directory within the Laravel application.
    sudo chown -R "$laravel_owner:$laravel_owner_group" $laravel_app_directory/bootstrap/cache 
    sudo chmod -R 775 "$laravel_app_directory/bootstrap/cache"
ENDSSH

# -- INSTALL LARAVEL APPLICATION DEPENDENCIES --
# Download the Composer installation script from getcomposer.org and execute it. 
# This script downloads Composer and installs it in the /usr/local/bin directory with the name 'composer'. 
# After installation, the setup script is removed.
vagrant ssh "$master_vm" << ENDSSH
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    php -r "unlink('composer-setup.php');"
ENDSSH

# Change the working directory to the laravel application root and install application dependencies
# using Composer, excluding development dependencies.
vagrant ssh "$master_vm" << ENDSSH  
    # If the change fails, exit the script.     
    cd "$laravel_app_directory" || exit    

    # The '-d memory_limit=-1' flag sets an unlimited memory limit for Composer.
    # The '--no-dev' option excludes development dependencies.                      
    php -d memory_limit=-1 /usr/local/bin/composer install --no-dev                              
ENDSSH

# -- UPDATE LARAVEL ENVIRONMENT CONFIGURATION AND GENERATE ENCRYPTION KEY --
# In this section, the code performs various tasks related to the Laravel environment configuration.
# This includes creating the Laravel environment configuration file '.env',
# setting file permissions and ownership, copying the template '.env.example' to '.env',
# changing the working directory to the Laravel application root, and generating an encryption key.
vagrant ssh "$master_vm" << ENDSSH
    # Create the Laravel environment configuration file '.env' in the application directory.
    sudo touch $laravel_app_directory/.env       

    # Set file permissions for '.env'.
    sudo chmod 600 /$laravel_app_directory/.env   

    # Set ownership for '.env'
    sudo chown -R "$laravel_owner:$laravel_owner_group" $laravel_app_directory/.env   
    
    # Copy the template '.env.example' to '.env' to provide initial configuration settings.
    sudo cp $laravel_app_directory/.env.example $laravel_app_directory/.env                                                                
ENDSSH

# Change the working directory to the Laravel application root, and generate a secure 
# encryption key for the Laravel application.
vagrant ssh "$master_vm" -c "cd $laravel_app_directory && sudo php artisan key:generate"

# -- CREATE A NEW MYSQL DATABASE AND USER -- 
# MySQL commands to create a new database, user, and grant privileges.
vagrant ssh "$master_vm" << ENDSSH
    mysql -u root -p -e "CREATE DATABASE $project_name;"
    mysql -u root -p -e "CREATE USER '$project_name'@'localhost' IDENTIFIED BY '$db_password';"
    mysql -u root -p -e "GRANT ALL PRIVILEGES ON $project_name.* TO '$project_name'@'localhost';"
ENDSSH

# -- UPDATE ENVIRONMENTAL VARIABLES IN THE LARAVEL .ENV CONFIGURATION --
# This section updates the environmental variables in the Laravel configuration file '.env'.
# It replaces the 'DB_DATABASE' value with the provided database name,
# 'DB_PASSWORD' with the provided database password, and 'DB_USERNAME' with the provided database username.
vagrant ssh "$master_vm" << ENDSSH
    # Replace the 'DB_DATABASE' value in the Laravel configuration with the provided database name.
    sudo sed -i "s/DB_DATABASE=.*$/DB_DATABASE=$db_name/" $laravel_app_directory/.env

    # Replace the 'DB_PASSWORD' value in the Laravel configuration with the provided database password.
    sudo sed -i "s/DB_PASSWORD=.*$/DB_PASSWORD=$db_password/" $laravel_app_directory/.env

    # Replace the 'DB_USERNAME' value in the Laravel configuration with the provided database username.
    sudo sed -i "s/DB_USERNAME=.*$/DB_USERNAME=$db_user/" $laravel_app_directory/.env
ENDSSH

# -- CONFIGURE APACHE VIRTUAL HOST --
# This code configures an Apache VirtualHost, including creating the necessary directory structure,
# specifying server settings, directory options, and log file locations for Apache. The VirtualHost
# configuration allows the web server to host a specified site with customized settings.

# Append a VirtualHost configuration to the Apache site file using a here document.
vagrant ssh "$master_vm" << ENDSSH
    sudo tee -a "$apache_virtual_host_location"/"$apache_virtual_host_name" <<EOF
    <VirtualHost *:80>
        ServerAdmin $server_admin_email
        DocumentRoot $document_root
        ServerName $server_name

    <Directory $document_root>
        Options Indexes FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog $apache_log_dir/error.log
    CustomLog $apache_log_dir/access.log combined
    </VirtualHost>
EOF
ENDSSH

# -- APPEND PROJECT ENTRY TO /etc/hosts FILE --
# This code appends an entry to the /etc/hosts file, which maps a hostname (e.g., $project_name.local) 
# to an IP address (e.g., $localhost). 
vagrant ssh "$master_vm" << ENDSSH
    echo "$ip_address $project_name.local" | sudo tee -a /etc/hosts
ENDSSH

# -- ENABLE APACHE REWRITE MODULE AND CONFIGURE VIRTUAL HOST --
# This code performs several tasks related to configuring the Apache web server:
# - Activates the Apache rewrite module, essential for URL rewriting often used by web applications.
# - Enables the 'master' virtual host configuration for the Laravel application.
# - Disables the default Apache virtual host (usually named '000-default') to prioritize your web application's virtual host.
# - Restarts the Apache service to apply the new configuration settings.

vagrant ssh "$master_vm" << ENDSSH
    # - Activate the Apache rewrite module.
    sudo a2enmod rewrite

    # - Enable the '$project_name' virtual host configuration.
    sudo a2ensite $project_name.conf

    # - Disable the default Apache virtual host (usually named '000-default') if it's enabled.
    sudo a2dissite 000-default

    # - Restarts the Apache service.
    sudo systemctl restart apache2
ENDSSH

# -- CACHE LARAVEL CONFIGURATIONS, MIGRATE DATABASE, AND RESTART APACHE --
# In this section, the code performs final setup tasks for the Laravel application.
# It includes:
# - Caching the Laravel configurations to enhance performance. 
# - Migrating the database to apply any pending migrations.
# - Restarting the Apache web server to ensure the changes take effect.
vagrant ssh "$master_vm" << ENDSSH
    # Change to the Laravel project directory.
    cd "$laravel_app_directory" || exit

    # Cache Laravel configurations to improve performance.
    php artisan config:cache
    
    # Migrate the database to apply any pending migrations.
    php artisan migrate --force
    
    # Restart the Apache web server to apply the changes.
    sudo systemctl restart apache2
ENDSSH
