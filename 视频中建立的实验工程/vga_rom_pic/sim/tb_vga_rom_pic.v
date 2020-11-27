`timescale  1ns/1ns
module  tb_vga_rom_pic();

reg sys_clk;
reg sys_rst_n;

wire    hsync  ;
wire    vsync  ;
wire    [15:0]  vga_rgb;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n   <=  1'b1;
    end
always #10 sys_clk = ~sys_clk;

vga_rom_pic vga_rom_pic_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),

    .hsync       (hsync  ),
    .vsync       (vsync  ),
    .vga_rgb     (vga_rgb)

);
endmodule
