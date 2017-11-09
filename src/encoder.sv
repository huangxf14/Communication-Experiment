module encoder
	(
		clk,
		reset,
		data_in,
		data_out
	);
	input clk;
	input reset;
	input wire data_in;
	output reg [1:0] data_out;

	reg [1:0]state;

	always@(posedge clk)
	begin
		if(reset)
			begin
				data_out <= 2'b0;
				state <= 2'b0;
			end 
		else
			begin
				data_out[0] <= data_in + state[0] + state[1];
				data_out[1] <= data_in + state[1];
				state[1] <= state[0];
				state[0] <= data_in;
			end
	end
endmodule // encoder
