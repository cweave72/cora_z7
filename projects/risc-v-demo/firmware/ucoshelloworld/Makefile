CROSS_COMPILE = riscv32-unknown-elf-

TARGET=ucoshelloworld

TARGET_ELF = $(CURDIR)/build/$(TARGET).elf
TARGET_BIN = $(CURDIR)/build/$(TARGET).bin
TARGET_MAP = $(CURDIR)/build/$(TARGET).map
TARGET_TXT = $(CURDIR)/build/$(TARGET).txt

UCOS := $(CURDIR)/../risc-v/ucos
UCOS_LIBPATH := $(UCOS)/build
UCOS_CFG_INCLUDE_PATH := $(CURDIR)/pubinc

RV32_PERIPH := $(CURDIR)/../risc-v/periph
RV32_LIB := $(CURDIR)/../risc-v/lib
MK_ROM_PKG := $(CURDIR)/../../../../components/RV32/python/make_rom/make_rom.py

TIMER_NUM_PWM_OUTPUTS ?= 6

SRC := \
	$(CURDIR)/start.s \
	$(CURDIR)/init.c \
	$(RV32_PERIPH)/debug_print/src/debug.c \
	$(RV32_PERIPH)/debug_print/src/printf.c \
	$(RV32_PERIPH)/timer/src/timer.c \
	$(RV32_PERIPH)/irqctlr/src/irqctlr.c \
	$(RV32_PERIPH)/stream/src/stream.c \
	$(RV32_LIB)/rgb/src/rgb.c \
	$(CURDIR)/src/tasks.c \
	$(CURDIR)/src/main.c

INC = \
	-I $(RV32_PERIPH)/debug_print/pubinc \
	-I $(RV32_PERIPH)/timer/pubinc \
	-I $(RV32_PERIPH)/stream/pubinc \
	-I $(RV32_PERIPH)/irqctlr/pubinc \
	-I $(RV32_LIB)/rgb/pubinc \
	-I $(UCOS)/core/src \
	-I $(UCOS)/port/src \
	-I $(CURDIR)/pubinc

DEFINES = \
	-DROM_TOTAL=65536 \
	-DRAM_TOTAL=16384 \
	-DPRINTF_DISABLE_SUPPORT_FLOAT \
	-DPRINTF_DISABLE_SUPPORT_EXPONENTIAL \
	-DPRINTF_DISABLE_SUPPORT_LONG_LONG \
	-DPRINTF_DISABLE_SUPPORT_PTRDIFF_T \
	-DTIMER_NUM_PWM_OUTPUTS=$(TIMER_NUM_PWM_OUTPUTS) \
	$(if $(OS_TICKS_PER_SEC),-DOS_TICKS_PER_SEC=$(OS_TICKS_PER_SEC),) \

define getObj
$(addsuffix .o, $(addprefix build/, $(notdir $(basename $(1)))))
endef

OBJS := $(call getObj, $(SRC))

#$(info "OBJS = $(OBJS)")

CFLAGS := -march=rv32im -ffreestanding -nostdlib -O2 -g
CPPFLAGS :=
LDFLAGS := -Wl,-Bstatic,-T,build/linker_sections.lds,--strip-debug,--print-map > $(TARGET_MAP)
LDLIBS := -lgcc -lucos
LIBPATHS := -L$(UCOS_LIBPATH)

.PHONY: all ucos ucos_clean clean

all: $(TARGET_BIN)

build:
	@mkdir $@

define build_objs
$$(call getObj, $(1)): $(1)
	$$(CROSS_COMPILE)gcc $$(CFLAGS) $$(CPPFLAGS) $$(DEFINES) $$(INC) -c -o $$@ $$<
endef

# Create rules to create objs from sources.
$(foreach s, $(SRC), $(eval $(call build_objs, $(s))))

# Run linker script through C preprocessor.
build/linker_sections.lds: sections.lds | build
	$(CROSS_COMPILE)cpp -P $(DEFINES) -o $@ $^

$(TARGET_ELF): build/linker_sections.lds ucos ${OBJS}
	$(CROSS_COMPILE)gcc $(CFLAGS) $(LDFLAGS) $(DEFINES) $(INC) $(LIBPATHS) \
		-o $@ ${OBJS} $(LDLIBS)

$(TARGET_BIN): $(TARGET_ELF)
	$(CROSS_COMPILE)objcopy -O binary $(TARGET_ELF) $@
	$(CROSS_COMPILE)objdump -x -d -r -S -t $(TARGET_ELF) > $(TARGET_TXT)
	@python3 $(MK_ROM_PKG) $@ -o build/Rom_Init_P.vhd

ucos:
	$(MAKE) -C $(UCOS) OS_CFG_INCLUDE_PATH=$(UCOS_CFG_INCLUDE_PATH) \
		OS_TICKS_PER_SEC=$(OS_TICKS_PER_SEC) all

clean: ucos_clean
	@rm -rf build

ucos_clean:
	$(MAKE) -C $(UCOS) clean
