`timescale  1ns/1ns
module  tb_rs485();

reg             sys_clk     ;
reg             sys_rst_n   ;
reg             key_in_w    ;
reg             key_in_b    ;


wire            tx          ;
wire            re          ;
wire    [3:0]   led         ;

initial
    begin
        sys_clk =   1'b1;
        sys_rst_n   <=  1'b0;
        key_in_w    <=  1'b1;
        key_in_b    <=  1'b1;
        #20
        sys_rst_n   <=  1'b1;
        //流水灯
        #2000000    key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #200        key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        //呼吸灯
        #2000000    key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #200        key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        //呼吸灯
        #2000000    key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #200        key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        //呼吸灯
        #2000000    key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #200        key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        #20         key_in_b    <=  1'b0;
        #20         key_in_b    <=  1'b1;
        //流水灯
        #2000000    key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #200        key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        //流水灯
        #2000000    key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #200        key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
        #20         key_in_w    <=  1'b0;
        #20         key_in_w    <=  1'b1;
    end

always #10 sys_clk = ~sys_clk;

defparam    rs485_inst0.KEY_CNT_MAX = 5;
defparam    rs485_inst0.WATER_LED_CNT_MAX = 4000;
defparam    rs485_inst1.WATER_LED_CNT_MAX = 4000;
defparam    rs485_inst0.B_CNT_1US_MAX = 4;
defparam    rs485_inst1.B_CNT_1US_MAX = 4;
defparam    rs485_inst0.B_CNT_1MS_MAX = 9;
defparam    rs485_inst1.B_CNT_1MS_MAX = 9;
defparam    rs485_inst0.B_CNT_1S_MAX = 9;
defparam    rs485_inst1.B_CNT_1S_MAX = 9;
defparam    rs485_inst0.UART_BPS = 1000000;
defparam    rs485_inst1.UART_BPS = 1000000;

//控制板
rs485   rs485_inst0
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .key_in_w    (key_in_w),
    .key_in_b    (key_in_b),
    .rx          (),

    .tx          (tx),
    .re          (re),
    .led         ()
);

//被控板
rs485   rs485_inst1
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .key_in_w    (),
    .key_in_b    (),
    .rx          (tx),

    .tx          (),
    .re          (),
    .led         (led)
);

endmodule
