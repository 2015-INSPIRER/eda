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
lappend signals i_acc_0.matrix_row_1
lappend signals i_acc_0.matrix_row_2
lappend signals i_acc_0.matrix_row_3
lappend signals i_acc_0.column_count
lappend signals i_acc_0.enable_pixel_storage

# Individual pixels
lappend signals i_acc_0.i_pixel_calculator_0.pixel_1_conv_0
lappend signals i_acc_0.i_pixel_calculator_0.pixel_2_conv_0
lappend signals i_acc_0.i_pixel_calculator_0.pixel_3_conv_0
lappend signals i_acc_0.i_pixel_calculator_0.pixel_4_conv_0
lappend signals i_acc_0.i_pixel_calculator_0.pixel_5_conv_0
lappend signals i_acc_0.i_pixel_calculator_0.pixel_6_conv_0
lappend signals i_acc_0.i_pixel_calculator_0.d_x

lappend signals i_acc_0.i_pixel_calculator_0.pixel_out

# Pixel storage
lappend signals i_acc_0.i_pixel_storage_0.enable
lappend signals i_acc_0.i_pixel_storage_0.pixel_pair
lappend signals i_acc_0.i_pixel_storage_0.saved_pixel_row
lappend signals i_acc_0.saved_counter

# Writer
lappend signals i_acc_0.i_pixel_writer_0.addr
lappend signals i_acc_0.i_pixel_writer_0.data

# lappend signals i_acc_0.finish

gtkwave::addSignalsFromList $signals

gtkwave::setZoomRangeTimes 0ns 10000ns
