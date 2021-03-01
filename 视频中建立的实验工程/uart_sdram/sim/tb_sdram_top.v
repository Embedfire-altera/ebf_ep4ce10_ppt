`timescale  1ns/1ns
module  tb_sdram_top();

wire            clk_50m     ;
wire            clk_100m    ;
wire            clk_100m_shift;
wire            locked      ;
wire            rst_n       ;

wire    [15:0]  rd_fifo_rd_data;
wire    [9:0]   rd_fifo_num    ;

wire            sdram_clk      ;
wire            sdram_cke      ;
wire            sdram_cs_n     ;
wire            sdram_ras_n    ;
wire            sdram_cas_n    ;
wire            sdram_we_n     ;
wire    [1:0]   sdram_ba       ;
wire    [12:0]  sdram_addr     ;
wire            sdram_dqm      ;
wire    [15:0]  sdram_dq       ;

reg             sys_clk     ;
reg             sys_rst_n   ;
reg             wr_data_flag;
reg     [15:0]  wr_data_in  ;
reg     [2:0]   cnt_wr_wait ;
reg             wr_en       ;
reg             rd_en       ;
reg     [3:0]   cnt_rd_data ;
reg             read_valid  ;

defparam    sdram_model_plus_inst.addr_bits = 13;
defparam    sdram_model_plus_inst.data_bits = 16;
defparam    sdram_model_plus_inst.col_bits = 9;
defparam    sdram_model_plus_inst.mem_sizes = 2*1024*1024;
defparam    sdram_top_inst.sdram_ctrl_inst.sdram_aref_inst.CNT_REF_MAX = 39;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n   <=  1'b0;
        #30
        sys_rst_n   <=  1'b1;
    end

always #10 sys_clk = ~sys_clk;

assign  rst_n = sys_rst_n & locked;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_wr_wait <=  3'd0;
    else    if(wr_en == 1'b1)
        cnt_wr_wait <=  cnt_wr_wait + 1'b1;
    else
        cnt_wr_wait <=  3'd0;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_data_flag    <=  1'b0;
    else    if(cnt_wr_wait == 3'd7)
        wr_data_flag    <=  1'b1;
    else
        wr_data_flag    <=  1'b0;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_data_in    <=  16'b0;
    else    if(cnt_wr_wait == 3'd7)
        wr_data_in   <=  wr_data_in + 1'b1;
    else
        wr_data_in    <=  wr_data_in;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_en   <=  1'b1;
    else    if(wr_data_in == 16'd10)
        wr_en   <=  1'b0;
    else
        wr_en   <=  wr_en;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if(cnt_rd_data == 4'd9)
        rd_en   <=  1'b0;
    else    if((wr_en == 1'b0) && (rd_fifo_num == 10'd10))
        rd_en   <=  1'b1;
    else
        rd_en   <=  rd_en;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_rd_data <=  4'd0;
    else    if(rd_en == 1'b1)
        cnt_rd_data <=  cnt_rd_data + 1'b1;
    else
        cnt_rd_data <=  4'd0;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        read_valid  <=  1'b1;
    else    if(rd_fifo_num == 10'd10)
        read_valid  <=  1'b0;


clk_gen clk_gen_inst
(
    .areset (~sys_rst_n),
    .inclk0 (sys_clk),
    .c0     (clk_50m),
    .c1     (clk_100m),
    .c2     (clk_100m_shift),
    .locked (locked)
);


sdram_top   sdram_top_inst
(
    .sys_clk         (clk_100m),
    .sys_rst_n       (rst_n),
    .clk_out         (clk_100m_shift),
    //写fifo信号
    .wr_fifo_wr_clk  (clk_50m),
    .wr_fifo_wr_req  (wr_data_flag),
    .wr_fifo_wr_data (wr_data_in),
    .sdram_wr_b_addr (0),
    .sdram_wr_e_addr (10),
    .wr_burst_len    (10),
    .wr_rst          (~rst_n),
    //读fifo信号
    .rd_fifo_rd_clk  (clk_50m),
    .rd_fifo_rd_req  (rd_en),
    .sdram_rd_b_addr (0),
    .sdram_rd_e_addr (10),
    .rd_burst_len    (10),
    .rd_rst          (~rst_n),
    .rd_fifo_rd_data (rd_fifo_rd_data),
    .rd_fifo_num     (rd_fifo_num),
    .read_valid      (read_valid),
    //SDRAM硬件接口
    .sdram_clk       (sdram_clk  ),
    .sdram_cke       (sdram_cke  ),
    .sdram_cs_n      (sdram_cs_n ),
    .sdram_ras_n     (sdram_ras_n),
    .sdram_cas_n     (sdram_cas_n),
    .sdram_we_n      (sdram_we_n ),
    .sdram_ba        (sdram_ba   ),
    .sdram_addr      (sdram_addr ),
    .sdram_dqm       (sdram_dqm  ),
    .sdram_dq        (sdram_dq   )
);

sdram_model_plus    sdram_model_plus_inst
(
    .Dq     (sdram_dq),
    .Addr   (sdram_addr),
    .Ba     (sdram_ba),
    .Clk    (sdram_clk),
    .Cke    (sdram_cke),
    .Cs_n   (sdram_cs_n),
    .Ras_n  (sdram_ras_n),
    .Cas_n  (sdram_cas_n),
    .We_n   (sdram_we_n),
    .Dqm    (sdram_dqm),
    .Debug  (1'b1)
);

endmodule
