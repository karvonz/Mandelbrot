#ifndef __MY_PRINTF_H__
#define __MY_PRINTF_H__

void my_printf(char* str, int value)
{
  puts(str); print_int( value ); puts("\n");
}
void my_printfh(char* str, int* ptr, int value)
{
  puts(str); print_hex( ptr ); puts(" = "); print_int( value ); puts("\n");
}
void my_printh(int* ptr)
{
  print_hex( ptr ); puts(" = "); print_hex( *ptr ); puts("\n");
}

#endif