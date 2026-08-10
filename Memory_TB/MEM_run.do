vdel -all
vlib work

vlog ./RTL/axi_memory.v
vlog ./RTL/axi_memory_fixed.v
vlog ./Memory_TB/memory_packet.sv
vlog ./Memory_TB/memory_tb.sv

vsim -voptargs=+acc work.memory_tb

add wave *

run -all