interface wishbone_if(input logic clk,input logic rst_n);
logic cyc;
logic stb;
logic we;
logic [3:0]adr;
logic [31:0] dat_i;
logic [31:0] dat_o;
logic ack;
modport master(
    input dat_o,input ack,
    output cyc,stb,we,adr,dat_i,
    import read,write
);
modport slave(input cyc,stb,we,adr,dat_i,
output dat_o,ack);
task automatic read(input logic [3:0] addr,output logic [31:0]data);
cyc=1;
stb=1;
we=0;
adr=addr;
dat_i=0;
@(posedge clk);
while(!ack)@(posedge clk);
@(posedge clk);
data=dat_o;
cyc=0;
stb=0;
endtask
task automatic write(input logic [3:0] addr,input logic [31:0]data);
cyc=1;
stb=1;
we=1;
adr=addr;
dat_i=data;
@(posedge clk);
while(!ack) @(posedge clk);
cyc=0;
stb=0;
we=0;
dat_i=0;
@(posedge clk);
endtask
endinterface