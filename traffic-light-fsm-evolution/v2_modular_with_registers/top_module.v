module top_traffic_fsm(
    input clk,
    input rst,
    input write_en,
    input [3:0] addr, 
    input [31:0] write_data,  
    output [2:0] NS,
    output [2:0] EW
);
    reg [1:0] present;
    wire [1:0]next;
    wire [3:0] count;
  
    wire [3:0] green_time;
    wire [3:0] yellow_time;
    // State update
    always @(posedge clk) begin
        if(rst==0)
            present <= 2'b00; 
        else
            present <= next; 
    end
    // Timer
    timer t1 (.clk(clk), .rst(rst), .green_time(green_time),.yellow_time(yellow_time),.present(present), .count(count));
    //register module
    reg_block a1(.clk(clk),.rst(rst),.write_en(write_en),.addr(addr),.write_data(write_data),.green_time(green_time),.yellow_time(yellow_time));

    // FSM
    fsm f1 (.present(present),.green_time(green_time),.yellow_time(yellow_time), .count(count), .next(next));

    // Output
    output_module out1(.present(present), .NS(NS), .EW(EW));


endmodule