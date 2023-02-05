# copy newest verilog_file
# cp ./../../FPGA/TinyFPGABX/lib/UART_COPI/uart_copi_if.v .
# cp ./../../FPGA/TinyFPGABX/lib/UART_COPI/uart_copi_if_tb.v .

# convert a verilog file to C++ code
verilator --cc --exe \
--trace --trace-params --trace-structs --trace-underscore \
uart_copi_if.v -exe uart_copi_if_tb.cpp

# compile and run C++ code
make -C obj_dir -f Vuart_copi_if.mk
for VAL in `seq 10 -1 1`
do
    time ./obj_dir/Vuart_copi_if
done
