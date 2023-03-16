#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fstream>
#include <iostream>
#include <vector>
#include<cstdlib>
using namespace std;

#define MASK_SIZE 25
#define PICTURE_SIZE 100
void write_ip(const int start_stop, const int position, const int value);
void read_ip_result(std::vector<int> &result);
void print_result(std::vector<int> &result);

int width = 10;
int height = 10;
int border1 = 2;
int l1 = 1;
int START = 1;
int STOP = 0;
int test_for_read = 0;
int start_stop;


//int mask[MASK_SIZE] = {0,0,-1,0,0,0,-1,-2,-1,0,-1,-2,16,-2,-1,0,-1,-2,-1,0,0,0,-1,0,0};

int main ()
{   
    srand (time(NULL));
    int random;

    std::vector<int> result;
    for(int i = 0; i < width*height; i++)
    {
        result.push_back(0);
    }
    int mask[MASK_SIZE] = {0,0,-1,0,0,0,-1,-2,-1,0,-1,-2,16,-2,-1,0,-1,-2,-1,0,0,0,-1,0,0};
    int i;
    int j;
    
    
    write_ip(STOP,0, width);
    write_ip(STOP,1, height);
    
    for (i = 2; i < MASK_SIZE + 2; ++i)
    {
        write_ip(STOP,i, mask[i-2]);
    }

    for (j = MASK_SIZE+2; j < PICTURE_SIZE+MASK_SIZE+2; j++)
    {
        random = 10 + (rand() % 11);
        write_ip(STOP,j,random);
    }

    
    write_ip(START, 0, 0);
    read_ip_result(result);
    print_result(result);
         

    return 0;
}

void write_ip(const int start_stop,const int position, const int value)
{
    FILE *laplas;
    laplas = fopen("/dev/xlnx,laplas", "w");

        fprintf(laplas, "%d,%d,%d\n",start_stop,position,value);
        printf(" [APP] %d ,%d, %d\n",start_stop,position,value);

    fclose(laplas);
}

void read_ip_result(std::vector<int> &result)
{
    FILE *laplas;
    int read_result;

    laplas = fopen("/dev/xlnx,laplas", "r");
    for (int i = 0; i < width*height; i++)
    {
       fscanf(laplas, "%d ", &read_result);
       result[i]= read_result;
    }

    fclose(laplas);
}
void print_result(std::vector<int> &result)
{
    cout<<"result: ";
    for(int i = 0; i < width*height; i++)
    {
        cout<<result[i]<<" "; 
    }
    cout<<endl;
}