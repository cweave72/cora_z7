CROSS_COMPILE = arm-linux-gnueabihf-
KERNEL_SRC = $(CURDIR)/../../../../../linux_os/linux-xlnx

obj-m = rv32_axi.o

all:
	$(MAKE) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNEL_SRC) M=$(CURDIR)

clean:
	$(MAKE) -C $(KERNEL_SRC) M=$(CURDIR) clean
