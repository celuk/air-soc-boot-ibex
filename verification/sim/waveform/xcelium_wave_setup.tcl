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
if {[catch {window new WaveWindow -name "Waveform 1" -geometry 1920x1043+0+0}] != ""} {
    window geometry "Waveform 1" 1920x1043+0+0
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
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.adr_r[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.clk100}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.clk_ddr}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.clk_ddr_dqs}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.clk_i}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.clk_ref}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.command_r}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.data_read_w[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.data_write_r[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_addr[13:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_ba[2:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_cas_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_ck_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_ck_p}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_cke}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_cs_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_dm[1:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_dq[15:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_dqs_n[1:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_dqs_p[1:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_odt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_ras_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_reset_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ddr3_we_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.nonseq[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.power_up_r}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ram_accept}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ram_accept_r}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ram_ack}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ram_ack_r}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ram_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ram_rd}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ram_rd_data[127:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ram_req_id[15:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ram_wr}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.ram_wr_data[127:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.re_r}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.reset_i}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.rst_i}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.rwnonseq[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.rwseq[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.timer_r[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.timer_rst_r}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.trcd[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.trfc[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.trp[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.wb_ack_o}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.wb_adr_i[7:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.wb_cyc_i}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.wb_dat_i[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.wb_dat_o[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.wb_sel_i[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.wb_stb_i}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.wb_we_i}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_dut.dram_iface_dut.we_r}]}
	} ]]
