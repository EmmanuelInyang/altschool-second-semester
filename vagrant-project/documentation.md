<h1>vagrant-ubuntu.sh</h1>
  <p><strong>NOTE:</strong> In all the steps, I'm referring to the vagrant-ubuntu.sh script.</p>
  <br>
<h2>Step 1: Declaration of Variables</h2>
<p>In the vagrant-ubuntu.sh script, the section with the comment "--VARIABLES--" declares the various variables needed to carry out the project, making the project reusable.</p>
<p>The variables declared are:
<ul>
  <li>box_name - The name of the Linux-based OS</li>
  <li>master_vm - The name of the master virtual machine.</li>
  <li>slave_vm - The name of the slave virtual machine.</li>
  <li>master_user - The name of the master user.</li>
  <li>slave_user - The name of the slave user.</li>
  <li>vb_memory - The memory needed for the virtual machine.</li>
  <li>slave_target_dir - The slave target directory for file transfer on initiation</li>
  <li>master_target_dir - The master target directory for file transfer on initiation</li>
</ul>
</p>

<h2>Step 2: Vagrant File Configuration</h2>
<p>The section with the comment "--VAGRANT FILE CONFIGURATION--" sets up the vagrant file configuration for the master and slave virtual machine.</p>

<h2>Step 3: Setting up the Virtual Machines/Infrastructure Configuration</h2>
<p>The comment "--SETTING UP THE VIRTUAL MACHINES/INFRASTRUCTURE CONFIGURATION--" indicates the section that sets up the virtual machines
  <br>
The commands are:</p> 
<code>vagrant up</code> creates and provisions the Master and Slave nodes.
  <br>
  <br>
<code>sudo useradd -m -d "/home/$master_user" -s /bin/bash "$master_user"</code> creates a master_user with a specified directory and bash shell.
  <br>
  <br>
<code>echo "$master_user:password" | sudo chpasswd</code> sets password for the master_user.
  <br>
  <br>
<code>sudo usermod -aG sudo "$master_user"</code> add the master_user to the sudo group.
  <br>
  <br>
<code>if [ "$NODE_TYPE" == "$master_user" ]</code> the statement indicates when the master_vm is accessed.
  <br>
  <br>
<code>if [ ! -f "/home/$master_user/.ssh/id_rsa.pub" ]</code> the statement creates a private key for the master_user when there's no key.
  <br>
  <br>
<code>sudo chmod 700 /home/"$master_user"/.ssh</code> sets the permission of the .ssh folder of the master_user.
  <br>
  <br>
<code>sudo chmod 644 /home/"$master_user"/.ssh/id_rsa.pub</code> sets the permission of the id_rsa file of the master_user.
  <br>
  <br>
