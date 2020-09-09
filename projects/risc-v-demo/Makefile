VIVADO_VERSION ?= 2018.2
VIVADO := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/vivado
SDK := /opt/Xilinx/SDK/$(VIVADO_VERSION)/bin/xsdk
XSDB := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/xsdb

JTAG_BOOT_SCRIPT = $(CURDIR)/../../vivado_scripts/jtagboot.tcl
XILINX_HW_SERVER ?= localhost
FSBL_PATH = $(CURDIR)/software/build/fsbl.elf
UBOOT_PATH = $(CURDIR)/../../linux_os/build/u-boot.elf
UIMAGE_PATH = $(CURDIR)/../../linux_os/build/uImage
DTB_PATH = $(CURDIR)/software/build/dts/system-top.dtb
RAMDISK_PATH = $(CURDIR)/../../linux_os/build/initramfs.ub
HWDEF = $(CURDIR)/hardware/build/System_top.hdf
BITFILE = $(HWDEF:.hdf=.bit)

# Bootgen vars
BOOT_BIF = build/boot.bif
BOOT_BIN = $(BOOT_BIF:.bif=.bin)

#Parameters for u-boot uEnv.txt, which should be copied to sd card with boot.bin.
UENV = build/uEnv.txt
UENV_BOOTARGS = "console=ttyPS0,115200 root=/dev/mmcblk0p2 rw rootfstype=ext4 rootwait"
UENV_BOOTCMD = "bootm 0x13200000 - 0x16400000"

ROOTFS = $(CURDIR)/../../linux_os/build/rootfs.tar

FW_APP = ucoshelloworld

.PHONY: all hw sw boot image updateboot updaterootfs updateall clean help

all: hw fw sw image

help:
	@echo "Targets supported:"
	@echo "    all          : Creates all products (fsbl, bitstream, device-tree). Use clean first to re-create all."
	@echo "    hw           : Builds the FPGA binaries."
	@echo "    fw           : Builds the firmware binaries."
	@echo "    sw           : Builds the software bsp and fsbl binaries."
	@echo "    boot         : Boots design via jtag (see hw/proj/jtagboot.tcl)."
	@echo "    image        : Creates the boot.bin file."
	@echo "    updateboot   : Copies the image file to the remote board. (Board must be booted w/initramfs, i.e. JTAG)"
	@echo "    updaterootfs : Copies the rootfs to the remote board. (Board must be booted w/initramfs)"
	@echo "    updateall    : Performs both updateboot and updaterootfs operations."
	@echo "    clean        : Cleans all generated products (in the hw/build and sw/build directories)."


build:
	@mkdir -p $@

hw:
	$(MAKE) -C hardware

fw:
	$(MAKE) -C firmware/$(FW_APP)

sw:
	$(MAKE) -C software

boot:
	@(HW_SERVER=$(XILINX_HW_SERVER) \
	  BITFILE=$(BITFILE) \
	  FSBL=$(FSBL_PATH) \
	  UBOOT=$(UBOOT_PATH) \
	  UIMAGE=$(UIMAGE_PATH) \
	  DTB=$(DTB_PATH) \
	  RAMDISK=$(RAMDISK_PATH) \
	  $(XSDB) $(JTAG_BOOT_SCRIPT))

image: | build
	@echo "Creating bootgen image file, boot.bin"
	@echo "image : {" > $(BOOT_BIF)
	@echo "    [bootloader]$(FSBL_PATH)" >> $(BOOT_BIF)
	@echo "    $(BITFILE)" >> $(BOOT_BIF)
	@echo "    $(UBOOT_PATH)" >> $(BOOT_BIF)
	@echo "    [load=0x16400000]$(DTB_PATH)" >> $(BOOT_BIF)
	@echo "    [load=0x10000000]$(RAMDISK_PATH)" >> $(BOOT_BIF)
	@echo "    [load=0x13200000]$(UIMAGE_PATH)" >> $(BOOT_BIF)
	@echo "}" >> $(BOOT_BIF)
	bootgen -w -image $(BOOT_BIF) -o i $(BOOT_BIN)
	@echo "Creating uEnv.txt"
	@echo "bootargs=$(UENV_BOOTARGS)" > $(UENV)
	@echo "bootcmd=$(UENV_BOOTCMD)" >> $(UENV)
	@echo "uenvcmd=boot" >> $(UENV)
	@echo "" >> $(UENV)

updateall: image updateboot updaterootfs

updateboot:
	@scripts/copy_boot.sh remote

updaterootfs:
	@scripts/copy-rootfs.sh $(ROOTFS)

clean:
	@rm -rf build/
	$(MAKE) -C hardware clean
	$(MAKE) -C software clean
