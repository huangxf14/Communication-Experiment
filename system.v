`timescale 1ns/1ps

/**
 * Organizationo of the system (half)
 *      _________
 *     | clk gen |--------------------------------------------------------------
 *     |_________|  slow            slow               slow            slow&fast
 *      _______________           _________           _______           ______
 *     |               |   bit   |         |   bit   |inter- |   bit   |modu- |
 *     | UART/Sampling | ------> | Encoder | ------> |leaver | ------> |lator |--------> DAC
 *     |_______________|  valid  |_________|  valid  |_______|  valid  |______|    ^
 *                                                                      _______    |
 *                                                                     |noise- | --|
 *                                                                     | gen   |
 *                                                                      -------
 */
module system(input clk_wave,input reset,output [7:0]led
);

reg clk1,clk2,clk3;

//reg rst;
//reg reset;
reg clk; 
reg clk_div2; 
wire valid_send;
wire valid_wave;
reg data_send;
wire code_send;
wire bit_send;

wire [7:0]wav_send;
wire [4:0]wav_noise;
wire [7:0]wav_recv;
wire valid_recv;
wire valid_dein;
wire valid_deco;


wire bit_recv;
wire code_recv;
wire code_prob;
wire data_recv;

reg [13:0]data_in;
reg [3:0]count;

reg flag;
reg [3:0]number;
reg data_show;
reg lock;
//wire[7:0]led;
//debounce xdebounce(.clk(clk_wave),.key_i(rst),.key_o(reset));

encoder enco(clk_div2,clk,reset,valid_send,valid_wave,data_send,code_send);

interleaver inter(clk, valid_send, reset, code_send, bit_send);

modulator modu(clk_wave, clk, reset, valid_wave, bit_send, wav_send);
pseudo_random noise(clk_wave, reset, wav_noise);
assign wav_recv = (~wav_noise[4])? wav_send + wav_noise[3:0] * 2:
                 (wav_noise[3:0] * 2 < wav_send)? wav_send - wav_noise[3:0] * 2:
                 8'd0;

demodulator demodu(clk_wave, clk, reset, wav_recv, bit_recv, valid_recv);

deinterleaver deinter(clk, reset,valid_recv,valid_dein,valid_deco,bit_recv, code_recv);

decoder deco(clk,clk_div2,reset,valid_deco,code_recv,code_prob,data_recv);

CommModem Show(.clk(clk_div2),.reset(reset),.lock(lock),.data_in(data_show),.led_1(led));

//initial
//	begin
//		clk_wave=0;
//		reset = 1; 
//		#10
//		reset = 0;
//		#99
//		reset = 1;
//		#200
//		reset = 0;
//		#60
//		reset = 1;
//	end
//clk generator
//always #1 clk_wave = ~clk_wave;

always@(posedge clk_wave or negedge reset)begin
	if(!reset) begin
		clk1<=0;
	end
	else begin
	clk1 <= ~clk1; 
	end
end 

always@(posedge clk1 or negedge reset)begin 
	if(!reset) begin
		clk2<=0;
	end
	else begin
	clk2 <= ~clk2; 
	end
end 

always@(posedge clk2 or negedge reset)begin 
	if(!reset) begin
		clk3<=0;
	end
	else begin
	clk3 <= ~clk3; 
	end
end 

always@(posedge clk3 or negedge reset)begin 
	if(!reset) begin
		clk<=0;
	end
	else begin
	clk <= ~clk; 
	end
end 

always@(posedge clk or negedge reset)begin 
	if(!reset) begin
		clk_div2<=0;
	end
	else begin
	clk_div2 <= ~clk_div2; 
	end
end 

//test data

always @(posedge clk_div2 or negedge reset) begin
	if (!reset) begin
		data_in <= 14'b10010000101100;
		data_send <= 0;
		count <= 0;
	end
	else if(count != 14)begin
		data_in <= {data_in[12:0],data_in[13]};
		data_send <= data_in[13];
		count <= count+1;
	end
	else begin
		data_send <= 0;
	end
end

always @(posedge clk or negedge reset) begin
	if(~reset) begin
		data_show <= 0;
	end else begin
		data_show <= data_recv;
	end
end

always @(posedge clk_div2 or negedge reset) begin
	if(~reset) begin
		flag <= 0;
		number <= 0;
		lock <= 0;
	end 
	else if(flag == 0 && data_show == 1) begin
		flag <= 1;
	end
	else if(flag == 1 && number != 12) begin
		number <= number+1;
	end
	else if(number == 12) begin
		lock <= 1;
	end
end
endmodule