quit -sim

vcom -check_synthesis edge_detector/src/types.vhd
vcom -check_synthesis edge_detector/src/clock.vhd
vcom -check_synthesis edge_detector/src/edge_detection_accelerator.vhd
vcom -check_synthesis edge_detector/src/memory.vhd

vcom -check_synthesis edge_detector/tests/edge_detection_accelerator_test.vhd

vsim edge_detection_accelerator_test

restart -force -nowave

add wave -noupdate -divider -height 25 "Clock and reset"
add wave -noupdate /edge_detection_accelerator_test/clk
add wave -noupdate /edge_detection_accelerator_test/reset

add wave -noupdate -divider -height 25 "Edge detector"
add wave -noupdate /edge_detection_accelerator_test/start
add wave -noupdate /edge_detection_accelerator_test/req
add wave -noupdate /edge_detection_accelerator_test/dataR
add wave -noupdate /edge_detection_accelerator_test/dataW
add wave -noupdate /edge_detection_accelerator_test/rw
add wave -noupdate /edge_detection_accelerator_test/finish

add wave -noupdate -divider -height 25 "Edge detector internal"
add wave -noupdate /edge_detection_accelerator_test/i_acc_0/read_addr
add wave -noupdate /edge_detection_accelerator_test/i_acc_0/write_addr
add wave -noupdate /edge_detection_accelerator_test/i_acc_0/pixel_in
add wave -noupdate /edge_detection_accelerator_test/i_acc_0/pixel_out
add wave -noupdate /edge_detection_accelerator_test/i_acc_0/next_state
add wave -noupdate /edge_detection_accelerator_test/i_acc_0/state

WaveRestoreZoom {0 ms} {200 ms}

run 200 ms
