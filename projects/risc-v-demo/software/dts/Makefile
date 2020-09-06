DTC = dtc
DTC_FLAGS = -@ -H epapr -R 8 -p 0x3000 -b 0

DTS ?= system-top.dts
DTB = $(DTS:.dts=.dtb)

.PHONY: all
all: clean $(DTB)

#%.dtb: %.dts
$(DTB): $(DTS) system-user.dtsi
	$(DTC) $(DTC_FLAGS) -I dts -O dtb -o $@ $<

$(DTS):

.PHONY: clean
clean:
	rm -f $(DTB)
