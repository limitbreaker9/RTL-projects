module reg_block(
    input clk,
    input rst,
    input [1:0] state,
    input write_en,
    input read_en,
    input [3:0] addr,
    input [31:0] write_data,
    output reg [31:0] read_data,
    output reg [3:0] green_time,
    output reg [3:0] yellow_time,
    output reg enable
    
);
reg [3:0]green_time_shadow;
reg [3:0]yellow_time_shadow;
reg [1:0]pstate;
reg update_pending;
localparam CONTROL_ADDR=4'd0;
localparam GREEN_ADDR=4'd1;
localparam YELLOW_ADDR=4'd2;
localparam STATUS_ADDR=4'd3;
//write
always @(posedge clk) begin
    if (rst == 0) begin
        // Reset to default traffic light timings
        enable <=1'b1;
        green_time  <= 4'd10;
        yellow_time <= 4'd3;
        green_time_shadow  <= 4'd10;
        yellow_time_shadow <= 4'd3;
        
    end
    else if (write_en) begin
        case (addr)
            CONTROL_ADDR: enable <=write_data[0];
            GREEN_ADDR:begin green_time_shadow  <= write_data[3:0];
            update_pending<=1;
            end
            YELLOW_ADDR: begin yellow_time_shadow <= write_data[3:0];
            update_pending<=1;
            end
        endcase
    end
end

//writing to the main registers after full cycle 
always@(posedge clk) begin
    if(rst==0) pstate<=0;
    else
   pstate<=state; 
end
always@(posedge clk) begin
    if(state==2'b00&&pstate==2'b11)begin    
        green_time  <= green_time_shadow;
        yellow_time <= yellow_time_shadow;
        update_pending<=0;
    end
end
//updating pending reg
always @(posedge clk) begin
    if (!rst) begin
        update_pending <= 0;
    end
    else begin
        // WRITE sets it
        if (write_en && (addr == GREEN_ADDR || addr == YELLOW_ADDR))
            update_pending <= 1;

        // FSM cycle completion clears it
        else if (state == 2'b00 && pstate == 2'b11)
            update_pending <= 0;
    end
end
//read
always@(posedge clk)begin
    if(read_en) begin
        case(addr)
        CONTROL_ADDR: read_data<={31'b0,enable};
        GREEN_ADDR: read_data<={28'b0, green_time_shadow};
        YELLOW_ADDR: read_data<={28'b0, yellow_time_shadow};
        STATUS_ADDR: read_data<={29'b0,update_pending,state};
        default: read_data<={32'b0};
        endcase
    end
    else
        read_data <= 0;
end

endmodule