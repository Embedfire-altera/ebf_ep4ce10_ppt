`timescale 1ns/1ns
module  tb_flash_be_ctrl();

reg     sys_clk  ;
reg     sys_rst_n;
reg     key_flag ;

wire    cs_n   ;
wire    sck    ;
wire    mosi   ;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n   <=  1'b0;
        key_flag    <=  1'b0;
        #30
        sys_rst_n   <=  1'b1;
        #1000
        key_flag    <=  1'b1;
        #20
        key_flag    <=  1'b0;
    end

always #10 sys_clk = ~sys_clk;

defparam memory.mem_access.initfile = "initmemory.txt";

flash_be_ctrl   flash_be_ctrl_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .key_flag    (key_flag),

    .cs_n        (cs_n),
    .sck         (sck),
    .mosi        (mosi)
);

m25p16 memory 
(
    .c          (sck    ),
    .data_in    (mosi   ),
    .s          (cs_n   ),
    .w          (1'b1   ),
    .hold       (1'b1   ),
    .data_out   (       )
); 

endmodule
