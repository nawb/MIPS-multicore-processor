onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/DUT/CPUCLK
add wave -noupdate /system_tb/DUT/halt
add wave -noupdate /system_tb/nRST
add wave -noupdate -expand -group {DP Layer} /system_tb/DUT/CPU/DP/dpif/imemload
add wave -noupdate -expand -group {Cache Layer} /system_tb/DUT/CPU/CM/dcif/ihit
add wave -noupdate -expand -group {Cache Layer} /system_tb/DUT/CPU/CM/dcif/dhit
add wave -noupdate -expand -group {Cache Layer} /system_tb/DUT/CPU/CM/dcif/imemload
add wave -noupdate -expand -group {Cache Layer} /system_tb/DUT/CPU/CM/ccif/iwait
add wave -noupdate -expand -group {Cache Layer} {/system_tb/DUT/CPU/CM/ccif/iload[0]}
add wave -noupdate -expand -group {Cache Layer} {/system_tb/DUT/CPU/CM/ccif/dload[0]}
add wave -noupdate -expand -group {Memory Control} /system_tb/DUT/CPU/CC/ccif/iwait
add wave -noupdate -expand -group {Memory Control} /system_tb/DUT/CPU/CC/ccif/dwait
add wave -noupdate -expand -group {Memory Control} {/system_tb/DUT/CPU/CC/ccif/iload[0]}
add wave -noupdate -expand -group {Memory Control} {/system_tb/DUT/CPU/CC/ccif/dload[0]}
add wave -noupdate -group singlecycle /system_tb/DUT/CPU/CLK
add wave -noupdate -group singlecycle /system_tb/DUT/CPU/nRST
add wave -noupdate -group singlecycle /system_tb/DUT/CPU/halt
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
add wave -noupdate /system_tb/DUT/CPU/dcif/dmemaddr
add wave -noupdate /system_tb/DUT/CPU/dcif/dmemload
add wave -noupdate -expand -group RAM /system_tb/DUT/RAM/ramif/ramaddr
add wave -noupdate -expand -group RAM /system_tb/DUT/CPU/CM/ccif/ramload
add wave -noupdate -expand -group RAM /system_tb/DUT/CPU/CM/ccif/ramstore
add wave -noupdate -expand -group RAM /system_tb/DUT/RAM/en
add wave -noupdate -expand -group RAM /system_tb/DUT/RAM/wren
add wave -noupdate {/system_tb/DUT/CPU/ccif/dREN[0]}
add wave -noupdate {/system_tb/DUT/CPU/ccif/dWEN[0]}
add wave -noupdate /system_tb/DUT/CPU/ccif/ramWEN
add wave -noupdate /system_tb/DUT/CPU/ccif/ramREN
add wave -noupdate /system_tb/DUT/prif/ramWEN
add wave -noupdate /system_tb/DUT/RAM/ramif/ramREN
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/regdst
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/extop
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/alu_op
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/alu_src
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/pc_src
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/memwr
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/memtoreg
add wave -noupdate -expand -group {Control Signals} /system_tb/DUT/CPU/DP/CU/cuif/regwr
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/PC/pc_cnt
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/PC/pcif/imemaddr
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/PC/pcif/pcEN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {162559 ps} 0}
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
WaveRestoreZoom {0 ps} {1050 ns}
