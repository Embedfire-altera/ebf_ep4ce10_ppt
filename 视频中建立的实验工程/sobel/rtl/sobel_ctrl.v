module  sobel_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            pi_flag     ,
    input   wire    [7:0]   pi_data     ,

    output  reg             po_flag     ,
    output  reg     [7:0]   po_data
);

parameter   CNT_COL_MAX = 8'd100  ,
            CNT_ROW_MAX = 8'd100  ;

parameter   THR     =   8'b000_011_00;

parameter   BLACK   =   8'B000_000_00,
            WHITE   =   8'B111_111_11;

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
reg     [7:0]   cnt_rd      ;
reg     [7:0]   dout_1_reg  ;
reg     [7:0]   dout_2_reg  ;
reg     [7:0]   pi_data_reg ;
reg             rd_en_reg   ;
reg             rd_en_reg1  ;
reg     [7:0]   a1          ;
reg     [7:0]   a2          ;
reg     [7:0]   a3          ;
reg     [7:0]   b1          ;
reg     [7:0]   b2          ;
reg     [7:0]   b3          ;
reg     [7:0]   c1          ;
reg     [7:0]   c2          ;
reg     [7:0]   c3          ;
reg             gx_gy_flag  ;
reg     [8:0]   gx          ;
reg     [8:0]   gy          ;
reg             gxy_flag    ;
reg     [7:0]   gxy         ;
reg             com_flag    ;

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
        cnt_rd  <=  8'd0;
    else    if((cnt_rd == (CNT_COL_MAX - 1)) && (rd_en == 1'b1))
        cnt_rd  <=  8'd0;
    else    if(rd_en == 1'b1)
        cnt_rd  <=  cnt_rd + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout_1_reg  <=  8'd0;
    else    if(rd_en_reg == 1'b1)
        dout_1_reg  <=  dout_1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout_2_reg  <=  8'd0;
    else    if(rd_en_reg == 1'b1)
        dout_2_reg  <=  dout_2;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_data_reg <=  8'd0;
    else    if(rd_en_reg == 1'b1)
        pi_data_reg <=  pi_data;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en_reg   <=  1'b0;
    else    if(rd_en == 1'b1)
        rd_en_reg   <=  1'b1;
    else
        rd_en_reg   <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en_reg1   <=  1'b0;
    else    if(rd_en_reg == 1'b1)
        rd_en_reg1   <=  1'b1;
    else
        rd_en_reg1   <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            a1  <=  8'd0;
            a2  <=  8'd0;
            a3  <=  8'd0;
            b1  <=  8'd0;
            b2  <=  8'd0;
            b3  <=  8'd0;
            c1  <=  8'd0;
            c2  <=  8'd0;
            c3  <=  8'd0;
        end
    else
        begin
            a1  <=  a2;
            a2  <=  a3;
            a3  <=  dout_1_reg;
            b1  <=  b2;
            b2  <=  b3;
            b3  <=  dout_2_reg;
            c1  <=  c2;
            c2  <=  c3;
            c3  <=  pi_data_reg;
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gx_gy_flag  <=  1'b0;
    else    if((rd_en_reg1 == 1'b1) && ((cnt_rd >= 8'd3) || (cnt_rd == 8'd0)))
        gx_gy_flag  <=  1'b1;
    else
        gx_gy_flag  <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gx  <=  9'd0;
    else    if(gx_gy_flag ==1'b1)
        gx  <=  (a3-a1)+((b3-b1) << 1)+(c3-c1);
    else
        gx  <=  gx;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gy  <=  9'd0;
    else    if(gx_gy_flag ==1'b1)
        gy  <=  (a1-c1)+((a2-c2) << 1)+(a3-c3);
    else
        gy  <=  gy;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gxy_flag  <=  1'b0;
    else    if(gx_gy_flag == 1'b1)
        gxy_flag  <=  1'b1;
    else
        gxy_flag  <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gxy <=  8'd0;
    else    if((gx[8] == 1'b1) && (gy[8] == 1'b1) && (gxy_flag == 1'b1))
        gxy <=  (~gx[7:0] + 1'b1) + (~gy[7:0] + 1'b1);
    else    if((gx[8] == 1'b1) && (gy[8] == 1'b0) && (gxy_flag == 1'b1))
        gxy <=  (~gx[7:0] + 1'b1) + (gy[7:0]);
    else    if((gx[8] == 1'b0) && (gy[8] == 1'b1) && (gxy_flag == 1'b1))
        gxy <=  (gx[7:0]) + (~gy[7:0] + 1'b1);
    else    if((gx[8] == 1'b0) && (gy[8] == 1'b0) && (gxy_flag == 1'b1))
        gxy <=  (gx[7:0]) + (gy[7:0]);

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        com_flag    <=  1'b0;
    else    if(gxy_flag == 1'b1)
        com_flag    <=  1'b1;
    else
        com_flag    <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data <=  8'd0;
    else    if((com_flag == 1'b1) && (gxy > THR))
        po_data <=  BLACK;
    else    if(com_flag == 1'b1)
        po_data <=  WHITE;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_flag <=  1'b0;
    else    if(com_flag == 1'b1)
        po_flag <=  1'b1;
    else
        po_flag <=  1'b0;

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
