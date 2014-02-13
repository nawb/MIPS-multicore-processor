onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate -expand -group ALU -radix symbolic /system_tb/DUT/CPU/DP/ALU/aluif/opcode
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/ALU/aluif/op1
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/ALU/aluif/op2
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/ALU/aluif/res
add wave -noupdate -expand -group RFILE -expand -group rs -radix unsigned /system_tb/DUT/CPU/DP/RF/rfif/rsel1
add wave -noupdate -expand -group RFILE -expand -group rs /system_tb/DUT/CPU/DP/RF/rfif/rdat1
add wave -noupdate -expand -group RFILE -expand -group rt -radix unsigned /system_tb/DUT/CPU/DP/RF/rfif/rsel2
add wave -noupdate -expand -group RFILE -expand -group rt /system_tb/DUT/CPU/DP/RF/rfif/rdat2
add wave -noupdate -expand -group RFILE -expand -group rd -radix unsigned /system_tb/DUT/CPU/DP/RF/rfif/wsel
add wave -noupdate -expand -group RFILE -expand -group rd /system_tb/DUT/CPU/DP/RF/rfif/wdat
add wave -noupdate /system_tb/DUT/CPU/DP/RF/rfif/WEN
add wave -noupdate /system_tb/DUT/CPU/DP/RF/rfile
add wave -noupdate /system_tb/DUT/CPU/DP/PC/pcif/imemaddr
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/regdst
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/extop
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/alu_op
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/alu_src
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/pc_src
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/memwr
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/memtoreg
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/regwr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {132599 ps} 0}
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
WaveRestoreZoom {0 ps} {1053084 ps}
