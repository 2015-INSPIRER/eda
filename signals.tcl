set signals [list]

# Clock
lappend signals Clock
lappend signals i_clock_0.clk
lappend signals i_acc_0.reset

# Accelerator
lappend signals i_acc_0.start
lappend signals i_acc_0.req
lappend signals i_acc_0.read_addr
lappend signals i_acc_0.next_pixel
lappend signals i_acc_0.pixel
lappend signals i_acc_0.write_addr
lappend signals i_acc_0.rw
lappend signals i_acc_0.finish

gtkwave::addSignalsFromList $signals

gtkwave::setZoomRangeTimes 0ns 10000ns
