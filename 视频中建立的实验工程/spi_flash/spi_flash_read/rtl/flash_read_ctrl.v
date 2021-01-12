module  flash_read_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_flag    ,
    input   wire            miso        ,

    output  reg             cs_n        ,
    output  reg             sck         ,
    output  reg             mosi        ,
    output  wire    [7:0]   pi_data     ,
    output  reg             pi_flag
);
parameter   WAIT_MAX = 16'd600_00;

parameter   DATA_NUM = 'd256;

parameter   IDLE    = 3'b001,
            READ    = 3'b010,
            SEND    = 3'b100;

parameter   READ_INST   =   8'b0000_0011,
            S_ADDR      =   8'b0000_0000,
            P_ADDR      =   8'b0000_0000,
            B_ADDR      =   8'b1100_1000;

wire    [8:0]   fifo_num;

reg     [2:0]   state   ;
reg     [4:0]   cnt_clk ;
reg     [15:0]  cnt_byte;
reg     [1:0]   cnt_sck ;
reg     [2:0]   cnt_bit ;
reg             miso_flag;
reg     [7:0]   data    ;
reg     [7:0]   data_reg;
reg             flag_reg;
reg             wr_en   ;
reg             rd_en   ;
reg     [15:0]  cnt_wait;
reg     [15:0]   rd_num  ;
reg             valid   ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else    case(state)
        IDLE:   if(key_flag == 1'b1)
            state   <=  READ;
        READ:   if((cnt_byte == DATA_NUM + 3) && (cnt_clk == 5'd31))
            state   <=  SEND;
        SEND:   if((rd_num == DATA_NUM) && (cnt_wait == WAIT_MAX - 1))
            state   <=  IDLE;
        default:state   <=  IDLE;
    endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <=  5'd0;
    else    if(state == READ)
        cnt_clk <=  cnt_clk + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_byte    <=  16'd0;
    else    if((cnt_byte == DATA_NUM + 3) && (cnt_clk == 5'd31))
        cnt_byte    <=  16'd0;
    else    if(cnt_clk == 5'd31)
        cnt_byte    <=  cnt_byte + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_sck <=  2'd0;
    else    if(state == READ)
        cnt_sck <= cnt_sck + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit <=  3'd0;
    else    if(cnt_sck == 2'd2)
        cnt_bit <=  cnt_bit + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        miso_flag   <=  1'b0;
    else    if((cnt_byte >= 16'd4) && (cnt_sck == 2'd1))
        miso_flag   <=  1'b1;
    else
        miso_flag   <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data    <=  8'b0;
    else    if(miso_flag == 1'b1)
        data    <=  {data[6:0],miso};//{miso,data[7:1]};//

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_reg    <=  1'b0;
    else    if((cnt_bit == 3'd7) && (miso_flag == 1'b1))
        flag_reg    <=  1'b1;
    else
        flag_reg    <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_reg    <=  8'b0;
    else    if(flag_reg == 1'b1)
        data_reg    <=  data;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en   <=  1'b0;
    else
        wr_en   <=  flag_reg;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if((cnt_wait == WAIT_MAX) && (rd_num < DATA_NUM))
        rd_en   <=  1'b1;
    else
        rd_en   <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  16'd0;
    else    if(valid == 1'b0)
        cnt_wait    <=  16'd0;
    else    if(cnt_wait == WAIT_MAX)
        cnt_wait    <=  16'd0;
    else    if(valid == 1'b1)
        cnt_wait    <=  cnt_wait + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_num  <=  16'd0;
    else    if(valid == 1'b0)
        rd_num  <=  16'd0;
    else    if(rd_en == 1'b1)
        rd_num  <=  rd_num + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        valid   <=  1'b0;
    else    if((rd_num == DATA_NUM) && (cnt_wait == WAIT_MAX))
        valid   <=  1'b0;
    else    if(fifo_num == DATA_NUM)
        valid   <=  1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cs_n    <=  1'b1;
    else    if(key_flag == 1'b1)
        cs_n    <=  1'b0;
    else    if((cnt_clk == 5'd31) &&(cnt_byte == DATA_NUM + 3) && (state == READ))
        cs_n    <=  1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mosi    <=  1'b0;
    else    if((cnt_byte >= 16'd4) && (state == READ))
        mosi    <=  1'b0;
    else    if((state == READ) && (cnt_byte == 16'd0) && (cnt_sck == 2'd0))
        mosi    <=  READ_INST[7 - cnt_bit];
    else    if((state == READ) && (cnt_byte == 16'd1) && (cnt_sck == 2'd0))
        mosi    <=  S_ADDR[7 - cnt_bit];
    else    if((state == READ) && (cnt_byte == 16'd2) && (cnt_sck == 2'd0))
        mosi    <=  P_ADDR[7 - cnt_bit];
    else    if((state == READ) && (cnt_byte == 16'd3) && (cnt_sck == 2'd0))
        mosi    <=  B_ADDR[7 - cnt_bit];

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sck <=  1'b0;
    else    if(cnt_sck == 2'd0)
        sck <=  1'b0;
    else    if(cnt_sck == 2'd2)
        sck <=  1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_flag <=  1'b0;
    else
        pi_flag <=  rd_en;

fifo_data   fifo_data_inst
(
    .clock  (sys_clk    ),
    .data   (data_reg   ),
    .rdreq  (rd_en),
    .wrreq  (wr_en  ),
    .q      (pi_data),
    .usedw  (fifo_num)
);

endmodule
