module  rs485
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_in_w    ,
    input   wire            key_in_b    ,
    input   wire            rx          ,

    output  wire            tx          ,
    output  wire            re          ,
    output  wire    [3:0]   led
);

parameter   KEY_CNT_MAX = 20'd999_999;
parameter   WATER_LED_CNT_MAX = 25'd24_999_999;
parameter   B_CNT_1US_MAX   =   6'd49  ,
            B_CNT_1MS_MAX   =   10'd999,
            B_CNT_1S_MAX    =   10'd999;
parameter   UART_BPS    =   9600        ,
            CLK_FREQ    =   50_000_000  ;

wire            w_flag  ;
wire            b_flag  ;
wire    [3:0]   w_led   ;
wire            b_led   ;
wire    [7:0]   rx_data ;
wire    [7:0]   po_data ;
wire            po_flag ;


key_filter
#(
    .CNT_MAX    (KEY_CNT_MAX)
)
key_filter_inst_w
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .key_in      (key_in_w),

    .key_flag    (w_flag)
);

key_filter
#(
    .CNT_MAX    (KEY_CNT_MAX)
)
key_filter_inst_b
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .key_in      (key_in_b),

    .key_flag    (b_flag)
);

water_led
#(
    .CNT_MAX    (WATER_LED_CNT_MAX)
)
water_led_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),

    .led_out     (w_led)
);

breath_led
#(
    .CNT_1US_MAX    (B_CNT_1US_MAX),
    .CNT_1MS_MAX    (B_CNT_1MS_MAX),
    .CNT_1S_MAX     (B_CNT_1S_MAX )
)
breath_led_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),

    .led_out     (b_led)
);

uart_rx 
#(
    .UART_BPS    (UART_BPS),
    .CLK_FREQ    (CLK_FREQ)
)
uart_rx_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .rx          (rx),

    .po_data     (rx_data),
    .po_flag     ()
);

led_ctrl    led_ctrl_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .key_flag_w  (w_flag),
    .key_flag_b  (b_flag),
    .pi_data     (rx_data),
    .led_out_w   (w_led),
    .led_out_b   (b_led),

    .led         (led),
    .po_data     (po_data),
    .po_flag     (po_flag)
);

uart_tx
#(
    .UART_BPS    (UART_BPS),
    .CLK_FREQ    (CLK_FREQ)
)
uart_tx_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .pi_data     (po_data),
    .pi_flag     (po_flag),

    .work_en     (re),
    .tx          (tx)
);

endmodule
