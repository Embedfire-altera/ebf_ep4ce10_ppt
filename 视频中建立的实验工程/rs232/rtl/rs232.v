module  rs232
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            rx          ,

    output  wire            tx
);

wire    [7:0]   rx_data ;
wire            rx_flag ;

uart_rx 
#(
    .UART_BPS    (9600          ),
    .CLK_FREQ    (50_000_000    )
)
uart_rx_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .rx          (rx),

    .po_data     (rx_data),
    .po_flag     (rx_flag)
);

uart_tx
#(
    .UART_BPS    (9600      ),
    .CLK_FREQ    (50_000_000)
)
uart_tx_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .pi_data     (rx_data),
    .pi_flag     (rx_flag),

    .tx          (tx)
);

endmodule
