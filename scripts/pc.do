onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pc_tb/CLK
add wave -noupdate /pc_tb/nRST
add wave -noupdate /pc_tb/DUT/pcif/imm26
add wave -noupdate /pc_tb/DUT/pcif/immext
add wave -noupdate /pc_tb/DUT/pcif/branchmux
add wave -noupdate /pc_tb/DUT/pcif/jumpmux
add wave -noupdate /pc_tb/DUT/pcif/imemaddr
add wave -noupdate /pc_tb/DUT/pc_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {895 ns} 0}
quietly wave cursor active 1
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1050 ns}
