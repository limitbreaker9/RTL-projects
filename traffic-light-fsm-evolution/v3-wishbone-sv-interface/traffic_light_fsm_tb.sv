module traffic_light_fsm_tb;
logic clk,rst_n;
logic [2:0] NS;
logic [2:0] EW;
wishbone_if i(.clk(clk),.rst_n(rst_n));
top_traffic_fsm dut(
    .clk(clk),
    .rst(rst_n),
    .wb_cyc_i(i.cyc),
    .wb_stb_i(i.stb),
    .wb_we_i(i.we),
    .wb_adr_i(i.adr),
    .wb_dat_i(i.dat_i),
    .wb_dat_o(i.dat_o),
    .wb_ack_o(i.ack),
    .NS(NS),
    .EW(EW)
);
always #5 clk=~clk;
logic [31:0] data_read;
initial begin
clk=0;
i.cyc=0;
i.stb=0;
rst_n=0;
#20;
rst_n=1;
//set green 15
i.write(4'd1,32'd15);
//set yellow 5
i.write(4'd2,32'd5);
i.read (4'd1, data_read);    // read it back
$display("green_time = %0d", data_read);
end
initial begin
    $monitor("T=%0t | clk=%b | rst=%b | state=%b | count=%0d | NS=%b | EW=%b | enable=%b | green_time=%0d | yellow_time=%0d | cyc=%b | stb=%b | we=%b | adr=%0d | dat_i=%0d | dat_o=%0d | ack=%b | update_pending=%b",
        $time,
        clk, rst_n,
        dut.present, dut.t1.count,
        NS, EW,
        dut.wb.r1.enable,
        dut.wb.r1.green_time,
        dut.wb.r1.yellow_time,
        i.cyc, i.stb, i.we, i.adr,
        i.dat_i, i.dat_o, i.ack,
        dut.wb.r1.update_pending
    );
end
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, traffic_light_fsm_tb);
end
initial #2000 $finish;
endmodule