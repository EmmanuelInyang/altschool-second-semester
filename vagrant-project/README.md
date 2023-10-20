<h2>Project Task: Deployment of Vagrant Ubuntu Cluster with LAMP Stack</h2>

<h2>Objective:</h2>

Develop a bash script to orchestrate the automated deployment of two vagrant-based Ubuntu systems designated as 'Master' and 'Slave', with an integrated LAMP stack on both systems.

<h2>Specifications:</h2>

<h4>Infrastructure Configuration:</h4>

<ul>
    <li>Deploy two Ubuntu systems:</li>
    <ol>
    <li>Master node: This node should be capable of acting as a control system.</li>
    <li>Slave node: This node will be managed by the master node.</li>
    </ol>
    <br>
    <li>User management:</li>
    On the Master node:
    <ol>
        <li>Create a user named altschool</li>
        <li>Grant altschool user root (Superuser) privileges</li>
    </ol>
    <br>
    <li>Inter-node connection:</li>
    Enabling SSH key-based authentication:
    <p>The master node (altschool user) should seamlessly SSH into the slave node without requiring a password</p>
    <br>
    <li>Data-Management and Transfer:</li>
    On Initiation:
    <p>Copy the contents of /mnt/altschool directory from the Master node to /mnt/altschool/slave on the slave node. This operation should be performed using the altschool user from the master node.</p>
</ul>

