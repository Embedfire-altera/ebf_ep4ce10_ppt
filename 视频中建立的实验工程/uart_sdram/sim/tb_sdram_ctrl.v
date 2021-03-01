`timescale  1ns/1ns
module  tb_sdram_ctrl();

wire            clk_50m     ;
wire            clk_100m    ;
wire            clk_100m_shift;
wire            locked      ;
wire            rst_n       ;

wire            init_end    ;
wire            wr_ack      ;

wire    [15:0]  sdram_data_out;
wire            rd_ack      ;
wire            sdram_cke   ;
wire            sdram_cs_n  ;
wire            sdram_ras_n ;
wire            sdram_cas_n ;
wire            sdram_we_n  ;
wire    [1:0]   sdram_ba    ;
wire    [12:0]  sdram_addr  ;
wire    [15:0]  sdram_dq    ;

reg             sys_clk     ;
reg             sys_rst_n   ;
reg     [15:0]  wr_data_in  ;
reg             wr_en       ;
reg             rd_en       ;

defparam    sdram_model_plus_inst.addr_bits = 13;
defparam    sdram_model_plus_inst.data_bits = 16;
defparam    sdram_model_plus_inst.col_bits = 9;
defparam    sdram_model_plus_inst.mem_sizes = 2*1024*1024;

defparam    sdram_ctrl_inst.sdram_aref_inst.CNT_REF_MAX = 39;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n   <=  1'b0;
        #30
        sys_rst_n   <=  1'b1;
    end

always #10 sys_clk = ~sys_clk;

assign  rst_n = sys_rst_n & locked;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_en   <=  1'b1;
    else    if(wr_data_in == 10'd10)
        wr_en   <=  1'b0;
    else
        wr_en   <=  wr_en;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_data_in  <=  16'd0;
    else    if(wr_data_in == 16'd10)
        wr_data_in  <=  16'd0;
    else    if(wr_ack == 1'b1)
        wr_data_in  <=  wr_data_in + 1'b1;
    else
        wr_data_in  <=  wr_data_in;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if(wr_en == 1'b0)
        rd_en   <=  1'b1;
    else
        rd_en   <=  rd_en;

clk_gen clk_gen_inst
(
    .areset (~sys_rst_n),
    .inclk0 (sys_clk),
    .c0     (clk_50m),
    .c1     (clk_100m),
    .c2     (clk_100m_shift),
    .locked (locked)
);

sdram_ctrl  sdram_ctrl_inst
(
    //时钟 复位 初始化结束信号
    .sys_clk        (clk_100m),
    .sys_rst_n      (rst_n),
    .init_end       (init_end),
    //SDRAM写端口
    .sdram_wr_req   (wr_en),
    .sdram_wr_addr  (24'h000_000),
    .wr_burst_len   (10'd10),
    .sdram_data_in  (wr_data_in),
    .sdram_wr_ack   (wr_ack),
    //SDRAM读端口
    .sdram_rd_req   (rd_en),
    .sdram_rd_addr  (24'h000_000),
    .rd_burst_len   (10'd10),
    .sdram_data_out (sdram_data_out),
    .sdram_rd_ack   (rd_ack),
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

sdram_model_plus    sdram_model_plus_inst
(
    .Dq     (sdram_dq),
    .Addr   (sdram_addr),
    .Ba     (sdram_ba),
    .Clk    (clk_100m_shift),
    .Cke    (sdram_cke),
    .Cs_n   (sdram_cs_n),
    .Ras_n  (sdram_ras_n),
    .Cas_n  (sdram_cas_n),
    .We_n   (sdram_we_n),
    .Dqm    (2'b00),
    .Debug  (1'b1)
);

endmodule
