module  dht11
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key         ,
    inout   wire            dht11       ,

    output  wire            ds          ,
    output  wire            oe          ,
    output  wire            shcp        ,
    output  wire            stcp
);

wire            key_flag;
wire    [19:0]  data_out;
wire            sign    ;

key_filter
#(
    .CNT_MAX (20'd999_999)
)
key_filter_inst
(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .key_in     (key),

    .key_flag   (key_flag)
);

dht11_ctrl  dht11_ctrl_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .key_flag    (key_flag),
    .dht11       (dht11),

    .data_out    (data_out),
    .sign        (sign)
);

seg_595_dynamic seg_595_dynamic_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .data        (data_out  ),
    .point       (6'b000_010 ),
    .sign        (sign  ),
    .seg_en      (1'b1),

    .ds          (ds  ),
    .oe          (oe  ),
    .shcp        (shcp),
    .stcp        (stcp)
);

endmodule
