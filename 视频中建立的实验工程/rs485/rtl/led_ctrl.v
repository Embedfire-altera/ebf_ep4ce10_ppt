module  led_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_flag_w  ,
    input   wire            key_flag_b  ,
    input   wire    [7:0]   pi_data     ,
    input   wire    [3:0]   led_out_w   ,
    input   wire            led_out_b   ,

    output  reg     [3:0]   led         ,
    output  wire    [7:0]   po_data     ,
    output  wire            po_flag
);

reg     w_en    ;
reg     b_en    ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        w_en    <=  1'b0;
    else    if(key_flag_b == 1'b1)
        w_en    <=  1'b0;
    else    if(key_flag_w == 1'b1)
        w_en    <=  ~w_en;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        b_en    <=  1'b0;
    else    if(key_flag_w == 1'b1)
        b_en    <=  1'b0;
    else    if(key_flag_b == 1'b1)
        b_en    <=  ~b_en;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led <=  4'b1111;
    else    if(pi_data[0] == 1'b1)
        led <=  led_out_w;
    else    if(pi_data[1] == 1'b1)
        led <=  {led_out_b,led_out_b,led_out_b,led_out_b};
    else
        led <=  4'b1111;

assign  po_data = {6'b000_000,b_en,w_en};

assign  po_flag = {key_flag_w || key_flag_b};

endmodule
