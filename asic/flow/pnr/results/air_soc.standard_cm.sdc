# ####################################################################

#  Created by Genus(TM) Synthesis Solution 22.13-s093_1 on Fri Aug 30 21:25:10 +03 2024

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design air_soc

create_clock -name "clk_i" -period 10.0 -waveform {0.0 5.0} [get_ports clk_i]
set_load -pin_load 2.0 [get_ports uart_tx_o]
set_load -pin_load 2.0 [get_ports qspi_cs_n_o]
set_load -pin_load 2.0 [get_ports qspi_sck_o]
set_load -pin_load 2.0 [get_ports {gpio_o[15]}]
set_load -pin_load 2.0 [get_ports {gpio_o[14]}]
set_load -pin_load 2.0 [get_ports {gpio_o[13]}]
set_load -pin_load 2.0 [get_ports {gpio_o[12]}]
set_load -pin_load 2.0 [get_ports {gpio_o[11]}]
set_load -pin_load 2.0 [get_ports {gpio_o[10]}]
set_load -pin_load 2.0 [get_ports {gpio_o[9]}]
set_load -pin_load 2.0 [get_ports {gpio_o[8]}]
set_load -pin_load 2.0 [get_ports {gpio_o[7]}]
set_load -pin_load 2.0 [get_ports {gpio_o[6]}]
set_load -pin_load 2.0 [get_ports {gpio_o[5]}]
set_load -pin_load 2.0 [get_ports {gpio_o[4]}]
set_load -pin_load 2.0 [get_ports {gpio_o[3]}]
set_load -pin_load 2.0 [get_ports {gpio_o[2]}]
set_load -pin_load 2.0 [get_ports {gpio_o[1]}]
set_load -pin_load 2.0 [get_ports {gpio_o[0]}]
set_load -pin_load 2.0 [get_ports usb_dp_pu_o]
set_load -pin_load 2.0 [get_ports usb_tx_en_o]
set_load -pin_load 2.0 [get_ports usb_dp_tx_o]
set_load -pin_load 2.0 [get_ports usb_dn_tx_o]
set_load -pin_load 2.0 [get_ports {qspi_data_io[3]}]
set_load -pin_load 2.0 [get_ports {qspi_data_io[2]}]
set_load -pin_load 2.0 [get_ports {qspi_data_io[1]}]
set_load -pin_load 2.0 [get_ports {qspi_data_io[0]}]
set_load -pin_load 2.0 [get_ports sda_io]
set_load -pin_load 2.0 [get_ports scl_io]
set_clock_gating_check -setup 0.0 
set_input_transition 1.0 [get_ports clk_i]
set_input_transition 1.0 [get_ports rst_ni]
set_input_transition 1.0 [get_ports uart_rx_i]
set_input_transition 1.0 [get_ports {gpio_i[15]}]
set_input_transition 1.0 [get_ports {gpio_i[14]}]
set_input_transition 1.0 [get_ports {gpio_i[13]}]
set_input_transition 1.0 [get_ports {gpio_i[12]}]
set_input_transition 1.0 [get_ports {gpio_i[11]}]
set_input_transition 1.0 [get_ports {gpio_i[10]}]
set_input_transition 1.0 [get_ports {gpio_i[9]}]
set_input_transition 1.0 [get_ports {gpio_i[8]}]
set_input_transition 1.0 [get_ports {gpio_i[7]}]
set_input_transition 1.0 [get_ports {gpio_i[6]}]
set_input_transition 1.0 [get_ports {gpio_i[5]}]
set_input_transition 1.0 [get_ports {gpio_i[4]}]
set_input_transition 1.0 [get_ports {gpio_i[3]}]
set_input_transition 1.0 [get_ports {gpio_i[2]}]
set_input_transition 1.0 [get_ports {gpio_i[1]}]
set_input_transition 1.0 [get_ports {gpio_i[0]}]
set_input_transition 1.0 [get_ports usb_dp_rx_i]
set_input_transition 1.0 [get_ports usb_dn_rx_i]
set_input_transition 1.0 [get_ports {qspi_data_io[3]}]
set_input_transition 1.0 [get_ports {qspi_data_io[2]}]
set_input_transition 1.0 [get_ports {qspi_data_io[1]}]
set_input_transition 1.0 [get_ports {qspi_data_io[0]}]
set_input_transition 1.0 [get_ports sda_io]
set_input_transition 1.0 [get_ports scl_io]
