# Cora Z7-10 Development Kit Notes

This repo provides demos using Digilent's Cora-Z7-10 development board.

Clone: ```git clone https://github.com/cweave72/cora_z7```

Xilinx tools: Vivado & SDK (v2018.2)

## Building Linux

The ```linux_os``` directory contains the submodules for building the following items:
- U-Boot
- Linux kernel
- rootfs (via Buildroot)

The idea is that you configure/build the binaries above once then use them for
projects in the projects/ directory.  The system designs for an individual demo
project will contain the hardware definition ultimately needed to generate the
device tree blob necessary for booting linux. Each demo project will have
sub-Makefiles responsible for generating all hardware and software binaries
required for booting the demo design.

To build everything:
```
cd linux_os
make
```
Other options:
```
$ make help
Targets:
        all         : Builds everything. Results in build/
        u-boot      : Builds the u-boot elf (build/u-boot)
        linux       : Builds linux kernel (build/zImage).
        buildroot   : Builds the rootfs (build/rootfs.cpio.gz).
        umenuconfig : Launch u-boot menuconfig.
        lmenuconfig : Launch linux menuconfig.
        bmenuconfig : Launch buildroot menuconfig.
        uclean      : Clean u-boot.
        lclean      : Clean linux.
        bclean      : Clean buildroot.
        clean       : Clean everything.
```

## Basic IO Demo project

The projects/basic_io directory produces a design which toggles the tri-color LEDs.

Building the demo:
```
cd projects/basic_io
make
```

### Design Flow for Building the PL independently.

Note: The following details are for the basic_io demo project but applicable in general to any project created.

You can build the whole shooting match in one step as show above, or you can
build the PL design in steps.  The design flow is managed by the Makefile in
basic_io/hw. The build process uses TCL scripts in the vivado_scripts/ directory to
drive the flow in batch-mode.  Below shows the other make targets available:
```
$ make help
Targets supported:
    all   : Creates all output products (ip, bitstream). Use clean first to re-create project file.
    proj  : Cleans and re-creates project file only.
    synth : Runs (or re-runs) synthesis step only.
    par   : Runs (or re-runs) place-and-route step only (creates bitstream).
    ip    : Generates ip products only (in vhdl/ip directory).
    gui   : Launches the Vivado gui with the current project file.
    clean : Cleans all generated products (in the build/ directory).
```

To build the design step-by-step from scratch (e.g. after ```make clean```), you could:
- Build the project file only (must re-run if any project parameters change): \
```make proj```
- Run synthesis: \
```make synth```
- Run place and route (results in a bitfile): \
```make par```
- Run synthesis and place and route: \
```make all``` (i.e. to rebuild after any VHDL changes - does not re-create vivado project)
- Open the Vivado GUI to inspect the results, block design, etc...: \
```make gui```

PL Directory Structure:
```
$ tree basic_io/hw
Makefile
proj
├── Cora-Z7-10-Master.xdc
├── cora_z7_bd.tcl
└── params.tcl
vhdl
├── ip
│   └── <ip subdirs>
└── src
    └── system_top.vhd
        ...
```

Project files:
- *cora_z7_bd.tcl*: Script which generates the system block design.  This has all the system information for the Zynq PS as well as an PL peripherals.
- *Cora-Z7-10-Master.xdc*: Constraint file containing all FPGA IO definitions. Provided by Digilent.
- *params.tcl*: Vivado project parameters (source files, constraints, etc...):
```
...
set part "xc7z010clg400-1"
set block_design "$currpath/cora_z7_bd.tcl"

# Define list of source files to be added to the project.
set srcs [list]
lappend srcs "$currpath/../vhdl/src/system_top.vhd"

set ip {}

# Define list of xdc files to be added to the project.
set constr [list]
lappend constr "$currpath/Cora-Z7-10-Master.xdc"
```

TODO: Add description of how IP is handled.

### Booting over JTAG

- Connect the USB-JTAG cable to the dev board.
- run minicom. Make sure to turn off Hardware Flow Control (Ctlr-A Z/cOnfigure Minicom(O)/Serial port setup)
```
minicom -b115200 -D/dev/ttyUSB1
```

