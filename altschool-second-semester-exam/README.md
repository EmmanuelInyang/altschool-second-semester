<h2>Cloud Engineering Second Semester Examination Project (Deploy LAMP Stack)</h2>

<h2>Steps</h2>

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
      
4. **Create a Bash script file (master-slave-setup.sh):**
   - I proceeded to create a Bash script file using the following command:
      ```bash
         touch master-slave-setup.sh

5. **Grant the necessary permission:**
   - For the Bash script to be executable, I granted the required permission using the command:
      ```bash
         chmod +x master-slave-setup.sh

6. **Write out the contents of master-slave-setup.sh**
   - This script automates the setup of two Vagrant virtual machines (master and slave) and configures them for Ansible provisioning.
       
7. **Execute the master-slave-setup script:**
   - Next, I executed the script with the command:
     ```bash
        sh master-slave-setup.sh

**After installing the master-slave-ubuntu.sh script, the next step I took was creating a script to automate the installation of LAMP stack on the master node (VM).**
   <br>
   <br>
8. **Creating a Bash script file (master.sh)**
   - I ran the command on the terminal to create the Bash script file:
     ```bash
        sh master.sh

9. **Grant the necessary permission**
    - The necessary permission was granted by running the command below to make the Bash script file and executable file.
      ```bash
         chmod +x master-slave-setup.sh

10. **Write out the contents of master.sh**
    - This bash automates the deployment of a Laravel web application on the master virtual machine.
      
11. **Execute the master.sh script:**
      - To execute the master.sh script, I used the command:
         ```bash
            sh master.sh
      
**After the master.sh script completion, the Lamp stack installation on the master node was successful, and the Laravel GitHub repository was cloned without issues. The next step involved testing the Laravel application.**
   <br>
   <br>
   
12. **Testing the Laravel Application on the Master node:** <br>
<ul>
   <li> Access the master node via SSH using the command: `vagrant ssh master`. </li>
   <li> Retrieve the master node's IP address by executing `hostname -I` within the terminal. The second IP displayed is the correct one to use. </li>
   <li> Open your web browser and enter this IP address. </li>
   <li> You will be directed to the Laravel application's homepage. </li>
</ul>

   **Below is a screenshot of the homepage displayed in my browser:**
     ![master_vm](https://github.com/EmmanuelInyang/altschool-second-semester/assets/95512710/e0999b82-451e-4bbd-b5a5-83d3a77fdea4)
<br>  
<br>
**After successfully testing the Laravel Application on the master node, the next step I took was installing the same LAMP stack application on the slave node using Ansible.**
The primary difference between the master LAMP stack installation and the Slave LAMP stack installation is the utilization of Ansible for the installation on the Slave node.

**NOTE:** Ansible was installed and configured on the master node when the master.sh script was executed.
<br>
12. **SSH into the Master node:**
    I checked if I'm already on the master node from the previous task. If i'm not, I can SSH into the master node with the command: 
      ```bash
         vagrant ssh master.
         
14. **Locate the "plays" directory**
    Once logged into the master node, I switched to the 'altschool' user by using the following command:
       ```bash
          su - altschool.
   A password prompt appeared, and I entered the password, which is 'password', as configured by the **master.sh** script. After successfully entering the password, I was logged in as     the 'AltSchool' user on the master node. Next, I navigated to the 'plays' directory with the command: cd plays. 
   
   **NOTE:** It's worth noting that during the setup process using the 'master.sh' script, Ansible was installed, and essential components like the 'Altschool' user, the 'myhosts' file    (also known as the Inventory file), and 'ansible.cfg' (Ansible configuration file) were configured.
    
