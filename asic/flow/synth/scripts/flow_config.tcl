#------------------------------------------------------------------------------
# DESIGN FLOW PARAMETERS

set_db design_process_node 45
# Note: LEC script generation does not when efforts are set to express
# Efforts to be set:  medium | low | high | express | none
# express is used in for flow configuration
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

# information level can be set in the range 0-11
# recommended is 6
set_db information_level 6

set_db remove_assigns true

# set_db optimize_merge_flops false

set_db max_cpus_per_server 8 ; # limiting to 8 CPU
#used to mimic a non-cadence environment
set_db enable_domain_name_check 0

# Chipware priority -> rtl compiler replaces some verilog modules (e.g. CW_8b10b_dec.v)
set_db hdl_use_cw_first false
set_db wlec_set_cdn_synth_root true

# used to override pin properties from LEF
set_db use_power_ground_pin_from_lef true

set_db hdl_track_filename_row_col                 true   ;#used for cross probing and datapath report. May be memory consuming
set_db verification_directory_naming_style        "./LEC"

set_db lp_insert_clock_gating                     false   ; # disable clock gating insertion during synthesis

#set_db hdl_error_on_latch true

set_db auto_super_thread true
set_db / .max_cpus_per_server 8

# If the design attribute physical_aware_mapping is set to true, the tool does
# accurate long wire prediction that influences datapath structuring and cell
# selection for convergent timing closure.
# This option is available only with the Genus_Physical_Opt License Key.
# set_db physical_aware_mapping true
