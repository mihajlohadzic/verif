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
    
    int picture[PICTURE_SIZE] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,1,2,3,4,5,6,7,8,9,10,11,12,13,14,1,2,3,4,5,6,7,8,9,10,11,12,13,14, 1,2,3,4,5,6,7,8,9,10,11,12,13,14, 1,2,3,4,5,6,7,8,9,10,11,12,13,14, 1,2,3,4,5,6,7,8,9,10,11,12,13,14, 1,2,3,4,5,6,7,8,9,10,11,12,13,14, 11,11};
    int picture1[PICTURE_SIZE] = {13,28,39,41,52,63,71,77,88,10,81,212,153,142,199,29,32,49,55,66,77,88,129,180,191,212,213,214,241,209,153,200,155,166,187,88,9,10,11,12,13,14, 1,2,3,251,5,156,78,8,98,10,11,12,13,14, 1,2,3,4,5,6,7,8,9,10,11,12,13,14, 1,2,3,4,5,68,7,8,99,107,11,12,13,14, 1,2,3,4,5,6,78,8,9,10,191,12,13,14, 11,11};  
	int picture2[PICTURE_SIZE] = {38,162,95,94,161,105,209,108,22,240,131,166,84,47,51,3,198,118,82,186,64,138,29,52,177,216,2,134,222,199,181,46,184,188,212,252,206,75,254,42,32,31,208,136,176,67,24,172,26,243,20,10,16,87,25,104,133,248,4,171,81,154,169,165,40,43,210,201,228,45,78,189,128,1,99,217,187,164,185,106,71,50,143,167,112,155,92,183,247,192,58,229,220,93,146,130,142,238,205,213};
	int picture3[PICTURE_SIZE] = {138,134,66,14,181,238,55,156,23,179,80,143,190,104,195,248,106,158,239,131,10,122,159,213,119,109,71,9,130,243,88,150,120,38,139,94,221,24,20,42,225,126,51,198,90,202,32,167,58,56,222,36,11,234,57,50,215,194,144,33,76,229,27,220,180,84,85,105,184,28,171,152,188,205,2,87,29,59,15,118,95,135,147,185,232,226,6,148,40,142,200,241,116,63,141,199,52,101,172,3};
    int i;
    int j;
    
    
    write_ip(STOP,0, width);
    write_ip(STOP,1, height);
    
    for (i = 2; i < MASK_SIZE + 2; ++i)
    {
        write_ip(STOP,i, mask[i-2]);
    }

    int p = 0;

    for (j = MASK_SIZE+2; j < PICTURE_SIZE+MASK_SIZE+2; j++)
    {
        //random = 10 + (rand() % 11);
        random = picture[p];
        write_ip(STOP,j,random);
        p++;
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
        if (result[i] == 255)
         {
             cout << " adresa: " << i << endl <<endl;
         } 
    }
    cout<<endl;
}
