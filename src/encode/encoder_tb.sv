`timescale 1ns / 1ps
module encode_tb;
	reg test_in;
	wire [1:0]test_out;
	reg reset,clk;
	encoder conv(.clk(clk),.reset(reset),.data_in(test_in),.data_out(test_out));

	always #5 clk = ~clk;
	initial
		begin
			reset = 1;
			#10;
			reset = 0;
		end

	initial
		begin
			clk = 0;
			#12;
			test_in = 1;
			#10;
			test_in = 1;
			#10;
			test_in = 0;
			#10;
			test_in = 1;
			#10;
			test_in = 0;
			#10;
			test_in = 0;
			#10;
			test_in = 0;
			$stop;
		end
endmodule // encode_tb