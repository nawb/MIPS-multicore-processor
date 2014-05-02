onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/PC/pc_cnt
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/PC/pcif/imemaddr
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/PC/pcif/pcEN
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/pcif/pc_src
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/pcif/branchmux
add wave -noupdate /system_tb/DUT/CPU/DP/ppif/DE_out.imm16
add wave -noupdate /system_tb/DUT/CPU/DP/ppif/DE_out.imm26
add wave -noupdate /system_tb/DUT/CPU/DP/pcif/imm26
add wave -noupdate /system_tb/DUT/CPU/DP/pcif/imm16
add wave -noupdate /system_tb/DUT/CPU/DP/hzif/branching
add wave -noupdate /system_tb/DUT/CPU/DP/hzif/jumping
add wave -noupdate -expand -group FLUSHES /system_tb/DUT/CPU/DP/hzif/FDflush
add wave -noupdate -expand -group FLUSHES /system_tb/DUT/CPU/DP/hzif/DEflush
add wave -noupdate -expand -group FLUSHES /system_tb/DUT/CPU/DP/hzif/EMflush
add wave -noupdate -expand -group FLUSHES /system_tb/DUT/CPU/DP/hzif/MWflush
add wave -noupdate -expand -group FLUSHES /system_tb/DUT/CPU/DP/hzif/halt
add wave -noupdate -expand -group {DP Layer} /system_tb/DUT/CPU/DP/dpif/imemload
add wave -noupdate -height 20 -expand -group RFILE -expand -group rs -radix unsigned /system_tb/DUT/CPU/DP/RF/rfif/rsel1
add wave -noupdate -height 20 -expand -group RFILE -expand -group rs /system_tb/DUT/CPU/DP/RF/rfif/rdat1
add wave -noupdate -height 20 -expand -group RFILE -expand -group rt -radix unsigned /system_tb/DUT/CPU/DP/RF/rfif/rsel2
add wave -noupdate -height 20 -expand -group RFILE -expand -group rt /system_tb/DUT/CPU/DP/RF/rfif/rdat2
add wave -noupdate /system_tb/DUT/CPU/DP/RF/rfile
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/fwif/fwd_op1
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/fwif/fwd_op2
add wave -noupdate -expand -group ALU -label ALU_src /system_tb/DUT/CPU/DP/ppif/DE_out.alu_src
add wave -noupdate -expand -group ALU -radix symbolic /system_tb/DUT/CPU/DP/ALU/aluif/opcode
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/ALU/aluif/op1
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/ALU/aluif/op2
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/ALU/aluif/res
add wave -noupdate -expand -group MEMORY -group {Cache Layer} /system_tb/DUT/CPU/CM/dcif/ihit
add wave -noupdate -expand -group MEMORY -group {Cache Layer} /system_tb/DUT/CPU/CM/dcif/dhit
add wave -noupdate -expand -group MEMORY -group {Cache Layer} /system_tb/DUT/CPU/CM/dcif/imemload
add wave -noupdate -expand -group MEMORY -group {Cache Layer} {/system_tb/DUT/CPU/CM/ccif/iwait[0]}
add wave -noupdate -expand -group MEMORY -group {Cache Layer} {/system_tb/DUT/CPU/CM/ccif/iload[0]}
add wave -noupdate -expand -group MEMORY -group {Cache Layer} {/system_tb/DUT/CPU/CM/ccif/dload[0]}
add wave -noupdate -expand -group MEMORY /system_tb/DUT/CPU/dcif/dmemaddr
add wave -noupdate -expand -group MEMORY /system_tb/DUT/CPU/dcif/dmemload
add wave -noupdate -expand -group MEMORY -label dmemstore /system_tb/DUT/CPU/DP/ppif/EM_out.dmemstore
add wave -noupdate -expand -group MEMORY -group addresshandlin {/system_tb/DUT/CPU/CC/ccif/iREN[0]}
add wave -noupdate -expand -group MEMORY -group addresshandlin {/system_tb/DUT/CPU/CC/ccif/dREN[0]}
add wave -noupdate -expand -group MEMORY -group addresshandlin {/system_tb/DUT/CPU/CC/ccif/dWEN[0]}
add wave -noupdate -expand -group MEMORY -group addresshandlin {/system_tb/DUT/CPU/CC/ccif/iaddr[0]}
add wave -noupdate -expand -group MEMORY -group addresshandlin {/system_tb/DUT/CPU/CC/ccif/daddr[0]}
add wave -noupdate -expand -group MEMORY /system_tb/DUT/CPU/CC/ccif/ramaddr
add wave -noupdate -expand -group MEMORY /system_tb/DUT/CPU/ccif/ramWEN
add wave -noupdate -expand -group MEMORY /system_tb/DUT/CPU/ccif/ramREN
add wave -noupdate -expand -group MEMORY -expand -group RegDst -label RegDst /system_tb/DUT/CPU/DP/ppif/EM_out.regdst
add wave -noupdate -expand -group MEMORY -expand -group RegDst -label rd -radix unsigned /system_tb/DUT/CPU/DP/ppif/EM_out.rd
add wave -noupdate -expand -group MEMORY -expand -group RegDst -label rt -radix unsigned /system_tb/DUT/CPU/DP/ppif/EM_out.rt
add wave -noupdate -expand -group MEMORY -expand -group RegDst -label wsel -radix unsigned /system_tb/DUT/CPU/DP/ppif/MW_in.wsel
add wave -noupdate -expand -group WRITEBACK /system_tb/DUT/CPU/DP/RF/rfif/WEN
add wave -noupdate -expand -group WRITEBACK -radix unsigned /system_tb/DUT/CPU/DP/ppif/MW_out.wsel
add wave -noupdate -expand -group WRITEBACK -expand -group MemToReg -label memtoreg /system_tb/DUT/CPU/DP/ppif/MW_out.memtoreg
add wave -noupdate -expand -group WRITEBACK -expand -group MemToReg -label alu_res /system_tb/DUT/CPU/DP/ppif/MW_out.alu_res
add wave -noupdate -expand -group WRITEBACK -expand -group MemToReg -label dmemload /system_tb/DUT/CPU/DP/ppif/MW_out.dmemload
add wave -noupdate /system_tb/DUT/CPU/DP/RF/rfile
add wave -noupdate -group {Memory Control} {/system_tb/DUT/CPU/CC/ccif/iwait[0]}
add wave -noupdate -group {Memory Control} {/system_tb/DUT/CPU/CC/ccif/dwait[0]}
add wave -noupdate -group {Memory Control} {/system_tb/DUT/CPU/CC/ccif/iload[0]}
add wave -noupdate -group {Memory Control} {/system_tb/DUT/CPU/CC/ccif/dload[0]}
add wave -noupdate -group singlecycle /system_tb/DUT/CPU/CLK
add wave -noupdate -group singlecycle /system_tb/DUT/CPU/nRST
add wave -noupdate -group singlecycle /system_tb/DUT/CPU/halt
add wave -noupdate /system_tb/CLK
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {577142 ps} 0}
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
