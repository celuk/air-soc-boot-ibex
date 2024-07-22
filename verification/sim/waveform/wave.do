onerror {resume}
quietly WaveActivateNextPane {} 0

#add wave -noupdate /teknofest_wrapper/flash/WPNeg
#add wave -noupdate -divider controller
#add wave -noupdate /teknofest_wrapper/soc/isl_blksiz/veriyolu_dut/qspi_denetleyici_dut/wb_adr_i

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {205870500 ps} 0} {{Cursor 2} {205585589 ps} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {205822282 ps} {205935841 ps}

