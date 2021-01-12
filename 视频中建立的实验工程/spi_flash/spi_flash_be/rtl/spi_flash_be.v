module  spi_flash_be
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_in      ,
    input   wire            miso        ,

    output  wire            cs_n        ,
    output  wire            sck         ,
    output  wire            mosi
);

wire    key_flag;

key_filter
#(
    .CNT_MAX (20'd999_999)
)
key_filter_inst
(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .key_in     (key_in),

    .key_flag   (key_flag)
);

flash_be_ctrl   flash_be_ctrl_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .key_flag    (key_flag),

    .cs_n        (cs_n),
    .sck         (sck),
    .mosi        (mosi)
);



endmodule
