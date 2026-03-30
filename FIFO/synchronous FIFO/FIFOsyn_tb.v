  module sync_fifo_TB;
    reg clk, rst_n;
    reg w_en, r_en;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire full, empty;
    
    synchronous_fifo s_fifo(.clk(clk), .rst_n(rst_n), .w_en(w_en),.r_en(r_en), .data_in(data_in), .data_out(data_out), .full(full), .empty(empty));
    
    always #2 clk = ~clk; 
    initial begin
      clk = 0; rst_n = 0;
      w_en = 0; r_en = 0;
      #3 rst_n = 1;
      drive(20);
      drive(40);
      $finish;
    end
    
     
    task automatic drive(int delay);
      w_en = 0; r_en = 0;
      fork
        begin
          repeat(10) begin @(posedge clk)  if(!full) begin
        w_en = 1;
        data_in = $random;
        #1 $display("Push In: w_en=%b, r_en=%b, data_in=%d",w_en, r_en,data_in);
        w_en = 0;
      end
      else $display("FIFO Full!! Can not push data_in=%d", data_in); end
          
        end
        begin
          #delay
          repeat(10) begin @(posedge clk) if(!empty) begin
        r_en = 1;
        #1 $display("Pop Out: w_en=%b, r_en=%b, data_out=%d",w_en, r_en,data_out);
        r_en = 0;
      end
      else $display("FIFO Empty!! Can not pop data_out"); end
   
        end
      join
    endtask
    
    initial begin 
      $dumpfile("dump.vcd");
      $dumpvars(0,sync_fifo_TB);
    end
  endmodule
