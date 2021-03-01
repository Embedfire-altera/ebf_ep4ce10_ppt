`timescale  1ns/1ns
module  tb_uart_sdram();

wire            tx              ;
wire            sdram_clk       ;
wire            sdram_cke       ;
wire            sdram_cs_n      ;
wire            sdram_ras_n     ;
wire            sdram_cas_n     ;
wire            sdram_we_n      ;
wire    [1:0]   sdram_ba        ;
wire    [12:0]  sdram_addr      ;
wire    [1:0]   sdram_dqm       ;
wire    [15:0]  sdram_dq        ;

reg     sys_clk  ;
reg     sys_rst_n;
reg     rx       ;
reg     [7:0]   data_mem[9:0];

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n   <=  1'b0;
        #30
        sys_rst_n   <=  1'b1;

    end

always #10 sys_clk = ~sys_clk;

initial
    $readmemh("C:/Users/admin/Desktop/FPGA/uart_sdram/sim/data.txt",data_mem);
    
defparam    uart_sdram_inst.CLK_FREQ = 50_000_0;
defparam    uart_sdram_inst.fifo_read_inst.BAUD_CNT_MAX  = 52;
defparam    uart_sdram_inst.fifo_read_inst.BAUD_CNT_HALF = 26;

defparam    sdram_model_plus_inst.addr_bits = 13;
defparam    sdram_model_plus_inst.data_bits = 16;
defparam    sdram_model_plus_inst.col_bits = 9;
defparam    sdram_model_plus_inst.mem_sizes = 2*1024*1024;

initial
    begin
        rx  <=  1'b1;
        #200
        rx_byte();
    end

task    rx_byte();
    integer j;
        for(j=0;j<10;j=j+1)
            rx_bit(data_mem[j]);
endtask

task    rx_bit(input [7:0] data);
    integer i;
for(i = 0; i < 10; i = i + 1)
    begin
    case(i)
        0:rx    <=  1'b0;
        1:rx    <=  data[0];
        2:rx    <=  data[1];
        3:rx    <=  data[2];
        4:rx    <=  data[3];
        5:rx    <=  data[4];
        6:rx    <=  data[5];
        7:rx    <=  data[6];
        8:rx    <=  data[7];
        9:rx    <=  1'b1;
    endcase
    #(52*20);
    end
endtask

uart_sdram  uart_sdram_inst
(
    .sys_clk         (sys_clk),
    .sys_rst_n       (sys_rst_n),
    .rx              (rx),

    .tx              (tx         ),
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
