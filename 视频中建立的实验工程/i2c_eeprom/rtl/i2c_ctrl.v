module  i2c_ctrl
#(
    parameter   DEVICE_ADDR     =   7'b1010_011,
    parameter   SYS_CLK_FREQ    =   'd50_000_000,
    parameter   SCL_FREQ        =   'd250_000
)
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            i2c_start   ,
    input   wire            wr_en       ,
    input   wire    [15:0]  byte_addr   ,
    input   wire    [7:0]   wr_data     ,
    input   wire            rd_en       ,
    input   wire            addr_num    ,

    output  reg             i2c_scl     ,
    inout   wire            i2c_sda     ,
    output  reg     [7:0]   rd_data     ,
    output  reg             i2c_end     ,
    output  reg             i2c_clk
);

parameter   CNT_CLK_MAX = (SYS_CLK_FREQ / SCL_FREQ) >> 3 ;

parameter   IDLE        =    4'd00,
            START       =    4'd01,
            SEND_D_A    =    4'd02,
            ACK_1       =    4'd03,
            SEND_B_H    =    4'd04,
            ACK_2       =    4'd05,
            SEND_B_L    =    4'd06,
            ACK_3       =    4'd07,
            WR_DATA     =    4'd08,
            ACK_4       =    4'd09,
            START_2     =    4'd10,
            SEND_R_A    =    4'd11,
            ACK_5       =    4'd12,
            RD_DATA     =    4'd13,
            N_ACK       =    4'd14,
            STOP        =    4'd15;

wire            sda_en          ;
wire            sda_in          ;

reg     [7:0]   cnt_clk         ;
reg     [3:0]   state           ;
reg     [1:0]   cnt_i2c_clk     ;
reg             cnt_i2c_clk_en  ;
reg     [2:0]   cnt_bit         ;
reg             sda_out         ;
reg             ack             ;
reg     [7:0]   rd_data_reg     ;


