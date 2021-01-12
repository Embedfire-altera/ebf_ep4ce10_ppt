module  flash_se_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_flag    ,

    output  reg             cs_n        ,
    output  reg             sck         ,
    output  reg             mosi
);

parameter   IDLE  = 4'B0001,
            WREN  = 4'B0010,
            DELAY = 4'B0100,
            SE    = 4'B1000;

parameter   WREN_IN = 8'B0000_0110,
            SE_IN   = 8'B1101_1000,
            S_ADDR  = 8'B0000_0000,
            P_ADDR  = 8'B0000_0100,
            B_ADDR  = 8'B0010_0101;

reg     [3:0]   state   ;
reg     [4:0]   cnt_clk ;
reg     [3:0]   cnt_byte;
reg     [1:0]   cnt_sck ;
reg     [2:0]   cnt_bit ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else
        case(state)
            IDLE :if(key_flag == 1'b1)
                    state   <=  WREN;
            WREN :if(cnt_byte == 4'd2 && cnt_clk == 5'd31)
                    state   <=  DELAY;
            DELAY:if(cnt_byte == 4'd3 && cnt_clk == 5'd31)
                    state   <=  SE;
            SE   :if(cnt_byte == 4'd9 && cnt_clk == 5'd31)
                    state   <=  IDLE;
            default:state   <=  IDLE;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <=  5'd0;
    else    if(state != IDLE)
        cnt_clk <=  cnt_clk + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_byte    <=  4'd0;
    else    if(cnt_byte == 4'd9 && cnt_clk == 5'd31)
        cnt_byte    <=  4'd0;
    else    if(cnt_clk == 5'd31)
        cnt_byte    <=  cnt_byte + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_sck <=  2'd0;
    else    if(state == WREN && cnt_byte == 4'd1)
        cnt_sck <=  cnt_sck + 1'b1;
    else    if(state == SE && cnt_byte >= 4'd5 && cnt_byte <= 4'd8)
        cnt_sck <=  cnt_sck + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit <=  3'd0;
    else    if(cnt_sck == 2'd2)
        cnt_bit <=  cnt_bit + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cs_n    <=  1'b1;
    else    if(key_flag == 1'b1)
        cs_n    <=  1'b0;
    else    if(cnt_byte == 4'd2 && cnt_clk == 5'd31 && state == WREN)
        cs_n    <=  1'b1;
    else    if(cnt_byte == 4'd3 && cnt_clk == 5'd31 && state == DELAY)
        cs_n    <=  1'b0;
    else    if(cnt_byte == 4'd9 && cnt_clk == 5'd31 && state == SE)
        cs_n    <=  1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mosi    <=  1'b0;
    else    if(state == WREN && cnt_byte == 4'd2)
        mosi    <=  1'b0;
    else    if(state == SE && cnt_byte == 4'd9)
        mosi    <=  1'b0;
    else    if(state == WREN && cnt_byte == 4'd1 && cnt_sck == 2'd0)
        mosi    <=  WREN_IN[7 - cnt_bit];
    else    if(state == SE && cnt_byte == 4'd5 && cnt_sck == 2'd0)
        mosi    <=  SE_IN[7 - cnt_bit];
    else    if(state == SE && cnt_byte == 4'd6 && cnt_sck == 2'd0)
        mosi    <=  S_ADDR[7 - cnt_bit];
    else    if(state == SE && cnt_byte == 4'd7 && cnt_sck == 2'd0)
        mosi    <=  P_ADDR[7 - cnt_bit];
    else    if(state == SE && cnt_byte == 4'd8 && cnt_sck == 2'd0)
        mosi    <=  B_ADDR[7 - cnt_bit];

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sck <=  1'b0;
    else    if(cnt_sck == 2'd0)
        sck <=  1'b0;
    else    if(cnt_sck == 2'd2)
        sck <=  1'b1;

endmodule
