/*
Copyright 2018 Embedded Microprocessor Benchmark Consortium (EEMBC)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Original Author: Shay Gal-on
*/
#include "coremark.h"
#include "core_portme.h"



//#define CPU_CLK CLOCKS_PER_SEC
//#define BAUD_RATE 115200

#define UART_CPB       (*(volatile uint32_t*)0xFF000000)
#define UART_STP       (*(volatile uint32_t*)0xFF000004)
#define UART_CFG       (*(volatile uint32_t*)0xFF000010)

void init_uart()
{
    UART_CFG = UART_CFG | 0x7;
    UART_CPB = CPU_CLK / BAUD_RATE;
    UART_STP = UART_STP | 0x1;
}

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

void init_timer()
{
    //TIM_PRE = 0;
    //TIM_ENA = 1;
    //TIM_MOD = 1;

    timer_set_clr(1);
    timer_set_evc(1);
    timer_set_pre(0);
    timer_set_are(0xFFFFFFFF);
    timer_set_ena(1);
    timer_set_mod(1);
    timer_set_evc(0);
    timer_set_clr(0);
}

void timer_set_pre (unsigned int pre){
    TIM_PRE = pre;
}

int timer_get_pre (){
    return TIM_PRE;
}

void timer_set_are (unsigned int are){
    TIM_ARE = are;
}

int timer_get_are (){
    return TIM_ARE;
}

void timer_set_clr (unsigned int clr){
    TIM_CLR = clr;
}

int timer_get_clr (){
    return TIM_CLR;
}

void timer_set_ena (unsigned int ena){
    TIM_ENA = ena;
}

int timer_get_ena (){
    return TIM_ENA;
}

void timer_set_mod (unsigned int mod){
    TIM_MOD = mod;
}

int timer_get_mod (){
    return TIM_MOD;
}

int timer_get_cnt (){
    return TIM_CNT;
}

int timer_get_evn (){
    return TIM_EVN;
}

void timer_set_evc (unsigned int evc){
    TIM_EVC = evc;
}

int timer_get_evc (){
    return TIM_EVC;
}

#define US(x) (CPU_CLK/1000000 * x)

void wait_for(uint32_t time){
    init_timer();
	uint32_t start = timer_get_cnt();
	uint32_t end = timer_get_cnt();
    uint32_t diff = end - start;
	while(((diff)) < time){
		end = timer_get_cnt();
        if(end > start)
            diff = end - start;
        else
            diff = start - end;
	}
}

void wait_for_us(uint32_t time){
    wait_for(US(time));
}


#if VALIDATION_RUN
volatile ee_s32 seed1_volatile = 0x3415;
volatile ee_s32 seed2_volatile = 0x3415;
volatile ee_s32 seed3_volatile = 0x66;
#endif
#if PERFORMANCE_RUN
volatile ee_s32 seed1_volatile = 0x0;
volatile ee_s32 seed2_volatile = 0x0;
volatile ee_s32 seed3_volatile = 0x66;
#endif
#if PROFILE_RUN
volatile ee_s32 seed1_volatile = 0x8;
volatile ee_s32 seed2_volatile = 0x8;
volatile ee_s32 seed3_volatile = 0x8;
#endif
volatile ee_s32 seed4_volatile = ITERATIONS;
volatile ee_s32 seed5_volatile = 0;
/* Porting : Timing functions
        How to capture time and convert to seconds must be ported to whatever is
   supported by the platform. e.g. Read value from on board RTC, read value from
   cpu clock cycles performance counter etc. Sample implementation for standard
   time.h and windows.h definitions included.
*/
CORETIMETYPE
barebones_clock()
{
//#error \
    "You must implement a method to measure time in barebones_clock()! This function should return current time.\n"
    //return (get_timer_high() << 32) + get_timer_low();//get_timer();
  //uint32_t val;
  //asm volatile ("rdcycle %0 ;\n":"=r" (val) ::);
  return timer_get_cnt(); //val;
}
/* Define : TIMER_RES_DIVIDER
        Divider to trade off timer resolution and total time that can be
   measured.

        Use lower values to increase resolution, but make sure that overflow
   does not occur. If there are issues with the return value overflowing,
   increase this value.
        */
#define GETMYTIME(_t)              (*_t = barebones_clock())
#define MYTIMEDIFF(fin, ini)       ((fin) - (ini))
#define TIMER_RES_DIVIDER          1
#define SAMPLE_TIME_IMPLEMENTATION 1
#define EE_TICKS_PER_SEC           (CLOCKS_PER_SEC / TIMER_RES_DIVIDER)

/** Define Host specific (POSIX), or target specific global time variables. */
static CORETIMETYPE start_time_val, stop_time_val;

/* Function : start_time
        This function will be called right before starting the timed portion of
   the benchmark.

        Implementation may be capturing a system timer (as implemented in the
   example code) or zeroing some system parameters - e.g. setting the cpu clocks
   cycles to 0.
*/
void
start_time(void)
{
    GETMYTIME(&start_time_val);
}
/* Function : stop_time
        This function will be called right after ending the timed portion of the
   benchmark.

        Implementation may be capturing a system timer (as implemented in the
   example code) or other system parameters - e.g. reading the current value of
   cpu cycles counter.
*/
void
stop_time(void)
{
    GETMYTIME(&stop_time_val);
}
/* Function : get_time
        Return an abstract "ticks" number that signifies time on the system.

        Actual value returned may be cpu cycles, milliseconds or any other
   value, as long as it can be converted to seconds by <time_in_secs>. This
   methodology is taken to accommodate any hardware or simulated platform. The
   sample implementation returns millisecs by default, and the resolution is
   controlled by <TIMER_RES_DIVIDER>
*/
CORE_TICKS
get_time(void)
{
    CORE_TICKS elapsed
        = (CORE_TICKS)(MYTIMEDIFF(stop_time_val, start_time_val));
    return elapsed;
}
/* Function : time_in_secs
        Convert the value returned by get_time to seconds.

        The <secs_ret> type is used to accommodate systems with no support for
   floating point. Default implementation implemented by the EE_TICKS_PER_SEC
   macro above.
*/
secs_ret
time_in_secs(CORE_TICKS ticks)
{
    secs_ret retval = ((secs_ret)ticks) / (secs_ret)EE_TICKS_PER_SEC;
    return retval;
}

ee_u32 default_num_contexts = 1;

/* Function : portable_init
        Target specific initialization code
        Test for some common mistakes.
*/

void
portable_init(core_portable *p, int *argc, char *argv[])
{
//#error \
    "Call board initialization routines in portable init (if needed), in particular initialize UART!\n"

    init_uart();

    init_timer();

    (void)argc; // prevent unused warning
    (void)argv; // prevent unused warning

    if (sizeof(ee_ptr_int) != sizeof(ee_u8 *))
    {
        ee_printf(
            "ERROR! Please define ee_ptr_int to a type that holds a "
            "pointer!\n");
    }
    if (sizeof(ee_u32) != 4)
    {
        ee_printf("ERROR! Please define ee_u32 to a 32b unsigned type!\n");
    }
    p->portable_id = 1;
}
/* Function : portable_fini
        Target specific final code
*/
void
portable_fini(core_portable *p)
{
    p->portable_id = 0;
}
