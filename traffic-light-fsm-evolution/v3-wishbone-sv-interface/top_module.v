module top_traffic_fsm(
    input clk,
    input rst,
    input wb_we_i,
    input wb_stb_i,
    input wb_cyc_i,
    input [3:0] wb_adr_i, 
    input [31:0] wb_dat_i,
    output [2:0] NS,
    output [2:0] EW,
    output [31:0] wb_dat_o,
    output wb_ack_o
);
    reg [1:0] present;
    wire [1:0]next;
    wire [3:0] count;
    wire enable;
    wire [3:0] green_time;
    wire [3:0] yellow_time;
    wire [31:0]read_data;
    // State update
    always @(posedge clk) begin
        if(rst==0)
            present <= 2'b00;
            else if(enable)
            present <= next;
        else
             present <= present;
    end
    // Timer
    timer t1 (.clk(clk), .rst(rst), .green_time(green_time),.yellow_time(yellow_time),.present(present), .count(count));
    //wishbone wrapper
        wb_reg_wrapper wb (.wb_clk_i(clk),.wb_rst_i(rst),.wb_adr_i(wb_adr_i),.wb_dat_i(wb_dat_i),.wb_dat_o(wb_dat_o),.wb_we_i(wb_we_i),.wb_stb_i(wb_stb_i),.wb_cyc_i(wb_cyc_i),.wb_ack_o(wb_ack_o),.state(present),.green_time(green_time),.yellow_time(yellow_time),.enable(enable));
    // FSM
    fsm f1 (.present(present),.green_time(green_time),.yellow_time(yellow_time), .count(count), .next(next));

    // Output
    output_module out1(.present(present), .NS(NS), .EW(EW));


endmodule