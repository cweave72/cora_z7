VIVADO_VERSION ?= 2018.2
SDK := /opt/Xilinx/SDK/$(VIVADO_VERSION)/bin/xsdk
XSDB := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/xsdb

CROSS_COMPILE = arm-none-eabi-

DEVICE_TREE_XLNX_PATH := ../../../linux_os/device-tree-xlnx
VIVADO_SCRIPTS=../../../vivado_scripts

PROC = ps7_cortexa9_0

CC=$(CROSS_COMPILE)gcc
AR=$(CROSS_COMPILE)ar
CFLAGS := -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard
CPPFLAGS := -Wall -fmessage-length=0
LDFLAGS := -Wl,-build-id=none -specs bsp/Xilinx.spec -Wl,-T

CPPFLAGS += \
	-I build/bsp/bsp_0/$(PROC)/include/ \
	-I build/bsp/hw_0/ \
	-DFSBL_DEBUG_INFO

LDFLAGS += \
	-L build/bsp/bsp_0/$(PROC)/lib/ \

LDLIBS += -Wl,--start-group,-lxil,-lxilffs,-lgcc,-lc,--end-group

APP := fsbl
SRCS := $(wildcard $(APP)/src/*.c)
HDRS := $(wildcard $(APP)/src/*.h)
OBJS := $(addsuffix .o, $(addprefix build/$(APP)/, $(notdir $(basename $(SRCS)))))
S_SRCS := $(wildcard $(APP)/src/*.S)
S_OBJS := $(addsuffix .o, $(addprefix build/$(APP)/, $(notdir $(basename $(S_SRCS)))))
PROG := $(APP).elf
LDSCRIPT := $(APP)/src/lscript.ld

# Hardware definition file resulting from vivado build
HWDEF := ../hardware/build/System_top.hdf

DTS_USER = dts/system-user.dtsi
DTS = build/dts/system-top.dts
DTB = $(DTS:.dts=.dtb)

BSP_HW := build/bsp/hw_0
PS7_INIT_SRC := $(BSP_HW)/ps7_init.c
PS7_INIT_OBJ := $(addsuffix .o, $(addprefix build/$(APP)/, $(notdir $(basename $(PS7_INIT_SRC)))))

BSPFLAG := build/bsp/done.flag

#$(info SRCS = "$(SRCS)")
#$(info HDRS = "$(HDRS)")
#$(info OBJS = "$(OBJS)")

all: build/$(PROG) dtb kmod

clean:
	rm -rf build/
	$(MAKE) -C kmod clean

build:
	mkdir -p $@

build/$(APP)/%.o: $(APP)/src/%.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(S_OBJS): $(S_SRCS)
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(PS7_INIT_OBJ): $(PS7_INIT_SRC)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

build/$(PROG): $(BSPFLAG) $(OBJS) $(S_OBJS) $(PS7_INIT_OBJ) $(LDSCRIPT) $(HDRS) | build
	$(CC) $(CFLAGS) $(LDFLAGS) -Wl,$(LDSCRIPT) -o $@ $(OBJS) $(S_OBJS) $(PS7_INIT_OBJ) $(LDLIBS)

$(BSPFLAG): bsp/create_bsp.tcl | build
	rm -rf $(@D)
	mkdir -p $(@D)
	@HWDEF=$(CURDIR)/$(HWDEF) xsdk -batch $(<) tee $(@D)/bsp.log 2>&1
	touch $@

bsp: $(BSPFLAG)
.PHONY: bsp

dtb: $(DTB)
.PHONY: dtb

$(DTB): $(DTS)
	@DTS=$(CURDIR)/$(DTS) $(MAKE) -C dts

$(DTS): $(HWDEF) $(DTS_USER)
	@(HWDEF_PATH=$(CURDIR)/$(HWDEF) \
	  DEVICE_TREE_XLNX_PATH=$(CURDIR)/$(DEVICE_TREE_XLNX_PATH) \
	  OUTDIR_PATH=$(CURDIR)/build/dts \
	  $(SDK) -batch -source $(VIVADO_SCRIPTS)/generate_device_tree.tcl | tee dts.log)
	cp $(DTS_USER) build/dts/
	@echo "Patching dts file to include system-user.dtsi."
	@sed -i '/^\/include\/ "pcw.dtsi"/a \/include\/ "system-user.dtsi"' $@

.PHONY: kmod
kmod:
	$(MAKE) -C kmod

gui:
	xsdk -workspace build/bsp -wait
.PHONY: gui
