module  ds18b20_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    inout   wire            dq          ,

    output  wire    [19:0]  data_out    ,
    output  reg             sign
);

parameter   INIT        =   6'b000_001  ,
            WR_CMD      =   6'b000_010  ,
            WAIT        =   6'b000_100  ,
            INIT_AGAIN  =   6'b001_000  ,
            RD_CMD      =   6'b010_000  ,
            RD_TEMP     =   6'b100_000  ;
parameter   WAIT_MAX    =   20'd750_000 ;

parameter   WR_CC_44    =   16'h44_cc   ,
            WR_CC_BE    =   16'hbe_cc   ;

reg             clk_us      ;
reg     [4:0]   cnt         ;
reg     [5:0]   state       ;
reg     [19:0]  cnt_us      ;
reg             flag        ;
reg     [3:0]   bit_cnt     ;
reg     [15:0]  data_temp   ;
reg     [19:0]  data        ;
reg             dq_en       ;
reg             dq_out      ;


assign  dq  =  (dq_en == 1'b1) ? dq_out : 1'bz;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sign    <=  1'b0;
    else    if((state == RD_TEMP) && (bit_cnt == 4'd15) && (cnt_us == 20'd60)
                 && (data_temp[15] == 1'b0))
        sign    <=  1'b0;
    else    if((state == RD_TEMP) && (bit_cnt == 4'd15) && (cnt_us == 20'd60)
                && (data_temp[15] == 1'b1))
        sign    <=  1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  5'd0;
    else    if(cnt == 5'd24)
        cnt <=  5'd0;
    else
        cnt <=  cnt + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_us  <=  1'b0;
    else    if(cnt == 5'd24)
        clk_us  <=  ~clk_us;
    else
        clk_us  <=  clk_us;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_us  <=  20'd0;
    else    if(((state == INIT || state == INIT_AGAIN) && (cnt_us == 20'd999))
               || ((state == WR_CMD || state == RD_CMD || state == RD_TEMP) && (cnt_us == 20'd64))
               ||((state == WAIT && cnt_us == WAIT_MAX)))
        cnt_us  <=  20'd0;
    else
        cnt_us  <=  cnt_us + 1'b1;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag    <=  1'b0;
    else    if((state == INIT || state == INIT_AGAIN) && (cnt_us == 20'd570) && (dq == 1'b0))
        flag    <=  1'b1;
    else    if((state == INIT || state == INIT_AGAIN) && (cnt_us == 20'd999))
        flag    <=  1'b0;
    else
        flag    <=  flag;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        bit_cnt <=  4'd0;
    else    if((state == WR_CMD || state == RD_CMD || state == RD_TEMP) 
                && (bit_cnt == 4'd15) && (cnt_us == 20'd64))
        bit_cnt <=  4'd0;
    else    if((state == WR_CMD || state == RD_CMD || state == RD_TEMP) 
                && (cnt_us == 20'd64))
        bit_cnt <=  bit_cnt + 1'b1;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_temp   <=  16'b0;
    else    if((state == RD_TEMP) && (cnt_us == 20'd13))
        data_temp   <=  {dq,data_temp[15:1]};
    else
        data_temp   <=  data_temp;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data    <=  20'd0;
    else    if((state == RD_TEMP) && (bit_cnt == 4'd15) && (cnt_us == 20'd60)
                && (data_temp[15] == 1'b0))
        data    <=  data_temp[11:0];
    else    if((state == RD_TEMP) && (bit_cnt == 4'd15) && (cnt_us == 20'd60)
                && (data_temp[15] == 1'b1))
        data    <=  ~data_temp[11:0] + 1;

assign  data_out  =  ((data * 625) / 10);

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            dq_en   <=  1'b0;
            dq_out  <=  1'b0;
        end
    else
        case(state)
            INIT      :
                if(cnt_us < 499)
                    begin
                        dq_en   <=  1'b1;
                        dq_out  <=  1'b0;
                    end
                else
                    begin
                        dq_en   <=  1'b0;
                        dq_out  <=  1'b0;
                    end
            WR_CMD    :
                if(cnt_us > 62)
                    begin
                        dq_en   <=  1'b0;
                        dq_out  <=  1'b0;
                    end
                else    if(cnt_us <= 1)
                    begin
                        dq_en   <=  1'b1;
                        dq_out  <=  1'b0;
                    end
                else    if(WR_CC_44[bit_cnt] == 1'b0)
                    begin
                        dq_en   <=  1'b1;
                        dq_out  <=  1'b0;
                    end
                else    if(WR_CC_44[bit_cnt] == 1'b1)
                    begin
                        dq_en   <=  1'b0;
                        dq_out  <=  1'b0;
                    end
            WAIT      :
                begin
                    dq_en   <=  1'b1;
                    dq_out  <=  1'b1;
                end
            INIT_AGAIN:
                if(cnt_us < 499)
                    begin
                        dq_en   <=  1'b1;
                        dq_out  <=  1'b0;
                    end
                else
                    begin
                        dq_en   <=  1'b0;
                        dq_out  <=  1'b0;
                    end
            RD_CMD    :
                if(cnt_us > 62)
                    begin
                        dq_en   <=  1'b0;
                        dq_out  <=  1'b0;
                    end
                else    if(cnt_us <= 1)
                    begin
                        dq_en   <=  1'b1;
                        dq_out  <=  1'b0;
                    end
                else    if(WR_CC_BE[bit_cnt] == 1'b0)
                    begin
                        dq_en   <=  1'b1;
                        dq_out  <=  1'b0;
                    end
                else    if(WR_CC_BE[bit_cnt] == 1'b1)
                    begin
                        dq_en   <=  1'b0;
                        dq_out  <=  1'b0;
                    end
            RD_TEMP   :
                if(cnt_us <= 1)
                    begin
                        dq_en   <=  1'b1;
                        dq_out  <=  1'b0;
                    end
                else
                    begin
                        dq_en   <=  1'b0;
                        dq_out  <=  1'b0;
                    end
            default:
                begin
                    dq_en   <=  1'b0;
                    dq_out  <=  1'b0;
                end
        endcase

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  INIT;
    else
        case(state)
            INIT      :
                if(cnt_us == 20'd999 && flag == 1'b1)
                    state   <=  WR_CMD;
                else
                    state   <=  INIT;
            WR_CMD    :
                if(bit_cnt == 4'd15 && cnt_us == 20'd64)
                    state   <=  WAIT;
                else
                    state   <=  WR_CMD;
            WAIT      :
                if(cnt_us == WAIT_MAX)
                    state   <=  INIT_AGAIN;
                else
                    state   <=  WAIT;
            INIT_AGAIN:
                if(cnt_us == 20'd999 && flag == 1'b1)
                    state   <=  RD_CMD;
                else
                    state   <=  INIT_AGAIN;
            RD_CMD    :
                if(bit_cnt == 4'd15 && cnt_us == 20'd64)
                    state   <=  RD_TEMP;
                else
                    state   <=  RD_CMD;
            RD_TEMP   :
                if(bit_cnt == 4'd15 && cnt_us == 20'd64)
                    state   <=  INIT;
                else
                    state   <=  RD_TEMP;
            default:state   <=  INIT;
        endcase













endmodule
