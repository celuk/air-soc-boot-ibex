#------------------------------------------------------------------------------
# (#07) CLOCK TREE SYNTHESIS
#------------------------------------------------------------------------------
# Do not modify this file.
#------------------------------------------------------------------------------
# Note:
# - "Trunk" - refers to the wire and buffers not connected to DFFs' inputs
# - "Leaf" - refers to wires connect to the DFFs' inputs, and DFFs' themself
#
# TODO: After running the script, check in the reports:
# 1. How many clock buffers were used.
# 2. Check what is the Worst Rising/Falling Trunk/Leaf Slew. Are the values
# within the requirements?
# 3. Are there any other violations?
# TODO: Open "Clock Tree Debugger" and make a screenshot of the clock tree structure.

source scripts/_00_common_settings.tcl

# Specify the inverter cells available for CTS
#set_db cts_inverter_cells [get_db [get_lib_cells -regexp /CKND.*] .base_name]

# Specify the buffer cells for CTS
#set_db cts_buffer_cells [get_db [get_lib_cells -regexp /CKBD.*] .base_name]

# Specify the target slew used for CTS. This attribute specifies a maximum slew time
# that the clock tree synthesis algorithm will allow in this clock tree, in library units
set_db cts_target_max_transition_time 0.2

# Perform clock tree synthesis (CTS) on the design using the CCOpt (Clock Concurrent Optimization)
# engine. It does not perform any datapath optimization or useful skew
clock_design

# Report a summary of all defined clock trees. In particular, this report provides a summary of
# clock gates at different depths in each clock tree
report_clock_trees -summary -out_file $reportDir/07_clock_tree_summary.txt

# Report the structure of the clock network as a text report
report_clock_tree_structure -out_file $reportDir/07_clock_tree_structure.txt
