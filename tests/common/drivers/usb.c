#include "usb.h"
#include "defines.h"

//-----------------------------------------------
// Check if USB CDC is ready to transmit
//-----------------------------------------------
int usb_cdc_txfull()
{
    usb_cdc_status usb_stat;
    usb_stat.bits = USB_STATUS;
    return !usb_stat.fields.in_ready;
}

void zputchar(char c)
{
    while (usb_cdc_txfull())
        ;
    USB_WDATA = c;
}

//-----------------------------------------------
// print a string (char*)
//-----------------------------------------------
void print(const char* p)
{
    while (*p)
        zputchar(*(p++));
}

// tekno_printf function remains the same

//-----------------------------------------------
// Check if USB CDC has data to receive
//-----------------------------------------------
int usb_cdc_rxempty()
{
    usb_cdc_status usb_stat;
    usb_stat.bits = USB_STATUS;
    return !usb_stat.fields.out_valid;
}

char zgetchar()
{
    while (1) {
        if (!usb_cdc_rxempty()) {
            return (char)USB_RDATA;
        }
    }
}

// zscan, strcmp, and strlen functions remain the same

void init_usb_cdc()
{
    usb_cdc_ctrl usb_control;
    usb_control.fields.configured = 0x1; // Set configured bit
    USB_CTRL = usb_control.bits;

    // Wait for USB to be configured
    usb_cdc_status usb_stat;
    do {
        usb_stat.bits = USB_STATUS;
    } while (!usb_stat.fields.configured);
}
