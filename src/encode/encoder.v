module encoder
	(
		clk,
		clk2,
		reset,
		valid,
		valid_wave,
		data_in,
		code_out
	);
	input clk;
	input clk2;
	input reset;
	input wire data_in;
	output reg valid;
	output reg valid_wave;
	output reg code_out;
	reg [1:0] data_out;
	reg flag;

	reg [1:0]state;

	initial
	begin
		valid=0;
		valid_wave=0;
		flag=0;
	end

	always@(posedge clk)
	begin
		if(!reset)
			begin
				data_out <= 2'b0;
				state <= 2'b0;
				valid<=0;
				valid_wave<=0;
				flag<=0;
			end 
		else
			begin
				data_out[0] <= data_in + state[0] + state[1];
				data_out[1] <= data_in + state[1];
				state[1] <= state[0];
				state[0] <= data_in;			
				flag<=1;
			end
	end

	always@(posedge clk2)
	begin
	  if (flag)
	  begin
	  	code_out <= (clk)? data_out[0]: data_out[1];
	  	valid <= 1;
	  end
	  if (valid)
	  begin
	  	valid_wave=1;
	  end
	end
   
   
	
endmodule // encoder
