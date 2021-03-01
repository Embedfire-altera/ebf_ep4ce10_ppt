module  sdram_read
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            init_end    ,
    input   wire    [23:0]  rd_addr     ,
    input   wire    [15:0]  rd_data     ,
    input   wire    [9:0]   rd_burst_len,
    input   wire            rd_en       ,

    output  reg     [3:0]   rd_cmd      ,
    output  reg     [1:0]   rd_ba       ,
    output  reg     [12:0]  rd_sdram_addr,
    output  wire            rd_end      ,
    output  wire    [15:0]  rd_sdram_data,
    output  wire            rd_ack
);

parameter   RD_IDLE     =   4'b0000,
            RD_ACTIVE   =   4'b0001,
            RD_TRCD     =   4'b0011,
            READ        =   4'b0010,
            RD_CL       =   4'b0110,
            RD_DATA     =   4'b0111,
            RD_PCH      =   4'b0101,
            RD_TRP      =   4'b0100,
            RD_END      =   4'b1100;

parameter   TRCD     =  'd2,
            TRP      =  'd2,
            TCL      =  'd3;

parameter   NOP         =   4'b0111,
            ACTIVE      =   4'b0011,
            RD_CMD      =   4'b0101,
            B_STOP      =   4'b0110,
            P_CHARGE    =   4'b0010;


wire            trcd_end    ;
wire            tcl_end     ;
wire            trd_end     ;
wire            trp_end     ;
wire            rd_b_end    ;

reg     [15:0]  rd_data_reg ;
reg     [3:0]   rd_state    ;
reg     [9:0]   cnt_clk     ;
reg             cnt_clk_rst ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_data_reg <=  16'd0;
    else
        rd_data_reg <=  rd_data;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_state    <=  RD_IDLE;
    else
        case(rd_state)
            RD_IDLE  :
                if((init_end == 1'b1) && (rd_en == 1'b1))
                    rd_state    <=  RD_ACTIVE;
                else
                    rd_state    <=  rd_state;
            RD_ACTIVE:
                rd_state    <=  RD_TRCD;
            RD_TRCD  :
                if(trcd_end == 1'b1)
                    rd_state    <=  READ;
                else
                    rd_state    <=  rd_state;
            READ    :
                rd_state    <=  RD_CL;
            RD_CL:
                rd_state <= (tcl_end == 1'b1) ? RD_DATA : RD_CL;
            RD_DATA  :
                rd_state <= (trd_end == 1'b1) ? RD_PCH : RD_DATA;
            RD_PCH   :
                rd_state    <=  RD_TRP;
            RD_TRP   :
                rd_state <= (trp_end == 1'b1) ? RD_END : RD_TRP;
            RD_END   :
                rd_state    <=  RD_IDLE;
            default:
                rd_state    <=  RD_IDLE;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <=  10'd0;
    else    if(cnt_clk_rst == 1'b1)
        cnt_clk <=  10'd0;
    else
        cnt_clk <=  cnt_clk + 1'b1;

always@(*)
    begin
        case(rd_state)
            RD_IDLE :   cnt_clk_rst <=  1'b1;
            RD_TRCD :   cnt_clk_rst <=  (trcd_end == 1'b1) ? 1'b1 : 1'b0;
            READ    :   cnt_clk_rst <=  1'b1;
            RD_CL   :   cnt_clk_rst <=  (tcl_end == 1'b1) ? 1'b1 : 1'b0;
            RD_DATA :   cnt_clk_rst <=  (trd_end == 1'b1) ? 1'b1 : 1'b0;
            RD_PCH  :   cnt_clk_rst <=  (trp_end == 1'b1) ? 1'b1 : 1'b0;
            RD_END  :   cnt_clk_rst <=  1'b1;
            default:cnt_clk_rst <=  1'b0;
        endcase
    end

assign  trcd_end = ((rd_state == RD_TRCD) && (cnt_clk == TRCD)) ? 1'b1 : 1'b0;
assign  tcl_end  = ((rd_state == RD_CL) && (cnt_clk == TCL - 1'b1)) ? 1'b1 : 1'b0;
assign  trd_end  = ((rd_state == RD_DATA) && (cnt_clk == (rd_burst_len - 1'b1 + TCL))) ? 1'b1 : 1'b0;
assign  trp_end  = ((rd_state == RD_TRP ) && (cnt_clk == TRP )) ? 1'b1 : 1'b0;
assign  rd_b_end = ((rd_state == RD_DATA ) && (cnt_clk == (rd_burst_len - 1'b1 - TCL) )) ? 1'b1 : 1'b0;

assign  rd_ack   = ((rd_state == RD_DATA ) && (cnt_clk >= 10'd1) && (cnt_clk <= rd_burst_len)) ? 1'b1 : 1'b0;

assign  rd_end   = (rd_state == RD_END ) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            rd_cmd          <=  NOP;
            rd_ba           <=  2'b11;
            rd_sdram_addr   <=  13'h1fff;
        end
    else
        case(rd_state)
            RD_IDLE,RD_TRCD,RD_TRP:
                begin
                    rd_cmd          <=  NOP;
                    rd_ba           <=  2'b11;
                    rd_sdram_addr   <=  13'h1fff;
                end
            RD_ACTIVE:
                begin
                    rd_cmd          <=  ACTIVE;
                    rd_ba           <=  rd_addr[23:22];
                    rd_sdram_addr   <=  rd_addr[21:9];
                end
            READ:
                begin
                    rd_cmd          <=  RD_CMD;
                    rd_ba           <=  rd_addr[23:22];
                    rd_sdram_addr   <=  {4'b0000,rd_addr[8:0]};
                end
            RD_DATA:
                if(rd_b_end == 1'b1)
                    rd_cmd          <=  B_STOP;
                else
                    begin
                        rd_cmd          <=  NOP;
                        rd_ba           <=  2'b11;
                        rd_sdram_addr   <=  13'h1fff;
                    end
            RD_PCH:
                begin
                    rd_cmd          <=  P_CHARGE;
                    rd_ba           <=  rd_addr[23:22];
                    rd_sdram_addr   <=  13'h0400;
                end
            RD_END:
                begin
                    rd_cmd          <=  NOP;
                    rd_ba           <=  2'b11;
                    rd_sdram_addr   <=  13'h1fff;
                end
            default:
                begin
                    rd_cmd          <=  NOP;
                    rd_ba           <=  2'b11;
                    rd_sdram_addr   <=  13'h1fff;
                end
        endcase

assign  rd_sdram_data  = (rd_ack == 1'b1) ? rd_data_reg : 16'd0;

endmodule
