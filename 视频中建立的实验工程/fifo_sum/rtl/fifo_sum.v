module  fifo_sum
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            rx          ,

    output  wire            tx
);

parameter   CLK_FREQ = 50_000_000;

wire    [7:0]   rx_data ;
wire            rx_flag ;
wire    [7:0]   tx_data ;
wire            tx_flag ;

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
    .pi_data     (tx_data),
    .pi_flag     (tx_flag),

    .tx          (tx)
);

fifo_sum_ctrl   fifo_sum_ctrl_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .pi_flag     (rx_flag),
    .pi_data     (rx_data),

    .po_flag     (tx_flag),
    .po_data     (tx_data)
);


endmodule