
DIRS := \
	rv32_axi

.PHONY: all clean

all: 
	@(for d in $(DIRS); do \
		$(MAKE) -C $$d; \
	 done)

clean: 
	@(for d in $(DIRS); do \
		$(MAKE) -C $$d $@; \
	 done)
