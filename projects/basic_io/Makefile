
.PHONY: all hw sw boot clean help

help:
	@echo "Targets supported:"
	@echo "    all   : Creates all products (fsbl, bitstream, device-tree). Use clean first to re-create all."
	@echo "    hw    : Builds the FPGA binaries."
	@echo "    sw    : Builds the software bsp and fsbl binaries."
	@echo "    boot  : Boots design via jtag (see hw/proj/jtagboot.tcl)."
	@echo "    clean : Cleans all generated products (in the hw/build and sw/build directories)."


all: hw sw

hw:
	$(MAKE) -C hw

sw:
	$(MAKE) -C sw

boot:
	$(MAKE) -C hw boot

clean:
	$(MAKE) -C hw clean
	$(MAKE) -C sw clean
