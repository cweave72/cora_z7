VIVADO_VERSION ?= 2018.2
VIVADO := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/vivado
SDK := /opt/Xilinx/SDK/$(VIVADO_VERSION)/bin/xsdk
XSDB := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/xsdb

JTAG_BOOT_SCRIPTS = $(CURDIR)/../../linux_os/scripts
XILINX_HW_SERVER = 192.168.1.8 
#XILINX_HW_SERVER = localhost
FSBL_PATH = $(CURDIR)/sw/build/fsbl.elf
UBOOT_PATH = $(CURDIR)/../../linux_os/build/u-boot
UIMAGE_PATH = $(CURDIR)/../../linux_os/build/uImage
DTB_PATH = $(CURDIR)/sw/build/dts/system-top.dtb
RAMDISK_PATH = $(CURDIR)/../../linux_os/build/initramfs.ub
HWDEF = $(CURDIR)/hw/build/System_top.hdf
BITFILE = $(HWDEF:.hdf=.bit)

BOOT_BIF = build/boot.bif
BOOT_BIN = $(BOOT_BIF:.bif=.bin)

.PHONY: all hw sw boot image clean help

all: hw sw image

help:
	@echo "Targets supported:"
	@echo "    all   : Creates all products (fsbl, bitstream, device-tree). Use clean first to re-create all."
	@echo "    hw    : Builds the FPGA binaries."
	@echo "    sw    : Builds the software bsp and fsbl binaries."
	@echo "    boot  : Boots design via jtag (see hw/proj/jtagboot.tcl)."
	@echo "    image : Creates the boot.bin file."
	@echo "    clean : Cleans all generated products (in the hw/build and sw/build directories)."


build:
	@mkdir -p $@

hw:
	$(MAKE) -C hw

sw:
	$(MAKE) -C sw

boot:
	@(HW_SERVER=$(XILINX_HW_SERVER) \
	  BITFILE=$(BITFILE) \
	  FSBL=$(FSBL_PATH) \
	  UBOOT=$(UBOOT_PATH) \
	  UIMAGE=$(UIMAGE_PATH) \
	  DTB=$(DTB_PATH) \
	  RAMDISK=$(RAMDISK_PATH) \
	  $(XSDB) $(JTAG_BOOT_SCRIPTS)/jtagboot.tcl)

image: | build
	@echo "image : {" > $(BOOT_BIF)
	@echo "    [bootloader]$(FSBL_PATH)" >> $(BOOT_BIF)
	@echo "    $(BITFILE)" >> $(BOOT_BIF)
	@echo "    $(UBOOT_PATH)" >> $(BOOT_BIF)
	@echo "    [load=0x16400000]$(DTB_PATH)" >> $(BOOT_BIF)
	@echo "    [load=0x10000000]$(RAMDISK_PATH)" >> $(BOOT_BIF)
	@echo "    [load=0x13200000]$(UIMAGE_PATH)" >> $(BOOT_BIF)
	@echo "}" >> $(BOOT_BIF)
	bootgen -w -image $(BOOT_BIF) -o i $(BOOT_BIN)

clean:
	@rm -rf build/
	$(MAKE) -C hw clean
	$(MAKE) -C sw clean
