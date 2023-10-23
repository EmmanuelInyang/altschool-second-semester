#!/bin/bash

# Laravel Application Configuration
# Define variables for the Laravel application installation and setup.
laravel_app_directory="/var/www/html/laravel"      # Specify the Laravel application directory
laravel_owner="altschool"                          # Owner for Laravel files
laravel_owner_group="altschool"                    # Owner group for Laravel files
laravel_app_repo="https://github.com/laravel/laravel.git"  # Laravel application repository URL

apache_virtual_host_name=""
server_admin_email=""
server_name=""
document_root=""
apache_log_dir=""

# Update Package List and Upgrade Installed Packages
# The following code updates the package list to the latest available version of software packages.
# It then upgrades the installed packages to their latest versions, applying any available updates.
sudo apt-get update
sudo apt-get upgrade -y

# Install and Configure Apache Web Server
# The following code installs the Apache web server, enables it to start automatically on system boot,
# and starts the Apache service.
sudo apt install apache2 -y               
sudo systemctl enable apache2             
sudo systemctl start apache2     

# Configure Firewall Rule for Apache
# The following code adds a firewall rule to allow incoming traffic on port 80 (HTTP) for Apache.
# It ensures that the Apache web server can receive and respond to HTTP requests.
sudo ufw allow 80/tcp

# Install and Configure MySQL Server
# This code updates package information, installs MySQL Server, starts the MySQL service,
# and configures it to start automatically on system boot.
sudo apt-get update -y
sudo apt install mysql-server -y          
sudo systemctl start mysql                
sudo systemctl enable mysql             

# Secure MySQL Installation (Using Default Settings).
# The following code initiates the MySQL secure installation process with default settings.
# It provides predefined responses to set the root password and enforce security configurations.
# The options include setting a password, removing anonymous users, disallowing root login remotely,
# removing the test database, and applying changes to privileges.
sudo mysql_secure_installation <<EOF
    password
    Y
    Y
    Y
    Y
    Y
EOF

# Install PHP and Required Modules
# The following code installs PHP and related modules:
# - libapache2-mod-php: Apache PHP module for web server integration.
# - php-cli: PHP Command Line Interface (CLI) for executing PHP scripts from the command line.
# - php-cgi: PHP CGI for running PHP scripts independently of Apache.
# - php-mysql: PHP support for MySQL databases.
# After installation, Apache is restarted to apply changes.
sudo apt install php libapache2-mod-php -y    
sudo apt install php-cli -y                   
sudo apt install php-cgi -y                   
sudo apt install php-mysql -y                 
sudo systemctl restart apache2                

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
sudo tee -a "/etc/apache2/sites-available/$apache_virtual_host_name" <<EOF
<VirtualHost *:80>
     ServerAdmin "$server_admin_email"
     ServerName "$server_name"
     DocumentRoot "$document_root"

     <Directory "$document_root">
        Options Indexes Multiviews FollowSymlinks
        AllowOverride All
        Require all granted
     </Directory>

     ErrorLog "$apache_log_dir/error.log"
     CustomLog "$apache_log_dir/access.log" combined
 </VirtualHost>
EOF

# Enable Apache Rewrite Module and Virtual Host Configuration.
# Activate the Apache rewrite module to enable URL rewriting, which is often used by web applications.
sudo a2enmod rewrite              
# Enable the Apache virtual host configuration for your web application.
# This makes the web application accessible through the specified server name or IP address.                  
sudo a2ensite "$apache_virtual_host_name"  
# Disable the default Apache virtual host (usually named '000-default') if it's enabled.
# This step ensures that your web application's virtual host takes precedence.     
sudo a2dissite 000-default   
# Restart Apache to apply changes.                       
sudo systemctl restart apache2     

# Installing Laravel
# Create the directory that will hold the Laravel application files.
sudo mkdir "$laravel_app_directory" 
# Change the working directory to the newly created Laravel directory.
cd "$laravel_app_directory   
# Set ownership and permissions for the Laravel application directory.
# This ensures the web server (e.g., Apache) can read and write to the Laravel files.            
sudo chown -R {{ laravel_owner }}:{{ laravel_owner_group }} {{ laravel_app_directory }}   

