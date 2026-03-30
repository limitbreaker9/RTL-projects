module reg_block(
    input clk,
    input rst,
    input write_en,
    input [3:0] addr,
    input [31:0] write_data,
    output reg [3:0] green_time,
    output reg [3:0] yellow_time
);
localparam GREEN_ADDR  = 4'h0;
localparam YELLOW_ADDR = 4'h4;
always @(posedge clk) begin
    if (rst == 0) begin
        // Reset to default traffic light timings
        green_time  <= 4'd10;
        yellow_time <= 4'd3;
    end
    else if (write_en) begin
        case (addr)
            GREEN_ADDR: green_time  <= write_data[3:0];
            YELLOW_ADDR: yellow_time <= write_data[3:0];
        endcase
    end
end

endmodule