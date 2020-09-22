module  top_inf_rcv
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            inf_in      ,

    output  wire            ds          ,
    output  wire            oe          ,
    output  wire            shcp        ,
    output  wire            stcp        ,
    output  wire            led
);

wire    [19:0]  data        ;
wire            repeat_en   ;


inf_rcv     inf_rcv_inst
(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .inf_in      (inf_in    ),

    .data        (data      ),
    .repeat_en   (repeat_en )
);

seg_595_dynamic     seg_595_dynamic_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .data        (data),
    .point       (6'b000_000),
    .sign        (1'b0),
    .seg_en      (1'b1),

    .ds          (ds  ),
    .oe          (oe  ),
    .shcp        (shcp),
    .stcp        (stcp)
);

led_ctrl    led_ctrl_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .repeat_en   (repeat_en),

    .led         (led)
);

endmodule
