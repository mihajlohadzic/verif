#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/interrupt.h>
#include <linux/irq.h>
#include <linux/platform_device.h>
#include <asm/io.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/io.h>

#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>

#include <linux/version.h>
#include <linux/types.h>
#include <linux/kdev_t.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>
#include <linux/delay.h>

MODULE_AUTHOR("y22-g04");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Driver for Laplas algorithm");
MODULE_ALIAS("custom:laplas");

#define DEVICE_NAME "laplas"
#define DRIVER_NAME "laplas" 

//adresses for register
#define BRAM1 0x200
#define BRAM2 0x400
#define BRAM3 0x800

//***********************************************
static int laplas_probe(struct platform_device *pdev);
static int laplas_open(struct inode *i, struct file *f);
static int laplas_close(struct inode *i, struct file *f);
static ssize_t laplas_read(struct file *f, char __user *buf, size_t len, loff_t *off);
static ssize_t laplas_write(struct file *f, const char __user *buf, size_t count, loff_t *off);
static int __init laplas_init(void);
static void __exit laplas_exit(void);
static int laplas_remove(struct platform_device *pdev);

int tmp1_cols, tmp1_rows, img_cols;
int ready, sum2;

//**************GLOBAL VARIABLES****************  
static struct file_operations my_fops =
{
	
	.owner = THIS_MODULE,
	.open = laplas_open,
	.release = laplas_close,
	.read = laplas_read,
	.write = laplas_write
};

static struct of_device_id device_of_match[] = {
	{ .compatible = "xlnx,laplas", },
	
	{ /* end of list */ },
};

static struct platform_driver my_driver = {
	.driver = {
	.name = DRIVER_NAME,
	.owner = THIS_MODULE,
	.of_match_table = device_of_match,
	},
	.probe = laplas_probe,
	.remove = laplas_remove,
};

struct device_info {
	unsigned long mem_start;
	unsigned long mem_end;
	void __iomem *base_addr;
};

static struct device_info *laplas = NULL;
/*static struct device_info *bram_img = NULL;
static struct device_info *bram_tmpl = NULL;
static struct device_info *bram_resp = NULL;
static struct device_info *bram_sum1 = NULL;
*/
MODULE_DEVICE_TABLE(of, device_of_match);

static dev_t my_dev_id;
static struct class *my_class;
static struct cdev *my_cdev;
static struct device *my_device;

//***********************************************
// PROBE AND REMOVE
//***********************************************

int device_fsm = 0;

static int laplas_probe(struct platform_device *pdev)
{
    struct resource *r_mem;
    int rc = 0;

    printk(KERN_INFO "Probing\n");

    r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!r_mem) {
	printk(KERN_ALERT "invalid address\n");
	return -ENODEV;
    }

	
		  laplas = (struct device_info *) kmalloc(sizeof(struct device_info), GFP_KERNEL);
		  if (!laplas)
			{
			  printk(KERN_ALERT "Cound not allocate laplas device\n");
			  return -ENOMEM;
			}
		  laplas->mem_start = r_mem->start;
		  laplas->mem_end   = r_mem->end;
		  if(!request_mem_region(laplas->mem_start, laplas->mem_end - laplas->mem_start+1, DRIVER_NAME))
			{
			  printk(KERN_ALERT "Couldn't lock memory region at %p\n",(void *)laplas->mem_start);
			  rc = -EBUSY;
			  goto error1;
			}
		  laplas->base_addr = ioremap(laplas->mem_start, laplas->mem_end - laplas->mem_start + 1);
		  if (!laplas->base_addr)
			{
			  printk(KERN_ALERT "[PROBE]: Could not allocate laplas iomem\n");
			  rc = -EIO;
			  goto error2;
			}
		  ++device_fsm;
		  printk(KERN_INFO "[PROBE]: Finished probing laplas.\n");
		  return 0;
		  error2:
			release_mem_region(laplas->mem_start, laplas->mem_end - laplas->mem_start + 1);
		  error1:
			return rc;
		

	
}		
static int laplas_remove(struct platform_device *pdev)
{
 
      printk(KERN_ALERT "laplas device platform driver removed\n");
      iowrite32(0, laplas->base_addr);
      iounmap(laplas->base_addr);
      release_mem_region(laplas->mem_start, (laplas->mem_end - laplas->mem_start + 1));
      kfree(laplas);
      
      return 0;
     
  printk(KERN_INFO "Succesfully removed driver\n");
  
}	


//***********************************************
// OPEN & CLOSE 
//***********************************************

static int laplas_open(struct inode *i, struct file *f)
{
	
	return 0;
}	

static int laplas_close(struct inode *i, struct file *f)
{
	return 0;
}


//***************************************************
// READ & WRITE
//***************************************************
unsigned int width = 0; 
unsigned int height = 0;
unsigned int l1 = 0;
unsigned int border1 = 0;
unsigned int start1 = 0;
unsigned int start2 = 0;

