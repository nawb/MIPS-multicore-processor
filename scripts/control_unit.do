onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /control_unit_tb/regs
add wave -noupdate /control_unit_tb/regd
add wave -noupdate /control_unit_tb/regt
add wave -noupdate -expand -group IF -radix binary /control_unit_tb/cuif/instr
add wave -noupdate -expand -group IF /control_unit_tb/cuif/alu_flags
add wave -noupdate -expand -group ID /control_unit_tb/cuif/rs
add wave -noupdate -expand -group ID /control_unit_tb/cuif/rd
add wave -noupdate -expand -group ID /control_unit_tb/cuif/rt
add wave -noupdate -expand -group ID /control_unit_tb/cuif/regdst
add wave -noupdate -expand -group ID /control_unit_tb/cuif/extop
add wave -noupdate -expand -group EX /control_unit_tb/cuif/alu_op
add wave -noupdate -expand -group EX /control_unit_tb/cuif/alu_src
add wave -noupdate -expand -group EX /control_unit_tb/cuif/pc_src
add wave -noupdate -expand -group MEM+WB /control_unit_tb/cuif/memwr
add wave -noupdate -expand -group MEM+WB /control_unit_tb/cuif/memtoreg
add wave -noupdate -expand -group MEM+WB /control_unit_tb/cuif/regwr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {134 ns} 0}
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