Note: If your Cora-Z7 is connected to a remote PC, you can run Vivado Lab version's hardware server:
```
hw_server
```
Then, you can specify the IP of the remote PC when you boot the board (over JTAG).

Finally, booting:
```
cd projects/basic_io
make boot
```
or if using remote hw_server (@192.168.1.8 for example):
```
make XILINX_HW_SERVER=192.168.1.8 boot
```

Login information (user: root; password: cora)

```
Welcome to Cora Z7
cora_z7 login: root
Password: cora
Welcome to:

:'######:::'#######::'########:::::'###:::::::::::::'########:'########:::::::::::::'##:::::'#####:::
'##... ##:'##.... ##: ##.... ##:::'## ##::::::::::::..... ##:: ##..  ##:::::::::::'####::::'##.. ##::
 ##:::..:: ##:::: ##: ##:::: ##::'##:. ##::::::::::::::: ##:::..:: ##:::::::::::::.. ##:::'##:::: ##:
 ##::::::: ##:::: ##: ########::'##:::. ##:'#######:::: ##::::::: ##::::'#######:::: ##::: ##:::: ##:
 ##::::::: ##:::: ##: ##.. ##::: #########:........::: ##::::::: ##:::::........:::: ##::: ##:::: ##:
 ##::: ##: ##:::: ##: ##::. ##:: ##.... ##::::::::::: ##:::::::: ##::::::::::::::::: ##:::. ##:: ##::
. ######::. #######:: ##:::. ##: ##:::: ##:::::::::: ########::: ##:::::::::::::::'######::. #####:::
:......::::.......:::..:::::..::..:::::..:::::::::::........::::..::::::::::::::::......::::.....::::

<cora_z7> #
```

### Connecting via Ethernet

Linux configuration is set to connect via DHCP when connected to your local network.  
The board can be found as hostname cora_z7.home via DNS.

Test connectivity:
```
ping cora_z7
```

To set a static IP or change the hostname, set the ETH0_IP_STATIC variable in ```linux_os/configs/buildroot/external/board/device_config:```:

```
HOSTNAME=cora_z7

#S40network config
ETH0_USE_DHCP=y
ETH0_IP_STATIC=192.168.2.1
ETH0_NETMASK=255.255.255.0
```

You can then ssh to the board:
```
ssh root@cora_z7
```

## Preparing a microSD card for booting

I find it easiest to do the following procedure directly on the target Cora board.
- Insert microSD into the card slot.
- Boot to Linux via JTAG
- The SD card will show up as ```/dev/mmcblk0```
- Create 2 partitions, 1 boot partition (1GB), 1 regular partition
```
fdisk /dev/mmcblk0
...
Command (m for help): p
Disk /dev/mmcblk0: 14 GB, 15485370368 bytes, 30244864 sectors
472576 cylinders, 4 heads, 16 sectors/track
Units: sectors of 1 * 512 = 512 bytes

Device       Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type

Command (m for help): n
Partition type
   p   primary partition (1-4)
   e   extended
p
Partition number (1-4): 1
First sector (16-30244863, default 16): 
Using default value 16
Last sector or +size{,K,M,G,T} (16-30244863, default 30244863): +1G

Command (m for help): a
Partition number (1-4): 1

Command (m for help): n
Partition type
   p   primary partition (1-4)
   e   extended
p
Partition number (1-4): 2
First sector (2097168-30244863, default 2097168): 
Using default value 2097168
Last sector or +size{,K,M,G,T} (2097168-30244863, default 30244863): 
Using default value 30244863

Command (m for help): p

Device       Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk0p1 *  0,1,1       130,139,8           63    2097214    2097152 1024M 83 Linux
/dev/mmcblk0p2    130,139,9   1023,254,63    2097215   30244863   28147649 13.4G 83 Linux

Command (m for help): w
```
- Format the boot partition and root partition.
```
mkfs.vfat -F 32 -n boot /dev/mmcblk0p1
mkfs.ext4 -L root /dev/mmcblk0p2
```

See section below on booting from the sd card.

