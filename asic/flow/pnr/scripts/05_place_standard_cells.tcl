#------------------------------------------------------------------------------
# (#05) PLACE STANDARD CELLS
#------------------------------------------------------------------------------
# Do not modify this file.
#------------------------------------------------------------------------------
# TODO: After running the script write down WNS, TNS and DRV values from the report
# summary.

source scripts/_00_common_settings.tcl

# Execute pre-CTS (Clock Tree Synthesis) flow with both placement and pre-CTS optimization
place_opt_design -report_prefix 05_place_opt -report_dir $reportDir

# Specify the tie cell names to be used by the add_tieoffs command
#set_db add_tieoffs_cells {TIEHBWP TIELBWP}

# Add instances of specified tie-off cells to the logical hierarchy of the design
# and connects the tie-off pins of netlist instances to the tie-off pins of the added instances
#set_db add_tieoffs_max_fanout 1
#add_tieoffs
