onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /datapath_tb/CLK
add wave -noupdate /datapath_tb/DUT/dpif/halt
add wave -noupdate /datapath_tb/DUT/dpif/ihit
add wave -noupdate /datapath_tb/DUT/dpif/imemREN
add wave -noupdate /datapath_tb/DUT/dpif/imemload
add wave -noupdate /datapath_tb/DUT/dpif/imemaddr
add wave -noupdate /datapath_tb/DUT/dpif/dhit
add wave -noupdate /datapath_tb/DUT/dpif/datomic
add wave -noupdate /datapath_tb/DUT/dpif/dmemREN
add wave -noupdate /datapath_tb/DUT/dpif/dmemWEN
add wave -noupdate /datapath_tb/DUT/dpif/flushed
add wave -noupdate /datapath_tb/DUT/dpif/dmemload
add wave -noupdate /datapath_tb/DUT/dpif/dmemstore
add wave -noupdate /datapath_tb/DUT/dpif/dmemaddr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {174 ns} 0}
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
