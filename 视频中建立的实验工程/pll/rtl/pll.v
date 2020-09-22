module  pll
(
    input   wire    sys_clk     ,
    input   wire    sys_rst_n   ,
    output  wire    clk_mul_2   ,
    output  wire    clk_div     ,
    output  wire    clk_pha_90  ,
    output  wire    clk_duc_20  ,
    output  reg     [1:0]   cnt ,
    output  wire    locked

);

pll_ip  pll_ip_inst
(
    .inclk0 (sys_clk    ),
    .c0     (clk_mul_2  ),
    .c1     (clk_div    ),
    .c2     (clk_pha_90 ),
    .c3     (clk_duc_20 ),
    .locked (locked     )
);

always@(posedge clk_div or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  2'd0;
    else
        cnt <=  cnt +1'b1;

endmodule
