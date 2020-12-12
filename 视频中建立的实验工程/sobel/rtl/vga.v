module  vga
(
    input   wire            sys_clk     ,
    input   wire            vga_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            pi_flag     ,
    input   wire    [7:0]   pi_data     ,

    output  wire            hsync       ,
    output  wire            vsync       ,
    output  wire    [7:0]   rgb
);

wire    [7:0]   pix_data;
wire    [9:0]   pix_x   ;
wire    [9:0]   pix_y   ;



vga_ctrl    vga_ctrl_inst
(
    .vga_clk     (vga_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .pix_data    (pix_data  ),

    .pix_x       (pix_x     ),
    .pix_y       (pix_y     ),
    .hsync       (hsync     ),
    .vsync       (vsync     ),
    .vga_rgb     (rgb   )
);

vga_pic vga_pic_inst
(
    .sys_clk     (sys_clk),
    .vga_clk     (vga_clk),
    .sys_rst_n   (sys_rst_n),
    .pi_data     (pi_data),
    .pi_flag     (pi_flag),
    .pix_x       (pix_x),
    .pix_y       (pix_y),

    .pix_data    (pix_data)
);

endmodule
