#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define QF 28

int main(int argc, char ** argv){
  if (argc < 2)
  {
    fprintf(stderr, "usage %s <x>\n",argv[0]);
    exit(2);
  }
  float x=atof(argv[1]);
printf("x= 0x%08X \n", (int32_t)round(x*(1<<QF)));
return 0;
}
