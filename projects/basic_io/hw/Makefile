VIVADO_VERSION ?= 2018.2
VIVADO := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/vivado
SDK := /opt/Xilinx/SDK/$(VIVADO_VERSION)/bin/xsdk
XSDB := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/xsdb

TARGET = build/System_top.hdf
IP_DIR = vhdl/ip

IP_FLAG = $(IP_DIR)/done.flag

SCRIPTS = $(CURDIR)/../../../vivado_scripts
PROJ_DIR = $(CURDIR)/proj
BUILD_DIR = $(CURDIR)/build

.PHONY: all proj synth par ip gui clean help

all: $(TARGET)

help:
	@echo "Targets supported:"
	@echo "    all   : Creates all output products (ip, bitstream, device-tree). Use clean first to re-create project file."
	@echo "    proj  : Cleans and re-creates project file only."
	@echo "    synth : Runs (or re-runs) synthesis step only."
	@echo "    par   : Runs (or re-runs) place-and-route step only (creates bitstream)."
	@echo "    ip    : Generates ip products only (in $(IP_DIR) directory)."
	@echo "    gui   : Launches the Vivado gui with the current project file."
	@echo "    clean : Cleans all generated products (in the build/ directory)."

build:
	@mkdir -p $@

$(TARGET): $(IP_FLAG) | build
	@echo "Building PL design."
	(PROJ_DIR=$(PROJ_DIR) \
	 BUILD_DIR=$(BUILD_DIR) \
	 $(VIVADO) -mode batch -notrace -source $(SCRIPTS)/run_vivado.tcl -tclargs all)
	unzip -o -d build/ $@

# make proj (to create a new project only)
proj: clean $(IP_FLAG) | build 
	@echo "Cleaning and creating new project."
	(PROJ_DIR=$(PROJ_DIR) \
	 BUILD_DIR=$(BUILD_DIR) \
	 $(VIVADO) -mode batch -notrace -source $(SCRIPTS)/run_vivado.tcl -tclargs $@)

# Rules for incremental development
# make synth (to synthesize design only)
# make par (to synthesize (if necessary) and implement to bitstream)
synth: | build
	(PROJ_DIR=$(PROJ_DIR) \
	 BUILD_DIR=$(BUILD_DIR) \
	 $(VIVADO) -mode batch -notrace -source $(SCRIPTS)/run_vivado.tcl -tclargs $@)

par: | build
	(PROJ_DIR=$(PROJ_DIR) \
	 BUILD_DIR=$(BUILD_DIR) \
	 $(VIVADO) -mode batch -notrace -source $(SCRIPTS)/run_vivado.tcl -tclargs $@)
	unzip -o -d build/ $(TARGET)

$(IP_FLAG):
	@echo $(MAKE) -C $(IP_DIR)
	touch $(IP_FLAG)

gui:
	$(VIVADO) build/project_1.xpr

clean:
	#$(MAKE) -C $(IP_DIR) clean
	rm -rf build/ NA/
	rm -f vivado*
