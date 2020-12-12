module  tft_char
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,

    output  wire            hsync       ,
    output  wire            vsync       ,
    output  wire    [15:0]  tft_rgb     ,
    output  wire            tft_de      ,
    output  wire            tft_clk     ,
    output  wire            tft_bl
);

wire            clk_9m      ;
wire            locked      ;
wire            rst_n       ;

wire    [9:0]   pix_x       ;
wire    [9:0]   pix_y       ;
wire    [15:0]  pix_data    ;

assign  rst_n = (sys_rst_n && locked);

clk_gen clk_gen_inst
(
    .areset (~sys_rst_n ),
    .inclk0 (sys_clk    ),
    .c0     (clk_9m     ),
    .locked (locked     )
);

tft_ctrl    tft_ctrl_inst
(
    .clk_9m      (clk_9m),
    .sys_rst_n   (rst_n),
    .pix_data    (pix_data),

    .pix_x       (pix_x),
    .pix_y       (pix_y),
    .hsync       (hsync  ),
    .vsync       (vsync  ),
    .tft_rgb     (tft_rgb),
    .tft_de      (tft_de ),
    .tft_clk     (tft_clk),
    .tft_bl      (tft_bl)

);

tft_pic tft_pic_inst
(
    .clk_9m      (clk_9m),
    .sys_rst_n   (rst_n),
    .pix_x       (pix_x),
    .pix_y       (pix_y),

    .pix_data    (pix_data)
);

endmodule
