module fsm(input [1:0]present,input [3:0]green_time,input [3:0]yellow_time,input [3:0]count,output reg [1:0]next);

//next
always@(*)begin
    case(present)

    2'b00:next=(count==(green_time-1))?2'b01:2'b00;
    2'b01:next=(count==(yellow_time-1))?2'b10:2'b01;
    2'b10:next=(count==(green_time-1))?2'b11:2'b10;
    2'b11:next=(count==(yellow_time-1))?2'b00:2'b11; 
    default:next=2'b00;

    endcase
end
endmodule