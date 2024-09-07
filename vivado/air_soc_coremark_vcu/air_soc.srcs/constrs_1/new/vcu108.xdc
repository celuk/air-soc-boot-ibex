## vcu108.xdc

set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {DIV-1} [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1      [current_design]
set_property CONFIG_MODE BPI16                         [current_design]

set_property -dict {LOC BC9  IOSTANDARD LVDS} [get_ports clk_p]
set_property -dict {LOC BC8  IOSTANDARD LVDS} [get_ports clk_n]
create_clock -period 8.000 -name clk_125mhz_p [get_ports clk_p]

set_property -dict {LOC BC40 IOSTANDARD LVCMOS12} [get_ports {rst_ni}]

# PROGRAMLAYICI UART
#set_property -dict {LOC BC14 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {program_rx_i}]

# UART
set_property -dict {LOC BE24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_tx_o]
set_property -dict {LOC BC24 IOSTANDARD LVCMOS18} [get_ports uart_rx_i]

set_property -dict {LOC P22 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qspi_data_io[0]}]
set_property -dict {LOC N22 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qspi_data_io[1]}]
set_property -dict {LOC J20 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qspi_data_io[2]}]
set_property -dict {LOC K24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qspi_data_io[3]}]
set_property -dict {LOC J24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qspi_cs_n_o}]
set_property -dict {LOC T23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qspi_sck_o}]
