#------------------------------------------------------------------------------
# (#06) PRE-CTS TIMMING CHECK AND OPTIMIZATION
#------------------------------------------------------------------------------
# Use this file only if the timing results from the placement are bad.
#------------------------------------------------------------------------------
# TODO: After running the script write down WNS and TNS values, and DRV
# summary.
#
source scripts/_00_common_settings.tcl

# Run early global route, extraction, and timing analysis, and generate
# detailed timing reports.
time_design -pre_cts -report_prefix 06_prects -report_dir $reportDir

# In case the time_design gives the errors, you should run the pre-cts
# optimization. But we do not expect any.
# Menu: ECO -> Optimize design
# Design Stage = Pre-CTS
# Optimization type = Setup
opt_design -pre_cts -setup -drv -report_prefix 06b_prects_opt -report_dir $reportDir
