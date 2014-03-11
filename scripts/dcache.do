onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dcache_tb/nRST
add wave -noupdate /dcache_tb/CLK
add wave -noupdate {/dcache_tb/DUT/ccif/daddr[0]}
add wave -noupdate /dcache_tb/DUT/tag
add wave -noupdate /dcache_tb/DUT/index
add wave -noupdate /dcache_tb/DUT/offset
add wave -noupdate -expand -group DATAPATH /dcache_tb/DUT/dcif/dhit
add wave -noupdate -expand -group DATAPATH /dcache_tb/DUT/dcif/dmemREN
add wave -noupdate -expand -group DATAPATH /dcache_tb/DUT/dcif/dmemWEN
add wave -noupdate -expand -group DATAPATH /dcache_tb/DUT/dcif/dmemload
add wave -noupdate -expand -group DATAPATH /dcache_tb/DUT/dcif/dmemstore
add wave -noupdate -expand -group DATAPATH /dcache_tb/DUT/dcif/dmemaddr
add wave -noupdate -expand -group {MEMORY CONTROL} {/dcache_tb/DUT/ccif/dwait[0]}
add wave -noupdate -expand -group {MEMORY CONTROL} {/dcache_tb/DUT/ccif/dREN[0]}
add wave -noupdate -expand -group {MEMORY CONTROL} {/dcache_tb/DUT/ccif/dWEN[0]}
add wave -noupdate -expand -group {MEMORY CONTROL} {/dcache_tb/DUT/ccif/dload[0]}
add wave -noupdate -expand -group {MEMORY CONTROL} {/dcache_tb/DUT/ccif/dstore[0]}
add wave -noupdate /dcache_tb/DUT/cache
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {97619 ps} 0}
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
WaveRestoreZoom {0 ps} {278250 ps}
