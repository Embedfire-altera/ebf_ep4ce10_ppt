`timescale  1ns/1ns
module  tb_vga_ctrl();

reg             sys_clk     ;
reg             sys_rst_n   ;
wire     [15:0]  pix_data    ;

wire            vga_clk     ;
wire            locked      ;
wire            rst_n       ;

wire    [9:0]   pix_x       ;
wire    [9:0]   pix_y       ;
wire            hsync       ;
wire            vsync       ;
wire    [15:0]  vga_rgb     ;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
    end

always  #10 sys_clk = ~sys_clk;

assign  rst_n = (sys_rst_n && locked);

clk_gen clk_gen_inst
(
    .areset (~sys_rst_n ),
    .inclk0 (sys_clk    ),
    .c0     (vga_clk    ),
    .locked (locked     )
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
    .vga_rgb     (vga_rgb   )
);

vga_pic vga_pic_inst
(
    .vga_clk     (vga_clk),
    .sys_rst_n   (rst_n),
    .pix_x       (pix_x),
    .pix_y       (pix_y),

    .pix_data    (pix_data)
);


endmodule
