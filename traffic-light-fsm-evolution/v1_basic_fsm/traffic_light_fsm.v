module traffic_fsm( input clk,input rst,output reg [2:0]NS, output reg [2:0]EW);
//s0: NS=green EW=red;
//s1: NS=yellow EW=red;
//s2: NS=red EW=green;
//s3: NS=red EW=yellow;
localparam S0=2'b00;
localparam S1=2'b01;
localparam S2=2'b10;
localparam S3=2'b11;
localparam green=3'b001;
localparam yellow=3'b010;
localparam red=3'b100;
reg [1:0]present;
reg [1:0]next;
reg [3:0]count;

//present logic

always @(posedge clk)
begin
    if(rst==0)begin
    present<=S0;
    end
    else
    begin
     present<=next;     
    end
end

//counter

always@(posedge clk)
begin
    if(rst==0)begin
        count<=0;
    end
    else begin
        case(present)

        S0,S2:if(count==9)begin
            count<=0;
        end
        else begin
            count<=count+1;
        end
        S1,S3:if(count==2)begin
            count<=0;
        end
        else begin
            count<=count+1;
        end
        default: count<=0;
        endcase

    end
end

//next logic

always@(*)begin
    case(present)

    S0:next=(count==9)?S1:S0;
    S1:next=(count==2)?S2:S1;
    S2:next=(count==9)?S3:S2;
    S3:next=(count==2)?S0:S3;
    default:next=S0;

    endcase
end
//output
always@(*)begin
    case(present)
       S0:begin NS=green;EW=red;end
       S1:begin NS=yellow;EW=red; end
       S2:begin NS=red;EW=green; end
       S3:begin NS=red;EW=yellow; end
    default:begin NS=yellow;EW=yellow; end
    endcase
end

endmodule