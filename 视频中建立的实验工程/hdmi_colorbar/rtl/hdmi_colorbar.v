module  hdmi_colorbar
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,

    output  wire            ddc_scl     ,
    output  wire            ddc_sda     ,
    output  wire            hdmi_r_p    ,
    output  wire            hdmi_r_n    ,
    output  wire            hdmi_g_p    ,
    output  wire            hdmi_g_n    ,
    output  wire            hdmi_b_p    ,
    output  wire            hdmi_b_n    ,
    output  wire            hdmi_clk_p  ,
    output  wire            hdmi_clk_n
);

wire            vga_clk     ;
wire            clk_5x      ;
wire            locked      ;
wire            rst_n       ;
wire    [15:0]  pix_data    ;
wire    [9:0]   pix_x       ;
wire    [9:0]   pix_y       ;
wire            rgb_valid   ;
wire            hsync       ;
wire            vsync       ;
wire    [15:0]  vga_rgb     ;

assign  rst_n = (sys_rst_n & locked);
assign  ddc_scl = 1'b1;
assign  ddc_sda = 1'b1;

clk_gen clk_gen_inst
(
    .areset (~sys_rst_n ),
    .inclk0 (sys_clk    ),
    .c0     (vga_clk    ),
    .c1     (clk_5x     ),
    .locked (locked     )
);

vga_pic vga_pic_inst
(
    .vga_clk     (vga_clk   ),
    .sys_rst_n   (rst_n     ),
    .pix_x       (pix_x     ),
    .pix_y       (pix_y     ),

    .pix_data    (pix_data  )
);

vga_ctrl    vga_ctrl_inst
(
    .vga_clk     (vga_clk   ),
    .sys_rst_n   (rst_n     ),
    .pix_data    (pix_data  ),

    .pix_x       (pix_x     ),
    .pix_y       (pix_y     ),
    .rgb_valid   (rgb_valid ),
    .hsync       (hsync     ),
    .vsync       (vsync     ),
    .vga_rgb     (vga_rgb   )
);


hdmi_ctrl   hdmi_ctrl_inst
(
    .vga_clk     (vga_clk   ),
    .clk_5x      (clk_5x    ),
    .sys_rst_n   (rst_n     ),
    .hsync       (hsync     ),
    .vsync       (vsync     ),
    .rgb_valid   (rgb_valid ),
    .rgb_blue    ({vga_rgb[4:0],3'b0}),
    .rgb_green   ({vga_rgb[10:5],2'b0}),
    .rgb_red     ({vga_rgb[15:11],3'b0}),

    .hdmi_r_p    (hdmi_r_p  ),
    .hdmi_r_n    (hdmi_r_n  ),
    .hdmi_g_p    (hdmi_g_p  ),
    .hdmi_g_n    (hdmi_g_n  ),
    .hdmi_b_p    (hdmi_b_p  ),
    .hdmi_b_n    (hdmi_b_n  ),
    .hdmi_clk_p  (hdmi_clk_p),
    .hdmi_clk_n  (hdmi_clk_n)
);

endmodule
