#-----------------------------------------------------------------------
# (#13) SIGNOFF OPTIMIZATION
#-----------------------------------------------------------------------
# Do not modify this file.
#-----------------------------------------------------------------------
# This step is necesary only if the timing is not met at the previous stage.
#-----------------------------------------------------------------------
# TODO: After running the script write down WNS and TNS values in setup/hold
# modes, and DRV summary.
source scripts/_00_common_settings.tcl
#
delete_filler
#-----------------------------------------------------------------------
# addtional delay margin for signoff analysis
set_db opt_signoff_setup_target_slack 0.2

opt_signoff -drv \
    -no_eco_route \
    -report_dir $reportDir \
    -report_prefix 13a_signoff_opt_drv
#
opt_signoff -hold \
    -no_eco_route \
    -report_dir $reportDir \
    -report_prefix 13b_signoff_opt_hold
#
opt_signoff -setup \
    -no_eco_route \
    -report_dir $reportDir \
    -report_prefix 13c_signoff_opt_setup

add_fillers
route_eco
extract_rc
#-----------------------------------------------------------------------
# Signoff timing analysis after optimization

time_design_signoff \
    -report_dir $reportDir \
    -report_prefix 13d_signoff_time_opt \
    -report_only
