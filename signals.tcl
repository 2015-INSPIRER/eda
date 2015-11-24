set signals [list]

# Clock
lappend signals Clock
lappend signals i_clock_0.clk
lappend signals i_acc_0.reset

# Accelerator
lappend signals i_acc_0.start
lappend signals i_acc_0.req
lappend signals i_acc_0.rw
lappend signals i_acc_0.enable_pixel_reader_0
lappend signals i_acc_0.enable_pixel_reader_1
lappend signals i_acc_0.enable_pixel_reader_2
lappend signals i_acc_0.pixel_reader_0_addr
lappend signals i_acc_0.pixel_reader_1_addr
lappend signals i_acc_0.pixel_reader_2_addr
lappend signals i_acc_0.finish

gtkwave::addSignalsFromList $signals

gtkwave::setZoomRangeTimes 0ns 10000ns
