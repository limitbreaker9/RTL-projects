interface wishbone_if(
input clk,
input rst_n);
logic cyc;
logic stb;
logic we;
logic [3:0]adr;
logic [7:0]dat_i;
logic [7:0]dat_o;
logic ack;
modport master(
input dat_o,
input ack,
output cyc,
output stb,
output we,
output adr,
output dat_i,
import read,
import write
);
modport slave(
output dat_o,
output ack,
input cyc,
input stb,
input we,
input adr,
input dat_i);
task automatic read(input logic[3:0]addr,output logic [7:0]data);
cyc=1;
stb=1;
we=0;
adr=addr;
dat_i=0;
@(posedge clk);
while(!ack) @(posedge clk);
  @(posedge clk);
data=dat_o;
cyc=0;
stb=0;
endtask
  task automatic write(input logic [3:0]addr,input logic [7:0]data);
cyc=1;
stb=1;
we=1;
adr=addr;
dat_i=data;
@(posedge clk);
while(!ack) @(posedge clk);
cyc=0;
stb=0;

endtask

endinterface
