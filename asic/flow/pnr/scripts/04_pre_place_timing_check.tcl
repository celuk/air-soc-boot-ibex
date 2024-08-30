#------------------------------------------------------------------------------
# (#04) PRE-PLACEMENT TIMING CHECK
#------------------------------------------------------------------------------
# Do not modify this file.
#------------------------------------------------------------------------------
# TODO: After running the script write down WNS and TNS values from the report
# summary.

source scripts/_00_common_settings.tcl

# Specify the analysis type
set_db timing_analysis_type ocv

# Perform CPPR (Clock Path Pessimism Removal) checks in setup or hold mode
set_db timing_analysis_cppr both

# Perform a variety of consistency and completeness checks on the timing constraints
# specified for a design
check_timing -verbose > $reportDir/04a_timing_check.rpt

# Run early global route, extraction, and timing analysis, and generate detailed timing reports
time_design -pre_place -report_prefix 04b_preplace -report_dir $reportDir
