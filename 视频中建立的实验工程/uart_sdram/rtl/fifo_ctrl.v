module  fifo_ctrl
(
    input   wire            sys_clk         ,
    input   wire            sys_rst_n       ,
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

    input   wire            init_end        ,
    input   wire            read_valid      ,
    //SDRAM写信号
    input   wire            sdram_wr_ack    ,
    output  reg             sdram_wr_req    ,
    output  reg     [23:0]  sdram_wr_addr   ,
    output  wire    [15:0]  sdram_data_in   ,
    //SDRAM读信号
    input   wire            sdram_rd_ack    ,
    input   wire    [15:0]  sdram_data_out  ,
    output  reg             sdram_rd_req    ,
    output  reg     [23:0]  sdram_rd_addr
);

wire    [9:0]   wr_fifo_num ;
wire            wr_ack_fall ;
wire            rd_ack_fall ;

reg             wr_ack_dly  ;
reg             rd_ack_dly  ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_ack_dly  <=  1'b0;
    else
        wr_ack_dly  <=  sdram_wr_ack;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_ack_dly  <=  1'b0;
    else
        rd_ack_dly  <=  sdram_rd_ack;

assign  wr_ack_fall = (wr_ack_dly & ~sdram_wr_ack);
assign  rd_ack_fall = (rd_ack_dly & ~sdram_rd_ack);

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sdram_wr_addr   <=  24'd0;
    else    if(wr_rst == 1'b1)
        sdram_wr_addr   <=  sdram_wr_b_addr;
    else    if(wr_ack_fall == 1'b1)
        begin
            if(sdram_wr_addr < (sdram_wr_e_addr - wr_burst_len))
                sdram_wr_addr   <=  sdram_wr_addr + wr_burst_len;
            else
                sdram_wr_addr   <=  sdram_wr_b_addr;
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sdram_rd_addr   <=  24'd0;
    else    if(rd_rst == 1'b1)
        sdram_rd_addr   <=  sdram_rd_b_addr;
    else    if(rd_ack_fall == 1'b1)
        begin
            if(sdram_rd_addr < (sdram_rd_e_addr - rd_burst_len))
                sdram_rd_addr   <=  sdram_rd_addr + rd_burst_len;
            else
                sdram_rd_addr   <=  sdram_rd_b_addr;
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            sdram_wr_req    <=  1'b0;
            sdram_rd_req    <=  1'b0;
        end
    else    if(init_end == 1'b1)
        begin
            if(wr_fifo_num >= wr_burst_len)
                begin
                    sdram_wr_req    <=  1'b1;
                    sdram_rd_req    <=  1'b0;
                end
            else    if((rd_fifo_num < rd_burst_len) && (read_valid == 1'b1))
                begin
                    sdram_wr_req    <=  1'b0;
                    sdram_rd_req    <=  1'b1;
                end
            else
                begin
                    sdram_wr_req    <=  1'b0;
                    sdram_rd_req    <=  1'b0;
                end
        end
    else
        begin
            sdram_wr_req    <=  1'b0;
            sdram_rd_req    <=  1'b0;
        end

fifo_data   wr_fifo_data_inst
(
//用户接口
    .wrclk      (wr_fifo_wr_clk),
    .wrreq      (wr_fifo_wr_req),
    .data       (wr_fifo_wr_data),
//SDRAM接口
    .rdclk      (sys_clk),
    .rdreq      (sdram_wr_ack),
    .q          (sdram_data_in),

    .aclr       (wr_rst || ~sys_rst_n),
    .rdusedw    (wr_fifo_num),
    .wrusedw    ()
);


fifo_data   rd_fifo_data_inst
(
//SDRAM接口
    .wrclk      (sys_clk),
    .wrreq      (sdram_rd_ack),
    .data       (sdram_data_out),
//用户接口
    .rdclk      (rd_fifo_rd_clk),
    .rdreq      (rd_fifo_rd_req),
    .q          (rd_fifo_rd_data),

    .aclr       (rd_rst || ~sys_rst_n),
    .rdusedw    (),
    .wrusedw    (rd_fifo_num)
);

endmodule
