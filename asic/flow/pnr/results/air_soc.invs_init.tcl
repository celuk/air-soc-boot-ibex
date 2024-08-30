################################################################################
#
# Init setup file
# Created by Genus(TM) Synthesis Solution on 08/30/2024 21:25:18
#
################################################################################
if { ![is_common_ui_mode] } { error "ERROR: This script requires common_ui to be active."}

read_mmmc results/air_soc.mmmc.tcl

read_physical -lef {/home/ananas/Downloads/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045/lef/gsclib045_tech.lef /home/ananas/Downloads/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045_hvt/lef/gsclib045_hvt_macro.lef}

read_netlist results/air_soc.v

init_design
