onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /alu_tb/nRST
add wave -noupdate /alu_tb/op1
add wave -noupdate /alu_tb/op2
add wave -noupdate /alu_tb/res
add wave -noupdate /alu_tb/opcode
add wave -noupdate /alu_tb/flag_n
add wave -noupdate /alu_tb/flag_v
add wave -noupdate /alu_tb/flag_z
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {36 ns} 0}
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
