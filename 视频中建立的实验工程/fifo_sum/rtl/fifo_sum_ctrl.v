module  fifo_sum_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            pi_flag     ,
    input   wire    [7:0]   pi_data     ,

    output  reg             po_flag     ,
    output  reg     [7:0]   po_data
);

parameter   CNT_COL_MAX = 8'd3  ,
            CNT_ROW_MAX = 8'd4  ;

wire    [7:0]   dout_1      ;
wire    [7:0]   dout_2      ;

reg     [7:0]   cnt_col     ;
reg     [7:0]   cnt_row     ;
reg             wr_en_1     ;
reg     [7:0]   wr_data_1   ;
reg             wr_en_2     ;
reg     [7:0]   wr_data_2   ;
reg             rd_en       ;
reg             dout_flag   ;
reg             sum_flag    ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_col <=  8'd0;
    else    if(cnt_col == CNT_COL_MAX && pi_flag == 1'b1)
        cnt_col <=  8'd0;
    else    if(pi_flag == 1'b1)
        cnt_col <=  cnt_col + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_row <=  8'd0;
    else    if(cnt_col == CNT_COL_MAX && cnt_row == CNT_ROW_MAX && pi_flag == 1'b1)
        cnt_row <=  8'd0;
    else    if(cnt_col == CNT_COL_MAX && pi_flag == 1'b1)
        cnt_row <=  cnt_row + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en_1 <=  1'b0;
    else    if(cnt_row == 8'd0 && pi_flag == 1'b1)
        wr_en_1 <=  1'b1;
    else
        wr_en_1 <=  dout_flag;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_data_1   <=  8'd0;
    else    if(cnt_row == 8'd0 && pi_flag == 1'b1)
        wr_data_1   <=  pi_data;
    else    if(dout_flag == 1'b1)
        wr_data_1   <=  dout_2;
    else
        wr_data_1   <=  wr_data_1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en_2 <=  1'b0;
    else    if(cnt_row >= 8'd1 && (cnt_row <= CNT_ROW_MAX - 1'b1) && pi_flag == 1'b1)
        wr_en_2 <=  1'b1;
    else
        wr_en_2 <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_data_2   <=  8'd0;
    else    if(cnt_row >= 8'd1 && (cnt_row <= CNT_ROW_MAX - 1'b1) && pi_flag == 1'b1)
        wr_data_2   <=  pi_data;
    else
        wr_data_2   <=  wr_data_2;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if(cnt_row >= 8'd2 && (cnt_row <= CNT_ROW_MAX) && pi_flag == 1'b1)
        rd_en   <=  1'b1;
    else
        rd_en   <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout_flag   <=  1'b0;
    else    if(wr_en_2 == 1'b1 && rd_en == 1'b1)
        dout_flag   <=  1'b1;
    else
        dout_flag   <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sum_flag    <=  1'b0;
    else    if(rd_en == 1'b1)
        sum_flag    <=  1'b1;
    else
        sum_flag    <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data <=  8'd0;
    else    if(sum_flag == 1'b1)
        po_data <=  dout_1 + dout_2 + pi_data;
    else
        po_data <=  po_data;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_flag <=  1'b0;
    else
        po_flag <=  sum_flag;

fifo    fifo_inst_1
(
    .clock  (sys_clk    ),
    .data   (wr_data_1  ),
    .rdreq  (rd_en      ),
    .wrreq  (wr_en_1    ),
    .q      (dout_1     )
);

fifo    fifo_inst_2
(
    .clock  (sys_clk    ),
    .data   (wr_data_2  ),
    .rdreq  (rd_en      ),
    .wrreq  (wr_en_2    ),
    .q      (dout_2     )
);

endmodule
