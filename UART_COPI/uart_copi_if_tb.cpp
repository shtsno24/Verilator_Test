// https://msyksphinz.hatenablog.com/entry/2020/05/06/040000
// https://msyksphinz.hatenablog.com/entry/2020/05/08/040000
// https://msyksphinz.hatenablog.com/entry/2020/05/10/000000
#include <iostream>
#include <cstdint>
#include <bitset>
#include <string>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vuart_copi_if.h"

uint64_t time_counter = 0;

struct UART_PACKET{
    bool start_bit;
    uint8_t data_frame;
    bool stop_bit;
};

void print_packets(uint32_t cnt, UART_PACKET& packets){
    std::cout << "cnt : " << cnt << ", ";
    std::cout << std::hex;
    std::cout << std::boolalpha;
    std::cout << "start_bit : " << packets.start_bit << ", ";
    std::cout << "0b"<< static_cast<std::bitset<8>>(packets.data_frame) << " : 0x" << (uint32_t)(packets.data_frame) << " : ";
    if(std::isprint(char(packets.data_frame))){
        std::cout << char(packets.data_frame) << ", ";
    } else {
        if(packets.data_frame == 0xA){
            std::cout << R"(\n)" << ", ";
        }
    }
    std::cout << "stop_bit : " << packets.stop_bit << std::endl;
    std::cout << std::dec;
}

int main(int argc, char** argv) {

    Verilated::commandArgs(argc, argv);

    // Instantiate DUT
    Vuart_copi_if *dut = new Vuart_copi_if();
    // Trace DUMP ON
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;

    dut->trace(tfp, 100);  // Trace 100 levels of hierarchy
    tfp->open("uart_copi_if_verilator.vcd");

    uint32_t input_data_index = 0;
    char input_data[] = "Hello_World\n";

    UART_PACKET packets;
    packets.start_bit = true;
    packets.data_frame = 0;
    packets.stop_bit = false;

    uint32_t bit_index = 0;

    // Format
    dut->RESET = 0;
    dut->CLK = 0;
    dut->START_SEND_DATA = 0;
    dut->INPUT_DATA_REG = 0;
    dut->eval();
    tfp->dump(time_counter);
    time_counter += 1;

    // while (time_counter <= 100000000) {
    // while (time_counter <= 10000000) {
    // while (time_counter <= 1000000) {
    // while (time_counter <= 100000) {
    // while (time_counter <= 10000) {
    while (time_counter <= 1000) {
    // while (time_counter <= 100) {
        if(time_counter < 10){
            dut->RESET = 0;
        } else {
            dut->RESET = 1;
        }
        if (time_counter % 64 == 11) {
            dut->INPUT_DATA_REG = input_data[input_data_index % 12];
        } else if(time_counter % 64 == 12){
            input_data_index += 1;
            dut->START_SEND_DATA = 1;   // Assert En
        } else if(time_counter % 64 > 11 && time_counter % 64 < 16){
            dut->START_SEND_DATA = 1;   // Assert En
        } else {
            dut->START_SEND_DATA = 0;   // Deassert En
        }

        dut->CLK = !dut->CLK; // Toggle clock
        // Evaluate DUT
        dut->eval();
        tfp->dump(time_counter);
        time_counter += 1;

        // if(dut->CLK == 1){
        //     if ((dut->SER_DATA == 0) && bit_index == 0){
        //         packets.start_bit = static_cast<bool>(dut->SER_DATA);
        //         packets.data_frame = 0;
        //         packets.stop_bit = false;
        //         bit_index += 1;
        //     } else if (bit_index != 0){
        //         if(bit_index == 9){
        //             packets.stop_bit = static_cast<bool>(dut->SER_DATA);
        //             bit_index = 0;
        //             print_packets(input_data_index % 12, packets);
        //         } else {
        //             packets.data_frame >>= 1;
        //             packets.data_frame |= (dut->SER_DATA & 0x01) << 7;
        //             bit_index += 1;
        //         }
        //     }
        // }
    }

    dut->final();
    tfp->close(); 
}