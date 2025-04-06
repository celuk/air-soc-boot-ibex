#include "uart.h"
#include "defines.h"

int main()
{
    init_uart();
    
    print("Hello, world!\n");
    return 0;
}
