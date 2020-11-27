module  dht11_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_flag    ,
    inout   wire            dht11       ,

    output  reg     [19:0]  data_out    ,
    output  reg             sign
);

parameter   WAIT_1S =   6'b000_001,
            START   =   6'b000_010,
            DLY_1   =   6'b000_100,
            REPLY   =   6'b001_000,
            DLY_2   =   6'b010_000,
            RD_DATA =   6'b100_000;

parameter   WAIT_1S_MAX = 20'd999_999,
            LOW_18MS_MAX= 20'd17_999;

wire            dht11_rise  ;
wire            dht11_fall  ;

reg             clk_us      ;
reg     [4:0]   cnt         ;
reg     [5:0]   state       ;
reg     [19:0]  cnt_us      ;
reg     [19:0]  cnt_low     ;
reg             dht11_reg1  ;
reg             dht11_reg2  ;
reg     [5:0]   bit_cnt     ;
reg     [39:0]  data_temp   ;
reg     [31:0]  data        ;
reg             data_flag   ;
reg             dht11_en    ;
reg             dht11_out   ;

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
        state   <=  WAIT_1S;
    else
        case(state)
            WAIT_1S:
                if(cnt_us == WAIT_1S_MAX)
                    state   <=  START;
                else
                    state   <=  WAIT_1S;
            START  :
                if(cnt_us == LOW_18MS_MAX)
                    state   <=  DLY_1;
                else
                    state   <=  START;
            DLY_1  :
                if(cnt_us == 20'd10)
                    state   <=  REPLY;
                else
                    state   <=  DLY_1;
            REPLY  :
                if(dht11_rise == 1'b1 && cnt_low > 80)
                    state   <=  DLY_2;
                else    if(cnt_us > 1000)
                    state   <=  START;
                else
                    state   <=  REPLY;
            DLY_2  :
                if(dht11_fall == 1'b1 && cnt_us > 80)
                    state   <=  RD_DATA;
                else
                    state   <=  DLY_2;
            RD_DATA:
                if(bit_cnt == 40 && dht11_rise == 1'b1)
                    state   <=  START;
                else
                    state   <=  RD_DATA;
            default:state   <=  WAIT_1S;
        endcase

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            cnt_low <=  20'd0;
            cnt_us  <=  20'd0;
        end
    else
        case(state)
            WAIT_1S:
                if(cnt_us == WAIT_1S_MAX)
                    cnt_us  <=  20'd0;
                else
                    cnt_us  <=  cnt_us + 1'b1;
            START  :
                if(cnt_us == LOW_18MS_MAX)
                    cnt_us  <=  20'd0;
                else
                    cnt_us  <=  cnt_us + 1'b1;
            DLY_1  :
                if(cnt_us == 10)
                    cnt_us  <=  20'd0;
                else
                    cnt_us  <=  cnt_us + 1'b1;
            REPLY  :
                if(dht11_rise == 1'b1 && cnt_low > 80)
                    begin
                        cnt_low <=  20'd0;
                        cnt_us  <=  20'd0;
                    end
                else    if(dht11 == 1'b0)
                    begin
                        cnt_low <=  cnt_low + 1'b1;
                        cnt_us  <=  cnt_us + 1'b1;
                    end
                else    if(cnt_us > 1000)
                    begin
                        cnt_low <=  20'd0;
                        cnt_us  <=  20'd0;
                    end
                else
                    begin
                        cnt_low <=  cnt_low;
                        cnt_us  <=  cnt_us + 1'b1;
                    end
            DLY_2  :if(dht11_fall == 1'b1 && cnt_us > 80)
                        cnt_us  <=  20'd0;
                    else
                        cnt_us  <=  cnt_us + 1'b1;
            RD_DATA:
                if(dht11_fall == 1'b1 || dht11_rise == 1'b1)
                    cnt_us  <=  20'd0;
                else
                    cnt_us  <=  cnt_us + 1'b1;
            default:
                begin
                    cnt_low <=  20'd0;
                    cnt_us  <=  20'd0;
                end
        endcase

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            dht11_reg1  <=  1'b1;
            dht11_reg2  <=  1'b1;
        end
    else
        begin
            dht11_reg1  <=  dht11;
            dht11_reg2  <=  dht11_reg1;
        end

assign  dht11_rise  =   (~dht11_reg2) && (dht11_reg1);
assign  dht11_fall  =   (dht11_reg2) && (~dht11_reg1);

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        bit_cnt <=  6'd0;
    else    if(bit_cnt == 40 && dht11_rise == 1'b1)
        bit_cnt <=  6'd0;
    else    if(state == RD_DATA && dht11_fall == 1'b1)
        bit_cnt <=  bit_cnt + 1'b1;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_temp   <=  40'b0;
    else    if(state == RD_DATA && dht11_fall == 1'b1 && cnt_us <= 50)
        data_temp[39-bit_cnt]   <=  1'b0;
    else    if(state == RD_DATA && dht11_fall == 1'b1 && cnt_us > 50)
        data_temp[39-bit_cnt]   <=  1'b1;
    else
        data_temp   <=  data_temp;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data    <=  32'b0;
    else    if(data_temp[7:0] == data_temp[39:32] + data_temp[31:24] + data_temp[23:16] + data_temp[15:8])
        data    <=  data_temp[39:8];
    else
        data    <=  data;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dht11_en    <=  1'b0;
    else    if(state == START)
        dht11_en    <=  1'b1;
    else
        dht11_en    <=  1'b0;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dht11_out   <=  1'b0;
    else
        dht11_out   <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_flag   <=  1'b0;
    else    if(key_flag == 1'b1)
        data_flag   <=  ~data_flag;
    else
        data_flag   <=  data_flag;

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_out    <=  20'b0;
    else    if(data_flag == 1'b0)
        data_out    <=  data[31:24] * 10;
    else    if(data_flag == 1'b1)
        data_out    <=  (data[15:8] * 10) + data[3:0];

always@(posedge clk_us or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sign    <=  1'b0;
    else    if(data_flag == 1'b1 && data[7] == 1'b1)
        sign    <=  1'b1;
    else
        sign    <=  1'b0;

assign  dht11 = (dht11_en == 1'b1) ? dht11_out : 1'bz;

endmodule
