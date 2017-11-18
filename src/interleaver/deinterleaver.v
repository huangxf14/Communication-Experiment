`timescale 1ns/1ps

module deinterleaver (clk, rst,valid,data_i, data_o);
input  clk;
input  rst;
input valid;
input  data_i;
output data_o;
reg    [15:0] mem0;
reg    [15:0] mem1;
reg    [3:0] counter;
reg data_o;
reg flag;
//reg start;
	always @ (posedge clk or negedge rst )
   begin
       if((!rst)||(!valid))
         begin
		    flag <= 0;
		 mem0[15:0] <= 0;
		 mem1[15:0] <= 0;
			counter <= 0;
			data_o <=0;
			//start<=0;
         end
	   else// if(start == 1 || data_i == 1)
		 begin 
		    if(counter < 15)
			  begin
		        counter <= counter+1;
              if(flag == 0)
			    begin
			    mem0[counter]<=data_i;
			    data_o <= mem1[counter/4+(counter%4)*4];
			    end
	          else
			    begin
			    mem1[counter]<=data_i;
			    data_o <= mem0[counter/4+(counter%4)*4];
	            end
			end
			else if(counter == 15)
			  begin
			    counter <= 0;
				if (flag==0)
						flag<=1;
				else
					flag<=0;
			  end
			  //start <=1;
         end 
end 
endmodule
