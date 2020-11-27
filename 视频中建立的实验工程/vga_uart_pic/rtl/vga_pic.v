module  vga_pic
(
    input   wire            sys_clk     ,
    input   wire            vga_clk     ,
    input   wire            sys_rst_n   ,
    input   wire    [7:0]   pi_data     ,
    input   wire            pi_flag     ,
    input   wire    [9:0]   pix_x       ,
    input   wire    [9:0]   pix_y       ,

    output  wire    [7:0]  pix_data
);

parameter   H_VALID = 10'd640,
            V_VALID = 10'D480;

parameter   H_PIC = 10'd100,
            V_PIC = 10'd100,
            PIC_SIZE = 14'd10_000;


/* parameter   RED     = 16'hF800,
            ORANGE  = 16'hFC00,
            YELLOW  = 16'hFFE0,
            GREEN   = 16'h07E0,
            CYAN    = 16'h07FF,
            BLUE    = 16'h001F,
            PURPPLE = 16'hF81F,
            BLACK   = 16'h0000,
            WHITE   = 16'hFFFF,
            GRAY    = 16'hD69A; */

parameter   RED     =   8'b111_000_00,
            GREEN   =   8'b000_111_00,
            BLUE    =   8'b000_000_11,
            WHITE   =   8'b111_111_11,
            BLACK   =   8'b000_000_00;


wire            rd_en       ;
wire    [07:0]  pic_data    ;

reg     [13:0]  wr_addr     ;
reg     [07:0]  data_pix    ;
reg             pic_valid   ;
reg     [13:0]  rd_addr     ;

assign  pix_data  =  (pic_valid == 1'b1) ? pic_data : data_pix;


assign  rd_en =  ((pix_x >= (((H_VALID - H_PIC) / 2)) - 1'b1))
                 && ((pix_x < (((H_VALID - H_PIC) / 2) + H_PIC) - 1'b1))
                 && ((pix_y >= (((V_VALID - V_PIC) / 2))))
                 && ((pix_y < (((V_VALID - V_PIC) / 2) + V_PIC)));

always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pic_valid   <=  1'b0;
    else
        pic_valid   <=  rd_en;

always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_addr    <=  14'd0;
    else    if(rd_addr == PIC_SIZE - 1'b1)
        rd_addr    <=  14'd0;
    else    if(rd_en == 1'b1)
        rd_addr    <=  rd_addr + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_addr <=  14'd0;
    else    if((wr_addr == PIC_SIZE - 1'b1) && (pi_flag == 1'b1))
        wr_addr <=  14'd0;
    else    if(pi_flag == 1'b1)
        wr_addr <=  wr_addr + 1'b1;


always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_pix    <=  BLACK;
    else    if(pix_x >= 0 && pix_x < ((H_VALID / 10) * 1))
        data_pix    <=  RED;
    else    if(pix_x >= ((H_VALID / 10) * 1) && pix_x < ((H_VALID / 10) * 2))
        data_pix    <=  GREEN;
    else    if(pix_x >= ((H_VALID / 10) * 2) && pix_x < ((H_VALID / 10) * 3))
        data_pix    <=  BLUE;
    else    if(pix_x >= ((H_VALID / 10) * 3) && pix_x < ((H_VALID / 10) * 4))
        data_pix    <=  WHITE;
    else    if(pix_x >= ((H_VALID / 10) * 4) && pix_x < ((H_VALID / 10) * 5))
        data_pix    <=  BLACK;
    else    if(pix_x >= ((H_VALID / 10) * 5) && pix_x < ((H_VALID / 10) * 6))
        data_pix    <=  RED;
    else    if(pix_x >= ((H_VALID / 10) * 6) && pix_x < ((H_VALID / 10) * 7))
        data_pix    <=  GREEN;
    else    if(pix_x >= ((H_VALID / 10) * 7) && pix_x < ((H_VALID / 10) * 8))
        data_pix    <=  BLUE;
    else    if(pix_x >= ((H_VALID / 10) * 8) && pix_x < ((H_VALID / 10) * 9))
        data_pix    <=  WHITE;
    else    if(pix_x >= ((H_VALID / 10) * 9) && pix_x < H_VALID)
        data_pix    <=  BLACK;
    else
        data_pix    <=  BLACK;


ram_pic ram_pic_inst
(
    .data       (pi_data    ),
    .inclock    (sys_clk    ),
    .outclock   (vga_clk    ),
    .rdaddress  (rd_addr    ),
    .wraddress  (wr_addr    ),
    .wren       (pi_flag    ),

    .q          (pic_data   )
);


endmodule

