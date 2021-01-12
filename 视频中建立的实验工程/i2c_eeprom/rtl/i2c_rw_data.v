module  i2c_rw_data
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            write       ,
    input   wire            read        ,
    input   wire    [7:0]   rd_data     ,
    input   wire            i2c_end     ,
    input   wire            i2c_clk     ,

    output  reg             i2c_start   ,
    output  reg             wr_en       ,
    output  reg     [15:0]  byte_addr   ,
    output  reg     [7:0]   wr_data     ,
    output  reg             rd_en       ,
    output  wire    [7:0]   fifo_data
);

parameter   CNT_WR_RD_MAX   =   8'd200;
parameter   CNT_START_MAX   =   16'd50_000;
parameter   CNT_DATA_NUM    =   8'd10;
parameter   CNT_WAIT_MAX    =   20'd500_000;

wire    [7:0]   data_num    ;

reg             wr_valid    ;
reg     [7:0]   cnt_wr      ;
reg             rd_valid    ;
reg     [7:0]   cnt_rd      ;
reg     [15:0]  cnt_start   ;
reg     [7:0]   cnt_wr_num  ;
reg     [7:0]   cnt_rd_num  ;
reg             fifo_rd_valid;
reg             fifo_rd_en  ;
reg     [19:0]  cnt_wait    ;
reg     [7:0]   cnt_rd_fifo_num  ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_valid    <=  1'b0;
    else    if(cnt_wr == CNT_WR_RD_MAX - 1)
        wr_valid    <=  1'b0;
    else    if(write == 1'b1)
        wr_valid    <=  1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wr  <=  8'd0;
    else    if(wr_valid == 1'b0)
        cnt_wr  <=  8'd0;
    else    if(wr_valid == 1'b1)
        cnt_wr  <=  cnt_wr + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_valid    <=  1'b0;
    else    if(cnt_rd == CNT_WR_RD_MAX - 1)
        rd_valid    <=  1'b0;
    else    if(read == 1'b1)
        rd_valid    <=  1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd  <=  8'd0;
    else    if(rd_valid == 1'b0)
        cnt_rd  <=  8'd0;
    else    if(rd_valid == 1'b1)
        cnt_rd  <=  cnt_rd + 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_start   <=  16'd0;
    else    if((wr_en == 1'b0) && (rd_en == 1'b0))
        cnt_start   <=  16'd0;
    else    if(cnt_start == CNT_START_MAX - 1'b1)
        cnt_start   <=  16'd0;
    else    if((wr_en == 1'b1) || (rd_en == 1'b1))
        cnt_start   <=  cnt_start + 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wr_num  <=  8'd0;
    else    if(wr_en == 1'b0)
        cnt_wr_num  <=  8'd0;
    else    if((wr_en == 1'b1) && (i2c_end == 1'b1))
        cnt_wr_num  <=  cnt_wr_num + 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd_num  <=  8'd0;
    else    if(rd_en == 1'b0)
        cnt_rd_num  <=  8'd0;
    else    if((rd_en == 1'b1) && (i2c_end == 1'b1))
        cnt_rd_num  <=  cnt_rd_num + 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fifo_rd_valid   <=  1'b0;
    else    if((cnt_rd_fifo_num == CNT_DATA_NUM) 
            && (cnt_wait == CNT_WAIT_MAX - 1'b1))
        fifo_rd_valid   <=  1'b0;
    else    if(data_num == CNT_DATA_NUM)
        fifo_rd_valid   <=  1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fifo_rd_en  <=  1'b0;
    else    if((cnt_rd_fifo_num < CNT_DATA_NUM) 
            && (cnt_wait == CNT_WAIT_MAX - 1'b1))
        fifo_rd_en  <=  1'b1;
    else
        fifo_rd_en  <=  1'b0;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  20'd0;
    else    if(fifo_rd_valid == 1'b0)
        cnt_wait    <=  20'd0;
    else    if(cnt_wait == CNT_WAIT_MAX - 1'b1)
        cnt_wait    <=  20'd0;
    else    if(fifo_rd_valid == 1'b1)
        cnt_wait    <=  cnt_wait + 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd_fifo_num <=  8'd0;
    else    if(fifo_rd_valid == 1'b0)
        cnt_rd_fifo_num <=  8'd0;
    else    if(fifo_rd_en == 1'b1)
        cnt_rd_fifo_num <=  cnt_rd_fifo_num + 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en   <=  1'b0;
    else    if((cnt_wr_num == CNT_DATA_NUM - 1'b1) 
                && (i2c_end == 1'b1) && (wr_en == 1'b1))
        wr_en   <=  1'b0;
    else    if(wr_valid == 1'b1)
        wr_en   <=  1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if((cnt_rd_num == CNT_DATA_NUM - 1'b1) 
                && (i2c_end == 1'b1) && (rd_en == 1'b1))
        rd_en   <=  1'b0;
    else    if(rd_valid == 1'b1)
        rd_en   <=  1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        i2c_start   <=  1'b0;
    else    if(cnt_start == CNT_START_MAX - 1'b1)
        i2c_start   <=  1'b1;
    else
        i2c_start   <=  1'b0;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        byte_addr   <=  16'h00_99;
    else    if((wr_en == 1'b0) && (rd_en == 1'b0))
        byte_addr   <=  16'h00_99;
    else    if(((wr_en == 1'b1) || (rd_en == 1'b1)) && (i2c_end == 1'b1))
        byte_addr   <=  byte_addr + 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_data <=  8'h01;
    else    if(wr_en == 1'b0)
        wr_data <=  8'h01;
    else    if((wr_en == 1'b1) && (i2c_end == 1'b1))
        wr_data <=  wr_data + 1'b1;


fifo_data   fifo_data_inst
(
    .clock (i2c_clk),
    .data (rd_data),
    .rdreq (fifo_rd_en),
    .wrreq (i2c_end && rd_en),
    .q (fifo_data),
    .usedw (data_num)
);

endmodule
