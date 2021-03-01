`timescale  1ns/1ns
module  tb_sdram_write();

wire            clk_50m     ;
wire            clk_100m    ;
wire            clk_100m_shift;
wire            locked      ;
wire            rst_n       ;

wire    [3:0]   init_cmd    ;
wire    [1:0]   init_ba     ;
wire    [12:0]  init_addr   ;
wire            init_end    ;

wire    [3:0]   wr_cmd      ;
wire    [1:0]   wr_ba       ;
wire    [12:0]  wr_sdram_addr;
wire            wr_sdram_en ;
wire            wr_end      ;
wire    [15:0]  wr_sdram_data;
wire            wr_ack      ;

wire    [3:0]   sdram_cmd    ;
wire    [1:0]   sdram_ba     ;
wire    [12:0]  sdram_addr   ;
wire    [15:0]  sdram_data   ;

reg             sys_clk     ;
reg             sys_rst_n   ;
reg     [15:0]  wr_data_in  ;
reg             wr_en       ;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n   <=  1'b0;
        #30
        sys_rst_n   <=  1'b1;
    end

always #10 sys_clk = ~sys_clk;

assign  rst_n = sys_rst_n & locked;

defparam    sdram_model_plus_inst.addr_bits = 13;
defparam    sdram_model_plus_inst.data_bits = 16;
defparam    sdram_model_plus_inst.col_bits = 9;
defparam    sdram_model_plus_inst.mem_sizes = 2*1024*1024;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_en   <=  1'b0;
    else    if(wr_end == 1'b1)
        wr_en   <=  1'b0;
    else    if(init_end == 1'b1)
        wr_en   <=  1'b1;
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

assign  sdram_cmd  = (init_end == 1'b1) ? wr_cmd  : init_cmd ;
assign  sdram_ba   = (init_end == 1'b1) ? wr_ba   : init_ba  ;
assign  sdram_addr = (init_end == 1'b1) ? wr_sdram_addr : init_addr;
assign  sdram_data = (wr_sdram_en == 1'b1) ? wr_sdram_data : 16'hzzzz;

clk_gen clk_gen_inst
(
    .areset (~sys_rst_n),
    .inclk0 (sys_clk),
    .c0     (clk_50m),
    .c1     (clk_100m),
    .c2     (clk_100m_shift),
    .locked (locked)
);

sdram_init  sdram_init_inst
(
    .sys_clk     (clk_100m),
    .sys_rst_n   (rst_n),

    .init_cmd    (init_cmd ),
    .init_ba     (init_ba  ),
    .init_addr   (init_addr),
    .init_end    (init_end )
);

sdram_write sdram_write_inst
(
    .sys_clk        (clk_100m),
    .sys_rst_n      (rst_n),
    .init_end       (init_end),
    .wr_addr        (24'h000_000),
    .wr_data        (wr_data_in),
    .wr_burst_len   (10'd10),
    .wr_en          (wr_en),

    .wr_cmd         (wr_cmd       ),
    .wr_ba          (wr_ba        ),
    .wr_sdram_addr  (wr_sdram_addr),
    .wr_sdram_en    (wr_sdram_en  ),
    .wr_end         (wr_end       ),
    .wr_sdram_data  (wr_sdram_data),
    .wr_ack         (wr_ack       )
);

sdram_model_plus    sdram_model_plus_inst
(
    .Dq     (sdram_data),
    .Addr   (sdram_addr),
    .Ba     (sdram_ba),
    .Clk    (clk_100m_shift),
    .Cke    (1'b1),
    .Cs_n   (sdram_cmd[3]),
    .Ras_n  (sdram_cmd[2]),
    .Cas_n  (sdram_cmd[1]),
    .We_n   (sdram_cmd[0]),
    .Dqm    (2'b00),
    .Debug  (1'b1)
);

endmodule
