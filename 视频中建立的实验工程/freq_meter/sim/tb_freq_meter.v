`timescale  1ns/1ns
module  tb_freq_meter();

reg            sys_clk  ;
reg            sys_rst_n;
reg            clk_test ;

wire        clk_out;
wire        ds     ;
wire        oe     ;
wire        shcp   ;
wire        stcp   ;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n   <= 1'b0;
        #200
        sys_rst_n   <= 1'b1;
        clk_test = 1'b1;
    end

always #10 sys_clk = ~sys_clk;
always #100 clk_test = ~clk_test;

defparam freq_meter_inst.freq_meter_calc_inst.CNT_GATE_S_MAX = 74_9;
defparam freq_meter_inst.freq_meter_calc_inst.CNT_RISE_MAX = 12_4;
defparam freq_meter_inst.seg_595_dynamic_inst.seg_dynamic_inst.CNT_MAX = 49;
freq_meter  freq_meter_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .clk_test    (clk_test),

    .clk_out     (clk_out),
    .ds          (ds     ),
    .oe          (oe     ),
    .shcp        (shcp   ),
    .stcp        (stcp   )
);

endmodule
