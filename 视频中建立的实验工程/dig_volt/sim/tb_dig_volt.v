`timescale 1ns/1ns
module  tb_dig_volt();

reg     sys_clk  ;
reg     sys_rst_n;
reg [7:0]   ad_data  ;
reg [7:0]   ad_data_reg ;
reg     data_en     ;

wire    ad_clk  ;
wire    ds      ;
wire    oe      ;
wire    shcp    ;
wire    stcp    ;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n   <=  1'b0;
        #20
        sys_rst_n   <=  1'b1;
        data_en <=  1'b0;
        #499990
        data_en <=  1'b1;
    end

always #10 sys_clk = ~sys_clk;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ad_data_reg <=  8'd0;
    else    if(data_en == 1'b1)
        ad_data_reg <=  ad_data_reg + 1'b1;
    else
        ad_data_reg <=  8'd0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ad_data     <=  8'd0;
    else    if(data_en == 1'b0)
        ad_data     <=  8'd125;
    else    if(data_en == 1'b1)
        ad_data     <= ad_data_reg;
    else
        ad_data     <= ad_data;

dig_volt    dig_volt_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .ad_data     (ad_data),

    .ad_clk      (ad_clk),
    .ds          (ds    ),
    .oe          (oe    ),
    .shcp        (shcp  ),
    .stcp        (stcp  )
);

endmodule
