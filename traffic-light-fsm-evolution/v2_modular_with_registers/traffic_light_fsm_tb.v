module top_traffic_fsm_tb;
reg clk;
reg rst;
wire [2:0]NS;
wire [2:0]EW;
reg write_en;
reg [3:0]addr;
reg [31:0]write_data;
wire [3:0]green_time;
wire [3:0]yellow_time;
top_traffic_fsm a1(.clk(clk),.rst(rst),.write_en(write_en),.addr(addr),.write_data(write_data),.NS(NS),.EW(EW));
//initialisation
initial begin
    clk=0;
    rst=0;
    write_en=0;
    write_data=0;
    addr=0;
end
//clock

always #5 clk = ~clk;
//start
initial begin
    #12 rst=1;
end
//changing the green time and yellow time after completing a cycle of states
initial begin
 #405 addr=4'h0;
        write_data=15;
        write_en=1;
        
        #5 write_en=0;
    #5 addr=4'h4;
           write_data=10;
           write_en=1;
     #5 write_en=0;

end
//display
initial begin
$monitor("T=%0t | we=%b | wdata=%d | addr=%h | G_Time=%d | Y_Time=%d | state=%b | count=%d | NS=%b | EW=%b",
         $time, write_en, write_data, addr, a1.green_time, a1.yellow_time, a1.present, a1.count, NS, EW);
end

//wave
initial begin
      $dumpfile("traffic.vcd");   // file name
    $dumpvars(0, top_traffic_fsm_tb);
end
initial begin
    #800 $finish;
end
endmodule
