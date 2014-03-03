onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemload
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/halt
add wave -noupdate -expand -group BLOCKS -expand -group PC /system_tb/DUT/CPU/DP/pcif/imm26
add wave -noupdate -expand -group BLOCKS -expand -group PC /system_tb/DUT/CPU/DP/pcif/imm16
add wave -noupdate -expand -group BLOCKS -expand -group PC /system_tb/DUT/CPU/DP/pcif/regval
add wave -noupdate -expand -group BLOCKS -expand -group PC /system_tb/DUT/CPU/DP/pcif/pc_src
add wave -noupdate -expand -group BLOCKS -expand -group PC /system_tb/DUT/CPU/DP/pcif/branchmux
add wave -noupdate -expand -group BLOCKS -expand -group PC /system_tb/DUT/CPU/DP/pcif/imemaddr
add wave -noupdate -expand -group BLOCKS -expand -group PC /system_tb/DUT/CPU/DP/pcif/pcEN
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/WEN
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/wsel
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/rsel1
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/rsel2
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/wdat
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/rdat1
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/rdat2
add wave -noupdate -height 40 -expand -group DECODE -expand /system_tb/DUT/CPU/DP/ppif/FD_out
add wave -noupdate -height 40 -expand -group EXECUTE -expand /system_tb/DUT/CPU/DP/ppif/DE_out
add wave -noupdate -height 40 -expand -group MEMORY -expand /system_tb/DUT/CPU/DP/ppif/EM_out
add wave -noupdate -height 40 -expand -group WRITEBACK -expand /system_tb/DUT/CPU/DP/ppif/MW_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1019206 ps} 0}
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
WaveRestoreZoom {502500 ps} {1552500 ps}
