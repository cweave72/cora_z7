CURDIR = $(shell pwd)

UBOOT_DTS = dts/u-boot/zynq-cora-z7-10.dts
UBOOT_CONFIG = configs/u-boot/cora_z7_10_defconfig
UBOOT_CONFIG_PATH = u-boot-xlnx/configs/$(notdir $(UBOOT_CONFIG))
UBOOT_DTS_PATH = u-boot-xlnx/arch/arm/dts/$(notdir $(UBOOT_DTS))
UBOOT_ELF = u-boot-xlnx/u-boot

LINUX_CONFIG = configs/kernel/cora_z7_10_defconfig
LINUX_CONFIG_PATH = linux-xlnx/arch/arm/configs/$(notdir $(LINUX_CONFIG))
ZIMAGE = linux-xlnx/arch/arm/boot/zImage

BR_CONFIG = configs/buildroot/external/configs/cora_z7_10_defconfig
BR_TOOLCHAIN = /opt/Xilinx/SDK/2018.2/gnu/aarch32/lin/gcc-arm-linux-gnueabi
BR_ROOTFS = buildroot/output/images/rootfs.cpio.gz

CROSS_COMPILE = arm-linux-gnueabihf-

UBOOT_TARGET = build/u-boot
LINUX_TARGET = build/zImage
BR_TARGET = build/rootfs.cpio.gz

.PHONY: all u-boot linux buildroot umenuconfig lmenuconfig images uclean lclean bclean clean help

# All targets
all: u-boot linux buildroot images

help:
	@echo "Targets:"
	@echo "	all         : Builds everything. Results in build/"
	@echo "	u-boot      : Builds the u-boot elf ($(UBOOT_TARGET))"
	@echo "	linux       : Builds linux kernel ($(LINUX_TARGET))."
	@echo "	buildroot   : Builds the rootfs ($(BR_TARGET))."
	@echo "	umenuconfig : Launch u-boot menuconfig."
	@echo "	lmenuconfig : Launch linux menuconfig."
	@echo "	bmenuconfig : Launch buildroot menuconfig."
	@echo "	uclean      : Clean u-boot."
	@echo "	lclean      : Clean linux."
	@echo "	bclean      : Clean buildroot."
	@echo "	clean       : Clean everything."

build:
	mkdir -p $@

#### u-boot #########
u-boot: $(UBOOT_TARGET)
	
$(UBOOT_TARGET): $(UBOOT_CONFIG_PATH) $(UBOOT_DTS_PATH) | build
	$(MAKE) -C u-boot-xlnx ARCH=arm $(notdir $(UBOOT_CONFIG))
	$(MAKE) -C u-boot-xlnx ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) UBOOTVERSION="Custom U-Boot"
	@cp $(UBOOT_ELF) $(@D)

# Copy the config into the u-boot tree.
$(UBOOT_CONFIG_PATH): $(UBOOT_CONFIG)
	cp $? $@

# Copy the device tree into the u-boot tree.
$(UBOOT_DTS_PATH): $(UBOOT_DTS)
	cp $? $@

$(UBOOT_CONFIG):

#### linux #########
linux: $(LINUX_TARGET)

$(LINUX_TARGET): $(LINUX_CONFIG_PATH) | build
	$(MAKE) -C linux-xlnx ARCH=arm $(notdir $(LINUX_CONFIG))
	$(MAKE) -C linux-xlnx -j4 ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) zImage UIMAGE_LOADADDR=0x8000 | tee make.out
	@cp -f $(ZIMAGE) $(@D)

# Copy the config into the linux tree.
$(LINUX_CONFIG_PATH): $(LINUX_CONFIG)
	cp $? $@

# Copy the device tree into the u-boot tree.
$(LINUX_DTS_PATH): $(DTS)
	cp $? $@

$(LINUX_CONFIG):

# Buildroot ########
buildroot: $(BR_TARGET)

$(BR_TARGET): $(BR_CONFIG)
	$(MAKE) -C buildroot BR2_EXTERNAL=$(CURDIR)/configs/buildroot/external ARCH=arm cora_z7_10_defconfig
	$(MAKE) -C buildroot TOOLCHAIN_EXTERNAL_INSTALL_DIR=$(BR_TOOLCHAIN) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE)
	@cp $(BR_ROOTFS) $(@D)

$(BR_CONFIG):

# Helpers
umenuconfig:
	$(MAKE) -C u-boot-xlnx menuconfig

lmenuconfig:
	$(MAKE) -C linux-xlnx menuconfig

bmenuconfig:
	$(MAKE) -C buildroot BR2_EXTERNAL=$(CURDIR)/configs/buildroot/external menuconfig

images:
	@echo "Creating Ramdisk and Kernel images for booting."
	@mkimage -n 'Ramdisk Image' -A arm -O linux -T ramdisk -C gzip -d build/rootfs.cpio.gz build/initramfs.ub 
	@mkimage -n 'Kernel Image' -A arm -O linux -C none -T kernel -a 0x8000 -e 0x8000 -d build/zImage build/uImage

uclean:
	$(MAKE) -C u-boot-xlnx distclean
lclean:
	$(MAKE) -C linux-xlnx distclean
bclean:
	$(MAKE) -C buildroot distclean

clean: uclean lclean bclean
	rm -rf build/
