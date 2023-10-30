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
      
4. **Create a Bash script file:**
   - I proceeded to create a Bash script file using the following command:
      ```bash
         touch master-slave-setup.sh

5. **Grant the necessary permission:**
   - For the Bash script to be executable, I granted the required permissions using the command:
      ```bash
            chmod +x master-slave-setup.sh

6. **Execute the master-slave-setup script:**
   - Next, I executed the script with the command:
     ```bash
        sh master-slave-setup.sh

   - #### master-slave-setup.sh
     This script automates the setup of two Vagrant virtual machines (master and slave) and configures them for Ansible provisioning.
<br>

**After installing the master-slave-ubuntu.sh script, the next step I took was executing the master.sh script to install Lamp stack on the master node (VM).**

7. **Execute the master.sh script:**
   - To execute the master.sh script, I used the command:
      ```bash
         sh master.sh

   - #### master.sh
     This bash automates the deployment of a Laravel web application on the master virtual machine. It provides a detailed sequence of           steps for configuring the Laravel application, the Apache web server, and the associated database.
<br>

**After the master.sh script completion, the Lamp stack installation on the master node was successful, and the Laravel GitHub repository was cloned without issues. The subsequent step involved testing the Laravel application.**

8. **Testing the Laravel Application**
   - Access the master node via SSH using the command: vagrant ssh master.
   - Retrieve the master node's IP address by executing hostname -I within the terminal. The second IP displayed is the correct one to use.
   - Open your web browser and enter this IP address.
   - You will be directed to the Laravel application's homepage.
     <br>
     Below is a screenshot of the homepage displayed in my browser. 
