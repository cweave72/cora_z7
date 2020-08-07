CURDIR = $(shell pwd)

DTS = dts/u-boot/zynq-cora-z7-10.dts
DTS_FILE = $(notdir $(DTS))
DTB_FILE = $(addsuffix .dtb, $(basename $(DTS_FILE)))

UBOOT_CONFIG = configs/u-boot/cora_z7_10_defconfig
UBOOT_CONFIG_PATH = u-boot-xlnx/configs/$(notdir $(UBOOT_CONFIG))
UBOOT_DTS_PATH = u-boot-xlnx/arch/arm/dts/$(DTS_FILE)

LINUX_CONFIG = configs/kernel/zynq_pluto_defconfig
LINUX_CONFIG_PATH = linux/arch/arm/configs/$(notdir $(LINUX_CONFIG))

BR_CONFIG = configs/buildroot/external/configs/zynq_pluto_defconfig
BR_TOOLCHAIN = /opt/Xilinx/SDK/2018.2/gnu/aarch32/lin/gcc-arm-linux-gnueabi

CROSS_COMPILE = arm-linux-gnueabihf-

UBOOT_TARGET = u-boot-xlnx/u-boot
LINUX_TARGET = linux/arch/arm/boot/zImage
BR_TARGET = buildroot/output/images/rootfs.cpio.gz

.PHONY: all u-boot linux buildroot dtb umenuconfig lmenuconfig images uclean lclean bclean clean help

# All targets
all: u-boot linux buildroot images dtb

help:
	@echo "Targets:"
	@echo "	all         : Builds everything. Results in build/"
	@echo "	u-boot      : Builds the u-boot elf ($(UBOOT_TARGET))"
	@echo "	linux       : Builds linux kernel ($(LINUX_TARGET))."
	@echo "	buildroot   : Builds the rootfs ($(BR_TARGET))."
	@echo "	umenuconfig : Launch u-boot menuconfig."
	@echo "	lmenuconfig : Launch linux menuconfig."
	@echo "	uclean      : Clean u-boot."
	@echo "	lclean      : Clean linux."
	@echo "	bclean      : Clean buildroot."
	@echo "	clean       : Clean everything."

build:
	mkdir -p $@

dtb:
	$(MAKE) -C hw dts
	$(MAKE) -C hw/dts/ all
	cp hw/dts/*.dtb build/

#### u-boot #########
u-boot: build/$(notdir $(UBOOT_TARGET))
	
build/$(notdir $(UBOOT_TARGET)): $(UBOOT_TARGET) | build
	cp $(UBOOT_TARGET) $@


$(UBOOT_TARGET): $(UBOOT_CONFIG_PATH) $(UBOOT_DTS_PATH)
	$(MAKE) -C u-boot-xlnx ARCH=arm $(notdir $(UBOOT_CONFIG))
	$(MAKE) -C u-boot-xlnx ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) UBOOTVERSION="Custom U-Boot"

# Copy the config into the u-boot tree.
$(UBOOT_CONFIG_PATH): $(UBOOT_CONFIG)
	cp $? $@

# Copy the device tree into the u-boot tree.
$(UBOOT_DTS_PATH): $(DTS)
	cp $? $@

$(UBOOT_CONFIG):

#### linux #########
linux: build/$(notdir $(LINUX_TARGET))

build/$(notdir $(LINUX_TARGET)): $(LINUX_TARGET) | build
	cp $(LINUX_TARGET) $@

$(LINUX_TARGET): $(LINUX_CONFIG_PATH)
	$(MAKE) -C linux ARCH=arm $(notdir $(LINUX_CONFIG))
	$(MAKE) -C linux -j4 ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) zImage UIMAGE_LOADADDR=0x8000 | tee make.out

# Copy the config into the linux tree.
$(LINUX_CONFIG_PATH): $(LINUX_CONFIG)
	cp $? $@

# Copy the device tree into the u-boot tree.
$(LINUX_DTS_PATH): $(DTS)
	cp $? $@

$(LINUX_CONFIG):

# Buildroot ########
buildroot: build/$(notdir $(BR_TARGET))

build/$(notdir $(BR_TARGET)): $(BR_TARGET) | build
	cp -f $(BR_TARGET) $@

$(BR_TARGET): $(BR_CONFIG)
	#$(MAKE) -C buildroot BR2_EXTERNAL=configs/buildroot/external menuconfig
	$(MAKE) -C buildroot BR2_EXTERNAL=$(CURDIR)/configs/buildroot/external ARCH=arm zynq_pluto_defconfig
	$(MAKE) -C buildroot TOOLCHAIN_EXTERNAL_INSTALL_DIR=$(BR_TOOLCHAIN) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) \
		BUSYBOX_CONFIG_FILE=$(CURDIR)/configs/buildroot/busybox-1.25.0.config all

$(BR_CONFIG):

# Helpers
umenuconfig:
	$(MAKE) -C u-boot-xlnx menuconfig

lmenuconfig:
	$(MAKE) -C linux menuconfig

images:
	mkimage -n 'Ramdisk Image' -A arm -O linux -T ramdisk -C gzip -d build/rootfs.cpio.gz build/initramfs.ub 
	mkimage -n 'Kernel Image' -A arm -O linux -C none -T kernel -a 0x8000 -e 0x8000 -d build/zImage build/uImage

uclean:
	$(MAKE) -C u-boot-xlnx distclean
lclean:
	$(MAKE) -C linux distclean
bclean:
	$(MAKE) -C buildroot distclean

clean: uclean lclean bclean
	rm -rf build/
