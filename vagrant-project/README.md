<h2>Project Task: Deployment of Vagrant Ubuntu Cluster with LAMP Stack</h2>

<h2>Objective:</h2>

Develop a bash script to orchestrate the automated deployment of two vagrant-based Ubuntu systems. Designated as 'Master' and 'Slave', with an integrated LAMP stack on both systems.

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
            <li>Create a user named altschool.</li>
            <li>Grant altschool user root (superuser) privileges.</li>
        </ol>
    <br>
    <li>Inter-node connection:</li>
    Enabling SSH key-based authentication:
        <ol>
            <p>The master node (altschool user) should seamlessly SSH into the slave node without requiring a password.</p>
        </ol>
    <br>
    <li>Data-Management and Transfer:</li>
    On Initiation:
        <ol>
            <p>Copy the contents of "/mnt/altschool" directory from the Master node to "/mnt/altschool/slave" on the slave node. This                      operation should be performed using the altschool user from the master node.</p>
        </ol>
    <br>
    <li>Process monitoring:</li>
        <ol>
            <p>The master node should display an overview of the Linux process management, showcasing currently running processes.</p>
        </ol>
    <br>
    <li>Lamp Stack deployment</li>
        <ol>
            <li>Install a LAMP (Linux, Apache, MySQL, PHP) stack on both nodes.</li>
            <li>Ensure Apache is running and set to start on boot.</li>
            <li>Secure the MySQL installation and initialize it with a default user and password</li>
            <li>Validate PHP functionality with Apache.</li>
        </ol>
</ul>

<h3>Deliverables</h3>

<p>A bash script encapsulating the entire deployment process adhering to the specifications mentioned above.<br>
Documentation accompanying the script elucidating the steps and procedures for execution.</p>




