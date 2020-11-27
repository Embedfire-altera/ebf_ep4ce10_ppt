`timescale  1ns/1ns
module  tb_vga_rom_pic_jump();

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

defparam    vga_rom_pic_jump_inst.vga_pic_inst.H_VALID = 60;
defparam    vga_rom_pic_jump_inst.vga_pic_inst.V_VALID = 50;
defparam    vga_rom_pic_jump_inst.vga_pic_inst.H_PIC = 10;
defparam    vga_rom_pic_jump_inst.vga_pic_inst.V_PIC = 10;
defparam    vga_rom_pic_jump_inst.vga_pic_inst.PIC_SIZE = 100;

defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.H_SYNC  = 2;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.H_BACK  = 2;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.H_LEFT  = 2;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.H_VALID = 60;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.H_RIGHT = 2;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.H_FRONT = 2;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.H_TOTAL = 70;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.V_SYNC   = 2;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.V_BACK   = 2;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.V_TOP    = 2;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.V_VALID  = 50;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.V_BOTTOM = 2;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.V_FRONT  = 2;
defparam    vga_rom_pic_jump_inst.vga_ctrl_inst.V_TOTAL  = 60;

vga_rom_pic_jump vga_rom_pic_jump_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),

    .hsync       (hsync  ),
    .vsync       (vsync  ),
    .vga_rgb     (vga_rgb)

);
endmodule
