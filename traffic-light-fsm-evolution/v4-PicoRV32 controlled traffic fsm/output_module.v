module output_module(input [1:0]present,output reg [2:0]NS,output reg [2:0]EW);
localparam green=3'b001;
localparam yellow=3'b010;
localparam red=3'b100;
always@(*)begin
    case(present)
       2'b00:begin NS=green;EW=red;end
       2'b01:begin NS=yellow;EW=red; end
       2'b10:begin NS=red;EW=green; end
       2'b11:begin NS=red;EW=yellow; end
    default:begin NS=yellow;EW=yellow; end
    endcase
end

endmodule