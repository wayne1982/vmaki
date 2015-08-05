# Introduction #
This document describes in the first part the steps needed to take in order to set up a host running the vmaki management node including Xen Hypervisor support. The second part describes how to set up a so called "Xen Host", which is only being used as a container for Xen DomUs but does not provide any management functionality or host vmaki itself.

You can also resize an existing root volume if you have to, which is described [here](http://code.google.com/p/vmaki/wiki/ResizeRootVolume).

# Management Node #

## Prerequisites ##
Install Debian Lenny on a physical host using LVM volumes. Make sure there is enough free space within the volume pool for the creation of guest volumes, also make sure you write down the name of the volume group since that information will be needed when adding the host itself to vmaki. vmaki needs its own user it will run under, which has to be called "vmaki". During installation, you will have to specify a username for the initial user account to be created, so you directly enter "vmaki" to create it.

**Notes:**
  * Installation has only been tested on newly installed hosts, a dedicated machine for vmaki is highly recommended.
  * For client machines Firefox 3 is highly recommended. It has not been tested with other browsers.

## Setting up the repository ##

To make the installation as simple as possible, there's a package for the x64 architecture of Debian. for vmaki and all of its dependencies. To get it, you have to add the following line into "/etc/apt/sources.list":

```
deb http://www.roboprojects.com/debrepo binary/
```

Now hit "apt-get update" to apply these changes.

## Installation ##

Installation is just as simple, enter:

```
apt-get install vmaki
```
Answer all questions with _yes_. After the package has been installed, reboot the system. A Xen kernel has been installed and should now be set as the default kernel. After rebooting, vmaki and all of its components will start up automatically.

# Xen Node #

Install a host using Debian Lenny and LVM. Make sure the root volume doesn't take up all the space that's available within the volume group. You can also resize an existing root volume if you have to, which is described [here](http://code.google.com/p/vmaki/wiki/ResizeRootVolume).

## Install all Packages ##

# sudo apt-get install linux-image-xen-amd64, xen-hypervisor-3.2-1-amd64, xenstore-utils, xen-utils-common libvirt-bin openssh-server nfs-common portmap

## Xen ##
Edit "/etc/xen/xend-config.sxp" and add the following lines:
```
(xend-unix-server yes)
(network-script 'network-bridge')
(vnc-listen '0.0.0.0')
```