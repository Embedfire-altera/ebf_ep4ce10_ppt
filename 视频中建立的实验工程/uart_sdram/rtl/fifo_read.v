module  fifo_read
(
    input   wire            sys_clk         ,
    input   wire            sys_rst_n       ,
    input   wire    [9:0]   rd_fifo_num     ,
    input   wire    [7:0]   rd_fifo_rd_data ,
    input   wire    [9:0]   burst_num       ,

    output  reg             rd_en           ,
    output  wire    [7:0]   tx_data         ,
    output  reg             tx_flag
);

parameter   BAUD_CNT_MAX    =   13'd5207,
            BAUD_CNT_HALF   =   13'd2603;

wire    [9:0]   data_num    ;

reg             rd_en_dly   ;
reg             rd_flag     ;
reg     [12:0]  baud_cnt    ;
reg     [3:0]   bit_cnt     ;
reg             bit_flag    ;
reg             read_fifo_en;
reg     [9:0]   cnt_read    ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if(rd_fifo_num == burst_num)
        rd_en   <=  1'b1;
    else    if(data_num == burst_num - 2)
        rd_en   <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en_dly   <=  1'b0;
    else
        rd_en_dly   <=  rd_en;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_flag <=  1'b0;
    else    if(cnt_read == burst_num)
        rd_flag <=  1'b0;
    else    if(data_num == burst_num)
        rd_flag <=  1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        baud_cnt    <=  13'd0;
    else    if(baud_cnt == BAUD_CNT_MAX)
        baud_cnt    <=  13'd0;
    else    if(rd_flag == 1'b1)
        baud_cnt    <=  baud_cnt + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        bit_flag    <=  1'b0;
    else    if(baud_cnt == BAUD_CNT_HALF)
        bit_flag    <=  1'b1;
    else
        bit_flag    <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        bit_cnt <=  4'd0;
    else    if((bit_cnt == 4'd9) && (bit_flag == 1'b1))
        bit_cnt <=  4'd0;
    else    if(bit_flag == 1'b1)
        bit_cnt <=  bit_cnt + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        read_fifo_en    <=  1'b0;
    else    if((bit_cnt == 4'd9) && (bit_flag == 1'b1))
        read_fifo_en    <=  1'b1;
    else
        read_fifo_en    <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_read    <=  10'd0;
    else    if(cnt_read == burst_num)
        cnt_read    <=  10'd0;
    else    if(read_fifo_en == 1'b1)
        cnt_read    <=  cnt_read + 1'b1;
    else
        cnt_read    <=  cnt_read;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tx_flag <=  1'b0;
    else
        tx_flag <=  read_fifo_en;

read_fifo   read_fifo_inst
(
    .clock  (sys_clk            ),
    .data   (rd_fifo_rd_data    ),
    .rdreq  (read_fifo_en       ),
    .wrreq  (rd_en_dly          ),
    .q      (tx_data            ),
    .usedw  (data_num           )
);

endmodule
