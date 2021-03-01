module  sdram_init
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,

    output  reg     [3:0]   init_cmd    ,
    output  reg     [1:0]   init_ba     ,
    output  reg     [12:0]  init_addr   ,
    output  wire            init_end
);

parameter   INIT_IDLE   =   3'b000,
            INIT_PRE    =   3'b001,
            INIT_TRP    =   3'b011,
            INIT_AR     =   3'b010,
            INIT_TRF    =   3'b110,
            INIT_MRS    =   3'b111,
            INIT_TMRD   =   3'b101,
            INIT_END    =   3'b100;

parameter   WAIT_MAX   =   15'd20_000;

parameter   TRP     =   3'd2,
            TRF     =   3'd7,
            TMRD    =   3'd3;

parameter   NOP         =   4'b0111,
            P_CHARGE    =   4'b0010,
            AUTO_REF    =   4'b0001,
            M_REG_SET   =   4'b0000;


wire            wait_end        ;
wire            trp_end         ;
wire            trfc_end        ;
wire            tmrd_end        ;

reg     [2:0]   init_state      ;
reg     [14:0]  cnt_200us       ;
reg     [2:0]   cnt_clk         ;
reg             cnt_clk_rst     ;
reg     [3:0]   cnt_aref        ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        init_state  <=  INIT_IDLE;
    else
    case(init_state)
        INIT_IDLE:
            if(wait_end == 1'b1)
                init_state  <=  INIT_PRE;
            else
                init_state  <=  init_state;
        INIT_PRE :
            init_state  <=  INIT_TRP;
        INIT_TRP :
            if(trp_end == 1'b1)
                init_state  <=  INIT_AR;
            else
                init_state  <=  init_state;
        INIT_AR  :
            init_state  <=  INIT_TRF;
        INIT_TRF :
            if(trfc_end == 1'b1)
                if(cnt_aref == 4'd8)
                    init_state  <=  INIT_MRS;
                else
                    init_state  <=  INIT_AR;
            else
                init_state  <=  init_state;
        INIT_MRS :
            init_state  <=  INIT_TMRD;
        INIT_TMRD:
            if(tmrd_end == 1'b1)
                init_state  <=  INIT_END;
            else
                init_state  <=  init_state;
        INIT_END :
            init_state  <=  INIT_END;
        default:init_state  <=  INIT_IDLE;
    endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_200us   <=  15'd0;
    else    if(cnt_200us == WAIT_MAX)
        cnt_200us   <=  WAIT_MAX;
    else
        cnt_200us   <=  cnt_200us + 1'b1;

assign  wait_end = (cnt_200us == (WAIT_MAX - 1'b1)) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <=  3'd0;
    else    if(cnt_clk_rst == 1'b1)
        cnt_clk <=  3'd0;
    else
        cnt_clk <=  cnt_clk + 1'b1;

always@(*)
    begin
        case(init_state)
            INIT_IDLE:  cnt_clk_rst <=  1'b1;
            INIT_TRP:   cnt_clk_rst <=  (trp_end == 1'b1) ? 1'b1 : 1'b0;
            INIT_TRF:   cnt_clk_rst <=  (trfc_end == 1'b1) ? 1'b1 : 1'b0;
            INIT_TMRD:  cnt_clk_rst <=  (tmrd_end == 1'b1) ? 1'b1 : 1'b0;
            INIT_END:  cnt_clk_rst <=  1'b1;
            default:cnt_clk_rst <=  1'b0;
        endcase
    end


assign  trp_end = ((init_state == INIT_TRP) && (cnt_clk == TRP)) ? 1'b1 : 1'b0;
assign  trfc_end = ((init_state == INIT_TRF) && (cnt_clk == TRF)) ? 1'b1 : 1'b0;
assign  tmrd_end = ((init_state == INIT_TMRD) && (cnt_clk == TMRD)) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_aref    <=  4'd0;
    else    if(init_state == INIT_IDLE)
        cnt_aref    <=  4'd0;
    else    if(init_state == INIT_AR)
        cnt_aref    <=  cnt_aref + 1'b1;
    else
        cnt_aref    <=  cnt_aref;


always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            init_cmd    <=  NOP;
            init_ba     <=  2'b11;
            init_addr   <=  13'h1fff;
        end
    else
    case(init_state)
        INIT_IDLE,INIT_TRP,INIT_TRF,INIT_TMRD,INIT_END:
            begin
                init_cmd    <=  NOP;
                init_ba     <=  2'b11;
                init_addr   <=  13'h1fff;
            end
        INIT_PRE:
            begin
                init_cmd    <=  P_CHARGE;
                init_ba     <=  2'b11;
                init_addr   <=  13'h1fff;
            end
        INIT_AR:
            begin
                init_cmd    <=  AUTO_REF;
                init_ba     <=  2'b11;
                init_addr   <=  13'h1fff;
            end
        INIT_MRS:
            begin
                init_cmd    <=  M_REG_SET;
                init_ba     <=  2'b00;
                init_addr   <=  {3'b0,1'b0,2'b00,3'b011,1'b0,3'b111};
            end
        default:
            begin
                init_cmd    <=  NOP;
                init_ba     <=  2'b11;
                init_addr   <=  13'h1fff;
            end
    endcase

assign  init_end  = (init_state == INIT_END) ? 1'b1 : 1'b0;

endmodule
