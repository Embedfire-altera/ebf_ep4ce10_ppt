module  dds_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire    [3:0]   wave_sel    ,

    output  wire    [7:0]   dac_data
);

parameter F_WORD = 32'd42949;
parameter P_WORD = 12'd1024;

reg     [31:0]  fre_add ;
reg     [11:0]  rom_addr_reg    ;
reg     [13:0]  rom_addr;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fre_add <=  32'd0;
    else
        fre_add <=  fre_add + F_WORD;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rom_addr_reg    <=  12'd0;
    else
        rom_addr_reg    <=  fre_add[31:20] + P_WORD;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rom_addr    <=  14'd0;
    else
        case(wave_sel)
            4'b0001:
                rom_addr    <=  rom_addr_reg;
            4'b0010:
                rom_addr    <=  rom_addr_reg + 14'd4096;
            4'b0100:
                rom_addr    <=  rom_addr_reg + 14'd8192;
            4'b1000:
                rom_addr    <=  rom_addr_reg + 14'd12288;
            default:rom_addr    <=  rom_addr_reg;
        endcase

rom_wave    rom_wave_inst
(
    .address (rom_addr),
    .clock (sys_clk),
    .q (dac_data)
);

endmodule
