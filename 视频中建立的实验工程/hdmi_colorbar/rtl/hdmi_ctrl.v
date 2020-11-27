module  hdmi_ctrl
(
    input   wire            vga_clk     ,
    input   wire            clk_5x      ,
    input   wire            sys_rst_n   ,
    input   wire            hsync       ,
    input   wire            vsync       ,
    input   wire            rgb_valid   ,
    input   wire    [7:0]   rgb_blue    ,
    input   wire    [7:0]   rgb_green   ,
    input   wire    [7:0]   rgb_red     ,

    output  wire            hdmi_r_p    ,
    output  wire            hdmi_r_n    ,
    output  wire            hdmi_g_p    ,
    output  wire            hdmi_g_n    ,
    output  wire            hdmi_b_p    ,
    output  wire            hdmi_b_n    ,
    output  wire            hdmi_clk_p  ,
    output  wire            hdmi_clk_n
);

wire    [9:0]   red     ;
wire    [9:0]   green   ;
wire    [9:0]   blue    ;
wire    [9:0]   red_1   ;

encode  encode_inst_r
(
    .vga_clk     (vga_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .hsync       (hsync     ),
    .vsync       (vsync     ),
    .rgb_valid   (rgb_valid ),
    .data_in     (rgb_red   ),

    .data_out    (red       )
);

encode_1 encode_1_inst_r
(
  .clkin    (vga_clk),    // pixel clock input
  .rstin    (~sys_rst_n),    // async. reset input (active high)
  .din      (rgb_red),      // data inputs: expect registered
  .c0       (hsync),       // c0 input
  .c1       (vsync),       // c1 input
  .de       (rgb_valid),       // de input
  .dout     (red_1) // data outputs
);

encode  encode_inst_g
(
    .vga_clk     (vga_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .hsync       (hsync     ),
    .vsync       (vsync     ),
    .rgb_valid   (rgb_valid ),
    .data_in     (rgb_green ),
                  
    .data_out    (green     )
);

encode  encode_inst_b
(
    .vga_clk     (vga_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .hsync       (hsync     ),
    .vsync       (vsync     ),
    .rgb_valid   (rgb_valid ),
    .data_in     (rgb_blue  ),
                  
    .data_out    (blue      )
);

par_to_ser  par_to_ser_inst_r
(
    .clk_5x  (clk_5x    ),
    .data_in (red       ),

    .ser_p   (hdmi_r_p  ),
    .ser_n   (hdmi_r_n  )
);

par_to_ser  par_to_ser_inst_g
(
    .clk_5x  (clk_5x    ),
    .data_in (green     ),

    .ser_p   (hdmi_g_p  ),
    .ser_n   (hdmi_g_n  )
);

par_to_ser  par_to_ser_inst_b
(
    .clk_5x  (clk_5x    ),
    .data_in (blue      ),

    .ser_p   (hdmi_b_p  ),
    .ser_n   (hdmi_b_n  )
);

par_to_ser  par_to_ser_inst_clk
(
    .clk_5x  (clk_5x    ),
    .data_in (10'b11111_00000),

    .ser_p   (hdmi_clk_p),
    .ser_n   (hdmi_clk_n)
);

endmodule
