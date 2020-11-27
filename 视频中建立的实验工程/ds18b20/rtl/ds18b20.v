module  ds18b20
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    inout   wire            dq          ,

    output  wire            ds          ,
    output  wire            oe          ,
    output  wire            shcp        ,
    output  wire            stcp
);

wire    [19:0]  data_out    ;
wire            sign        ;

ds18b20_ctrl    ds18b20_ctrl_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .dq          (dq),

    .data_out    (data_out),
    .sign        (sign)
);

seg_595_dynamic seg_595_dynamic_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .data        (data_out),
    .point       (6'b001_000),
    .sign        (sign),
    .seg_en      (1'b1),

    .ds          (ds  ),
    .oe          (oe  ),
    .shcp        (shcp),
    .stcp        (stcp)
);

endmodule