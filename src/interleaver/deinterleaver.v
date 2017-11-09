`timescale 1ns/1ps

module deinterleaver (clk, rst, data_i, data_o);
input  clk;
input  rst;
input  data_i;
output data_o;
reg    [16:0] mem0;
reg    [16:0] mem1;
reg    [3:0] counter;
reg data_o;
reg flag;
//reg start;
always @ (posedge clk or posedge rst )
   begin
       if(!rst)
         begin
		    flag <= 0;
            mem0[16:0] <= 0;
			mem1[16:0] <= 0;
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
