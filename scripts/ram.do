onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ram_tb/nRST
add wave -noupdate /ram_tb/DUT/ramREN
add wave -noupdate /ram_tb/DUT/ramWEN
add wave -noupdate /ram_tb/DUT/ramaddr
add wave -noupdate /ram_tb/DUT/ramstore
add wave -noupdate /ram_tb/DUT/ramload
add wave -noupdate /ram_tb/DUT/ramstate
add wave -noupdate /ram_tb/DUT/memREN
add wave -noupdate /ram_tb/DUT/memWEN
add wave -noupdate /ram_tb/DUT/memaddr
add wave -noupdate /ram_tb/DUT/memstore
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82 ns} 0}
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
WaveRestoreZoom {0 ns} {105 ns}
