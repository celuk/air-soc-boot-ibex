#include "uart.h"
#include "defines.h"

int main()
{
    init_uart();
    
    print("EH\nello, world!\n");
    return 0;
}
