module wb_ram #(
    parameter DEPTH=256,
    parameter HEX_FILE="firmware.hex"
)(
input clk,
input rst,

input wb_cyc_i,
input wb_stb_i,
input wb_we_i,
input [7:0] wb_adr_i,
input [31:0]wb_dat_i,
input [3:0]wb_sel_i,
output reg [31:0] wb_dat_o,
output reg wb_ack_o
);
reg [31:0]mem[0:DEPTH-1];
initial $readmemh(HEX_FILE,mem);
always@(posedge clk)begin
    wb_ack_o<=0;
    if(rst) wb_ack_o<=0;
    else if(wb_cyc_i&&wb_stb_i&&!wb_ack_o)begin
        if(wb_we_i)begin
        if(wb_sel_i[0]) mem[wb_adr_i][7:0]<=wb_dat_i[7:0];
        if(wb_sel_i[1]) mem[wb_adr_i][15:8]<=wb_dat_i[15:8];
        if(wb_sel_i[2]) mem[wb_adr_i][23:16]<=wb_dat_i[23:16];
        if(wb_sel_i[3]) mem[wb_adr_i][31:24]<=wb_dat_i[31:24];
            end
        else wb_dat_o<=mem[wb_adr_i];
        wb_ack_o<=1;
        end
        end
endmodule