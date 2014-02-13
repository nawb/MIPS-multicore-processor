onerror {resume}
quietly virtual function -install /memory_control_tb/CPURAM/ramif -env /memory_control_tb { &{/memory_control_tb/CPURAM/ramif/ramREN, /memory_control_tb/CPURAM/ramif/ramWEN }} ramWENREN
quietly WaveActivateNextPane {} 0
add wave -noupdate /memory_control_tb/DUT/CLK
add wave -noupdate /memory_control_tb/DUT/ccif/iwait
add wave -noupdate /memory_control_tb/DUT/ccif/dwait
add wave -noupdate -expand -group RAM /memory_control_tb/CPURAM/ramif/memREN
add wave -noupdate -expand -group RAM /memory_control_tb/CPURAM/ramif/memWEN
add wave -noupdate -expand -group RAM /memory_control_tb/CPURAM/ramif/ramREN
add wave -noupdate -expand -group RAM /memory_control_tb/CPURAM/ramif/ramWEN
add wave -noupdate -expand -group RAM /memory_control_tb/CPURAM/ramif/ramstate
add wave -noupdate /memory_control_tb/ramif/ramaddr
add wave -noupdate /memory_control_tb/ramif/ramload
add wave -noupdate /memory_control_tb/ramif/ramstore
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {201470 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 248
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
WaveRestoreZoom {175150 ps} {525463 ps}