# Clone and Set Up the Laravel Application
# Update system packages to ensure the availability of required tools.
sudo apt update                                           
# Install Git and Composer, essential for managing and deploying the Laravel application.
sudo apt-get install git composer -y                      
# Clone the Laravel application repository to the specified directory.
sudo -u {{ laravel_owner }} git clone {{ laravel_app_repo }} {{ laravel_app_directory }}  
# Set the appropriate ownership of the Laravel application directory for the web server.
sudo chown -R $USER {{ laravel_app_directory }}     
# Change the working directory to the Laravel application root.       
cd {{ laravel_app_directory }}                             
# Install application dependencies using Composer, excluding development dependencies.
composer install --no-dev                                  

# Grant Apache User Ownership of Laravel Directory.
# Set the ownership and permissions of the Laravel application directory to ensure that the web server (e.g., Apache)
# can read and write to specific subdirectories where application files and caches are stored.
# Grant ownership to the Apache user and group for the Laravel application directory.
sudo chown -R {{ laravel_owner }}:{{ laravel_owner_group }} {{ laravel_app_directory }}                   
# Grant ownership to the Apache user and group for the 'storage' directory within the Laravel application.
sudo chown -R {{ laravel_owner }}:{{ laravel_owner_group }} {{ laravel_app_directory }}/storage/*         
# Grant ownership to the Apache user and group for the 'bootstrap' directory within the Laravel application.
sudo chown -R {{ laravel_owner }}:{{ laravel_owner_group }} {{ laravel_app_directory }}/bootstrap/*       
# Grant ownership to the Apache user and group for the 'bootstrap/cache' directory within the Laravel application.
sudo chown -R {{ laravel_owner }}:{{ laravel_owner_group }} {{ laravel_app_directory }}/bootstrap/cache 

# Update Laravel Environment Configuration and Generate Encryption Key.
# Create or update the Laravel environment configuration file '.env' in the application directory.
sudo touch {{ laravel_app_directory }}/.env       
# Copy the template '.env.example' to '.env' to provide initial configuration settings.
sudo cp {{ laravel_app_directory }}/.env.example {{ laravel_app_directory }}/.env       
# Generate a secure encryption key for the Laravel application. This key is used for various security purposes.
sudo php artisan key:generate                                                           

# Update Environmental Variables in the Laravel .env Configuration.
# Replace the 'DB_DATABASE' value in the Laravel configuration with the provided database name.
sudo sed -i 's/DB_DATABASE={{ db_name }}/DB_DATABASE={{ db_name_placeholder }}/' {{ laravel_app_directory }}/.env          
# Replace the 'DB_PASSWORD' value in the Laravel configuration with the provided database password.
sudo sed -i 's/DB_PASSWORD={{ db_password }}/DB_PASSWORD={{ db_password_placeholder }}/' {{ laravel_app_directory }}/.env   
# Replace the 'DB_USERNAME' value in the Laravel configuration with the provided database username.
sudo sed -i 's/DB_USERNAME={{ db_user }}/DB_USERNAME={{ db_user_placeholder }}/' {{ laravel_app_directory }}/.env         

# Start the MySQL Database Service.
# This command starts the MySQL database service, making it operational and ready to accept database connections.
sudo systemctl start mysql
# Configure MySQL Database and Create a Database
# The following block of code executes MySQL queries to configure the database:
# - Sets up a function to execute MySQL queries using the provided username and password.
# - Creates a function to create a database if it doesn't exist.
# - Grants privileges for creating databases to the specified user.
# - Finally, it creates a specific database if it doesn't already exist and starts the MySQL service.
sudo mysql -u root <<EOF
DB_USERNAME="{{ db_user_placeholder }}"
DB_PASSWORD="{{ db_password_placeholder }}"

execute_query() {
    local query="\$1"
    local database="\$2"
    mysql -u "\$DB_USERNAME" -p"\$DB_PASSWORD" "\$database" -e "\$query"
}

# Function to create a database.
create_database() {
    local database="\$1"
    execute_query "CREATE DATABASE IF NOT EXISTS \$database"
}

# Grant privileges for creating databases.
execute_query "GRANT CREATE DATABASE ON *.* TO '\$DB_USERNAME'@'localhost';" "mysql"

# Create a database.
create_database "{{ db_name_placeholder }}"
# Start MySQL service
sudo systemctl start mysql
EOF

# Cache Laravel Configurations, Migrate Database, and Restart Apache
# The following steps are executed to finalize the setup:
# Cache Laravel configurations to improve performance.
php artisan config:cache
# Migrate the database to apply any pending migrations.
php artisan migrate
# Restart the Apache web server to apply the changes.
sudo systemctl restart apache2
