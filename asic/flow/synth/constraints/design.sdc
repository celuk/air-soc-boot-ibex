set_units -capacitance 1.0pF
set_units -time 1.0ns
set_time_unit -nanoseconds
set_load_unit -picofarads

create_clock -p 10 clk_i

set_input_transition 1 [all_inputs]

set_load 2 [all_outputs]

