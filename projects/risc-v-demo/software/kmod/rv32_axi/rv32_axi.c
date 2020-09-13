/*******************************************************************************
*//** @file rv32_axidrv-1.0.c

    @brief Kernel driver for booting RV32 core.
*******************************************************************************/
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/uaccess.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/of_device.h>
#include <linux/platform_device.h>
#include <linux/cdev.h>
#include <linux/slab.h>
#include <linux/dma-mapping.h>
#include <linux/string.h>

#define SUCCESS             0
#define MODULE_NAME         "rv32_axi"
#define MEM_LENGTH(nregs)   ((nregs)*4)

#define CORE_RESET      1
#define CORE_RELEASE    0
#define REGISTER_PAGE_SIZE      0x10000

static int deviceOpen = 0;

static struct device *dev;
static dev_t dev_num;       // Global variable for the device number
static struct cdev c_dev;   // Global variable for the character device structure
static struct class *cl;    // Global variable for the device class
struct resource *res;       // Device Resource Structure

static char *axi_vaddr;
static char *ctrlreg_addr;
static char *imem_addr;
static unsigned int imem_size;
static unsigned int kbuf[1024];
static unsigned int currentWrOffset;
static unsigned int currentRdOffset;

/* File operations */

static int dev_open(struct inode *i, struct file *f)
{
    if (deviceOpen)
        return -EBUSY;

    currentWrOffset = 0;
    currentRdOffset = 0;

    iowrite32(CORE_RESET, ctrlreg_addr);

    deviceOpen++;
    return SUCCESS;
}

static int dev_close(struct inode *i, struct file *f)
{
    deviceOpen--;
    iowrite32(CORE_RELEASE, ctrlreg_addr);
    return SUCCESS;
}

static ssize_t dev_write(struct file *f, const char __user *buf, size_t size,
    loff_t *offset)
{
    unsigned int residual = size % 4;
    unsigned int numWords;
    ssize_t len;
    unsigned int i;

    if (residual != 0)
    {
        printk(KERN_ERR "Number to write must be a multiple of 4 (%u)\n.", len);
        return -EINVAL;
    }

    len = min(sizeof(kbuf), size);
    numWords = len/4;
    //printk(KERN_INFO "size=%u; numwords=%u\n", size, numWords);

    /* Copy data from user-space to kernel buffer. */
    if (copy_from_user(kbuf, buf, len) < 0)
    {
        printk(KERN_ERR "Error copying data from userspace\n");
        return -EFAULT;
    }

    /* Write kbuf to axi bus at imem address. */
    for (i=0; i<numWords; i++)
    {
        iowrite32(kbuf[i], imem_addr + currentWrOffset);
        currentWrOffset += 4;
    }

    *offset += len;
    return len;
}

static ssize_t dev_read(struct file *f, char __user *buf, size_t size, 
    loff_t *offset)
{
    return 0;
}

static struct file_operations fops = {
    .owner = THIS_MODULE,
    .open = dev_open,
    .release = dev_close,
    .read = dev_read,
    .write = dev_write,
};

// device match table to match with device node in device tree
static struct of_device_id rv32_axi_of_match[] = {
    { .compatible = "xlnx,rv32_axi", },
    {},
};
MODULE_DEVICE_TABLE(of, rv32_axi_of_match);

/*******************************************************************************
*//**   rv32_axi_probe

    @brief Probe function for device.
*******************************************************************************/
static int rv32_axi_probe(struct platform_device *pdev)
{
    struct device_node *np = pdev->dev.of_node;
    void *prop;

    res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!res) 
    {
        dev_err(&pdev->dev, "No memory resource\n");
        return -ENODEV;
    }

    ctrlreg_addr = (char *)res->start;
    imem_addr = (char *)(res->start + REGISTER_PAGE_SIZE);

    prop = of_get_property(np, "xlnx,imem_size", NULL);
    if (!prop)
    {
        dev_err(&pdev->dev, "Couldn't get property numregs.\n");
        return -EINVAL;
    }
    imem_size = be32_to_cpup(prop);
    printk(KERN_INFO "Instruction memory size = %u\n", imem_size);
    
    if (!request_mem_region(res->start, REGISTER_PAGE_SIZE + imem_size, pdev->name)) 
    {
        dev_err(&pdev->dev, "Cannot request IO\n");
        return -ENXIO;
    }

    // device constructor:
    printk(KERN_INFO "<%s> init: registered\n", MODULE_NAME);
    if (alloc_chrdev_region(&dev_num, 0, 1, MODULE_NAME) < 0) 
    {
        return -1;
    }

    if ((cl = class_create(THIS_MODULE, MODULE_NAME)) == NULL) 
    {
        unregister_chrdev_region(dev_num, 1);
        return -1;
    }

    if ((dev = device_create(cl, NULL, dev_num, NULL, MODULE_NAME)) == NULL) 
    {
        class_destroy(cl);
        unregister_chrdev_region(dev_num, 1);
        return -1;
    }

    cdev_init(&c_dev, &fops);

    if (cdev_add(&c_dev, dev_num, 1) == -1) 
    {
        device_destroy(cl, dev_num);
        class_destroy(cl);
        unregister_chrdev_region(dev_num, 1);
        return -1;
    }

#if 0
    /* Create attribute file. */
    if (device_create_file(dev, &dev_attr_reg0_wr) < 0)
    {
        printk(KERN_ALERT "Attribute device creation failed (reg0_wr).\n");
    }
    if (device_create_file(dev, &dev_attr_reg0_rd) < 0)
    {
        printk(KERN_ALERT "Attribute device creation failed (reg0_rd).\n");
    }
#endif

    // allocate mmap area:
    axi_vaddr = ioremap_nocache(res->start, REGISTER_PAGE_SIZE + imem_size);
    if (!axi_vaddr) 
    {
        printk(KERN_ERR "<%s> Error: allocating memory failed\n", MODULE_NAME);
        return -ENOMEM;
    }

    ctrlreg_addr = axi_vaddr;
    imem_addr = axi_vaddr + REGISTER_PAGE_SIZE;

    printk(KERN_INFO "Mapped physical memory 0x%08x to virtual memory 0x%p\n", 
        res->start, axi_vaddr);
    printk(KERN_INFO "imem address @ 0x%p\n", imem_addr);

    return 0;
}

static int rv32_axi_remove(struct platform_device *pdev)
{
    // device destructor:
    cdev_del(&c_dev);
    //device_remove_file(dev, &dev_attr_reg0_wr);
    //device_remove_file(dev, &dev_attr_reg0_rd);
    device_destroy(cl, dev_num);
    class_destroy(cl);
    unregister_chrdev_region(dev_num, 1);
    printk(KERN_INFO "<%s> exit: unregistered\n", MODULE_NAME);

    // free mmap area:
    if (axi_vaddr) {
        iounmap(axi_vaddr);
    }
    
    // Release the region:
    release_mem_region(res->start, REGISTER_PAGE_SIZE + imem_size);
    
    return 0;
}

// platform driver structure for driver:
static struct platform_driver rv32_axi_driver = {
    .driver = {
           .name = MODULE_NAME,
           .owner = THIS_MODULE,
           .of_match_table = rv32_axi_of_match},
    .probe = rv32_axi_probe,
    .remove = rv32_axi_remove,
};

// Register platform driver:
module_platform_driver(rv32_axi_driver);

MODULE_AUTHOR("cdw");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION(MODULE_NAME "rv32_axi");
MODULE_ALIAS(MODULE_NAME);
