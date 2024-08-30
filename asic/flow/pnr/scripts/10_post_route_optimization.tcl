#------------------------------------------------------------------------------
# (#10) POST-ROUTE OPTIMIZATION
#------------------------------------------------------------------------------
# Do not modify this file.
#------------------------------------------------------------------------------
# TODO: After running the script write down WNS and TNS values in setup/hold
# modes, and DRV summary.

source scripts/_00_common_settings.tcl

# Specify the extraction engine to use
set_db extract_rc_engine post_route

# Specify the post-route engine variant to use for performing RC extraction
set_db extract_rc_effort_level medium

# Enable SIAware delay calculation with cross-talk induced delays included
set_db delaycal_enable_si true

# Enable triggering DRV/glitch recovery if there are any left in the design
set_db opt_post_route_drv_recovery true

# Set high optimization effort
set_db opt_effort high

# Perform timing optimization after routing and generate timing reports
opt_design -post_route -drv -report_prefix 10a_opt_post_route_drv -report_dir $reportDir
opt_design -post_route -setup -hold -report_prefix 10b_opt_post_route_setup_hold -report_dir $reportDir

# save database
write_db $saveDir/${DESIGN}_10_postroute_opt.db
