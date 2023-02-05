`timescale 1ps/1ps
module uart_copi_if_tb();
reg clk;
reg reset;
reg send_data_flag;
wire ser_data;
wire[1:0] state_drv;
reg [7:0] input_data_array[0:11];
reg [3:0] input_data_cnt;
reg [7:0] input_data_char;

uart_copi_if drv_if(clk, reset, input_data_char, send_data_flag, ser_data, state_drv);

initial begin
    $dumpfile("uart_copi_if_tb.vcd"); //dump .vcd file
    $dumpvars(0, uart_copi_if_tb);     // set dump target "all"
    clk <= 0;
    reset <= 0;
    input_data_cnt <= 4'd0;
    input_data_char <= 7'd0;
    send_data_flag <= 0;
    input_data_array[0] <= "H";
    input_data_array[1] <= "e";
    input_data_array[2] <= "l";
    input_data_array[3] <= "l";
    input_data_array[4] <= "o";
    input_data_array[5] <= "_";
    input_data_array[6] <= "W";
    input_data_array[7] <= "o";
    input_data_array[8] <= "r";
    input_data_array[9] <= "l";
    input_data_array[10] <= "d";
    input_data_array[11] <= "\n";

    #10
        reset <= 1;
    // #99999990
    // #9999990
    // #999990
    // #99990
    // #9990
    #990
    // #90
        $finish;
end

always begin
    #11
        input_data_char <= input_data_array[input_data_cnt];
    #1
        send_data_flag <= 1;
        input_data_cnt <= (input_data_cnt + 1) % 12;
    #4
        // $display("%d, %c", input_data_cnt , input_data_char);
        send_data_flag <= 0;
    #48
        send_data_flag <= 0;
end

always #1
    clk <= ~clk;

endmodule