onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /datapath_tb/CLK
add wave -noupdate /datapath_tb/DUT/dpif/halt
add wave -noupdate /datapath_tb/DUT/dpif/imemREN
add wave -noupdate /datapath_tb/DUT/dpif/imemload
add wave -noupdate /datapath_tb/DUT/ppif/FD_in
add wave -noupdate /datapath_tb/DUT/ppif/FD_out
add wave -noupdate /datapath_tb/DUT/cuif/instr
add wave -noupdate /datapath_tb/DUT/dpif/imemaddr
add wave -noupdate /datapath_tb/DUT/dpif/dmemREN
add wave -noupdate /datapath_tb/DUT/dpif/dmemWEN
add wave -noupdate /datapath_tb/DUT/dpif/dmemload
add wave -noupdate /datapath_tb/DUT/dpif/dmemstore
add wave -noupdate /datapath_tb/DUT/dpif/dmemaddr
add wave -noupdate -expand -group rs /datapath_tb/DUT/rfif/rsel1
add wave -noupdate -expand -group rs /datapath_tb/DUT/rfif/rdat1
add wave -noupdate -expand -group rt -radix unsigned /datapath_tb/DUT/rfif/rsel2
add wave -noupdate -expand -group rt /datapath_tb/DUT/rfif/rdat2
add wave -noupdate -expand -group rd -radix unsigned /datapath_tb/DUT/rfif/wsel
add wave -noupdate -expand -group rd /datapath_tb/DUT/rfif/wdat
add wave -noupdate -expand -group ALU -radix binary /datapath_tb/DUT/ALU/aluif/opcode
add wave -noupdate -expand -group ALU /datapath_tb/DUT/ALU/aluif/op1
add wave -noupdate -expand -group ALU /datapath_tb/DUT/ALU/aluif/op2
add wave -noupdate -expand -group ALU /datapath_tb/DUT/ALU/aluif/res
add wave -noupdate -expand -group {Control Signals} /datapath_tb/DUT/CU/cuif/regdst
add wave -noupdate -expand -group {Control Signals} /datapath_tb/DUT/CU/cuif/extop
add wave -noupdate -expand -group {Control Signals} /datapath_tb/DUT/CU/cuif/memwr
add wave -noupdate -expand -group {Control Signals} /datapath_tb/DUT/CU/cuif/memtoreg
add wave -noupdate -expand -group {Control Signals} /datapath_tb/DUT/CU/cuif/regwr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {37 ns} 0}
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
WaveRestoreZoom {0 ns} {525 ns}
