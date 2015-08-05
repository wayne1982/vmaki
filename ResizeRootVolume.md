# Resize Root Volume #

For this you will need some kind of Live CD (e.g. [SystemRescueCD](http://www.sysresccd.org)), since the volume may not be mounted at boot-time and write down, how much space is being occupied and determine, the size it should have from now on.

After you booted with the Live CD, make sure the LVM module is loaded:
```
# modprobe dm-mod
```

Now activate all LVM volume groups:
```
# lvm vgchange -a y
```

First, check the filesystem on the volume and fix it if necessary prior to resizing it:
```
# e2fsck -f /dev/VGname/VOLname
```

The filesystem itself has to be resized. Be careful not to choose a too small amount, since it could lead to data corruption. 10G indicate 10 Gigabytes, substitute with your choice:
```
# resize2fs -f /dev/VGname/VOLname 10G
```

Now reduce the LVM volume to the exact size of the filesystem:
```
# lvreduce -L10G /dev/VGname/VOLname
```