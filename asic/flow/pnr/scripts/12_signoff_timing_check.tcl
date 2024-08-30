#------------------------------------------------------------------------------
# (#12) SIGN-OFF TIMING CHECK
#------------------------------------------------------------------------------
# Do not modify this file.
#------------------------------------------------------------------------------
source scripts/_00_common_settings.tcl

# Put the software into interactive constraint entry mode for the specified
# multi-mode multi-corner constraint mode objects
set_interactive_constraint_modes [all_constraint_modes -active]

# Put the propagated_clock assertion on the specified clock objects
set_propagated_clock [all_clocks]

# Control asynchronous checks
set_db timing_analysis_async_checks async

# Specify the multiple-CPU processing configuration for distributed processing or Superthreading.
# In this case use only jobs only on the local machine
set_distributed_hosts -local

# Specify the number of threads to use for multi-threading, or the maximum number of computers
# to use for distributed processing, or the maximum number of computers and the number of threads
# to use for Superthreading
set_multi_cpu_usage -local_cpu 8 -remote_host 1 -cpu_per_remote_host 1

# Run signoff timing analysis using extraction (QRC) and Tempus in batch mode
time_design_signoff -report_dir $reportDir -report_prefix 12_signoff_time -report_only