## Booting methods

### Method: Boot from sdcard using boot.bin + uEnv.txt + rootfs

This method is used for standalone operation with a persistent rootfs residing on the sdcard.

SD card partitions:
```
Partition 1 (FAT32 - bootable):
    boot.bin
    uEnv.txt

Partition 2 (ext4):
    rootfs:
        bin/
        etc/
        opt/
        ...
```

Partition 1:

All items needed to boot into a single bootgen image, boot.bin.
The boot.bin file packages the following things (in this order):
1. FSBL : The first-stage bootloader (initializes the PS and loads the PL)
2. PL bitstream
3. u-boot.elf: Secondary bootloader. Boots the kernel and provided the kernel bootargs.
4. devicetree blob (.dtb)
5. initramfs.ub: Compressed ramdisk
6. uImage: Compressed kernel image

The FSBL processes the boot.bin partition headers and loads each component into
memory at specified load addresses:

Example boot.bif (used by the bootgen application to create boot.bin):
```
image : {
    [bootloader]projects/basic_io/sw/build/fsbl.elf
    projects/basic_io/hw/build/System_top.bit
    linux_os/build/u-boot.elf
    [load=0x16400000]projects/basic_io/sw/build/dts/system-top.dtb
    [load=0x10000000]linux_os/build/initramfs.ub
    [load=0x13200000]linux_os/build/uImage
}
```
The ```[load=0x...]``` attribute instructs the FSBL to load the binary into memory at specified address.

The FSBL then hands off executtion to u-boot for bringing up the kernel.  This
is where uEnv.txt comes into play. When u-boot starts, it finds the boot
partition of the sd card (mmc0) and reads uEnv.txt.  This is used to set the
u-boot environment and specify instructions for booting the kernel. Below is
the uEnv.txt used:
```
bootargs=console=ttyPS0,115200 root=/dev/mmcblk0p2 rw rootfstype=ext4 rootwait
bootcmd=bootm 0x13200000 - 0x16400000
uenvcmd=boot
```
The first line specifies the kernel command line arguments. This tells the
kernel that the root of the filesystem is found on parition 2 of the sdcard.
The bootcmd variable instructs u-boot to boot the kernel using the image
located at 0x13200000 and devicetree blob at 0x16400000 - both of which were
loaded by the FSBL.

Partition 2:

This sdcard partition contains the uncompressed rootfs that linux will mount to
/. Any changes made to files in this partition will be preserved across reboots
(unlike initramfs, where any modifications would be lost).

### Updating the boot images and rootfs:

This process is followed after changes have been made to the fsbl, u-boot,
bitfile, devicetree, or kernel image.

Updating boot.bin:

This can be accomplished after a normal boot, either from sd card or JTAG.  (On
initialization, the boot partition of the sd card will be mounted at
/sdcard/boot.)  For the basic_io demo example, updating the boot.bin is
accomplished as follows:
```
cd projects/basic_io
make image updateboot
```

Updating rootfs:

The rootfs can only be updated after a JTAG boot, since we can't update the
rootfs if it's in use. After booting via JTAG as described above, run the
following:
```
cd projects/basic_io
make updaterootfs
```
This will extract the rootfs.tar from the linux_os build process and rsync the
new rootfs to the sdcard (mounted as /sdcard/rootfs during the JTAG boot)

Note: I've discovered that when switching from sd boot to JTAG boot, you need
to perform a hard reset in addition to removing JP2 in order to have the Zynq
recognize the change in boot mode.

## Set up passwordless SSH from host

The buildroot configuration provides a public/private RSA key pair for use with
the board.  The keys are generated by the linux_os Makefile and are stored in
the keys/ directory.

Copy the private key (```linux_os/keys/cora_z7_sshkey_rsa```) to your local
~/.ssh directory and add the following entry to the config file:
```
Host cora_z7
user root
hostname cora_z7
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
IdentityFile ~/.ssh/cora_z7_sshkey_rsa
HostKeyAlgorithms ssh-rsa
```

### Misc:

Useful:
```
cat /proc/cmdline
cat /proc/mounts
```
