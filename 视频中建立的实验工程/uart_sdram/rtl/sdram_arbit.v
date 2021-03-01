module  sdram_arbit
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,

    input   wire    [3:0]   init_cmd    ,
    input   wire    [1:0]   init_ba     ,
    input   wire    [12:0]  init_addr   ,
    input   wire            init_end    ,

    input   wire            aref_req    ,
    input   wire    [3:0]   aref_cmd    ,
    input   wire    [1:0]   aref_ba     ,
    input   wire    [12:0]  aref_addr   ,
    input   wire            aref_end    ,

    input   wire            wr_req      ,
    input   wire    [3:0]   wr_cmd      ,
    input   wire    [1:0]   wr_ba       ,
    input   wire    [12:0]  wr_addr     ,
    input   wire            wr_end      ,
    input   wire            wr_sdram_en ,
    input   wire    [15:0]  wr_data     ,

    input   wire            rd_req      ,
    input   wire    [3:0]   rd_cmd      ,
    input   wire    [1:0]   rd_ba       ,
    input   wire    [12:0]  rd_addr     ,
    input   wire            rd_end      ,
    //input   wire            rd_sdram_en ,

    output  reg             aref_en     ,
    output  reg             wr_en       ,
    output  reg             rd_en       ,

    output  wire            sdram_cke   ,
    output  wire            sdram_cs_n  ,
    output  wire            sdram_cas_n ,
    output  wire            sdram_ras_n ,
    output  wire            sdram_we_n  ,
    output  reg     [1:0]   sdram_ba    ,
    output  reg     [12:0]  sdram_addr  ,
    inout   wire    [15:0]  sdram_dq
);

parameter   IDLE    =   5'b0_0001,
            ARBIT   =   5'b0_0010,
            AREF    =   5'b0_0100,
            WRITE   =   5'b0_1000,
            READ    =   5'b1_0000;

parameter   NOP     =   4'b0111;

reg     [4:0]   state       ;
reg     [3:0]   sdram_cmd   ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else
        case(state)
            IDLE :
                if(init_end == 1'b1)
                    state   <=  ARBIT;
                else
                    state   <=  IDLE;
            ARBIT:
                if(aref_req == 1'b1)
                    state   <=  AREF;
                else    if(wr_req == 1'b1)
                    state   <=  WRITE;
                else    if(rd_req == 1'b1)
                    state   <=  READ;
                else
                    state   <=  ARBIT;
            AREF :
                if(aref_end == 1'b1)
                    state   <=  ARBIT;
                else
                    state   <=  AREF;
            WRITE:
                if(wr_end == 1'b1)
                    state   <=  ARBIT;
                else
                    state   <=  WRITE;
            READ :
                if(rd_end == 1'b1)
                    state   <=  ARBIT;
                else
                    state   <=  READ;
            default:state   <=  IDLE;
        endcase

always@(*)
    case(state)
        IDLE :
            begin
                sdram_cmd   <=  init_cmd;
                sdram_ba    <=  init_ba;
                sdram_addr  <=  init_addr;
            end
        AREF :
            begin
                sdram_cmd   <=  aref_cmd;
                sdram_ba    <=  aref_ba;
                sdram_addr  <=  aref_addr;
            end
        WRITE:
            begin
                sdram_cmd   <=  wr_cmd;
                sdram_ba    <=  wr_ba;
                sdram_addr  <=  wr_addr;
            end
        READ :
            begin
                sdram_cmd   <=  rd_cmd;
                sdram_ba    <=  rd_ba;
                sdram_addr  <=  rd_addr;
            end
        default:
            begin
                sdram_cmd   <=  NOP;
                sdram_ba    <=  2'b11;
                sdram_addr  <=  13'h1fff;
            end
    endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        aref_en <=  1'b0;
    else    if((state == ARBIT) && (aref_req == 1'b1))
        aref_en <=  1'b1;
    else    if(aref_end == 1'b1)
        aref_en <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en <=  1'b0;
    else    if((state == ARBIT) && (aref_req == 1'b0) && (wr_req == 1'b1))
        wr_en <=  1'b1;
    else    if(wr_end == 1'b1)
        wr_en <=  1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en <=  1'b0;
    else    if((state == ARBIT) && (aref_req == 1'b0) && (rd_req == 1'b1))
        rd_en <=  1'b1;
    else    if(rd_end == 1'b1)
        rd_en <=  1'b0;

assign  {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = sdram_cmd;

assign  sdram_cke = 1'b1;

assign  sdram_dq = (wr_sdram_en == 1'b1) ? wr_data : 16'bz;

endmodule
