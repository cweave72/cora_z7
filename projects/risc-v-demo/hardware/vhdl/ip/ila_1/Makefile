VIVADO_VERSION ?= 2018.2
VIVADO := /opt/Xilinx/Vivado/$(VIVADO_VERSION)/bin/vivado

IP_NAME = ila_1

.PHONY: all
all: $(IP_NAME).xci

$(IP_NAME).xci: ila_1.tcl config.yaml
	@echo "Building IP: $@"
	$(VIVADO) -mode batch -notrace -source $<

.PHONY: clean
clean:
	@rm -rf $(IP_NAME)/
	@rm -f vivado*
