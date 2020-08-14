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
