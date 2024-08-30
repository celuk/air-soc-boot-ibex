source scripts/01_initialize_design.tcl
source scripts/02_connect_power_to_gates.tcl
source scripts/03_create_floorplan.tcl
source scripts/04_pre_place_timing_check.tcl
source scripts/05_place_standard_cells.tcl
# source scripts/06_pre_cts_timing_opt.tcl
source scripts/07_clock_tree_synthesis.tcl
source scripts/08_post_cts_optimization.tcl
source scripts/09_routing.tcl
source scripts/10_post_route_optimization.tcl
source scripts/11_signoff_extraction.tcl
source scripts/12_signoff_timing_check.tcl
# source scripts/13_signoff_optimization.tcl
source scripts/14_signoff_drc_lvs.tcl
source scripts/15_final_data_save.tcl
exit 0
