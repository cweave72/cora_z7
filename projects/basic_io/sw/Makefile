CROSS_COMPILE = arm-none-eabi-

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

BSP_HW := build/bsp/hw_0
PS7_INIT_SRC := $(BSP_HW)/ps7_init.c
PS7_INIT_OBJ := $(addsuffix .o, $(addprefix build/$(APP)/, $(notdir $(basename $(PS7_INIT_SRC)))))

BSPFLAG := build/bsp/done.flag

#$(info SRCS = "$(SRCS)")
#$(info HDRS = "$(HDRS)")
#$(info OBJS = "$(OBJS)")

all: build/$(PROG)

clean:
	rm -rf build/

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
	xsdk -batch $(<) tee $(@D)/bsp.log 2>&1
	touch $@

bsp: $(BSPFLAG)
.PHONY: bsp

gui:
	xsdk -workspace build/bsp -wait
.PHONY: gui
