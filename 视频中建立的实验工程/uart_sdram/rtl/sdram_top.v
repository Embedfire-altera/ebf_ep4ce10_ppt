module  sdram_top
(
    input   wire            sys_clk         ,
    input   wire            sys_rst_n       ,
    input   wire            clk_out         ,
    //写fifo信号
    input   wire            wr_fifo_wr_clk  ,
    input   wire            wr_fifo_wr_req  ,
    input   wire    [15:0]  wr_fifo_wr_data ,
    input   wire    [23:0]  sdram_wr_b_addr ,
    input   wire    [23:0]  sdram_wr_e_addr ,
    input   wire    [9:0]   wr_burst_len    ,
    input   wire            wr_rst          ,
    //读fifo信号
    input   wire            rd_fifo_rd_clk  ,
    input   wire            rd_fifo_rd_req  ,
    input   wire    [23:0]  sdram_rd_b_addr ,
    input   wire    [23:0]  sdram_rd_e_addr ,
    input   wire    [9:0]   rd_burst_len    ,
    input   wire            rd_rst          ,
    output  wire    [15:0]  rd_fifo_rd_data ,
    output  wire    [9:0]   rd_fifo_num     ,
    input   wire            read_valid      ,
    //SDRAM硬件接口
    output  wire            sdram_clk       ,
    output  wire            sdram_cke       ,
    output  wire            sdram_cs_n      ,
    output  wire            sdram_ras_n     ,
    output  wire            sdram_cas_n     ,
    output  wire            sdram_we_n      ,
    output  wire    [1:0]   sdram_ba        ,
    output  wire    [12:0]  sdram_addr      ,
    output  wire    [1:0]   sdram_dqm       ,
    inout   wire    [15:0]  sdram_dq
);

assign  sdram_clk = clk_out;
assign  sdram_dqm = 2'b00;


wire            init_end        ;
wire            sdram_wr_ack    ;
wire            sdram_wr_req    ;
wire    [23:0]  sdram_wr_addr   ;
wire    [15:0]  sdram_data_in   ;

wire            sdram_rd_ack    ;
wire    [15:0]  sdram_data_out  ;
wire            sdram_rd_req    ;
wire    [23:0]  sdram_rd_addr   ;


fifo_ctrl   fifo_ctrl_inst
(
    .sys_clk         (sys_clk),
    .sys_rst_n       (sys_rst_n),
    //写fifo信号
    .wr_fifo_wr_clk  (wr_fifo_wr_clk),
    .wr_fifo_wr_req  (wr_fifo_wr_req),
    .wr_fifo_wr_data (wr_fifo_wr_data),
    .sdram_wr_b_addr (sdram_wr_b_addr),
    .sdram_wr_e_addr (sdram_wr_e_addr),
    .wr_burst_len    (wr_burst_len),
    .wr_rst          (wr_rst),
    //读fifo信号
    .rd_fifo_rd_clk  (rd_fifo_rd_clk),
    .rd_fifo_rd_req  (rd_fifo_rd_req),
    .sdram_rd_b_addr (sdram_rd_b_addr),
    .sdram_rd_e_addr (sdram_rd_e_addr),
    .rd_burst_len    (rd_burst_len),
    .rd_rst          (rd_rst),
    .rd_fifo_rd_data (rd_fifo_rd_data),
    .rd_fifo_num     (rd_fifo_num),
    .init_end        (init_end),
    .read_valid      (read_valid),
    //SDRAM写信号
    .sdram_wr_ack    (sdram_wr_ack),
    .sdram_wr_req    (sdram_wr_req),
    .sdram_wr_addr   (sdram_wr_addr),
    .sdram_data_in   (sdram_data_in),
    //SDRAM读信号
    .sdram_rd_ack    (sdram_rd_ack),
    .sdram_data_out  (sdram_data_out),
    .sdram_rd_req    (sdram_rd_req),
    .sdram_rd_addr   (sdram_rd_addr)
);



sdram_ctrl  sdram_ctrl_inst
(
    //时钟 复位 初始化结束信号
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .init_end       (init_end),
    //SDRAM写端口
    .sdram_wr_req   (sdram_wr_req),
    .sdram_wr_addr  (sdram_wr_addr),
    .wr_burst_len   (wr_burst_len),
    .sdram_data_in  (sdram_data_in),
    .sdram_wr_ack   (sdram_wr_ack),
    //SDRAM读端口
    .sdram_rd_req   (sdram_rd_req),
    .sdram_rd_addr  (sdram_rd_addr),
    .rd_burst_len   (rd_burst_len),
    .sdram_data_out (sdram_data_out),
    .sdram_rd_ack   (sdram_rd_ack),
    //SDRAM硬件接口
    .sdram_cke      (sdram_cke  ),
    .sdram_cs_n     (sdram_cs_n ),
    .sdram_ras_n    (sdram_ras_n),
    .sdram_cas_n    (sdram_cas_n),
    .sdram_we_n     (sdram_we_n ),
    .sdram_ba       (sdram_ba   ),
    .sdram_addr     (sdram_addr ),
    .sdram_dq       (sdram_dq   )
);

endmodule

