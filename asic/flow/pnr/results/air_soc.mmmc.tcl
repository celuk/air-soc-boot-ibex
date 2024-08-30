#################################################################################
#
# Created by Genus(TM) Synthesis Solution 22.13-s093_1 on Fri Aug 30 21:25:10 +03 2024
#
#################################################################################

## library_sets
create_library_set -name fast_lib \
    -timing { /home/ananas/Downloads/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045_hvt/timing/fast_vdd1v0_basicCells_hvt.lib }

## opcond
create_opcond -name fast_lib_cond \
    -process 1.0

## timing_condition
create_timing_condition -name fast_tim \
    -opcond fast_lib_cond \
    -library_sets { fast_lib }

## rc_corner
create_rc_corner -name RCcorner_fast \
    -qrc_tech /home/ananas/Downloads/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045/qrc/qx/gpdk045.tch \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0} \
    -post_route_clock_cross_cap {1.0 1.0 1.0}

## delay_corner
create_delay_corner -name delay_corner_fast \
    -early_timing_condition { fast_tim } \
    -late_timing_condition { fast_tim } \
    -early_rc_corner RCcorner_fast \
    -late_rc_corner RCcorner_fast

## constraint_mode
create_constraint_mode -name standard_cm \
    -sdc_files { results/air_soc.standard_cm.sdc }

## analysis_view
create_analysis_view -name fast_av \
    -constraint_mode standard_cm \
    -delay_corner delay_corner_fast

## set_analysis_view
set_analysis_view -setup { fast_av } \
                  -hold { fast_av } \
                  -leakage fast_av \
                  -dynamic fast_av
