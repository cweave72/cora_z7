VIVADO_VERSION ?= 2018.2
VIVADO := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/vivado
SDK := /opt/Xilinx/SDK/$(VIVADO_VERSION)/bin/xsdk
XSDB := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/xsdb

TARGET = build/System_top.hdf
IP_DIR = vhdl/ip

SCRIPTS = $(CURDIR)/../../../vivado_scripts
PROJ_DIR = $(CURDIR)/proj
BUILD_DIR = $(CURDIR)/build

ROM_INIT_FILE ?= $(CURDIR)/../firmware/ucoshelloworld/build/Rom_Init_P.vhd

.PHONY: all proj synth par ip gui clean help

all: $(TARGET)

help:
	@echo "Targets supported:"
	@echo "    all   : Creates all output products (ip, bitstream). Use clean first to re-create project file."
	@echo "    proj  : Cleans and re-creates project file only."
	@echo "    synth : Runs (or re-runs) synthesis step only."
	@echo "    par   : Runs (or re-runs) place-and-route step only (creates bitstream)."
	@echo "    ip    : Generates ip products only (in $(IP_DIR) directory)."
	@echo "    gui   : Launches the Vivado gui with the current project file."
	@echo "    clean : Cleans all generated products (in the build/ directory)."

build:
	@mkdir -p $@

$(TARGET): ip | build
	@echo "Building PL design."
	(PROJ_DIR=$(PROJ_DIR) \
	 BUILD_DIR=$(BUILD_DIR) \
	 ROM_INIT_FILE=$(ROM_INIT_FILE) \
	 $(VIVADO) -mode batch -notrace -source $(SCRIPTS)/run_vivado.tcl -tclargs all)
	unzip -o -d build/ $@

# make proj (to create a new project only)
proj: clean ip | build 
	@echo "Cleaning and creating new project."
	(PROJ_DIR=$(PROJ_DIR) \
	 BUILD_DIR=$(BUILD_DIR) \
	 ROM_INIT_FILE=$(ROM_INIT_FILE) \
	 $(VIVADO) -mode batch -notrace -source $(SCRIPTS)/run_vivado.tcl -tclargs $@)

# Rules for incremental development
# make synth (to synthesize design only)
# make par (to synthesize (if necessary) and implement to bitstream)
synth: $(ROM_INIT_FILE) | build
	(PROJ_DIR=$(PROJ_DIR) \
	 BUILD_DIR=$(BUILD_DIR) \
	 ROM_INIT_FILE=$(ROM_INIT_FILE) \
	 $(VIVADO) -mode batch -notrace -source $(SCRIPTS)/run_vivado.tcl -tclargs $@)

par: | build
	(PROJ_DIR=$(PROJ_DIR) \
	 BUILD_DIR=$(BUILD_DIR) \
	 ROM_INIT_FILE=$(ROM_INIT_FILE) \
	 $(VIVADO) -mode batch -notrace -source $(SCRIPTS)/run_vivado.tcl -tclargs $@)
	unzip -o -d build/ $(TARGET)

ip:
	$(MAKE) -C $(IP_DIR)

gui:
	$(VIVADO) build/project_1.xpr

clean:
	$(MAKE) -C $(IP_DIR) clean
	rm -rf build/ NA/
	rm -f vivado*
