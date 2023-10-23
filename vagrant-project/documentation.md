<h1>vagrant-ubuntu.sh</h1>
<h3>Vagrant LAMP Stack Deployment</h3>

<p>This script automates the setup and deployment of a LAMP (Linux, Apache, MySQL, PHP) stack on two Vagrant virtual machines, referred to as the "Master" and "Slave" nodes. To accomplish this, it performs the following steps.</p>

<ul>
   <li>Configure the Vagrantfile with the defined VM settings.</li>
   <li>Create and provision the Master and Slave VMs.</li>
   <li>Configure user accounts and generate SSH key pairs.</li>
   <li>Copy SSH keys between nodes for passwordless SSH.</li>
   <li>Set up directories for data synchronization.</li>
   <li>Synchronize data from the Master to the Slave using rsync.</li>
   <li>Install and configure a LAMP stack on both nodes.</li>
   <li>Create a PHP info file for testing the setup.</li>
   <li>Display process information on the Master node</li>
</ul>

## Prerequisites

Before running this script, ensure you have the following prerequisites:

- [Vagrant](https://www.vagrantup.com/) installed.
- [VirtualBox](https://www.virtualbox.org/) installed.
- Basic knowledge of Linux, as this script involves user creation, SSH setup, and Linux server provisioning.

## Usage

1. **Clone Repository:** Clone this repository to your local machine.

2. **Configure Variables:** Edit the script's variables at the beginning to match your desired configuration. These variables define VM names, users, and directories.

   - `box_name`: Set the name of the Vagrant box.
   - `master_vm`: Name of the Master node.
   - `slave_vm`: Name of the Slave node.
   - `master_user`: User name for the Master node.
   - `slave_user`: User name for the Slave node.
   - `vb_memory`: Amount of memory allocated to the VMs.
   - `slave_target_dir`: Target directory on the Slave node for data synchronization.
   - `master_target_dir`: Source directory on the Master node for data synchronization.

3. **Run the Script:**

   ```bash
   sh vagrant-ubuntu.sh

4. ****

