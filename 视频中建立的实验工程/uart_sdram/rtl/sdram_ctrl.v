module  sdram_ctrl
(
    //时钟 复位 初始化结束信号
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    output  wire            init_end    ,
    //SDRAM写端口
    input   wire            sdram_wr_req,
    input   wire    [23:0]  sdram_wr_addr,
    input   wire    [9:0]   wr_burst_len,
    input   wire    [15:0]  sdram_data_in,
    output  wire            sdram_wr_ack,
    //SDRAM读端口
    input   wire            sdram_rd_req,
    input   wire    [23:0]  sdram_rd_addr,
    input   wire    [9:0]   rd_burst_len,
    output  wire    [15:0]  sdram_data_out,
    output  wire            sdram_rd_ack,
    //SDRAM硬件接口
    output  wire            sdram_cke   ,
    output  wire            sdram_cs_n  ,
    output  wire            sdram_ras_n ,
    output  wire            sdram_cas_n ,
    output  wire            sdram_we_n  ,
    output  wire    [1:0]   sdram_ba    ,
    output  wire    [12:0]  sdram_addr  ,
    output  wire    [15:0]  sdram_dq
);

//init
wire    [3:0]   init_cmd    ;
wire    [1:0]   init_ba     ;
wire    [12:0]  init_addr   ;

//a_ref
wire            aref_en     ;
wire    [3:0]   aref_cmd    ;
wire    [1:0]   aref_ba     ;
wire    [12:0]  aref_addr   ;
wire            aref_end    ;
wire            aref_req    ;

//write
wire            wr_en       ;
wire    [3:0]   wr_cmd       ;
wire    [1:0]   wr_ba        ;
wire    [12:0]  wr_sdram_addr;
wire            wr_sdram_en  ;
wire            wr_end       ;
wire    [15:0]  wr_sdram_data;

//read
wire            rd_en       ;
wire    [3:0]   rd_cmd       ;
wire    [1:0]   rd_ba        ;
wire    [12:0]  rd_sdram_addr;
wire            rd_end       ;

sdram_init  sdram_init_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),

    .init_cmd    (init_cmd ),
    .init_ba     (init_ba  ),
    .init_addr   (init_addr),
    .init_end    (init_end )
);

sdram_arbit sdram_arbit_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),

    .init_cmd    (init_cmd ),
    .init_ba     (init_ba  ),
    .init_addr   (init_addr),
    .init_end    (init_end ),

    .aref_req    (aref_req ),
    .aref_cmd    (aref_cmd ),
    .aref_ba     (aref_ba  ),
    .aref_addr   (aref_addr),
    .aref_end    (aref_end ),

    .wr_req      (sdram_wr_req),
    .wr_cmd      (wr_cmd     ),
    .wr_ba       (wr_ba      ),
    .wr_addr     (wr_sdram_addr    ),
    .wr_end      (wr_end     ),
    .wr_sdram_en (wr_sdram_en),
    .wr_data     (wr_sdram_data ),

    .rd_req      (sdram_rd_req),
    .rd_cmd      (rd_cmd     ),
    .rd_ba       (rd_ba      ),
    .rd_addr     (rd_sdram_addr    ),
    .rd_end      (rd_end     ),
    //.rd_sdram_en (rd_sdram_en),

    .aref_en     (aref_en),
    .wr_en       (wr_en),
    .rd_en       (rd_en),

    .sdram_cke   (sdram_cke  ),
    .sdram_cs_n  (sdram_cs_n ),
    .sdram_cas_n (sdram_cas_n),
    .sdram_ras_n (sdram_ras_n),
    .sdram_we_n  (sdram_we_n ),
    .sdram_ba    (sdram_ba   ),
    .sdram_addr  (sdram_addr ),
    .sdram_dq    (sdram_dq   )
);

sdram_aref  sdram_aref_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .init_end    (init_end),
    .aref_en     (aref_en),

    .aref_cmd    (aref_cmd ),
    .aref_ba     (aref_ba  ),
    .aref_addr   (aref_addr),
    .aref_end    (aref_end ),
    .aref_req    (aref_req )
);

sdram_write sdram_write_inst
(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .init_end       (init_end),
    .wr_addr        (sdram_wr_addr),
    .wr_data        (sdram_data_in),
    .wr_burst_len   (wr_burst_len),
    .wr_en          (wr_en),

    .wr_cmd         (wr_cmd       ),
    .wr_ba          (wr_ba        ),
    .wr_sdram_addr  (wr_sdram_addr),
    .wr_sdram_en    (wr_sdram_en  ),
    .wr_end         (wr_end       ),
    .wr_sdram_data  (wr_sdram_data),
    .wr_ack         (sdram_wr_ack )
);

sdram_read  sdram_read_inst
(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .init_end       (init_end),
    .rd_addr        (sdram_rd_addr),
    .rd_data        (sdram_dq),
    .rd_burst_len   (rd_burst_len),
    .rd_en          (rd_en),

    .rd_cmd         (rd_cmd       ),
    .rd_ba          (rd_ba        ),
    .rd_sdram_addr  (rd_sdram_addr),
    .rd_end         (rd_end       ),
    .rd_sdram_data  (sdram_data_out),
    .rd_ack         (sdram_rd_ack)
);




endmodule
