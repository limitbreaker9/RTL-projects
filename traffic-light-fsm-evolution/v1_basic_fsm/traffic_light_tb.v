module traffic_fsm_tb;

reg clk;
reg rst;
wire [2:0] NS;
wire [2:0] EW;

// Instantiate DUT
traffic_fsm dut (.clk(clk),.rst(rst),.NS(NS),.EW(EW));

// Clock generation
always #5 clk = ~clk;

// Initial block
initial begin
clk = 0;
rst = 0;
#10 rst = 1;
// simulation limit
#500 $finish;

end

// Monitor outputs
initial begin
$monitor("Time=%0t | rst=%b | state=%b | count=%d | NS=%b | EW=%b",
         $time, rst, dut.present, dut.count, NS, EW);
end

// Dump waveform
initial begin
$dumpfile("traffic_fsm.vcd");
$dumpvars(0, traffic_fsm_tb);
end

endmodule
