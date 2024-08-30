#------------------------------------------------------------------------------
# (#00) COMMON SETTINGS
#------------------------------------------------------------------------------
# Do not modify this file
#------------------------------------------------------------------------------

# define top cell locally
set DESIGN air_soc

# The legal enum values are 'express standard extreme'.
set_db design_flow_effort standard

set_db design_process_node 45
set_db init_design_uniquify {1}
set_db init_no_new_assigns true
set_db route_design_bottom_routing_layer 1
set_db route_design_top_routing_layer 11

set reportDir ./timingReports
set resultDir ./results_pr
set saveDir ./saved

# Create output dirs
foreach {dir} [list $resultDir $reportDir $saveDir] {
  if {[expr ! [file exists $dir]]} { file mkdir $dir }
}
#------------------------------------------------------------------------------
# Local host distributed only
set_distributed_hosts -local
# NOTE: tempus 17.1 fails when -remote_host is set to 0!!! ?????
# NOTE: there are also some problems when local_cpu > 1
# set_multi_cpu_usage -local_cpu 8 -remote_host 8 -cpu_per_remote_host 1
set_multi_cpu_usage -local_cpu 8 -remote_host 1 -cpu_per_remote_host 1

#------------------------------------------------------------------------------
# run timing analysis in OCV mode
set_db timing_analysis_type ocv
set_db timing_analysis_cppr both
#------------------------------------------------------------------------------
# floorplan parameters
#
#------------------------------------------------------------------------------
# commonly used functions
proc drawRect {net layer x0 y0 x1 y1} {
  set_db edit_wire_nets $net
  set_db edit_wire_layer $layer
  edit_add_polygon_point $x0 $y0
  edit_add_polygon_point $x0 $y1
  edit_add_polygon_point $x1 $y1
  edit_end_polygon_point $x1 $y0
}
