# UART_COPI

## 概略

* UARTの送信(Controller Out/Peripheral In)回路用TB
* VerilatorとIcarus VerilogでTBをコンパイル/実行する
  * Verilator用TB：uart_copi_if_tb.cpp
  * Icarus Verilog用TB：uart_copi_if_tb.v
  * どちらのTBも.vcdで波形を出すので、GTKWave等で確認可能

## 参考

* [Verilator](https://www.veripool.org/verilator/)
  * [GitHubリポジトリ](https://github.com/verilator/verilator)
* [Icarus Verilog](http://iverilog.icarus.com/)
* [GTKWave](https://gtkwave.sourceforge.net/)
