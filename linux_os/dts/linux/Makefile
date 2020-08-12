DTC = dtc
DTC_FLAGS = -@ -H epapr -R 8 -p 0x3000 -b 0

DTS = zynq-cora-z7-10.dts
DTBS = $(DTS:.dts=.dtb)

.PHONY: all
all: clean $(DTBS)

%.dtb: %.dts
	$(DTC) $(DTC_FLAGS) -I dts -O dtb -o $@ $<

.PHONY: clean
clean:
	rm -f $(DTBS)
