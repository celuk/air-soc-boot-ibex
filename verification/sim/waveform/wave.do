onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate /air_soc/clk_i
add wave -noupdate /air_soc/rst_ni

add wave -noupdate /air_soc/qspi/qspi_iface_dut/state
add wave -noupdate /air_soc/qspi/qspi_iface_dut/bit_counter
add wave -noupdate /air_soc/qspi/qspi_iface_dut/QSPI_CCR_INST

add wave -noupdate -divider flash
add wave -noupdate /air_soc/flash/SI
add wave -noupdate /air_soc/flash/SO
add wave -noupdate /air_soc/flash/WPNeg
add wave -noupdate /air_soc/flash/HOLDNeg
add wave -noupdate /air_soc/flash/CSNeg
add wave -noupdate /air_soc/flash/SCK
add wave -noupdate /air_soc/flash/RSTNeg
add wave -noupdate /air_soc/flash/WEL
add wave -noupdate /air_soc/flash/WIP
add wave -noupdate /air_soc/flash/QUAD
add wave -noupdate /air_soc/flash/Config_reg1
add wave -noupdate /air_soc/flash/Status_reg1
add wave -noupdate /air_soc/flash/Status_reg2
add wave -noupdate /air_soc/flash/P_ERR
add wave -noupdate /air_soc/flash/E_ERR
add wave -noupdate /air_soc/flash/Mem

add wave -noupdate -divider controller
add wave -noupdate /air_soc/qspi/qspi_iface_dut/*

TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update

wave zoom full
