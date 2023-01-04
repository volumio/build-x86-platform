# Build your own Volumio x86 linux kernel
Copyright (c) 2022 Gé Koerkamp / ge.koerkamp@volum##.com

## Intro
This script is used for building the necessary x86 platform files, which includes kernel, firmware, scripts etc. It does NOT build an image.
This is default set to kernel 6.1.y, but can be used to build files for 5.10.y, both used for Volumio 3, see the config.x86 in the config directory.

## Prerequisites

This build process has been tested on Debia Buster (Debian 10), but should work on any Ubuntu >= 20.xy  
You will need the following minimal packages:

```
build-essential bc kmod flex cpio libncurses5-dev libelf-dev libssl-dev bison rsync libncurses-dev
```

## History
See at the end of this document.

## Process

### Clone the build repository

```
git clone https://github.com/gkkpch/volumio-x86-build-kernel --depth 1
```
### Run the build process

```
cd volumio-x86-build-kernel
./buildx86kernel.sh
```

### Patching

After cloning/ updating the kernel and platform repos and applying volumio patches, the build process comes to a break-point and displays:
```
[ .. ] Now ready for additional sources and patches [ Info ]
```
At this point further patches can be made in the kernel tree.  
Kernel patches are accumulated in ```./patches/volumio-kernel.patch```.  
When you're ready, or did not have any patches, press [Enter]

**Note** Currently, additional files are not automatically saved, you need to copy these into the build repo's sources folder.
Represent the location in the tree where you wish to add them by creating the corresponding directory tree structure.

### Kernel configuration
There is also an opportunity to change kernel configuration settings, using the menuconfig dialogue which will appear.
Just exit when you have no changes. 
Configuration modifications will be saved in ```/platform-x86/packages-buster/amd64-volumio-min..._defconfig``` and reused with future kernel compiles.

## History

|Date|Author|Change
|---|---|---|
|20220218|gkkpch|Initial version
|20220404|gkkpch|Use for kernel 5.10.y with github.com/volumio/platform-x86 
|20230103|gkkpch|Add kernel 6.1.y support
|||Add support for Realtek RTL88x2BU/ RTL8812AU/ RTL8814AU/ RTL8821AU
|||Add support for i2c-cht341-usb
|20230104|gkkpch|Moved firmware files from platform-x86 to ./firmware
|||Merged the 4 different tarballs into a single firmware tarball, script ```mergefirmware.sh``` added.  
|TODO|TODO|Remove the remainders in platform-x86 once the build recipe modification have been merged 
|||



<br />
<br />
<br />
<br />
<sub> January 2023/ Gé koerkamp
<br />ge.koerkamp@gmail.com
<br />04.01.2023 v1.0

