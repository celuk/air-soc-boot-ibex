#ifndef USB_H
#define USB_H

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdbool.h>

#define USB_CTRL     (*(volatile uint32_t*)0x20040000)
#define USB_STATUS   (*(volatile uint32_t*)0x20040004)
#define USB_RDATA    (*(volatile uint32_t*)0x20040008)
#define USB_WDATA    (*(volatile uint32_t*)0x2004000c)

void     tekno_printf    (const char *fmt, ...);
void     print           (const char *p);
int      zscan           (char *buffer, int max_size, int echo);
char     zgetchar        ();
void     zputchar        (char c);
int      strcmp          (const char *p1, const char *p2);
size_t   strlen          (const char *s);
int      usb_cdc_txfull  ();
int      usb_cdc_rxempty ();
void     init_usb_cdc    ();

typedef union
{
    struct {
        unsigned int configured : 1;
        unsigned int null       : 31;
    } fields;
    uint32_t bits;
} usb_cdc_ctrl;

typedef union
{
    struct {
        unsigned int in_ready  : 1;
        unsigned int out_valid : 1;
        unsigned int frame     : 11;
        unsigned int null      : 19;
    } fields;
    uint32_t bits;
} usb_cdc_status;

#endif
