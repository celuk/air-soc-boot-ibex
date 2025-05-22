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
	{$dbNames(realName1)::[format {air_soc.TZQCS}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.TZQINIT}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.TZQOPER}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.cache_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.cache_be[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.cache_gnt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.cache_rdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.cache_req}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.cache_rvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.cache_wdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.cache_we}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.clk100}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.clk_ddr}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.clk_ddr_dqs}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.clk_i}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.clk_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.clk_p}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.clk_ref}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.clkwiz_o}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.data_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.data_be[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.data_gnt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.data_rdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.data_req}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.data_rvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.data_wdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.data_we}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_addr[13:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_ba[2:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_cas_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_ck_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_ck_p}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_cke}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_cs_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_dm[1:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_dq[15:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_dqs_n[1:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_dqs_p[1:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_odt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_ras_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_reset_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.ddr3_we_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dmem_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dmem_be[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dmem_gnt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dmem_rdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dmem_req}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dmem_rvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dmem_wdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dmem_we}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dmem_wvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_be[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_gnt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_rdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_req}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_rvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_wdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.dram_we}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.imem_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.imem_gnt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.imem_rdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.imem_req}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.imem_rvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.instr_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.instr_gnt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.instr_rdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.instr_req}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.instr_rvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.mem_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.mem_be[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.mem_rdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.mem_req}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.mem_rvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.mem_wdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.mem_we}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.pll_locked}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.prog_mode_led_o}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.program_rx_i}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi_be[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi_gnt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi_rdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi_req}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi_rvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi_wdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.qspi_we}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.req_count[4:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.rst_n}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.rst_ni}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.system_reset_o}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.timer_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.timer_be[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.timer_gnt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.timer_rdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.timer_req}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.timer_rvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.timer_wdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.timer_we}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.uart_addr[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.uart_be[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.uart_gnt}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.uart_rdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.uart_req}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.uart_rvalid}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.uart_rx_i}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.uart_tx_o}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.uart_wdata[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {air_soc.uart_we}]}
	} ]]