always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <=  8'd0;
    else    if(cnt_clk == CNT_CLK_MAX - 1)
        cnt_clk <=  8'd0;
    else
        cnt_clk <=  cnt_clk + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        i2c_clk <=  1'b1;
    else    if(cnt_clk == CNT_CLK_MAX - 1)
        i2c_clk <=  ~i2c_clk;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else    case(state)
        IDLE:
            if(i2c_start == 1'b1)
                state   <=  START;
            else
                state   <=  state;
        START:
            if(cnt_i2c_clk == 2'd3)
                state   <=  SEND_D_A;
            else
                state   <=  state;
        SEND_D_A:
            if((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))
                state   <=  ACK_1;
            else
                state   <=  state;
        ACK_1:
            if((cnt_i2c_clk == 2'd3) && (ack == 1'b0))
                begin
                    if(addr_num == 1'b1)
                        state   <=  SEND_B_H;
                    else
                        state   <=  SEND_B_L;
                end
            else
                state   <=  state;
        SEND_B_H:
            if((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))
                state   <=  ACK_2;
            else
                state   <=  state;
        ACK_2:
            if((cnt_i2c_clk == 2'd3) && (ack == 1'b0))
                state   <=  SEND_B_L;
            else
                state   <=  state;
        SEND_B_L:
            if((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))
                state   <=  ACK_3;
            else
                state   <=  state;
        ACK_3:
            if((cnt_i2c_clk == 2'd3) && (ack == 1'b0))
                begin
                    if(wr_en == 1'b1)
                        state   <=  WR_DATA;
                    else    if(rd_en == 1'b1)
                        state   <=  START_2;
                    else
                        state   <=  state;
                end
            else
                state   <=  state;
        WR_DATA:
            if((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))
                state   <=  ACK_4;
            else
                state   <=  state;
        ACK_4:
            if((cnt_i2c_clk == 2'd3) && (ack == 1'b0))
                state   <=  STOP;
            else
                state   <=  state;
        START_2:
            if(cnt_i2c_clk == 2'd3)
                state   <=  SEND_R_A;
            else
                state   <=  state;
        SEND_R_A:
            if((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))
                state   <=  ACK_5;
            else
                state   <=  state;
        ACK_5:
            if((cnt_i2c_clk == 2'd3) && (ack == 1'b0))
                state   <=  RD_DATA;
            else
                state   <=  state;
        RD_DATA:
            if((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))
                state   <=  N_ACK;
            else
                state   <=  state;
        N_ACK:
            if(cnt_i2c_clk == 2'd3)
                state   <=  STOP;
            else
                state   <=  state;
        STOP:
            if((cnt_bit == 3'd3) && (cnt_i2c_clk == 2'd3))
                state   <=  IDLE;
            else
                state   <=  state;
        default:state   <=  IDLE;
    endcase

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_i2c_clk <=  2'd0;
    else    if(cnt_i2c_clk_en == 1'b1)
        cnt_i2c_clk <=  cnt_i2c_clk + 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_i2c_clk_en  <=  1'b0;
    else    if((state == STOP) && (cnt_bit == 3'd3) && (cnt_i2c_clk == 2'd3))
        cnt_i2c_clk_en  <=  1'b0;
    else    if(i2c_start == 1'b1)
        cnt_i2c_clk_en  <=  1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit <=  3'd0;
    else    if((state == IDLE) || (state == START) || (state == ACK_1)
                ||(state == ACK_2) || (state == ACK_3) ||(state == ACK_4)
                || (state == ACK_5) ||(state == START_2) || (state == N_ACK))
        cnt_bit <=  3'd0;
    else    if((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))
        cnt_bit <=  3'd0;
    else    if((cnt_i2c_clk == 2'd3)&& (state != IDLE))
        cnt_bit <=  cnt_bit + 1'b1;

always@(*)
    case(state)
        IDLE:
            sda_out <=  1'b1;
        START:
            if(cnt_i2c_clk == 2'd0)
                sda_out <=  1'b1;
            else
                sda_out <=  1'b0;
        SEND_D_A:
            if(cnt_bit <= 3'd6)
                sda_out <=  DEVICE_ADDR[6 - cnt_bit];
            else
                sda_out <=  1'b0;
        ACK_1:
            sda_out <=  1'b1;
        SEND_B_H:
            sda_out <=  byte_addr[15 - cnt_bit];
        ACK_2:
            sda_out <=  1'b1;
        SEND_B_L:
            sda_out <=  byte_addr[7 - cnt_bit];
        ACK_3:
            sda_out <=  1'b1;
        WR_DATA:
            sda_out <=  wr_data[7 - cnt_bit];
        ACK_4:
            sda_out <=  1'b1;
        START_2:
            if(cnt_i2c_clk <= 2'd1)
                sda_out <=  1'b1;
            else
                sda_out <=  1'b0;
        SEND_R_A:
            if(cnt_bit <= 3'd6)
                sda_out <=  DEVICE_ADDR[6 - cnt_bit];
            else
                sda_out <=  1'b1;
        ACK_5:
            sda_out <=  1'b1;
        RD_DATA:
            sda_out <=  1'b1;
        N_ACK:
            sda_out <=  1'b1;
        STOP:
            if((cnt_bit == 3'd0) && (cnt_i2c_clk < 2'd3))
                sda_out <=  1'b0;
            else
                sda_out <=  1'b1;
        default:sda_out <=  1'b1;
    endcase

assign  sda_en = ((state == RD_DATA) || (state == ACK_1) || (state == ACK_2) || (state == ACK_3) || (state == ACK_4) || (state == ACK_5)) ? 1'b0 : 1'b1;

always@(*)
    case(state)
        ACK_1,ACK_2,ACK_3,ACK_4,ACK_5:
            if(cnt_i2c_clk == 2'd0)
                ack <=  sda_in;//1'b0;//
            else
                ack <=  ack;
        default:ack <=  1'b1;
    endcase

assign  sda_in = i2c_sda;

always@(*)
    case(state)
        IDLE:
            rd_data_reg <=  8'd0;
        RD_DATA:
            if(cnt_i2c_clk == 2'd2)
                rd_data_reg[7-cnt_bit]  <=  sda_in;
            else
                rd_data_reg <=  rd_data_reg;
        default:rd_data_reg <=  rd_data_reg;
    endcase

always@(*)
    case(state)
        IDLE:
            i2c_scl <=  1'b1;
        START:
            if(cnt_i2c_clk == 2'd3)
                i2c_scl <=  1'b0;
            else
                i2c_scl <=  1'b1;
        SEND_D_A,ACK_1,SEND_B_H,ACK_2,SEND_B_L,ACK_3,
        WR_DATA,ACK_4,START_2,SEND_R_A,ACK_5,RD_DATA,N_ACK:
            if((cnt_i2c_clk == 2'd1) || (cnt_i2c_clk == 2'd2))
                i2c_scl <=  1'b1;
            else
                i2c_scl <=  1'b0;
        STOP:
            if((cnt_bit == 3'd0) && (cnt_i2c_clk == 2'd0))
                i2c_scl <=  1'b0;
            else
                i2c_scl <=  1'b1;
        default:i2c_scl <=  1'b1;
    endcase

assign  i2c_sda = (sda_en == 1'b1) ? sda_out : 1'bz;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        i2c_end <=  1'b0;
    else    if((state == STOP) && (cnt_bit == 3'd3) && (cnt_i2c_clk == 2'd3))
        i2c_end <=  1'b1;
    else
        i2c_end <=  1'b0;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_data <=  8'd0;
    else    if((state == RD_DATA) && (cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))
        rd_data <=  rd_data_reg;

endmodule