#define BUFF_SIZE 800
int end_read = 0;
int i = 0;
int j = 0;

ssize_t laplas_read(struct file *pfile, char __user *buffer, size_t length, loff_t *offset)
{
	char buff[BUFF_SIZE];
	
	int val;
	int addr;
	int i;
	for (i = 0; i < 256; i ++)
	{
		val = ioread32(laplas -> base_addr + BRAM3 + i);
		if (val == 255)
		{
			addr =	scnprintf(buff, BUFF_SIZE, "%d\n",BRAM3 + i);
			copy_to_user(buffer, buff, addr);
		}
	}	
	return 0;
};


////*******WRITEEE

ssize_t laplas_write(struct file *pfile, const char __user *buffer, size_t length, loff_t *offset) 
{
	char buff[BUFF_SIZE];
	int val1 = 0;
	int val2 = 0;

	copy_from_user(buff, buffer, length);

	sscanf(buff, "%u, %u, %u, %u", &width, &height, &border1, &l1);
	printk(KERN_INFO "[WRITE] %u, %u, %u, %u \n", width, height, border1 ,l1);
	iowrite32(width, laplas->base_addr + 0);
	iowrite32(height, laplas->base_addr + 4);
	iowrite32(border1, laplas->base_addr + 8);
	iowrite32(l1, laplas->base_addr + 12);

	//iowrite32(start1, di->base_addr + 16);
	//iowrite32(start2, di->base_addr + 20);
	
	//Write in BRAM1 and BRAM2

	sscanf(buff, "%d", &val1);
	//trebalo bi da upise sliku
	for (i = 0; i < 256; i++)
	{
		iowrite32(val1, laplas->base_addr + BRAM1 + i);
	}
	sscanf(buff, "%d", &val2);
	//trebalo bi da upise masku
	for (i = 0; i < 25; i++)
	{
		iowrite32(val2, laplas->base_addr + BRAM2 + i);
	}
	//start laplas
	iowrite32(1, laplas->base_addr + 16);
	udelay(1000);
	iowrite32(0, laplas->base_addr + 16);

	while(!ioread32(laplas->base_addr+24))
		udelay(1000);
	//start zero crossing
	iowrite32(1, laplas->base_addr + 20);
	udelay(1000);
	iowrite32(0, laplas->base_addr + 20);
	while(!ioread32(laplas->base_addr+24))
		udelay(1000);
		
	return 0;
};

//***************************************************
// INIT & EXIT
//***************************************************


static int __init laplas_init(void)
{
	int ret = 0;
	printk(KERN_INFO "\n");
	printk(KERN_INFO "Laplas driver starting insmod. \n");

	ret = alloc_chrdev_region(&my_dev_id,0,1, DRIVER_NAME);
	if(ret){
		printk(KERN_ERR "failed to register char device\n");
        return ret;
	}
	printk(KERN_INFO "char device region allocated\n");
	my_class = class_create(THIS_MODULE, "laplas_class");
	if(my_class == NULL)
	{
		printk(KERN_ERR "failed to create class\n");
        goto fail_0;
	}
	printk (KERN_INFO "Class created");

   my_device = device_create(my_class, NULL, my_dev_id, NULL, DRIVER_NAME);
   if (my_device == NULL){
      printk(KERN_ERR "failed to create device\n");
      goto fail_1;
   }
   printk(KERN_INFO "device created\n");

   my_cdev = cdev_alloc();
   my_cdev->ops = &my_fops;
   my_cdev->owner = THIS_MODULE;
   ret = cdev_add(my_cdev, my_dev_id, 1);
   if(ret)
   {
		printk(KERN_ERR "failed to add cdev\n");
		goto fail_2;
   }

	printk(KERN_INFO "cdev added\n");
    printk(KERN_INFO "Laplas driver\n");

	return platform_driver_register(&my_driver);
	
    fail_2:
     device_destroy(my_class, my_dev_id);
    fail_1:
      class_destroy(my_class);
    fail_0:
      unregister_chrdev_region(my_dev_id, 1);

	  return -1;
}




static void __exit laplas_exit(void)
{
  printk(KERN_INFO "laplas driver starting rmmod.\n");
	platform_driver_unregister(&my_driver);
	cdev_del(my_cdev);
  
  device_destroy(my_class, MKDEV(MAJOR(my_dev_id),4));  
  device_destroy(my_class, MKDEV(MAJOR(my_dev_id),3));	
  device_destroy(my_class, MKDEV(MAJOR(my_dev_id),2));
  device_destroy(my_class, MKDEV(MAJOR(my_dev_id),1));
  device_destroy(my_class, MKDEV(MAJOR(my_dev_id),0));
  class_destroy(my_class);
  unregister_chrdev_region(my_dev_id,1);
  printk(KERN_INFO "laplas driver exited.\n");
}

module_init(laplas_init);
module_exit(laplas_exit);



