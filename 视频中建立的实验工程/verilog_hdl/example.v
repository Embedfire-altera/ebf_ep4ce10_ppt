module  example     //模块开始 模块名
(
    input   wire            sys_clk     ,   //输入信号
    input   wire            sys_rst_n   ,   //输入信号
    inout   wire            sda         ,   //输入输出信号

    output  wire            po_flag         //输出信号
);

//线网型变量
wire    [0:0]   flag    ;

//寄存器型变量
reg     [7:0]   cnt     ;

//参数
parameter   CNT_MAX = 100;
localparam  CNT_MAX = 100;

//模块实例化
example
#(
    .CNT_MAX     (8'd100    )    //实例化时参数可修改
) 
example_inst
(
    .sys_clk     (sys_clk   ),    //input     sys_clk
    .sys_rst_n   (sys_rst_n ),    //input     sys_rst_n
    .sda         (sda       ),    //inout     sda

    .po_flag     (po_flag   )     //output    led_out
);

example example_inst
(
    .sys_clk     (sys_clk   ),    //input     sys_clk
    .sys_rst_n   (sys_rst_n ),    //input     sys_rst_n
    .sda         (sda       ),    //inout     sda

    .po_flag     (po_flag   )     //output    led_out
);

/*
常量
基数表示法
格式：[换算为二进制后位宽的总长度]['][数值进制符号][与数值进制符号对应的数值]
8'd171：位宽是8bit，十进制的171。
[数值进制符号]中如果是[h]则表示十六进制，如果是[o]则表示八进制，如果是[b]则表示二进制，如果[d]则表示十进制。
8'hab表示8bit的十六进制数ab；
8'o253表示8bit的八进制数253；
8'b1010_1011表示8bit的二进制数1010_1011，下划线增强可读性。
[换算为二进制后位宽的总长度]：可有可无，verilog会为常量自动匹配合适的位宽。
当总位宽大于实际位宽，则自动在左边补0，总位宽小于实际位宽，则自动截断左边超出的位数。
'd7与8'd7：表示相同数值，8'd7换算为二进制就是8'b0000_0111，前面5位补0；
2'd7换算为二进制就是2'b11，超过2位宽的部分被截断。
如果直接写参数，例如100，表示位宽为32bit的十进制数100.
*/

//阻塞赋值 “=”
a = 1;
b = 2;
c = 3;
begin
    a = b;
    c = a;
end
a = 2;
b = 2;
c = 2;

//非阻塞赋值 “<=”
a = 1;
b = 2;
c = 3;
begin
    a <= b;
    c <= a;
end
a = 2;
b = 2;
c = 1;

//always
always(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1’b0)
        cnt <= 8’d0;
    else    if(cnt == CNT_MAX)
        cnt <= CNT_MAX;
    else
        cnt <= cnt + 8’d1;

//assign
assign po_flag = (cnt== CNT_MAX) ? 1’b1 :1’b0;

endmodule


