#------------------------------------------------------------------------------
# (#08) POST-CTS OPTIMIZATION
#------------------------------------------------------------------------------
# Do not modify this file.
#------------------------------------------------------------------------------
# TODO: After running the script write down WNS and TNS values in setup/hold
# modes, and DRV summary.

source scripts/_00_common_settings.tcl

# Perform timing optimization after the clock tree is built and generate timing report.
# Menu: ECO -> Optimize Design ...

# Correct design rule violations, reduce total negative slack, optimize setup
opt_design -post_cts -report_prefix 08a_postCts_setup -report_dir $reportDir

# Correct hold violations
opt_design -post_cts -hold -report_prefix 08b_postCts_hold -report_dir $reportDir

# Correct max_cap and max_tran violations
opt_design -post_cts -drv -report_prefix 08c_postCts_drv -report_dir $reportDir

# If the opt_design reports timing violations other time_design/opt_design
# iterations may be necessary
# time_design -post_cts -report_prefix 08d_time_postCts_setup -report_dir $reportDir
# opt_design ...
# time_design -post_cts -hold -report_prefix 08e_time_postCts_hold -report_dir $reportDir
# opt_design ...
