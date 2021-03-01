`timescale  1ns/1ns
module  tb_sdram_aref();

wire            clk_50m     ;
wire            clk_100m    ;
wire            clk_100m_shift;
wire            locked      ;
wire            rst_n       ;

wire    [3:0]   init_cmd    ;
wire    [1:0]   init_ba     ;
wire    [12:0]  init_addr   ;
wire            init_end    ;

wire    [3:0]   aref_cmd    ;
wire    [1:0]   aref_ba     ;
wire    [12:0]  aref_addr   ;
wire            aref_end    ;
wire            aref_req    ;

wire    [3:0]   sdram_cmd    ;
wire    [1:0]   sdram_ba     ;
wire    [12:0]  sdram_addr   ;


reg             sys_clk     ;
reg             sys_rst_n   ;
reg             aref_en     ;

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
        aref_en <=  1'b0;
    else    if((init_end == 1'b1) && (aref_req == 1'b1))
        aref_en <=  1'b1;
    else    if(aref_end == 1'b1)
        aref_en <=  1'b0;

assign  sdram_cmd  = (init_end == 1'b1) ? aref_cmd  : init_cmd ;
assign  sdram_ba   = (init_end == 1'b1) ? aref_ba   : init_ba  ;
assign  sdram_addr = (init_end == 1'b1) ? aref_addr : init_addr;

defparam    sdram_model_plus_inst.addr_bits = 13;
defparam    sdram_model_plus_inst.data_bits = 16;
defparam    sdram_model_plus_inst.col_bits = 9;
defparam    sdram_model_plus_inst.mem_sizes = 2*1024*1024;

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

sdram_aref  sdram_aref_inst
(
    .sys_clk     (clk_100m),
    .sys_rst_n   (rst_n),
    .init_end    (init_end),
    .aref_en     (aref_en),

    .aref_cmd    (aref_cmd ),
    .aref_ba     (aref_ba  ),
    .aref_addr   (aref_addr),
    .aref_end    (aref_end ),
    .aref_req    (aref_req )
);


sdram_model_plus    sdram_model_plus_inst
(
    .Dq     (       ),
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
