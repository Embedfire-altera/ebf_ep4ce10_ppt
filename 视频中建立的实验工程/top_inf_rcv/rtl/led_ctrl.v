module  led_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            repeat_en   ,

    output  reg             led
);

parameter   CNT_MAX = 22'd2500_000;

reg             repeat_en_d1    ;
reg             repeat_en_d2    ;
wire            repeat_en_rise  ;
reg     [21:0]  cnt             ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            repeat_en_d1    <=  1'b0;
            repeat_en_d2    <=  1'b0;
        end
    else
        begin
            repeat_en_d1    <=  repeat_en;
            repeat_en_d2    <=  repeat_en_d1;
        end

assign  repeat_en_rise = (repeat_en_d1 == 1'b1) && (repeat_en_d2 == 1'b0);

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  22'd0;
    else    if(repeat_en_rise == 1'b1)
        cnt <=  CNT_MAX;
    else    if(cnt > 1'b0)
        cnt <=  cnt - 1'b1;
    else
        cnt <=  22'd0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led <=  1'b1;
    else    if(cnt > 0)
        led <=  1'b0;
    else
        led <=  1'b1;

endmodule
