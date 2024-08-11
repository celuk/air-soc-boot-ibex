#include "timer.h"

void init_timer()
{
    TIM_PRE = 0;
    TIM_ENA = 1;
    TIM_MOD = 1;
}
