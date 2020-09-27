`timescale  1ns/1ns
module  tb_uart_tx();

reg             sys_clk     ;
reg             sys_rst_n   ;
reg     [7:0]   pi_data     ;
reg             pi_flag     ;

wire            tx          ;

initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
        #20
        sys_rst_n   <=  1'b1;
    end

always #10 sys_clk = ~sys_clk;

initial
    begin
        pi_data <=  8'd0;
        pi_flag <=  1'b0;
        #200
        //数据0
        pi_data <=  8'd0;
        pi_flag <=  1'b1;
        #20
        pi_flag <=  1'b0;
        #(5208*10*20)
        //数据1
        pi_data <=  8'd1;
        pi_flag <=  1'b1;
        #20
        pi_flag <=  1'b0;
        #(5208*10*20)
        //数据2
        pi_data <=  8'd2;
        pi_flag <=  1'b1;
        #20
        pi_flag <=  1'b0;
        #(5208*10*20)
        //数据3
        pi_data <=  8'd3;
        pi_flag <=  1'b1;
        #20
        pi_flag <=  1'b0;
        #(5208*10*20)
        //数据4
        pi_data <=  8'd4;
        pi_flag <=  1'b1;
        #20
        pi_flag <=  1'b0;
        #(5208*10*20)
        //数据5
        pi_data <=  8'd5;
        pi_flag <=  1'b1;
        #20
        pi_flag <=  1'b0;
        #(5208*10*20)
        //数据6
        pi_data <=  8'd6;
        pi_flag <=  1'b1;
        #20
        pi_flag <=  1'b0;
        #(5208*10*20)
        //数据7
        pi_data <=  8'd7;
        pi_flag <=  1'b1;
        #20
        pi_flag <=  1'b0;
    end

uart_tx
#(
    .UART_BPS    (9600      ),
    .CLK_FREQ    (50_000_000)
)
uart_tx_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .pi_data     (pi_data),
    .pi_flag     (pi_flag),

    .tx          (tx)
);



endmodule
