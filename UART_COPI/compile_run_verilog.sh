# copy newest verilog_file
# cp ./../../FPGA/TinyFPGABX/lib/UART_COPI/uart_copi_if.v .
# cp ./../../FPGA/TinyFPGABX/lib/UART_COPI/uart_copi_if_tb.v .

# # compile and run Verilog code
iverilog -o uart_copi_if_tb.out -s uart_copi_if_tb uart_copi_if_tb.v uart_copi_if.v
# time ./uart_copi_if_tb.out
for VAL in `seq 10 -1 1`
do
    time vvp uart_copi_if_tb.out
done
