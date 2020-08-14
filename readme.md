# Cora Z7-10 Development Kit Notes

This repo provides demos using Digilent's Cora-Z7-10 development board.

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
make boot
```
or if remote:
```
make XILINX_HW_SERVER=<ip> boot
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
