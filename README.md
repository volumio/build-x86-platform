# Build your own Volumio x86 linux kernel
Copyright (c) 2022 Gé Koerkamp / ge.koerkamp@volum##.com

## **Intro**
This script is used for building the necessary x86 platform files, which includes kernel, firmware, scripts etc. It does NOT build an image.
This is default set to kernel 6.1.y, but can be used to build files for 5.10.y, both used for Volumio 3, see the config.x86 in the config directory.

## **Prerequisites**

This build process has been tested on Debia Buster (Debian 10), but should work on any Ubuntu >= 20.xy  
You will need the following minimal packages:

```
build-essential bc kmod flex cpio libncurses5-dev libelf-dev libssl-dev bison rsync libncurses-dev
```

## History
See at the end of this document.

## **Kernel Build Process**

### Clone the build repository

```
git clone https://github.com/gkkpch/build-x86-platform --depth 1
```
### Run the build process

```
cd build-x86-platform
./buildx86kernel.sh
```

### Patching

After cloning/ updating the kernel and platform repos and applying volumio patches, the build process comes to a break-point and displays:
```
[ .. ] Now ready for additional sources and patches [ Info ]
```
At this point further patches can be made in the kernel tree.  
Kernel patches are accumulated in ```./patches/<major-kernelversion>/0001-custom-volumio.patch```.  
When you're ready, or did not have any patches, press [Enter]

### Additional kernel sources
Currently, custom files are not automatically saved, you need to copy these into the build repo's sources folder: ```./sources/<major-kernelversion>/```.  
This needs to have same file structure as the corresponding kernel tree.  
For an example, see ```./sources/6.1.y```.

### Kernel configuration
There is also an opportunity to change kernel configuration settings, using the menuconfig dialogue which will appear.  
Just exit when you have no changes.  
Configuration modifications will be saved in ```/platform-x86/packages-buster/amd64-volumio-min..._defconfig``` and reused with future kernel compiles.

## Add support for a Release Candidate kernel
Release Candidate kernels are not part of the ```linux-stable``` repo.  
The compilation of such a kernel requires
* manuallly download the tarbal from http://kernel.org
* unzipping the tarbal into the corresponding kernel folder, example ```./linux-6.2-rc4```
* modification of ```./config/x86.conf```
    * comment the current kernel branch
    ```
    #KERNELBRANCH="6.1.y"
    ```

    * add a new one, e.g.
    ```
    KERNELBRANCH="6.2-rc4"
    ```
For the sources and patches, follow the instructions below (support for a new kernel).    
**Important** Omit any custom sources or patches in case it is used for bugzilla reporting.
Start the build process.

## Adding support for a new major kernel
* Create the new ```./sources/<kernelbranch>``` folder.
* Create the new ```./patches/<kernelbranch>``` folder.
* Copy the custom sources from a **previous** ```./sources/<major-kernelversion/``` (the closest version you have) to the new patches folder.
* Copy the custom patches from the corresponding previous ```./patches/<major-kernelversion>/``` to the new patches folder. 
* modify ```./config/x86.conf```
    * comment the current kernel branch
    ```
    #KERNELBRANCH="6.1.y"
    ```

    * add a new one, e.g.
    ```
    KERNELBRANCH="6.2.y"
    ```
* Start the build process.

Be aware, that patching or compiling may not work.
* in case patches do not apply
    * the build process will have stopped at 
    ```
    Now ready for additional sources and patches
    Press [Enter] key to resume ...
    ```
    * fix the failed patch manually (it can be mismatched a few lines in case the source was changed in the new kernel version)
* in case the kernel does not apply because of errors in custom sources  
Consult the internet and apply the necessary fixes, this is not always trivial  
With the wireless drivers, refer to the README.md file in the corresponding ```./sources``` folder.  
        The repo owners may already have created patches.

## **Firmware Maintenance**

There are two situations
* you wish to add a particular new or missing firmware binary and leave the rest as is
* you wish to add a complete new linux-firmware from kernel.org

## Add a new or missing firmware binary

Try to find out what is needed and then clone repo ```git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git```
```
cd firmware
git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git new-fw
```
This will give you the latest stable firmware repo in directory ```new-fw```.

Unpack the current linux-firmware tarball in firmware (on 20230104 this was firmware-20231216).
```
cd firmware
tar xfJ linux-fw-20221216.tar.xz
```
This gives you the current firmware tree in ```lib```.

Locate the new firmware and place it at the exact same location in the current tree.
Example:
```
cd firmware
cp new-fw/rtlwifi/rtl8188efw.bin lib/firmware/rtlwifi
```

Create a new linux-firmware tarball, note the name and the different date.
Only overwrite an existing one when you add something which was missing.
```
cd firmware
tar cfJ linux-fw-20230104.tar.xz ./lib
```
Remove the temp folders
```
rm -r new-fw
rm -r lib
```

In case you added new firmware (not missing stuff), open ```config/config.x86``` and add the date of the new firmware tarball (in this case "20230104") to the list of firmware releases.
```
LINUX_FW_REL=("20211027" "20221216" "20230104")
```
in both cases, start the merge script in the build-x86-platform root folder
```
./mergefirmware.sh
```
The new tarball will be copied to platform-x86

## New firmware-linux from kernel.org

This is a little trickier and more time-consuming.
The firmware from kernel.org is too big to use as-is, it needs cutting out the unnecessary firmware.
The best way to do this is to clone the firmware repo as shown above, but do this in a directory outside the build-x86-platform.

Now comes to tedious part. Compare the contents of the current firmware tarball in firmware. On 20230104 this was ```linux-fw-20221216``` and start with removing all directories in the new firmware repo which are not in the current one, unless you are sure it is a new one that matters (graphics, wifi). 
Do the same for the files in the root folder of the new firmware repo, keep the matching ones but also new binaries starting with "ar", "ath", "iwlwifi", "mt", "rt". When unsure, keep it.

Then bring this new folder in a "lib/firmware" structure (like the current one) and pack it to a tarball linux-fw-<dat>.tar.xz, where date is kernel.org's release date (should be visible when doing a ```git tag -l``` (it is the last one).

Add the new date to config/config.x86 and start the merge (see above)

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
|20230118|gkkpch|Support release candidate kernels



<br />
<br />
<br />
<br />
<sub> January 2023/ Gé koerkamp
<br />ge.koerkamp@gmail.com
<br />04.01.2023 v1.0

