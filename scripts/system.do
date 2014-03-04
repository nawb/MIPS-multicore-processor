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
add wave -noupdate -expand -group BLOCKS /system_tb/DUT/CPU/DP/dpif/ihit
add wave -noupdate -expand -group BLOCKS /system_tb/DUT/CPU/DP/dpif/dhit
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/WEN
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} -radix unsigned /system_tb/DUT/CPU/DP/rfif/wsel
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} -radix unsigned /system_tb/DUT/CPU/DP/rfif/rsel1
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} -radix unsigned /system_tb/DUT/CPU/DP/rfif/rsel2
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/wdat
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/rdat1
add wave -noupdate -expand -group BLOCKS -expand -group {REGISTER FILE} /system_tb/DUT/CPU/DP/rfif/rdat2
add wave -noupdate -height 40 -expand -group DECODE -expand /system_tb/DUT/CPU/DP/ppif/FD_out
add wave -noupdate -height 40 -expand -group EXECUTE -childformat {{/system_tb/DUT/CPU/DP/ppif/DE_out.rd -radix unsigned} {/system_tb/DUT/CPU/DP/ppif/DE_out.rs -radix unsigned} {/system_tb/DUT/CPU/DP/ppif/DE_out.rt -radix unsigned}} -expand -subitemconfig {/system_tb/DUT/CPU/DP/ppif/DE_out.rd {-height 17 -radix unsigned} /system_tb/DUT/CPU/DP/ppif/DE_out.rs {-height 17 -radix unsigned} /system_tb/DUT/CPU/DP/ppif/DE_out.rt {-height 17 -radix unsigned}} /system_tb/DUT/CPU/DP/ppif/DE_out
add wave -noupdate -height 40 -expand -group MEMORY {/system_tb/DUT/CPU/CC/ccif/dREN[0]}
add wave -noupdate -height 40 -expand -group MEMORY {/system_tb/DUT/CPU/CC/ccif/dWEN[0]}
add wave -noupdate -height 40 -expand -group MEMORY {/system_tb/DUT/CPU/CC/ccif/dload[0]}
add wave -noupdate -height 40 -expand -group MEMORY {/system_tb/DUT/CPU/CC/ccif/dstore[0]}
add wave -noupdate -height 40 -expand -group MEMORY {/system_tb/DUT/CPU/CC/ccif/daddr[0]}
add wave -noupdate -height 40 -expand -group MEMORY -childformat {{/system_tb/DUT/CPU/DP/ppif/EM_out.rd -radix unsigned} {/system_tb/DUT/CPU/DP/ppif/EM_out.rt -radix unsigned}} -expand -subitemconfig {/system_tb/DUT/CPU/DP/ppif/EM_out.rd {-height 17 -radix unsigned} /system_tb/DUT/CPU/DP/ppif/EM_out.rt {-height 17 -radix unsigned}} /system_tb/DUT/CPU/DP/ppif/EM_out
add wave -noupdate -height 40 -expand -group WRITEBACK -childformat {{/system_tb/DUT/CPU/DP/ppif/MW_out.wsel -radix unsigned}} -expand -subitemconfig {/system_tb/DUT/CPU/DP/ppif/MW_out.wsel {-height 17 -radix unsigned}} /system_tb/DUT/CPU/DP/ppif/MW_out
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/BTB/nstate
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/BTB/tag
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/BTB/tag_w
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/btbif/entries
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/btbif/pc
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/btbif/pc_w
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/btbif/target
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/btbif/target_w
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/btbif/taken
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/btbif/taken_w
add wave -noupdate -expand -group BTB /system_tb/DUT/CPU/DP/btbif/WEN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {421920 ps} 0}
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
WaveRestoreZoom {0 ps} {735463 ps}
