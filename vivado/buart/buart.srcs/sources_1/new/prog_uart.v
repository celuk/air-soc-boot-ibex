// BASYS3 PROGRAMLAYICI UART
// Programlayici icin tek cikis da verilebilirdi. Ayni anda 8 FPGA'yi programlayabilirsiniz.
// 
// K17 ya da L17 portlarindan cikis alarak islemcinin calistigi FPGA'de program_rx_i portuna baglayin.
// Bu programlayiciyi attiginiz FPGA uzerindeki USB portunu uart_send_data.py dosyasinda belirterek diger ana FPGA'yi programlayin.
`timescale 1ns / 1ps

module prog_uart(
    input uart_rx_i, // USB rx
    input uart_coming,
    output program_tx1_o,
    output program_tx2_o,
    output led_tx_o // tx'e bagli led, programlanirken hizli hizli yanip sonuyor
);
    
    assign program_tx1_o = uart_rx_i;
    assign program_tx2_o = uart_coming;
    assign led_tx_o = program_tx2_o;
endmodule
