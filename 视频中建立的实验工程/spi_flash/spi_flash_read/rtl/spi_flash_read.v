module  spi_flash_read
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_in      ,
    input   wire            miso        ,

    output  wire            cs_n        ,
    output  wire            sck         ,
    output  wire            mosi        ,
    output  wire            tx
);

wire    key_flag;
wire    [7:0]   pi_data;
wire            pi_flag;

key_filter
#(
    .CNT_MAX (20'd999_999)
)
key_filter_inst
(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .key_in     (key_in),

    .key_flag   (key_flag)
);

flash_read_ctrl   flash_read_ctrl_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .key_flag    (key_flag),
    .miso        (miso),

    .cs_n        (cs_n),
    .sck         (sck),
    .mosi        (mosi),
    .pi_data     (pi_data),
    .pi_flag     (pi_flag)
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
    .pi_data     (pi_data),
    .pi_flag     (pi_flag),

    .tx          (tx)
);

endmodule
