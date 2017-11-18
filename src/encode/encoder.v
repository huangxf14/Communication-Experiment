`timescale 1ns / 1ps
module encoder
	(
		clk,
		clk_2,
		reset,
		valid,
		data_in,
		code_out
	);
	input clk;
	input clk_2;
	input reset;
	input wire data_in;
	output reg valid;
	output code_out;
	reg code;
	reg [1:0] data_out;
	reg count;

	reg [1:0]state;

	initial
	begin
		valid=0;
	end

	always@(posedge clk_2 or negedge reset)
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

	always@(posedge clk or negedge reset)
	begin
		if(!reset)
		begin
			count <= 0;
		end
		else if(count == 0)
		begin
			code <= data_out[0];
			count <= count+1;
		end
		else
		begin
			code <= data_out[1];
			count <= count+1;
		end
	end

	assign code_out = code;
	//assign code_out= (clk)? data_out[0]: data_out[1];
endmodule // encoder
