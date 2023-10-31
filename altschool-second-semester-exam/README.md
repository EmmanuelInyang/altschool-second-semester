<h2>Cloud Engineering Second Semester Examination Project (Deploy LAMP Stack)</h2>

<h2>Steps</h2>

Here are the steps I followed to complete the AltSchool Second Semester exam in an Ubuntu-based environment:

1. **Get Started:** 
   - To begin, I opened my code editor's terminal.
     
2. **Create a directory:**
   - I chose to name the directory 'altschool-second-semester-exam' and initiated it using the following command:
      ```bash
         mkdir altschool-second-semester-exam
      ```
3. **Navigate into the directory:**
   - I then changed my working directory to the newly created 'altschool-second-semester-exam' directory:
      ```bash
         cd altschool-second-semester-exam
      ```      
4. **Create a Bash script file (master-slave-setup.sh):**
   - I proceeded to create a Bash script file named 'master-slave-setup.sh' using the following command:
      ```bash
         touch master-slave-setup.sh
      ```
5. **Grant the necessary permission (master-slave-setup.sh):**
   - To make the Bash script executable, I granted the required permission using the command:
      ```bash
         chmod +x master-slave-setup.sh
      ```
6. **Write the contents of master-slave-setup.sh:**
   - This script automates the setup of two Vagrant virtual machines (master and slave) and configures them for Ansible provisioning.
       
7. **Execute the master-slave-setup.sh script:**
   - Next, I executed the script using the command:
     ```bash
        sh master-slave-setup.sh
     ```
**After installing the master-slave-ubuntu.sh script, the next step I took was to create a script to automate the installation of the LAMP stack on the master VM.**
   <br>
   <br>
8. **Create a Bash script file (master.sh):**
   - I ran the command on the terminal to create the Bash script file:
     ```bash
        touch master.sh
     ```
9. **Grant the necessary permission (master.sh):**
    - The necessary permission was granted by running the command below to make the Bash script file an executable file.
      ```bash
         chmod +x master.sh
      ```
10. **Write the contents of master.sh:**
    - This script automates the installation and setup of the LAMP stack on the master virtual machine.
      
11. **Execute the master.sh script:**
      - To execute the 'master.sh' script, I used the following command:
         ```bash
            sh master.sh
         ```
**After the completion of the 'master.sh' script, the LAMP stack installation on the master VM was successful, and the Laravel GitHub repository was cloned without issues. The next step involved testing the Laravel application.**
   <br>
   <br>
12. **Test the Laravel Application on the Master VM:** 
   <ul>
      <li> Access the master VM via SSH using the command: `vagrant ssh master`. </li>
      <li> Retrieve the master VM's IP address by executing `hostname -I` within the terminal. The second IP displayed is the correct one to use. </li>
      <li> Open your web browser and enter this IP address. </li>
      <li> You will be directed to the Laravel application's homepage. </li>
   </ul>
   
   **Below is a screenshot of the homepage displayed in my browser:**
   ![master_vm](https://github.com/EmmanuelInyang/altschool-second-semester/assets/95512710/e0999b82-451e-4bbd-b5a5-83d3a77fdea4)
<br>  
<br>
**After successfully testing the Laravel Application on the master VM, the next step I took was installing the same LAMP stack application on the slave VM using Ansible.**

**NOTE:** 
   - The main difference between the LAMP stack installation on the master and slave VMs is the use of Ansible for the installation on the slave VM. 
   - Ansible was installed and configured on the master VM when the master.sh script was executed.

13. **SSH into the Master VM:**
    - I verified whether I was already on the master VM from the previous task. If I'm not, I could SSH into the master VM with the command: 
         ```bash
            vagrant ssh master
         ```
     
14. **Locate the "plays" directory:**
    - Once logged into the master VM, I switched to the 'altschool' user by using the following command:
          ```bash
             su - altschool
          ```
      A password prompt appeared, and I entered the password 'password' as configured by the 'master.sh' script. After successfully entering the password, I logged in as the                 'altschool' user on the master VM. Next, I navigated to the 'plays' directory using the command:
         ```bash
            cd plays
         ```
      **NOTE:** During the setup process using the 'master.sh' script, Ansible was installed, and essential components like the 'altschool' user, the 'myhosts' file (also known as the       Inventory file), and 'ansible.cfg' (Ansible configuration file) were configured.

15. **Create a Jinja2 template file (slave.sh.j2):**
    - In the 'plays' directory, I created a Jinja template file named 'slave.sh.j2.' Jinja templates are used to make Ansible plays involving bash scripts as dynamic as possible.
      To create the Jinja2 template file, I used the following command:
      ```bash
            touch slave.sh.j2
         ```
16. **Grant the necessary permission (slave.sh.j2):**
    - I executed the following command to make the 'slave.sh.j2' file executable.
         ```bash
            chmod +x slave.sh.j2
         ```
17. **Write the contents for slave.sh.j2**
    - This script automates the installation and setup of the LAMP stack on the slave virtual machine.

18. **Create an Ansible playbook file (ansible-playbook.yml):**
    - In the 'plays' directory, I created an Ansible playbook file named 'ansible-playbook.yml.' In this file, I defined the Ansible play for the LAMP stack installation using the           'slave.sh.j2' file and added another specified play. This additional play involved creating a cron job on the slave node to run at midnight (12 AM).
      To create the file, I used the command:
         ```bash
            touch ansible-playbook.yml
         ```
19. **Grant the necessary permission (ansible-playbook.yml):**
    - To make the 'ansible-playbook.yml' file executable, I ran the command:
         ```bash
            chmod +x ansible-playbook.yml
         ```
      This is the 'plays' directory after completing the steps.
      ![inside the plays directory](https://github.com/EmmanuelInyang/altschool-second-semester/assets/95512710/90aa6da1-f3dc-4026-8628-b81e51cc4777)
  
20. **Execute the Ansible file (ansible-playbook.yml):**
    - To execute the 'ansible-playbook.yml' file, I used the command:
         ```bash
            ansible-playbook ansible-playbook.yml
         ``` 
       **Note:** The first ansible-playbook is the command, and the second one is the name of the ansible playbook to run.

21. **Test the Ansible playbook (ansible-playbook.yml):**
    - Using the second IP address obtained from the slave VM by logging into the slave VM and running the
      `hostname -I` command, I accessed the Laravel homepage by entering the slave's second IP address in the web browser.
   
   **Below, you'll find a screenshot of the Laravel homepage with the slave VM's IP address:**
   ![slave_vm](https://github.com/EmmanuelInyang/altschool-second-semester/assets/95512710/2841ff30-1ad7-4a43-926e-edc0215f1ac6)
      
   **The terminal displaying a successful Cron Job**
   ![Cron Job was successful](https://github.com/EmmanuelInyang/altschool-second-semester/assets/95512710/86eeb744-8c3c-49ae-9a60-2ea23512b251)
   
