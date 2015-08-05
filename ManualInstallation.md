# Introduction #
This document describes in the first part the steps needed to take in order to set up a host running the vmaki management node including Xen Hypervisor support. The second part describes how to set up a so called "Xen Host", which is only being used as a container for Xen DomUs but does not provide any management functionality or host vmaki itself.

You can also resize an existing root volume if you have to, which is described [here](http://code.google.com/p/vmaki/wiki/ResizeRootVolume).

# Manual Installation: Management Node #

## Prerequisites ##
Install Debian Lenny on a physical host using LVM volumes. Make sure there is enough free space within the volume pool for the creation of guest volumes. For client machines the Firefox browser is highly recommended.

## Getting vmaki ##
Check out vmaki's trunk:
```
# svn checkout http://vmaki.googlecode.com/svn/trunk/ vmaki
```

## Linux ##
Install required packages via apt & RubyGems:
```
# sudo apt-get install linux-image-xen-amd64 xen-hypervisor-3.2-1-amd64 xenstore-utils xen-utils-common \
make gcc ruby ruby-dev rubygems irb libvirt-bin libvirt-dev libxml-ruby postgresql postgresql-server-dev-8.3 \
sqlite3 libsqlite3-dev libopenssl-ruby libxml2-dev libxslt-ruby libxslt1-dev openssh-server nfs-kernel-server
```
Add the following line to the .profile file in your home directory:
```
PATH="$PATH:/var/lib/gems/1.8/bin"
```
Immediately apply those changes to your environment and upgrade RubyGems to >1.3.1:
```
# source .profile
# sudo gem install rubygems-update
# cd /var/lib/gems/1.8/bin
# sudo ./update_rubygems
```
Install some more gems:
```
# sudo gem install rails rake mongrel postgres libxml-ruby uuid net-ssh net-sftp
```
download http://vmaki.googlecode.com/svn/trunk/ruby-libvirt/pkg/ruby-libvirt-0.1.1.gem
```
# sudo gem install ruby-libvirt-0.1.1.gem
```

## Xen ##
Edit "/etc/xen/xend-config.sxp" and add the following lines:
```
(xend-unix-server yes)
(network-script 'network-bridge')
(vnc-listen '0.0.0.0')
```

You can optionally also add a VNC Password:
```
(vncpasswd 'mypassword')
```

Create a symlink called "xen" pointing to the lib folder of the xen installation to be used:
```
ln -sf /usr/lib64/xen-3.2-1 /usr/lib64/xen
```

## PostgreSQL ##
### PostgreSQL Settings ###

Change password of the postgres admin user:
```
# sudo passwd postgres
```

Then edit the postgresql.conf file:
```
# sudo gedit /etc/postgresql/8.3/main/postgresql.conf
```

And change the line:
```
#listen_addresses = 'localhost'
```
**TO:**
```
listen_addresses = '*'
```
The line:
```
#password_encryption = on
```
**TO:**
```
password_encryption = on
```
Now edit the file "/etc/postgresql/8.3/main/pg\_hba.conf" and change all lines containing the following:
```
# sudo gedit /etc/postgresql/8.3/main/pg_hba.conf
local all all ident sameuser
```
**TO:**
```
local all all md5
```

### Create new vmaki User ###

```
# sudo -u postgres createuser --superuser vmakidb
# sudo -u postgres createdb vmakidb
# sudo -u postgres psql vmakidb
vmaki=# alter user vmakidb with password 'virtual_M0nk83';
\q
```

## NFS ##

Install NFS Server & create directory:
```
# chmod 777 /var/vmaki/isos
# mkdir -p /mnt/tmp
```

Add the following line to "/etc/exports":
```
/var/vmaki/isos *(ro,sync,insecure,no_root_squash,no_subtree_check)
```

Now export the filesystem and mount it:
```
# sudo exportfs -ra
# sudo mount IP:/var/vmaki/isos /mnt/tmp
```

## Final Steps ##
Set up the database (change into vmaki's directory):
```
# rake db:migrate
```

Start the vmaki process (also insides vmaki's directory):
```
# script/server
```

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