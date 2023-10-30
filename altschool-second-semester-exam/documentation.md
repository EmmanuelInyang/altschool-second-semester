# USAGE
Here are the steps to run this script in an Ubuntu-based environment:

1. **Get Started:** <br>
   - I opened my code editor terminal.
     
2. **Create a directory:** <br>
   - I decided to name the directory "altschool-second-semester-exam" and created it using the following command:
      ```bash
         mkdir altschool-second-semester-exam

3. **Navigate into the directory:**
   - I changed my working directory to the newly created "altschool-second-semester-exam" directory:
      ```bash
         cd altschool-second-semester-exam
      
4. **Write the setup script for virtual machines:**
   To write the setup script for the virtual machines (Master and Slave), I first created a ".sh" file with the name "master-slave-         
   setup.sh" using this command:
   ```bash
      touch master-slave-setup.sh
   ***ffffff***
then granted execution permissions to the script using:  
   


### master-slave-setup.sh

This script automates the setup of Vagrant virtual machines and configures them for Ansible provisioning. It covers the following steps:

1. **Variables Setup**
   - Defines VM names, memory allocation, user settings, and box name.
   - Sets the SSH key file location.

2. **Vagrant Configuration**
   - Generates a `Vagrantfile` to configure the Vagrant virtual machines.
   - Defines box name, network settings, port forwarding, and memory allocation.

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
   - Configures the inventory file and Ansible configuration.

8. **Inventory Setup**
   - Retrieves the IP address of the Slave VM.
   - Configures the inventory file for Ansible.

9. **Ansible Configuration**
   - Sets up the Ansible configuration file.

## Usage

1. Review and modify the variables in the script to suit your requirements.
2. Run the script in your terminal.
3. The script will create and configure Vagrant VMs, provision users, set up SSH key authentication, install Ansible, and prepare the environment for Ansible playbooks.

Enjoy your Vagrant and Ansible environment!

For further details on each step, refer to the comments in the script itself.
