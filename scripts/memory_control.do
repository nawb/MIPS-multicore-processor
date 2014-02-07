onerror {resume}
quietly WaveActivateNextPane {} 0
#add wave -noupdate /memory_control_tb/nRST
add wave -noupdate /memory_control_tb/ramif/ramaddr
add wave -noupdate /memory_control_tb/ramif/ramload
add wave -noupdate /memory_control_tb/ramif/ramstore
#add wave -noupdate /memory_control_tb/ramif/ramstate
add wave -noupdate /memory_control_tb/ramif/ramWEN
add wave -noupdate /memory_control_tb/DUT/ramif/ramREN
#add wave -noupdate /memory_control_tb/ccif/iREN
#add wave -noupdate /memory_control_tb/ccif/dREN
#add wave -noupdate /memory_control_tb/ccif/dWEN
#add wave -noupdate /memory_control_tb/ccif/iwait
#add wave -noupdate /memory_control_tb/ccif/dwait
#add wave -noupdate /memory_control_tb/ccif/dload
#add wave -noupdate /memory_control_tb/ccif/dstore
#add wave -noupdate /memory_control_tb/ccif/iload
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {224538 ps} 0}
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
WaveRestoreZoom {0 ps} {525 ns}
