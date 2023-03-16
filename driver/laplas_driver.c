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

MODULE_DESCRIPTION("Driver for Laplas algorithm");
MODULE_ALIAS("custom:laplas");
MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR ("laplas team");
#define DEVICE_NAME "laplas"
#define DRIVER_NAME "laplas"
#define BUFF_SIZE 900
#define MASK_SIZE 25
#define PICTURE_SIZE 100
//**GLOBAL VARIABLES**//

int pos;

int b = 0;
int endRead = 0;
int position;
int value;
int height = 0;
int width = 0;
int cnt_pos = 0; //mask counter
int cnt_pos1 = 0; // picture counter
int read_pos;
int start_stop;
int spix;

int mask[MASK_SIZE];        //INPUT MASK FROM APP
int mask1[5][5];            //INPUT MASK CONVERTED TO 2D ARRAY
int picture[PICTURE_SIZE];  //INPUT PICTURE FROM APP
int picturEv2[10][10];      //INPUT PICTURE CONVERTED TO 2D ARRAY
int newinp[10][10];         //RESULT OF LAPLAS
int im[10][10];             //RESULT OF ZERO CROSSING
int result[PICTURE_SIZE];   //OUTPUT RESULT

int max = 0;
int th = 0;
int finish = 0;
/*
int start_stop;
int test_for_read = 0;
int val=0;
int i = 0;
int j = 0;

*/

static int laplas_open(struct inode *i, struct file *pfile);
static int laplas_close(struct inode *i, struct file *pfile);
static ssize_t laplas_read(struct file *pfile, char __user *buffer, size_t length, loff_t *offset);
static ssize_t laplas_write(struct file *pfile, const char __user *buffer, size_t length, loff_t *offset) ;
static int __init laplas_init(void);
static void __exit laplas_exit(void);
static void laplas_hw(const int width, const int height, const int mask[], const int picture[]);


static struct file_operations my_fops =
{
    
    .owner = THIS_MODULE,
    .open = laplas_open,
    .read = laplas_read,
    .write = laplas_write,
    .release = laplas_close,
};

static dev_t my_dev_id;
static struct class *my_class;
static struct cdev *my_cdev;
static struct device *my_device;

static int __init laplas_init(void)
{
    
    int ret = 0;
   

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

    //CREATE IP MODULE
   my_device = device_create(my_class, NULL, my_dev_id, NULL, "xlnx,laplas");
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
    return 0;
    
    fail_2:
     device_destroy(my_class, my_dev_id);
    fail_1:
      class_destroy(my_class);
    fail_0:
      unregister_chrdev_region(my_dev_id, 1);

      return -1;
}

static int laplas_open(struct inode *i, struct file *pfile)
{
        printk(KERN_INFO "Succesfully opened file\n");

      return 0;
} 
static int laplas_close(struct inode *i, struct file *pfile)
{
    printk(KERN_INFO "Succesfully closed file\n");
    return 0;
}  

/**READ AND WRITE**/
ssize_t laplas_write(struct file *pfile, const char __user *buffer, size_t length, loff_t *offset) 
{
    printk(KERN_INFO "Welcome TO laplas_write\n");
    char buff[BUFF_SIZE];
    int ret;
    
    
    ret = copy_from_user(buff, buffer, length);
    if (ret)
        return -EFAULT;
    buff[length-1] = '\0';
    
    
    ret = sscanf(buff, "%d,%d,%d",&start_stop,&position, &value);
    if (start_stop == 0)
    {
            if (position == 0)
            {
                width = value;
                printk(KERN_INFO "width is := %d\n", width);

            }
            else if (position == 1)
            {
                height = value;
                printk(KERN_INFO "height is := %d\n", height);
            }
            else if (position >= 2 && position <= 26)
            {
                printk(KERN_INFO "cnt pos = %d\n",cnt_pos);
                mask[cnt_pos] = value;
                printk(KERN_INFO "mask  is := %d\n", mask[cnt_pos]);
                cnt_pos++;   
            }
            else if (position >=27 && position <= 126)
            {
                printk(KERN_INFO "cnt pos 1 = %d\n",cnt_pos1);
               picture[cnt_pos1] = value;
               printk(KERN_INFO "picture is := %d\n", picture[cnt_pos1]);
               cnt_pos1++;

            }
    }
    else if (start_stop == 1 && position == 0 && value == 0)
    {
        printk(KERN_INFO "Time to start LAPLAS HW !!\n \n");
        laplas_hw(width,height,mask,picture);
        finish = 1;
        printk(KERN_INFO "finish is = %d \n",finish);
    }
 
    return length;
};


