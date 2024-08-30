#!/bin/bash
# This script generates one netlist file from all the sources
# based on the xrun log file.

#source xcelium to get xrun
#source /cad/env/cadence_path.XCELIUM1909
PERL=/usr/bin/perl

cd "$(dirname "$0")"

#pkgs=../../../pkgs.f

f1=../../../soc.f
top=air_soc
netlist=netlist.sv

rm -f $netlist src_file_list.txt

#xrun -compile -work worklib -F $pkgs

# compile
xrun \
  -clean \
  -compile \
  -sv \
  -F $f1 \
  -top $top \
  -incdir ../../../rtl \
  -incdir ../../../cv32e40p/rtl \
  -incdir ../../../cv32e40p/rtl/include \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include/common_cells \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include/common_cells \
  #-incdir ../../../cv32e40p/rtl/vendor \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/src \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906 \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk/rtl \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpu_div_sqrt_mvp \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpu_div_sqrt_mvp/hdl \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/src \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/src/deprecated \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include/common_cells \
  #-incdir ../../../rtl/sim

# -64bit -disable_sem2009 -access +rwc -nowarn UEXPSC 

# check status
if [[ "$?" != "0" ]]; then
  echo COMPILATION ERROR!
  exit -1
fi

# File list preparing (include files + .v files)

$PERL -lane 'print $1 if /file: (.*)/' xrun.log >> src_file_list.txt

#------------------------------------------------------------------------------
# create single file netlist
#------------------------------------------------------------------------------

#echo "\`define $define" > $netlist
cat src_file_list.txt | xargs cat >> $netlist

echo "Netlist created ($netlist)"

#------------------------------------------------------------------------------
# verify the netlist (elaborate)
#------------------------------------------------------------------------------

echo "------------------------------------------------------------------------------"
echo " Starting netlist verification ..."
PARAMS=""
PARAMS+=" -timescale 1ns/1ps"

xrun \
  -sv \
  -incdir ../../../rtl \
  -incdir ../../../cv32e40p/rtl \
  -incdir ../../../cv32e40p/rtl/include \
  -elaborate $netlist $PARAMS +nowarnTRNNOP \
  -clean \
  -top $top \
  #>> /dev/null
  #-64bit -disable_sem2009 -access +rwc -nowarn UEXPSC 
#-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include/common_cells \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include/common_cells \
  #-incdir ../../../cv32e40p/rtl/vendor \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/src \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906 \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk/rtl \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpu_div_sqrt_mvp \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_fpu_div_sqrt_mvp/hdl \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/src \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/src/deprecated \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include \
  #-incdir ../../../cv32e40p/rtl/vendor/pulp_platform_common_cells/include/common_cells \

if [[ "$?" != "0" ]]; then
  echo "Netlist compilation failed."
  exit -1
fi

rm -rf xcelium.d
rm -f xrun.history

echo "------------------------------------------------------------------------------"
echo "-- FILES IN THE NETLIST ------------------------------------------------------"
echo "------------------------------------------------------------------------------"
cat src_file_list.txt
echo "------------------------------------------------------------------------------"
echo "-- Netlist verification successful"
echo "------------------------------------------------------------------------------"

exit 0
