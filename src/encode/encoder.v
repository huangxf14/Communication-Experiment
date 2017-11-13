module encoder
	(
		clk,
		reset,
		valid,
		data_in,
		code_out
	);
	input clk;
	input reset;
	input wire data_in;
	output reg valid;
	output code_out;
	reg [1:0] data_out;

	reg [1:0]state;

	initial
	begin
		valid=0;
	end

	always@(posedge clk)
	begin
		if(!reset)
			begin
				data_out <= 2'b0;
				state <= 2'b0;
				valid<=0;
			end 
		else
			begin
				data_out[0] <= data_in + state[0] + state[1];
				data_out[1] <= data_in + state[1];
				state[1] <= state[0];
				state[0] <= data_in;
				valid<=1;
			end
	end

	assign code_out= (clk)? data_out[0]: data_out[1];
endmodule // encoder