static ssize_t laplas_read(struct file *pfile, char __user *buffer, size_t length, loff_t *offset)
{
    int ret;
    char buff[BUFF_SIZE];
    long int len = 0;
    printk(KERN_INFO "Welcome to LAPLAS_READ");
    if (endRead == 1)
    {
        endRead = 0;
        read_pos = 0;
        printk(KERN_INFO "Succesfully read from file\n");
    }
    
    len = scnprintf(buff, BUFF_SIZE, "%d ",result[read_pos]);
    printk(KERN_INFO "read pos is %d \n", read_pos);
    ret = copy_to_user(buffer, buff, len);
    if (ret)
    {
        return -EFAULT;    
    }
    read_pos++;
    printk(KERN_INFO "read pos is %d \n", read_pos);
    if (read_pos == width*height)
    {
        endRead = 1;
    }
    
    
    return len;
}


static void __exit laplas_exit(void)
{
  printk(KERN_INFO "laplas driver starting rmmod.\n");
    cdev_del(my_cdev);
  
  device_destroy(my_class,my_dev_id);  

  class_destroy(my_class);
  unregister_chrdev_region(my_dev_id,1);
  printk(KERN_INFO "laplas driver exited.\n");
}

void laplas_hw(const int width, const int height, const int mask[], const int picture[])
{
    
    printk(KERN_INFO" WE ARE IN HW SIMULATION");
    
    
    
    int k = 0;
    int m = 0;
    int cnt = 0;
    for (int i = 0; i < width; ++i)
    {
        for (int j = 0; j < height; ++j)
        {
            picturEv2[i][j] = picture[cnt];
            newinp[i][j] = 0;
            im[i][j] = 0;
           
            cnt++;
        
        }
    }
    cnt = 0;

    for (int i = 0; i < 5; ++i)
    {
        for (int j = 0; j < 5; ++j)
        {
            mask1[i][j] = mask[cnt];
            cnt++;
        
        }
    }

    printk(KERN_INFO "Laplas start ! \n");
    for (int i=2 ;i< height-2; i++)
    {
            for (int j=2;j<(width-2);j++)
            {
                spix=0;
                for (k=0;k<5;k++)
                {           
                    for (m=0;m<5;m++)
                    { 
                        spix = spix+(mask1[k][m]*(picturEv2[i-2+k][j-2+m]));
                        

                    }

                }
                printk(KERN_INFO "spix is = %d \n", spix); 
                newinp[i][j]=spix; // nova slika 
            }
    }
    printk(KERN_INFO "Find maximum falue !\n");
    for (int i = 0; i < height; ++i)
    {
        for (int j = 0; j < width; ++j)
        {
            if (newinp[i][j] > max)
            {
                max = newinp[i][j];
            }
        }
    }
    printk(KERN_INFO "Maximum value is = %d\n", max);
    printk(KERN_INFO "Zero crossing and tresholding!\n");

    for (int i=1;i<(height-1);i++)
        {    //j=0;
            for (int j=1;j<(width-1);j++)
            {
                if ( newinp[i][j]!=0)
                {
                    if ((newinp[i][j+1]>=0 && newinp[i][j-1]<0) || (newinp[i][j+1]<0 && newinp[i][j-1]>=0))
                          {
                              /*
                                In the next 'if' originaly has been:  
                                    newinp[i][j] >= th , where is th = 0.75*max
                                    newinp[i][j] >= (3/4)*max
                                    4*newinp[i][j] >= 3*max
                              */    
                              if ((4*(newinp[i][j])>= 3*max))
                                   { 
                                       im[i][j]=255;
                                       printk(KERN_INFO "i = %d , j = %d , im[i][j] = 255 \n", i,j);
                                    } 
                          }
                    
                    else if ((newinp[i+1][j]>=0 && newinp[i-1][j]<0) || (newinp[i+1][j]<0 && newinp[i-1][j]>=0))
                            { if ((4*(newinp[i][j])>= 3*max))
                                 {  
                                    im[i][j]=255;
                                    printk(KERN_INFO "i = %d , j = %d , im[i][j] = 255 \n", i,j);
                                 }
                             }

                    else if ((newinp[i+1][j+1]>=0 && newinp[i-1][j-1]<0) || (newinp[i+1][j+1]<0 && newinp[i-1][j-1]>=0))
                             { if ((4*(newinp[i][j])>= 3*max))
                                   {
                                    im[i][j]=255;
                                    printk(KERN_INFO "i = %d , j = %d , im[i][j] = 255 \n", i,j);
                                   }
                             }
                    
                    else if ((newinp[i-1][j+1]>=0 && newinp[i+1][j-1]<0) || (newinp[i-1][j+1]<0 && newinp[i+1][j-1]>=0))
                            { if ((4*(newinp[i][j])>= 3*max))
                                 {
                                    im[i][j]=255;
                                    printk(KERN_INFO "i = %d , j = %d , im[i][j] = 255 \n", i,j);
                                 }
                            }
                }
            }
        }
        for (int i = 0; i < height; ++i)
        {
            for (int j = 0; j < width; ++j)
            {
                result[j+i*width] = im[i][j];
                printk(KERN_INFO "result = %d , position = %d\n", result[j+i*width], j+i*width);            
            }
        }





    printk(KERN_INFO "Laplas finish ! \n");

    
    
}

module_init(laplas_init);
module_exit(laplas_exit);
