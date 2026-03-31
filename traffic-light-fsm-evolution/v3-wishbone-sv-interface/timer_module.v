module timer(input clk,input [3:0]green_time,input [3:0]yellow_time,input rst,input [1:0]present,output reg [3:0]count);

always@(posedge clk)
begin
    if(rst==0)begin
        count<=0;
    end
    else begin
        case(present)

        2'b00,2'b10:if(count==(green_time-1))begin
            count<=0;
        end
        else begin
            count<=count+1;
        end
        2'b01,2'b11:if(count==(yellow_time-1))begin
            count<=0;
        end
        else begin
            count<=count+1;
        end
        default: count<=0;
        endcase

    end
end
endmodule