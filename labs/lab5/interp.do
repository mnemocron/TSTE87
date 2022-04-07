vlib work

vcom -93 timingcontroller.vhdl
vcom -93 memorycontroller1.vhdl
vcom -93 memorycontroller2.vhdl
vcom -93 pecontroller1.vhdl
vcom -93 pecontroller2.vhdl
vcom -93 pecontroller3.vhdl
vcom -93 pecontroller4.vhdl
vcom -93 interpolator_tb.vhdl

vsim -novopt work.interpolator_tb(behavior)
view wave
add wave sim:/interpolator_tb/clock
add wave sim:/interpolator_tb/reset
add wave sim:/interpolator_tb/state
add wave sim:/interpolator_tb/address1
add wave sim:/interpolator_tb/enable1
add wave sim:/interpolator_tb/readwrite1
add wave sim:/interpolator_tb/address2
add wave sim:/interpolator_tb/enable2
add wave sim:/interpolator_tb/readwrite2

add wave -decimal sim:/interpolator_tb/coeff1
add wave sim:/interpolator_tb/start1
add wave -decimal sim:/interpolator_tb/coeff2
add wave sim:/interpolator_tb/start2
add wave -decimal sim:/interpolator_tb/coeff3
add wave sim:/interpolator_tb/start3
add wave -decimal sim:/interpolator_tb/coeff4
add wave sim:/interpolator_tb/start4

run 1us

