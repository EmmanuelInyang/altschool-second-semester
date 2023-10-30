# STEPS
Here are the steps to run this script in an Ubuntu-based environment:

1. **Get Started:** 
   - To begin, I opened my code editor terminal.
     
2. **Create a directory:** <br>
   - I chose to name the directory "altschool-second-semester-exam" and initiated it using the following command:
      ```bash
         mkdir altschool-second-semester-exam

3. **Navigate into the directory:**
   - I then changed my working directory to the newly created "altschool-second-semester-exam" directory:
      ```bash
         cd altschool-second-semester-exam
      
4. **Create a Bash script file:**
   - I proceeded to create a Bash script file using the following command:
      ```bash
         touch master-slave-setup.sh

5. **Grant the necessary permission:**
   - For the Bash script to be executable, I granted the required permissions using the command:
      ```bash
         chmod +x altschool-second-semester-exam

6. **Execute the master-slave-setup script:**
   - Finally, I executed the script with the command:
      ```bash
         sh master-slave-setup.sh
      
   #### master-slave-setup.sh
   This script automates the setup of two Vagrant virtual machines (master and slave) and configures them for Ansible provisioning. It        covers the following steps:
   1. **Variables Setup**
      - Defines the Virtual machine names, memory allocation, user settings, network settings, and Ubuntu version.
      - Sets the SSH key file location.

   2. **Vagrant Configuration**
      - Generates a `Vagrantfile` to configure the Vagrant virtual machines.
        
   3. **Vagrant Initialization**
      - Initializes and provisions Vagrant virtual machines.

   4. **Master Node Provisioning**
      - Creates a user and sets a password on the Master node.
      - Grants the user root privileges.
      - Sets environment variables and generates an SSH key pair.
      - Ensures proper ownership and permissions for SSH-related files.

   5. **Slave Node Provisioning**
      - Performs similar tasks as the Master node on the Slave node.

   6. **SSH Key Authentication**
      - Establishes secure SSH key authentication from the Master to the Slave node.

   7. **Ansible Installation**
      - Installs Ansible on the Master VM.
      - Creates directories and sets permissions for Ansible playbooks.

   8. **Inventory Setup**
      - Retrieves the IP address of the Slave VM.
      - Configures the inventory file for Ansible.

   9. **Ansible Configuration**
      - Sets up the Ansible configuration file.

7. **Execute the master.sh script:**
   - To execute the master.sh script, I used the command:
      ```bash
         sh master.sh

   #### master.sh
   This bash automates the deployment of a Laravel web application on the master virtual machine. It provides a detailed sequence of steps    for configuring the Laravel application, the Apache web server, and the associated database. Here's a breakdown of the script's            sections and their respective functions:
   1. **Variables**
      - This script sets several variables used for configuring the Laravel application, Apache web server, and the database.

   2. **Update Package List and Upgrade Installed Packages**
      - The script first updates the package list to ensure it has the latest versions of software packages available. It then upgrades            the installed packages to their latest versions, applying any available updates.

   3. **Install and Configure Apache Web Server**
      - This section installs the Apache web server, enabling it to start automatically on system boot, and starts the Apache service.

   4. **Install and Configure MySQL Server**
      - The script updates package information, installs MySQL Server, starts the MySQL service, and configures it to start automatically          on system boot.

   5. **Install PHP and Required Modules**
      - This part of the script installs PHP 8.1 and related modules, including common utilities, prerequisites, and the Ondřej Surý PPA           repository. It then installs PHP 8.1 and related modules and restarts the Apache web server.

   6. **Configure PHP**
      - This script updates the package list for PHP configuration, installs necessary prerequisites for PHP configuration, and configures         PHP for the Laravel application.

   7. **Create the Laravel Application Directory and Set Permissions**
      - This section creates the directory for storing the Laravel application files and sets the necessary ownership and permissions for          the directory.

    8. **Clone and Set Up the Laravel Application**
The script updates system packages, installs Git, and clones the Laravel application repository. It then grants the Apache user ownership of specific Laravel directories.

## Install Laravel Application Dependencies
The script downloads and installs Composer and uses it to install Laravel application dependencies, excluding development dependencies.

## Update Laravel Environment Configuration and Generate Encryption Key
The script creates the Laravel environment configuration file '.env', sets file permissions and ownership, copies the template '.env.example' to '.env', and generates an encryption key for the Laravel application.

## Create a New MySQL Database and User
This part of the script creates a new MySQL database and user.

## Update Environmental Variables in the Laravel .env Configuration
This section updates environmental variables in the Laravel configuration file '.env'.

## Configure Apache Virtual Host
The script configures an Apache VirtualHost, specifying server settings, directory options, and log file locations for Apache.

## Append Project Entry to /etc/hosts File
The script appends an entry to the /etc/hosts file, mapping a hostname to an IP address.

## Enable Apache Rewrite Module and Configure Virtual Host
This code activates the Apache rewrite module, enables the Laravel virtual host configuration, disables the default Apache virtual host, and restarts the Apache service.

## Cache Laravel Configurations, Migrate Database, and Restart Apache
Finally, the script caches Laravel configurations to improve performance, migrates the database to apply any pending migrations, and restarts the Apache web server to ensure the changes take effect.

