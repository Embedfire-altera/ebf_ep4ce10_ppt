`timescale  1ns/1ns
module  tb_tft_colorbar();

reg             sys_clk     ;
reg             sys_rst_n   ;

wire            hsync       ;
wire            vsync       ;
wire    [15:0]  tft_rgb     ;
wire            tft_de      ;
wire            tft_clk     ;
wire            tft_bl      ;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
    end

always  #10 sys_clk = ~sys_clk;

tft_colorbar    tft_colorbar_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),

    .hsync       (hsync),
    .vsync       (vsync),
    .tft_rgb     (tft_rgb),
    .tft_de      (tft_de ),
    .tft_clk     (tft_clk),
    .tft_bl      (tft_bl )
);

endmodule
