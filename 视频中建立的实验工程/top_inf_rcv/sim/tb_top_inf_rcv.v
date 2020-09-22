`timescale  1ns/1ns
module  tb_top_inf_rcv();

reg     sys_clk ;
reg     sys_rst_n   ;
reg     inf_in      ;

wire    ds      ;
wire    oe      ;
wire    shcp    ;
wire    stcp    ;
wire    led     ;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <=    1'b0;
        inf_in  <=  1'b1;
        #30
        sys_rst_n   <=  1'b1;
        #1000
//引导码
        inf_in  <=  1'b0;
        #9000_000
        inf_in  <=  1'b1;
        #4500_000
//地址码(8'h57   0101_0111   1110_1010)
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
//地址反码(1110_1010   0001_0101)
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
//数据码(8'h22  0010_0010   0100_0100)
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
//数据反码(0100_0100   1011_1011)
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #560_000            //逻辑0
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
        #1690_000           //逻辑1
//结束位
        inf_in  <=  1'b0;
        #560_000
//高电平保持
        inf_in  <=  1'b1;
        #4200_0000
//重复码
        inf_in  <=  1'b0;
        #9000_000
        inf_in  <=  1'b1;
        #2250_000
//结束位
        inf_in  <=  1'b0;
        #560_000
        inf_in  <=  1'b1;
    end

always #10 sys_clk = ~sys_clk;

top_inf_rcv top_inf_rcv_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .inf_in      (inf_in),

    .ds          (ds  ),
    .oe          (oe  ),
    .shcp        (shcp),
    .stcp        (stcp),
    .led         (led )
);
endmodule
