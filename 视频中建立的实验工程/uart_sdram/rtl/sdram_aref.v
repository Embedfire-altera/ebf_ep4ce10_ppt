module  sdram_aref
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            init_end    ,
    input   wire            aref_en     ,

    output  reg     [3:0]   aref_cmd    ,
    output  reg     [1:0]   aref_ba     ,
    output  reg     [12:0]  aref_addr   ,
    output  wire            aref_end    ,
    output  reg             aref_req
);

parameter   CNT_REF_MAX     =   10'd749;

parameter   AREF_IDLE   =   3'b000,
            AREF_PCH    =   3'b001,
            AREF_TRP    =   3'b011,
            AUTO_REF    =   3'b010,
            AREF_TRF    =   3'b110,
            AREF_END    =   3'b111;
parameter   TRP     =   3'd2,
            TRF     =   3'd7;
parameter   NOP         =   4'b0111,
            P_CHARGE    =   4'b0010,
            A_REF       =   4'b0001;

wire            aref_ack    ;
wire            trp_end     ;
wire            trf_end     ;

reg     [9:0]   cnt_ref     ;
reg     [2:0]   aref_state  ;
reg     [2:0]   cnt_clk     ;
reg             cnt_clk_rst ;
reg     [1:0]   cnt_aref    ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_ref <=  10'd0;
    else    if(cnt_ref >= CNT_REF_MAX)
        cnt_ref <=  10'd0;
    else    if(init_end == 1'b1)
        cnt_ref <=  cnt_ref + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        aref_req    <=  1'b0;
    else    if(cnt_ref == (CNT_REF_MAX - 1'b1))
        aref_req    <=  1'b1;
    else    if(aref_ack == 1'b1)
        aref_req    <=  1'b0;

assign  aref_ack  =  (aref_state == AREF_PCH) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        aref_state  <=  AREF_IDLE;
    else
        case(aref_state)
            AREF_IDLE:
                if((init_end == 1'b1) && (aref_en == 1'b1))
                    aref_state  <=  AREF_PCH;
                else
                    aref_state  <=  aref_state;
            AREF_PCH:
                aref_state  <=  AREF_TRP;
            AREF_TRP:
                if(trp_end == 1'b1)
                    aref_state  <=  AUTO_REF;
                else
                    aref_state  <=  aref_state;
            AUTO_REF:
                aref_state  <=  AREF_TRF;
            AREF_TRF:
                if(trf_end == 1'b1)
                    if(cnt_aref == 2'd2)
                        aref_state  <=  AREF_END;
                    else
                        aref_state  <=  AUTO_REF;
                else
                    aref_state  <=  aref_state;
            AREF_END:
                aref_state  <=  AREF_IDLE;
            default:aref_state  <=  AREF_IDLE;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <=  3'd0;
    else    if(cnt_clk_rst == 1'b1)
        cnt_clk <=  3'd0;
    else
        cnt_clk <=  cnt_clk + 1'b1;

always@(*)
    begin
        case(aref_state)
            AREF_IDLE:  cnt_clk_rst <=  1'b1;
            AREF_TRP:   cnt_clk_rst <=  (trp_end == 1'b1) ? 1'b1 : 1'b0;
            AREF_TRF:   cnt_clk_rst <=  (trf_end == 1'b1) ? 1'b1 : 1'b0;
            AREF_END:   cnt_clk_rst <=  1'b1;
            default:cnt_clk_rst <=  1'b0;
        endcase
    end

assign  trp_end = ((aref_state == AREF_TRP) && (cnt_clk == TRP)) ? 1'b1 : 1'b0;
assign  trf_end = ((aref_state == AREF_TRF) && (cnt_clk == TRF)) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_aref    <=  2'd0;
    else    if(aref_state == AREF_IDLE)
        cnt_aref    <=  2'd0;
    else    if(aref_state == AUTO_REF)
        cnt_aref    <=  cnt_aref + 1'b1;
    else
        cnt_aref    <=  cnt_aref;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            aref_cmd    <=  NOP;
            aref_ba     <=  2'b11;
            aref_addr   <=  13'h1fff;
        end
    else
    case(aref_state)
        AREF_IDLE,AREF_TRP,AREF_TRF:
            begin
                aref_cmd    <=  NOP;
                aref_ba     <=  2'b11;
                aref_addr   <=  13'h1fff;
            end
        AREF_PCH:
            begin
                aref_cmd    <=  P_CHARGE;
                aref_ba     <=  2'b11;
                aref_addr   <=  13'h1fff;
            end
        AUTO_REF:
            begin
                aref_cmd    <=  A_REF;
                aref_ba     <=  2'b11;
                aref_addr   <=  13'h1fff;
            end
        AREF_END:
            begin
                aref_cmd    <=  NOP;
                aref_ba     <=  2'b11;
                aref_addr   <=  13'h1fff;
            end
        default:
            begin
                aref_cmd    <=  NOP;
                aref_ba     <=  2'b11;
                aref_addr   <=  13'h1fff;
            end
    endcase

assign  aref_end  = (aref_state == AREF_END) ? 1'b1 : 1'b0;

endmodule
