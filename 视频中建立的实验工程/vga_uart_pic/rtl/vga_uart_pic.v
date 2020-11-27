module  vga_uart_pic
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            rx          ,

    output  wire    [7:0]   rgb         ,
    output  wire            hsync       ,
    output  wire            vsync
);

parameter   UART_BPS    =   'd9600      ,
            CLK_FREQ    =   'd50_000_000;

wire            clk_50m ;
wire            vga_clk ;
wire            locked  ;
wire            rst_n   ;
wire    [7:0]   po_data ;
wire            po_flag ;
wire    [9:0]   pix_x   ;
wire    [9:0]   pix_y   ;
wire    [7:0]   pix_data;

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
    .UART_BPS   (UART_BPS),
    .CLK_FREQ   (CLK_FREQ)
)
uart_rx_inst
(
    .sys_clk     (clk_50m),
    .sys_rst_n   (rst_n),
    .rx          (rx),

    .po_data     (po_data),
    .po_flag     (po_flag)
);

vga_ctrl    vga_ctrl_inst
(
    .vga_clk     (vga_clk   ),
    .sys_rst_n   (rst_n     ),
    .pix_data    (pix_data  ),

    .pix_x       (pix_x     ),
    .pix_y       (pix_y     ),
    .hsync       (hsync     ),
    .vsync       (vsync     ),
    .vga_rgb     (rgb   )
);

vga_pic vga_pic_inst
(
    .sys_clk     (clk_50m),
    .vga_clk     (vga_clk),
    .sys_rst_n   (rst_n),
    .pi_data     (po_data),
    .pi_flag     (po_flag),
    .pix_x       (pix_x),
    .pix_y       (pix_y),

    .pix_data    (pix_data)
);

endmodule
