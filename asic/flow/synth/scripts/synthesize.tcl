# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Copyright 2020 AGH University of Science and Technology
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
set DESIGN air_soc
set REPORT_DIR reports
set RESULT_DIR results

source scripts/flow_config.tcl

# Read the Multi-Mode, Multi-Corner view definition file and populate the MMMC-related attributes
read_mmmc "constraints/mmode.tcl"

# List of global Power nets
set_db init_power_nets  {VDD}
set_db init_ground_nets {VSS}

# Read the physical design information from the specified LEF files
read_physical -lefs {
    /home/ananas/Downloads/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045/lef/gsclib045_tech.lef
    /home/ananas/Downloads/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045_hvt/lef/gsclib045_hvt_macro.lef
}

set_db init_hdl_search_path {
    ../../rtl \
    ../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include/common_cells \
    ../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include/common_cells \
    ../../cv32e40p/rtl \
    ../../cv32e40p/rtl/include \
    ../../cv32e40p/rtl/vendor \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/src \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906 \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk/rtl \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpu_div_sqrt_mvp \
    ../../cv32e40p/rtl/vendor/pulp_platform_fpu_div_sqrt_mvp/hdl \
    ../../cv32e40p/rtl/vendor/pulp_platform_common_cells \
    ../../cv32e40p/rtl/vendor/pulp_platform_common_cells/src \
    ../../cv32e40p/rtl/vendor/pulp_platform_common_cells/src/deprecated \
    ../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include \
    ../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include/common_cells \
}

puts "--------------------------------------------------------------------------------"
puts "-- HDL READ --------------------------------------------------------------------"
puts "--------------------------------------------------------------------------------"

read_hdl -sv rtl/netlist.sv

#------------------------------------------------------------------------------
# merge and analyse the input files
puts "--------------------------------------------------------------------------------"
puts "-- ELABORATION -----------------------------------------------------------------"
puts "--------------------------------------------------------------------------------"
elaborate $DESIGN
timestat ELABORATE

# Initialize the database and ensure that the tool is ready for full execution
puts "--------------------------------------------------------------------------------"
puts "-- INIT DESIGN -----------------------------------------------------------------"
puts "--------------------------------------------------------------------------------"
init_design -top $DESIGN

# Check the SDC quality and timing attributes placed on the current design and
# print timing lint report
puts "--------------------------------------------------------------------------------"
puts "-- CHECK TIMING CONSTRATINTS ---------------------------------------------------"
puts "--------------------------------------------------------------------------------"
check_timing_intent -verbose > ${REPORT_DIR}/check_timing_intent.rpt

# Provide information on unresolved references
check_design -unresolved  > ${REPORT_DIR}/check_design.rpt


# Take an elaborated and fully constrained design as input and synthesize it into a netlist
# of generic gates by doing high-level RTL and datapath optimizations
syn_generic $DESIGN
timestat GENERIC

# Map a design from generic gates to a technology library while optimizing for best performance,
# power and area
syn_map $DESIGN
timestat MAPPED

# Take a mapped design as input and incrementally optimize timing, area and power
syn_opt $DESIGN
timestat OPT

report_qor $DESIGN > ${REPORT_DIR}/qor.log

# Generate a timing report of the current design
report_timing > ${REPORT_DIR}/timing.log

#------------------------------------------------------------------------------
# Generate all the files needed to reload the session in Genus or Innovus (-innovus option)
write_design -innovus -basename ${RESULT_DIR}/$DESIGN
