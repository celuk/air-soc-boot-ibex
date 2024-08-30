#------------------------------------------------------------------------------
# (#15) SIGN-OFF DRC LVS
#------------------------------------------------------------------------------
# Do not modify this file.
#------------------------------------------------------------------------------
source scripts/_00_common_settings.tcl

#------------------------------------------------------------------------------
# GDS
#------------------------------------------------------------------------------
# Label all pin shapes, whether or not they are physically connected
set_db write_stream_label_all_pin_shape true

# Check the specified map file
set_db write_stream_check_map_file true

# Create a GDS2 Stream (layout) file of the current database
write_stream -merge {/home/ananas/Downloads/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045/gds/gsclib045.gds /home/ananas/Downloads/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045_hvt/gds/gsclib045_hvt.gds} $resultDir/${DESIGN}.gds.gz

#------------------------------------------------------------------------------
# REPORTS
#------------------------------------------------------------------------------
# Report quality of results
report_qor -format html -file $reportDir/15_qor.html

# Report the combined standard cell area in each of the hierarchy modules
# and the top-level design
report_area -out_file $reportDir/15_area.rpt

#------------------------------------------------------------------------------
# SDF
#------------------------------------------------------------------------------

# Write delays to a Standard Delay Format (SDF) file
# write_sdf -edges noedge -max_view WC_av -min_view BC_av $resultDir/${DESIGN}.sdf.gz
write_sdf -edges noedge -max_view WCL_av -min_view BC_av \
  -version 3.0 \
  -recompute_delaycal \
  -recompute_parallel_arcs \
  $resultDir/${DESIGN}.sdf.gz

#------------------------------------------------------------------------------
# SAVE NETLIST
#------------------------------------------------------------------------------
#save flattened netlist
write_netlist -flat \
    -include_pg_ports \
    -include_phys_insts \
    -omit_floating_ports \
    -exclude_leaf_cells \
    $resultDir/${DESIGN}_flat.v.gz

#save hierarchical netlist with power/ground ports (for external LVS)
write_netlist \
    -include_pg_ports \
    -include_phys_insts \
    -omit_floating_ports \
    -exclude_leaf_cells \
    $resultDir/${DESIGN}_nonFlat.v.gz

#save hierarchical netlist without power ports for simulation
write_netlist $resultDir/${DESIGN}.noPower.v.gz

#save flatted netlist without power ports for simulation
write_netlist  -flat  $resultDir/${DESIGN}.noPower.flat.v.gz

#------------------------------------------------------------------------------
# OTHER
#------------------------------------------------------------------------------
# write pin labels into file (for external LVS)
# create_pin_text \
#     -cells "$DESIGN" \
#     $resultDir/${DESIGN}_pins.txt

write_def $resultDir/${DESIGN}_floorplan.def.gz
#
#------------------------------------------------------------------------------
# SAVE DATABASE
#------------------------------------------------------------------------------
# Write the complete design database in the native Innovus DB format
write_db $saveDir/${DESIGN}_15_final.db
