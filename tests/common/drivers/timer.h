#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>

#define TIM_BASE_ADDR  0xFF050000
#define TIM_PRE_OFFSET 0x00
#define TIM_ARE_OFFSET 0x04
#define TIM_CLR_OFFSET 0x08
#define TIM_ENA_OFFSET 0x0C
#define TIM_MOD_OFFSET 0x10
#define TIM_CNT_OFFSET 0x14
#define TIM_EVN_OFFSET 0x18
#define TIM_EVC_OFFSET 0x1C

#define TIM_PRE (*(volatile uint32_t*) (TIM_BASE_ADDR + TIM_PRE_OFFSET))
#define TIM_ARE (*(volatile uint32_t*) (TIM_BASE_ADDR + TIM_ARE_OFFSET))
#define TIM_CLR (*(volatile uint32_t*) (TIM_BASE_ADDR + TIM_CLR_OFFSET))
#define TIM_ENA (*(volatile uint32_t*) (TIM_BASE_ADDR + TIM_ENA_OFFSET))
#define TIM_MOD (*(volatile uint32_t*) (TIM_BASE_ADDR + TIM_MOD_OFFSET))
#define TIM_CNT (*(volatile uint32_t*) (TIM_BASE_ADDR + TIM_CNT_OFFSET))
#define TIM_EVN (*(volatile uint32_t*) (TIM_BASE_ADDR + TIM_EVN_OFFSET))
#define TIM_EVC (*(volatile uint32_t*) (TIM_BASE_ADDR + TIM_EVC_OFFSET))

void init_timer();
void timer_set_pre (unsigned int pre);
int timer_get_pre ();
void timer_set_are (unsigned int are);
int timer_get_are ();
void timer_set_clr (unsigned int clr);
int timer_get_clr ();
void timer_set_ena (unsigned int ena);
int timer_get_ena ();
void timer_set_mod (unsigned int mod);
int timer_get_mod ();
int timer_get_cnt ();
int timer_get_evn ();
void timer_set_evc (unsigned int evc);
int timer_get_evc ();
void wait_for(uint32_t time);
void wait_for_us(uint32_t time);

#endif
