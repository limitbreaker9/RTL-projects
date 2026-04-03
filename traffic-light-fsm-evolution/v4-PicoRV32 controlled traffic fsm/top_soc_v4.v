module top_soc_v4 (input clk,input rst_n,output [2:0] NS,output [2:0] EW,output cpu_trap);
wire wb_rst=~rst_n;//as picorv32_wb uses active high wb_rst_i
//pico32_wb o/p's
wire [31:0] wbm_adr;
wire [31:0] wbm_dat_m2s; //master to slave data
wire [31:0] wbm_dat_s2m; //slave to master data
wire wbm_we;
wire [3:0] wbm_sel;
wire wbm_stb;
wire wbm_ack;
wire wbm_cyc;
//address decode
wire sel_ram=(wbm_adr[31:28]==4'h0);
wire sel_p=(wbm_adr[31:28]==4'h1);
//ram signals
wire [31:0]ram_dat_o;
wire ram_ack;
//peripheral signals
wire [31:0] p_dat_o;
wire p_ack;

assign wbm_dat_s2m= sel_ram ? ram_dat_o :sel_p?p_dat_o:32'h0;
assign wbm_ack= sel_ram ? ram_ack :sel_p?p_ack:0;

picorv32_wb #(.ENABLE_COUNTERS(0),.ENABLE_COUNTERS64(0),
.ENABLE_REGS_16_31(1),
.CATCH_MISALIGN(0),
.CATCH_ILLINSN(0),
.PROGADDR_RESET(32'h00000000),
.STACKADDR(32'h000003FC)  // top of 1KB RAM
) cpu (
.wb_clk_i(clk),
.wb_rst_i(wb_rst),
.trap(cpu_trap),
.wbm_adr_o(wbm_adr),
.wbm_dat_o(wbm_dat_m2s),
.wbm_dat_i(wbm_dat_s2m),
.wbm_we_o(wbm_we),
.wbm_sel_o(wbm_sel),
.wbm_stb_o(wbm_stb),
.wbm_ack_i(wbm_ack),
.wbm_cyc_o(wbm_cyc),
// Unused ports making them 0
.pcpi_wr(1'b0),
.pcpi_rd(32'h0),
.pcpi_wait(1'b0),
.pcpi_ready(1'b0),
.irq(32'h0)
);

//instruction and data ram
wb_ram #(
    .DEPTH(256),          // 256*32bit=1KB
    .HEX_FILE("firmware.hex")
) ram (
    .clk(clk),
    .rst(wb_rst),
    .wb_cyc_i(wbm_cyc&&sel_ram),
    .wb_stb_i(wbm_stb&&sel_ram),
    .wb_we_i (wbm_we),
    .wb_adr_i(wbm_adr[9:2]),// word address
    .wb_dat_i(wbm_dat_m2s),
    .wb_sel_i(wbm_sel),
    .wb_dat_o(ram_dat_o),
    .wb_ack_o(ram_ack)
);
top_traffic_fsm dut (
    .clk(clk),
    .rst(rst_n),
    .wb_cyc_i(wbm_cyc   && sel_p),
    .wb_stb_i(wbm_stb   && sel_p),
    .wb_we_i(wbm_we),
    .wb_adr_i(wbm_adr[3:0]),// lower 4 bits select register
    .wb_dat_i(wbm_dat_m2s),
    .wb_dat_o(p_dat_o),
    .wb_ack_o(p_ack),
    .NS(NS),
    .EW(EW)
);


endmodule