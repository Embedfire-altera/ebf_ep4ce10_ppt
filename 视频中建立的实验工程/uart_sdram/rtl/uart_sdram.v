module  uart_sdram
(
    input   wire            sys_clk         ,
    input   wire            sys_rst_n       ,
    input   wire            rx              ,

    output  wire            tx              ,
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

parameter   UART_BPS    =   'd9600,
            CLK_FREQ    =   'd50_000_000;
parameter   DATA_NUM    =   'd10;
parameter   WAIT_MAX    =   'd750;

wire            clk_50m     ;
wire            clk_100m    ;
wire            clk_100m_shift;
wire            locked      ;
wire            rst_n       ;
wire    [7:0]   rx_data     ;
wire            rx_flag     ;
wire            rfifo_wr_en ;
wire    [7:0]   rfifo_wr_data;
wire    [9:0]   rd_fifo_num ;
wire    [7:0]   rfifo_rd_data;
wire            rfifo_rd_en ;

reg             read_valid  ;
reg     [15:0]  cnt_wait    ;
reg     [23:0]  data_num    ;

assign  rst_n = sys_rst_n & locked;

always@(posedge clk_50m or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  16'd0;
    else    if(cnt_wait == WAIT_MAX)
        cnt_wait    <=  16'd0;
    else    if(data_num == DATA_NUM)
        cnt_wait    <=  cnt_wait + 1'b1;

always@(posedge clk_50m or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_num    <=  24'd0;
    else    if(read_valid == 1'b1)
        data_num    <=  24'd0;
    else    if(rx_flag == 1'b1)
        data_num    <=  data_num + 1'b1;
    else
        data_num    <=  data_num;

always@(posedge clk_50m or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        read_valid  <=  1'b0;
    else    if(cnt_wait == WAIT_MAX)
        read_valid  <=  1'b1;
    else    if(rd_fifo_num == DATA_NUM)
        read_valid  <=  1'b0;


clk_gen clk_gen_inst
(
    .areset (~sys_rst_n     ),
    .inclk0 (sys_clk        ),
    .c0     (clk_50m        ),
    .c1     (clk_100m       ),
    .c2     (clk_100m_shift ),
    .locked (locked         )
);

uart_rx 
#(
    .UART_BPS    (UART_BPS  ),
    .CLK_FREQ    (CLK_FREQ  )
)
uart_rx_inst
(
    .sys_clk     (clk_50m   ),
    .sys_rst_n   (rst_n     ),
    .rx          (rx        ),

    .po_data     (rx_data   ),
    .po_flag     (rx_flag   )
);

sdram_top   sdram_top_inst
(
    .sys_clk         (clk_100m      ),
    .sys_rst_n       (rst_n         ),
    .clk_out         (clk_100m_shift),
    //写fifo信号
    .wr_fifo_wr_clk  (clk_50m       ),
    .wr_fifo_wr_req  (rx_flag       ),
    .wr_fifo_wr_data ({8'b0,rx_data}),
    .sdram_wr_b_addr (0             ),
    .sdram_wr_e_addr (DATA_NUM      ),
    .wr_burst_len    (DATA_NUM      ),
    .wr_rst          (~rst_n),
    //读fifo信号
    .rd_fifo_rd_clk  (clk_50m       ),
    .rd_fifo_rd_req  (rfifo_wr_en   ),
    .sdram_rd_b_addr (0             ),
    .sdram_rd_e_addr (DATA_NUM      ),
    .rd_burst_len    (DATA_NUM      ),
    .rd_rst          (~rst_n),
    .rd_fifo_rd_data (rfifo_wr_data ),
    .rd_fifo_num     (rd_fifo_num   ),
    .read_valid      (read_valid    ),
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

fifo_read   fifo_read_inst
(
    .sys_clk         (clk_50m       ),
    .sys_rst_n       (rst_n         ),
    .rd_fifo_num     (rd_fifo_num   ),
    .rd_fifo_rd_data (rfifo_wr_data ),
    .burst_num       (DATA_NUM      ),

    .rd_en           (rfifo_wr_en   ),
    .tx_data         (rfifo_rd_data ),
    .tx_flag         (rfifo_rd_en   )
);

uart_tx
#(
    .UART_BPS    (UART_BPS      ),
    .CLK_FREQ    (CLK_FREQ      )
)
uart_tx_inst
(
    .sys_clk     (sys_clk       ),
    .sys_rst_n   (sys_rst_n     ),
    .pi_data     (rfifo_rd_data ),
    .pi_flag     (rfifo_rd_en   ),

    .tx          (tx            )
);

endmodule
