module  sobel
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            rx          ,

    output  wire            tx          ,
    output  wire            hsync       ,
    output  wire            vsync       ,
    output  wire    [7:0]   rgb
);

parameter   CLK_FREQ = 'd50_000_000;

wire    vga_clk;
wire    clk_50m;
wire    locked;
wire    [7:0]   rx_data ;
wire            rx_flag ;
wire    [7:0]   po_data ;
wire            po_flag ;

assign  rst_n = (sys_rst_n & locked);

clk_gen clk_gen_inst
(
    .areset (~sys_rst_n),
    .inclk0 (sys_clk),
    .c0     (vga_clk),
    .c1     (clk_50m),
    .locked (locked)
);

uart_rx 
#(
    .UART_BPS    (9600          ),
    .CLK_FREQ    (CLK_FREQ    )
)
uart_rx_inst
(
    .sys_clk     (clk_50m),
    .sys_rst_n   (rst_n),
    .rx          (rx),

    .po_data     (rx_data),
    .po_flag     (rx_flag)
);

uart_tx
#(
    .UART_BPS    (9600      ),
    .CLK_FREQ    (CLK_FREQ)
)
uart_tx_inst
(
    .sys_clk     (clk_50m),
    .sys_rst_n   (rst_n),
    .pi_data     (po_data),
    .pi_flag     (po_flag),

    .tx          (tx)
);

sobel_ctrl  sobel_ctrl_inst
(
    .sys_clk     (clk_50m),
    .sys_rst_n   (rst_n),
    .pi_flag     (rx_flag),
    .pi_data     (rx_data),

    .po_flag     (po_flag),
    .po_data     (po_data)
);

vga vga_inst
(
    .sys_clk     (clk_50m),
    .vga_clk     (vga_clk),
    .sys_rst_n   (rst_n),
    .pi_flag     (po_flag),
    .pi_data     (po_data),

    .hsync       (hsync),
    .vsync       (vsync),
    .rgb         (rgb)
);



endmodule
