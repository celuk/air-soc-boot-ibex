set stdcellTimingLibDir /home/ananas/Downloads/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045_hvt/timing
set qrcTechDir /home/ananas/Downloads/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045/qrc/qx

create_library_set -name fast_lib -timing [ list $stdcellTimingLibDir/fast_vdd1v0_basicCells_hvt.lib ]

create_opcond -name fast_lib_cond -process 1

create_timing_condition -name fast_tim -opcond fast_lib_cond  -library_sets "fast_lib"

create_rc_corner -name RCcorner_fast -qrc_tech $qrcTechDir/gpdk045.tch

create_delay_corner -name delay_corner_fast -timing_condition fast_tim -rc_corner RCcorner_fast

create_constraint_mode -name standard_cm -sdc_files [ list ./constraints/design.sdc ]

create_analysis_view -name fast_av -delay_corner delay_corner_fast -constraint_mode standard_cm

set_analysis_view \
  -setup [ list fast_av ] \
  -hold  [ list fast_av ] \
  -leakage fast_av \
  -dynamic fast_av
