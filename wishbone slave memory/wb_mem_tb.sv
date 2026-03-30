module wb_mem_tb;
logic clk;
logic rst_n;
logic [7:0] read_data;
wishbone_if i(.*);
wb_mem dut(.clk(clk),.rst_n(rst_n),.wb_cyc(i.cyc),.wb_stb(i.stb),.wb_we(i.we),.wb_adr(i.adr),.wb_dat_i(i.dat_i),.wb_dat_o(i.dat_o),.wb_ack(i.ack));
always #5 clk=~clk;
initial begin
      $dumpfile("dump.vcd");
    $dumpvars;  
    clk=0;
    rst_n=0;
    @(posedge clk);
  rst_n=1;
      @(posedge clk);

    i.master.write(10,100);
    i.master.write(3,201);
    i.master.read(10,read_data);
    if(read_data!=100) $error("read mismatch at addr 10 : got %d",read_data);
    else $display("PASS at addr 10 read data is %d ",read_data);
    i.master.read(3,read_data);
    if(read_data!=201) $error("read mismatch at addr 3 : got %d",read_data);
    else $display("PASS at addr 3 read data is %d ",read_data);
    $display("test bench completed");
    $finish;
end

endmodule