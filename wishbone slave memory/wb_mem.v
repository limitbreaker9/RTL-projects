//wb_mem.v
//simple wishbone b4 slave memory
//16x8 bit memory
//address 0 to 15
//supports single read/write cycles
//no wait states (acknowledge in same cycles as we are going to use the resgister as our memory not any other modules like sram)

module wb_mem (
    input clk,
    input rst_n,
    //wishbone signals
    input wb_cyc,
    input wb_stb,
    input wb_we,
    input [3:0]wb_adr,
    input [7:0]wb_dat_i,
    output reg [7:0]wb_dat_o,
    output reg wb_ack
);
reg [7:0]mem[16];
always@(posedge clk)begin
    if(!rst_n)begin
        wb_ack<=0;
        wb_dat_o<=0;
    end
    else begin
        wb_ack<=0;
        if(wb_cyc&&wb_stb)begin
            //write
            if(wb_we)begin
                mem[wb_adr]<=wb_dat_i;

            end
            //read
            else begin
            wb_dat_o<=mem[wb_adr];
            end
            // ack is asserted combinatorially after write completes in same cycle
            wb_ack <= 1;

        end
    end
end
endmodule
