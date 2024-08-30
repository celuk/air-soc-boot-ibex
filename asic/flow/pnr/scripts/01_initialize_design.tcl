#------------------------------------------------------------------------------
# (#01) INITIALIZE DESIGN
#------------------------------------------------------------------------------
# Do not modify this file.
#------------------------------------------------------------------------------
source scripts/_00_common_settings.tcl

# Specify power net names
# The library has separated bulks for both vdd and gnd:
set_db init_power_nets  {VDD}
set_db init_ground_nets {VSS}

#------------------------------------------------------------------------------
# Read the data prepared by genus with the write_design command.
# This will load the netlist, constraints, libraries and MMMC (multi-mode
# multi-corner) configuration.
#
# TODO: link the synthesis RESULT directory locally with the same name, e.g.:
# ln -s ../synth/RESULTS .

source ./results/${DESIGN}.invs_setup.tcl

# add corner cells to the floorplan
#read_io_file corners.io
