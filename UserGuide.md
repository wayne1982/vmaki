# Introduction #

This page contains the user guide for **vmaki 1.0** and will help you using it effectively in your environment.





# Contents #








# Getting Started #

Check out the [Getting Started Guide](GettingStarted.md) to get vmaki running in your environment.




# Login #

If _vmaki_ is set up as described in the [Getting Started Guide](GettingStarted.md) you can connect to it using your browser (Firefox is highly recommended) entering the URI of the host on which _vmaki_ is installed from any workstation in your network. vmaki is running on **Port 8000**, therefore you have to make sure to specify the port in the URI. Have a look at the example below.

![http://vmaki.googlecode.com/files/url.png](http://vmaki.googlecode.com/files/url.png)

You will then be prompted to enter the username and password. If you log in for the first time you will have to use the predefined admin user account:

  * **username: admin**
  * **password: admin**

After you successfully logged in with the admin user account you should create a new user account and change the admin's password. Have a look at [User Management](UserGuide#User_Management.md) to see how this is done.




# Host Management #

You can add one or several Xen hosts to _vmaki_. The local Xen host on the system _vmaki_ has been installed can be added right away without any further modifications. In order to connect remote Xen Hosts running on an other system than _vmaki_ itself, you have to set up the Xen host as described in the [Getting Started Guide](GettingStarted#Xen_Node.md).


## Adding a Xen Host ##

To add a Xen host to _vmaki_ you simply click on the _Host Menu_ on the top toolbar and choose the item _Add Host_. A pop-up will appear and ask you for some parameters:

![http://vmaki.googlecode.com/files/add_host_menu.png](http://vmaki.googlecode.com/files/add_host_menu.png)

![http://vmaki.googlecode.com/files/add_host.png](http://vmaki.googlecode.com/files/add_host.png)


#### Host Name ####

This field expects the name of the host on which Xen is installed. You can either enter the IP address or the DNS name of the host. It is not recommended to use localhost as the host name for the local Xen host because the hostname will also be used for the VNC link which is needed to access the console of a VM and could not be used in that case.

#### Connection ####
This field sets the protocol which is used to establish the connection to the Xen host. In the current version of _vmaki_ only SSH connections are supported, therefore this entry can not be changed.

#### User ####
This field specifies the user which is used to connect to the Xen host.


#### Password ####
Here you have to enter the password of the user specified above.

#### LVM Pool Name ####
It is mandatory that you set up your Xen host using LVM as described in the [Getting Started Guide](GettingStarted.md). In this field you have to enter the LVM pool name of the Xen host.




# VM Management #

## Creating a VM ##

To create a VM you have to select the host on which you want the VM to be created. If the correct Xen host is selected you can simply click on the _Add VM_ button on the top toolbar.

![http://vmaki.googlecode.com/files/add_vm_button.png](http://vmaki.googlecode.com/files/add_vm_button.png)

A pop-up window will appear in which you can enter the desired configuration for the VM.

![http://vmaki.googlecode.com/files/add_vm.png](http://vmaki.googlecode.com/files/add_vm.png)

### VM Name ###
Enter the name for the VM

### Type ###
There are two different virtualization types offered by Xen. _vmaki_ supports both of them:

#### para-virtualized (PV) ####
A guest operating system on a para-virtualized VM must be _virtualization aware_ which means that it has to provide an interface to the Xen hypervisor. Therefore the kernel of the guest operating system has to be modified. This virtualization method provides better performance when compared to full virtualization. The disadvantage is that only operating systems with a modified kernel can be installed. Also the installation process is more complex compared to other methods.

_vmaki_ supports the fully automated provisioning of a Debian Lenny system. Choose type PV and you get a fully installed Debian Lenny System and are good to go! PV is the best choice if you want a VM with good performance and do not have any special requirements in terms of the operating system.

After a PV VM has been created the provisioning of Debian Lenny automatically starts and the status of the VM in the _Tree_ and on the _General Tab_ are set to _provisioning_. The provisioning can take a couple of minutes, you will see that the provisioning is done when the status of the VM has been updated to _shutoff_.

![http://vmaki.googlecode.com/files/provisioning.png](http://vmaki.googlecode.com/files/provisioning.png)

#### HVM ####

On an HVM based VM virtualization support is implemented directly within hardware. The guest operating system has not to be aware that it is being virtualized and therefore its kernel does not have to be modified in any way.

To be able to run HVM VMs the CPU of the Xen host must provide HVM support (Intel VT-x/VT-i or AMD Pacifica). Also HVM support must be activated within the mainboard's BIOS. You can make sure it is supported by selecting the host and clicking on the _General Tab_ in _vmaki_.

![http://vmaki.googlecode.com/files/hvm_support.png](http://vmaki.googlecode.com/files/hvm_support.png)

### Memory ###
This setting let's you enter how much of the physical memory of the Xen host is going to be used by the VM.

### VCPU ###
This field sets the amount of virtual CPUs that are going to be used by the VM.

### Root Partition Capacity ###
Here you can enter the size of the logical volume for the VM. The size may not be larger than the available capacity left on the LVM pool.

### NIC ###
This drop down menu let's you choose which network interface of the Xen Host is going to be mapped to the VM.

### Media ###
Here you can specify which media is attached to the VM. You can either choose _CD-ROM_ for the physical drive of the Xen host or _ISO File_ to attach an ISO file which has been uploaded to _vmaki_. Have a look at [ISO Management](UserGuide#ISO_Management.md) to see how an ISO file can be uploaded.

## Installing the Guest Operating System ##

### PV ###
For PV VMs Debian Lenny is being installed automatically. The operating system can be started as soon as provisioning has completed.

### HVM ###
To install the guest operating system on HVM VMs you need to provide the installation media. You can either attach a physical CD-ROM drive or an ISO file. If not changed when adding the VM, the CD-ROM drive is attached by default. Have a look at [Change attached Media](UserGuide#Change_the_attached_Media_of_a_VM.md) to see how you can change the attached media of a VM.

Further you have to configure the boot device of the VM. By default the CD-ROM drive is set as the boot device. Alternative boot devices are HD (logical volume) and Network (PXE). [Reconfigure a VM](UserGuide#Reconfigure_a_VM.md) shows you how you can change the boot device of a VM.

## Controlling a VM ##

A VM can be controlled via the top toolbar or the VM context menu, which can be opened by right clicking on the VM. A VM can be started, suspended, resumed, restarted, shut down or killed. You can only select an action that is possible to be applied to the current status of a VM.

![http://vmaki.googlecode.com/files/vm_context.png](http://vmaki.googlecode.com/files/vm_context.png)

## Reconfigure a VM ##

To reconfigure the VM settings you can either use the _Reconfigure VM_ item in the _Edit Menu_ from the top toolbar or from the context menu of the selected VM. After clicking on the _Reconfigure VM_ item a pop-up window is displayed with the current configuration of the VM.

![http://vmaki.googlecode.com/files/reconfigure_vm.png](http://vmaki.googlecode.com/files/reconfigure_vm.png)

#### Memory ####
This let's you change how much of the physical memory of the Xen host is used by the VM. For _HVM_ VMs this can only be changed if the VM is shut down. The memory for _PV_ VMs can be changed at runtime but may not exceed the _Maximum Memory_ value.

#### Maximum Memory ####
This parameter can only be set for _PV_ VMs and specifies the maximum value the memory can grow at runtime. The maximum memory value mustn't be smaller than the memory value.

#### Root Partition Capacity ####
The size of the root partition can be increased or decreased. Be aware that decreasing the partition may cause data loss. This parameter can only be changed if the VM is shut down.

#### Boot Device ####
Here you can change the boot device of the VM. Since _PV_ VMs do not allow for a custom boot device, this can only be changed for _HVM_ VMs.

#### NIC ####
In this drop down menu you can change which network interface from the Xen host is used by the VM.

## Change the attached Media of a VM ##

To change the attached media of a VM you can click on the _Media_ item in the context menu of the VM or in the _Edit Menu_ of the top toolbar. A pop-up window will appear in which you can either select the physical CD-ROM drive of the Xen host or a ISO file which has been uploaded to _vmaki_.

![http://vmaki.googlecode.com/files/media_item.png](http://vmaki.googlecode.com/files/media_item.png)

![http://vmaki.googlecode.com/files/attach_iso.png](http://vmaki.googlecode.com/files/attach_iso.png)

## Connect VNC Console of a VM ##

To connect to the VNC console of a VM you simply need to click on the VNC link which can be found in the _Console Tab_. After clicking on the VNC link you will be prompted to choose which VNC viewer will be used to connect the console (depends on the client's operating system).

![http://vmaki.googlecode.com/files/vnc_link.png](http://vmaki.googlecode.com/files/vnc_link.png)

![http://vmaki.googlecode.com/files/vnc_console_debian_small.png](http://vmaki.googlecode.com/files/vnc_console_debian_small.png)

A VNC viewer has to be installed on your system in order to be able to make VNC connections. Here are some links to download a VNC viewer from which can be used for _vmaki_. ThightVNC also provides a Java version of its viewer which even doesn't have to be installed, in case you don't have sufficient permissions on the client system.

[ThightVNC (Linux / Windows)](http://www.tightvnc.com/download.html)

[RealVNC (Linux / Windows)](http://www.realvnc.com/products/download.html)

### Registering VNC Protocol on Windows ###

If you are using a Windows operating system you will need to register the VNC protocol in order to be able to choose your VNC viewer when clicking on the VNC link in _vmaki_. This can be done by adding an entry to the Windows registry. To simplify this we recommend to use the _customURL_ tool which can be downloaded [here](http://customurl.codeplex.com/Release/ProjectReleases.aspx?ReleaseId=15090#ReleaseFiles).

# ISO Management #

You can upload ISO files to _vmaki_ which can be attached to VMs. Click on the _ISO Tab_ to get an overview of all ISO files that are currently available. You can then add a new ISO file, delete or rename an existing one.

![http://vmaki.googlecode.com/files/iso_toolbar.png](http://vmaki.googlecode.com/files/iso_toolbar.png)

# Snapshot Management #

To backup a VM you can take a snapshot of it which stores the current state of the VM and writes it to an image file. Click on the _Snapshot Tab_ to get to the overview panel of all snapshots created for the VM.

![http://vmaki.googlecode.com/files/toolbar_snapshot.png](http://vmaki.googlecode.com/files/toolbar_snapshot.png)

## Taking a Snapshot ##

To take a snapshot of a VM you simply select the VM you want to backup and click on the _Add Snapshot_ button. This can be done while the VM is running. After clicking on the _Add Snapshot_ button you will be prompted to enter a description for the snapshot.

![http://vmaki.googlecode.com/files/add_snapshot.png](http://vmaki.googlecode.com/files/add_snapshot.png)

As soon as you commit, the snapshot is being taken and written into the file. This can take a couple of minutes depending on the size of the root volume that the VM is using. You can check the status of the snapshot in the panel of the _Snapshot Tab_.

![http://vmaki.googlecode.com/files/creating_snapshot.png](http://vmaki.googlecode.com/files/creating_snapshot.png)

![http://vmaki.googlecode.com/files/ready_snapshot.png](http://vmaki.googlecode.com/files/ready_snapshot.png)

## Restoring a Snapshot ##

To restore a snapshot you have to select the snapshot which has to be restored. Simply click on the _Restore Snapshot_ button within the toolbar. Make sure the VM is not running. The status of the snapshot and the VM is changed to _restoring_. After the restore is done the status will change back to _ready_. This can take a couple of minutes depending on the size of the snapshot that has to be restored.

![http://vmaki.googlecode.com/files/restoring_snapshot.png](http://vmaki.googlecode.com/files/restoring_snapshot.png)

![http://vmaki.googlecode.com/files/restoring_snapshot_node.png](http://vmaki.googlecode.com/files/restoring_snapshot_node.png)

# User Management #

_vmaki_ has a build-in user management which allows you to control access to _vmaki_. The user management area can be accessed via the _User tab_. It allows you to create new users, but also to delete or rename an existing ones. This area also allows you to reset user passwords (if your account belongs to the _Administrator_ role).

![http://vmaki.googlecode.com/files/user_tab.png](http://vmaki.googlecode.com/files/user_tab.png)

## Creating a new User ##

A new user can be added via the _Add User_ button. The pop-up menu that appears let's you set user name, user role and password. The role of the new user can either be _Administrator_ or _User_. If you define a new user as belonging to the _Administrator_ role, he can also make modifications to existing users and is allowed to create new ones, while the _User_ role does not allow this. Except for this, there are no differences between these two roles.

![http://vmaki.googlecode.com/files/add_user_window.png](http://vmaki.googlecode.com/files/add_user_window.png)