`timescale 1ns/1ns
module tb_top_soc_v4;
logic clk;
logic rst_n;
logic [2:0]NS;
logic [2:0]EW;
logic cpu_trap;
top_soc_v4 dut(.clk(clk),.rst_n(rst_n),.NS(NS),.EW(EW),.cpu_trap(cpu_trap));
initial clk =0;
always #5clk=~clk;
initial begin
    rst_n=0;
    #40;
    rst_n=1;
end
always@(posedge cpu_trap)begin
    $display("ERROR t=%t:CPU trapped ",$time);
end
always @(posedge clk) begin
    $strobe("T=%0t | rst=%b | wbm_adr=%h | we=%b | stb=%b | cyc=%b | dat_m2s=%0d | dat_s2m=%0d | ack=%b | enable=%b | green=%0d | yellow=%0d | pending=%b | state=%b | count=%0d | NS=%b | EW=%b",
        $time,
        rst_n,
        dut.wbm_adr,
        dut.wbm_we,
        dut.wbm_stb,
        dut.wbm_cyc,
        dut.wbm_dat_m2s,
        dut.wbm_dat_s2m,
        dut.wbm_ack,
        dut.dut.wb.r1.enable,
        dut.dut.wb.r1.green_time,
        dut.dut.wb.r1.yellow_time,
        dut.dut.wb.r1.update_pending,
        dut.dut.present,
        dut.dut.t1.count,
        NS,
        EW
    );
end
initial begin
    #2000;
    $display("CHECK at T=2000ns");

    if (dut.dut.wb.r1.green_time_shadow === 4'd15)
        $display("PASS: green_time_shadow = 15 ");
    else
        $display("FAIL: green_time_shadow = %0d (expected 15)",
                 dut.dut.wb.r1.green_time_shadow);

    if (dut.dut.wb.r1.yellow_time_shadow === 4'd5)
        $display("PASS: yellow_time_shadow = 5 ");
    else
        $display("FAIL: yellow_time_shadow = %0d (expected 5)",
                 dut.dut.wb.r1.yellow_time_shadow);

    if (dut.dut.wb.r1.enable === 1'b1)
        $display("PASS: enable = 1 ");
    else
        $display("FAIL: enable = %b (expected 1)",
                 dut.dut.wb.r1.enable);
end
//monitoring FSM states when changing
logic [1:0] prev_state;
always@(posedge clk)begin
    prev_state <= dut.dut.present;
    if (dut.dut.present !== prev_state)
        $display("FSM T=%0t: state %b to %b | NS=%b EW=%b | green=%0d yellow=%0d",
                 $time, prev_state, dut.dut.present,
                 NS, EW,
                 dut.dut.wb.r1.green_time,
                 dut.dut.wb.r1.yellow_time);
end
initial begin
    $dumpfile("traffic.vcd");
    $dumpvars(0, tb_top_soc_v4);
end
initial begin
    #20000 $finish;
end
endmodule