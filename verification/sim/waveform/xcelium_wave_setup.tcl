# SimVision Command Script (Cum May 23 01:15:43 +03 2025)
#
# Version 24.03.s001
#
# You can restore this configuration with:
#
#     simvision -input simvision.svcf
#  or simvision -input simvision.svcf database1 database2 ...
#


#
# Preferences
#
preferences set plugin-enable-svdatabrowser-new 1
preferences set plugin-enable-groupscope 0
preferences set plugin-enable-interleaveandcompare 0
preferences set plugin-enable-waveformfrequencyplot 0

#
# Databases
#
array set dbNames ""
set dbNames(realName1) [ database require cocotb_waves -hints {
	file ./verification/sim/sim_build/cocotb_waves.shm/cocotb_waves.trn
	file /home/shc/projects/air-soc-boot/verification/sim/sim_build/cocotb_waves.shm/cocotb_waves.trn
}]
if {$dbNames(realName1) == ""} {
    set dbNames(realName1) cocotb_waves
}

#
# Mnemonic Maps
#
mmap new  -reuse -name {Boolean as Logic} -radix %b -contents {{%c=FALSE -edgepriority 1 -shape low}
{%c=TRUE -edgepriority 1 -shape high}}
mmap new  -reuse -name {Example Map} -radix %x -contents {{%b=11???? -bgcolor orange -label REG:%x -linecolor yellow -shape bus}
{%x=1F -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=2C -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=* -label %x -linecolor gray -shape bus}}

#
# Waveform windows
#
if {[catch {window new WaveWindow -name "Waveform 1" -geometry 1920x675+128+74}] != ""} {
    window geometry "Waveform 1" 1920x675+128+74
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar select designbrowser
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units ns \
    -valuewidth 75
waveform baseline set -time 0

set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi.qspi_iface_dut.clk_i}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi.qspi_iface_dut.qspi_cs_n_o}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi.qspi_iface_dut.qspi_sck_o}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi.qspi_iface_dut.bit_counter[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi.qspi_iface_dut.qspi_data_i[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi.qspi_iface_dut.qspi_data_o[3:0]}]}
	} ]]

waveform xview limits 1012082.966ns 1013563.368ns

#
# Waveform Window Links
#

#
# Layout selection
#

