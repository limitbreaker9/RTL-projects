module wb_reg_wrapper(input wb_clk_i,
input wb_rst_i,
input [3:0]wb_adr_i,
input [31:0] wb_dat_i,
input wb_we_i,
input wb_stb_i,
input wb_cyc_i,
input [1:0]state,
output reg[31:0]wb_dat_o,
output reg wb_ack_o,
output [3:0] green_time,
output [3:0] yellow_time,
output enable);
wire write_en;
wire read_en;
wire [31:0] read_data;
assign write_en= (wb_stb_i&&wb_cyc_i&&wb_we_i);
assign read_en = (wb_stb_i&&wb_cyc_i&&!wb_we_i);
//here for now as the registers only are involved we are not adding delay in the wb_ack_o assuming the operation will be completed within one clk cycle
always@(posedge wb_clk_i) begin
  if(wb_rst_i==0)begin
    wb_ack_o<=0;
  end  
  else wb_ack_o<=wb_stb_i&&wb_cyc_i;
end 
//reading data
always@(posedge wb_clk_i)begin
if(wb_rst_i==0) 
wb_dat_o<=0;
else if(read_en)
wb_dat_o<=read_data;

end
//register block
reg_block r1(.clk(wb_clk_i),.rst(wb_rst_i),.state(state),.write_en(write_en),.read_en(read_en),.addr(wb_adr_i),.write_data(wb_dat_i),.read_data(read_data),.green_time(green_time),.yellow_time(yellow_time),.enable(enable));

endmodule