#include "timer.h"

void init_timer()
{
    TIM_PRE = 0;
    TIM_ENA = 1;
    TIM_MOD = 1;
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
