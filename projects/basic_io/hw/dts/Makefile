DTC = dtc
DTC_FLAGS = -@ -H epapr -R 8 -p 0x3000 -b 0

DTS = system-top.dts
DTBS = $(addsuffix .dtb, $(basename $(DTS)))

all: clean $(DTBS)

%.dtb: %.dts
	$(DTC) $(DTC_FLAGS) -I dts -O dtb -o $@ $<

clean:
	rm -f $(DTBS)
