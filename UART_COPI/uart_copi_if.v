/* verilator lint_off DECLFILENAME */
/*
 * Start   : 1bit : H -> L
 * data    : 8bit : LSB_First
 * Parity  : None : None or Odd or Even
 * Stop    : 1bit : L -> H
 * Disable : H
 * state_machine/serializer : negedge
 * PHY : posedge
 * READY -> SendStartBit
 * RUN -> SendSerData
 * Done -> SendStopBit
 * Interval between completion of transmission and start of reading next data: 3clk
 * See https://www.analog.com/jp/analog-dialogue/articles/uart-a-hardware-communication-protocol.html
 */

`default_nettype none

module uart_copi_if(
    input CLK,
    input RESET,
    input[7:0] INPUT_DATA_REG,
    input START_SEND_DATA,
    output SER_DATA,
    output[1:0] STATE
);

wire[1:0] state; // 00->RESET/STBY 10->READY 01->RUN 11->DONE
wire done_ser_data;
wire ir_ser_data;

uart_copi_state_machine st(CLK, RESET, START_SEND_DATA, done_ser_data, state);
// uart_copi_serializer ser(CLK, state, INPUT_DATA_REG, done_ser_data, ir_ser_data);
// uart_copi_phy phy(CLK, state, done_ser_data, ir_ser_data, SER_DATA);
uart_copi_serializer ser(CLK, state, INPUT_DATA_REG, done_ser_data, SER_DATA);

assign STATE = state;

endmodule

module uart_copi_state_machine(
    input CLK,
    input RESET,
    input START_SEND_DATA,
    input DONE_SER_DATA,
    output[1:0] oSTATE
);

parameter RESET_STBY = 2'b00;
parameter READY = 2'b10;
parameter RUN = 2'b01;
parameter DONE = 2'b11;
reg[1:0] state; // 00->RESET/STBY 10->READY 01->RUN 11->DONE

reg[1:0] delay_cnt;

always @(negedge CLK)begin
// always @(posedge CLK)begin
    if(!RESET) begin
        state <= RESET_STBY;
        delay_cnt <= 2'h2;
    end else begin
        if (delay_cnt == 0) begin
            if(DONE_SER_DATA) begin
                state <= DONE;
                delay_cnt <= 2'h2;
            end else if (state == READY) begin
                state <= RUN;
            end else if (state == RUN) begin
                // pass
            end else if (START_SEND_DATA) begin
                state <= READY;
            end
        end else begin
            delay_cnt <= delay_cnt - 2'h1;
        end
    end
end
assign oSTATE = state;
endmodule

// module uart_copi_phy(
//     input CLK,
//     input[1:0] STATE,
//     input DONE_SER_DATA,
//     input IR_SER_DATA,
//     output SR_DATA
// );
// reg sr_data;

// parameter RESET_STBY = 2'b00;
// parameter READY = 2'b10;
// parameter RUN = 2'b01;
// parameter DONE = 2'b11;

// always @(posedge CLK) begin
//     if(STATE == RUN) begin
//         sr_data <= 1;
//     end else begin
//         sr_data <= 1;
//     end
// end

// assign SR_DATA = sr_data;
// endmodule

module uart_copi_serializer(
    input CLK,
    input[1:0] STATE,
    input[7:0] INPUT_DATA_REG,
    output DONE_SER_DATA,
    output SER_DATA
);
reg[4:0] data_cnt;
reg[9:0] serial_data;
reg serial_buffer;
reg done_ser_data;

parameter RESET_STBY = 2'b00;
parameter READY = 2'b10;
parameter RUN = 2'b01;
parameter DONE = 2'b11;

always @(posedge CLK) begin
    if(STATE == RESET_STBY) begin
        data_cnt <= 5'd0;
        serial_data <= 0;
        done_ser_data <= 0;
        serial_buffer <= 1;
    end else if(STATE == RUN) begin
        if(data_cnt >= 5'd1) begin
            serial_buffer <= serial_data[0];
            serial_data <= serial_data >> 1;
            data_cnt <= data_cnt - 5'd1;
        end else begin
            done_ser_data <= 1;
        end
    end else if (STATE == READY) begin
        data_cnt <= 5'd10;
        done_ser_data <= 0;
        serial_data <= {1'b1, INPUT_DATA_REG, 1'b0}; // LSB First
    end else begin
        done_ser_data <= 0;
        serial_buffer <= 1;
    end
end

assign SER_DATA = serial_buffer;
assign DONE_SER_DATA = done_ser_data;

endmodule

`default_nettype wire
