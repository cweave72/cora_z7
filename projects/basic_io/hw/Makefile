VIVADO_VERSION ?= 2018.2
VIVADO := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/vivado
SDK := /opt/Xilinx/SDK/$(VIVADO_VERSION)/bin/xsdk
XSDB := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/xsdb

DEVICE_TREE_XLNX_PATH := ../../../submodules/device-tree-xlnx

TARGET = build/System_top.hdf
IP_DIR = vhdl/ip

DTS_TARGET = build/dts/system-top.dts
DTS_FILES = \
	pcw.dtsi \
	system-top.dts \
	zynq-7000.dtsi

IP_FLAG = $(IP_DIR)/done.flag

VIVADO_SCRIPTS=$(CURDIR)/../../../vivado_scripts
PROJ_DIR=$(CURDIR)/proj
BUILD_DIR=$(CURDIR)/build

JTAG_BOOT_SCRIPTS = $(CURDIR)/../../../linux_os/scripts
XILINX_HW_SERVER = 192.168.1.8 
#XILINX_HW_SERVER = localhost
FSBL_PATH = $(CURDIR)/../sw/build/fsbl.elf
UBOOT_PATH = $(CURDIR)/../../../linux_os/build/u-boot

export PROJ_DIR
export BUILD_DIR

.PHONY: all proj synth par ip dts gui boot clean help

all: $(TARGET) #dts

help:
	@echo "Targets supported:"
	@echo "    all   : Creates all output products (ip, bitstream, device-tree). Use clean first to re-create project file."
	@echo "    proj  : Cleans and re-creates project file only."
	@echo "    synth : Runs (or re-runs) synthesis step only."
	@echo "    par   : Runs (or re-runs) place-and-route step only (creates bitstream)."
	@echo "    dts   : Generates device-tree from hardware specification."
	@echo "    ip    : Generates ip products only (in $(IP_DIR) directory)."
	@echo "    gui   : Launches the Vivado gui with the current project file."
	@echo "    boot  : Boots design via jtag (see linux_os/scripts/jtagboot.tcl)."
	@echo "    clean : Cleans all generated products (in the build/ directory)."

build:
	@mkdir -p $@

$(TARGET): $(IP_FLAG) | build
	@echo "Building PL design."
	echo $(VIVADO) -mode batch -notrace -source $(VIVADO_SCRIPTS)/run_vivado.tcl -tclargs all
	unzip -o -d build/ $@

# make proj (to create a new project only)
proj: clean $(IP_FLAG) | build 
	@echo "Cleaning and creating new project."
	$(VIVADO) -mode batch -notrace -source $(VIVADO_SCRIPTS)/run_vivado.tcl -tclargs $@

# Rules for incremental development
# make synth (to synthesize design only)
# make par (to synthesize (if necessary) and implement to bitstream)
synth: | build
	$(VIVADO) -mode batch -notrace -source $(VIVADO_SCRIPTS)/run_vivado.tcl -tclargs $@

par: | build
	$(VIVADO) -mode batch -notrace -source $(VIVADO_SCRIPTS)/run_vivado.tcl -tclargs $@
	unzip -o -d build/ $(TARGET)

$(IP_FLAG):
	@echo $(MAKE) -C $(IP_DIR)
	touch $(IP_FLAG)

boot:
	@(HW_SERVER=$(XILINX_HW_SERVER) \
	  BITFILE=$(CURDIR)/$(TARGET:.hdf=.bit) \
	  FSBL=$(FSBL_PATH) \
	  UBOOT=$(UBOOT_PATH) \
	  $(XSDB) $(JTAG_BOOT_SCRIPTS)/jtagboot.tcl)

gui:
	$(VIVADO) build/project_1.xpr

dts: $(DTS_TARGET)

$(DTS_TARGET): $(TARGET)
	@(HWDEF_PATH=$(CURDIR)/$(TARGET) \
	  DEVICE_TREE_XLNX_PATH=$(CURDIR)/$(DEVICE_TREE_XLNX_PATH) \
	  OUTDIR_PATH=$(CURDIR)/build/dts \
	  $(SDK) -batch -source $(VIVADO_SCRIPTS)/generate_device_tree.tcl | tee dts.log)
	cp $(addprefix build/dts/, $(DTS_FILES)) dts/
	#@echo "Patching dts file to include system-user.dtsi."
	#@sed -i '/^\/include\/ "pcw.dtsi"/a \/include\/ "system-user.dtsi"' $@

clean:
	#$(MAKE) -C $(IP_DIR) clean
	rm -rf build/ NA/
	rm -f vivado*
