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

6. **Execute this script:**
   - Finally, I executed the script with the command:
      ```bash
         sh master-slave-setup.sh
      
      #### master-slave-setup.sh

      This script automates the setup of two Vagrant virtual machines (master and slave) and configures them for Ansible provisioning. It         covers the following steps:

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

   ## Usage
   1. Review and modify the variables in the script to suit your requirements.
   2. Run the script in your terminal.
   For further details on each step, refer to the comments in the script itself.
