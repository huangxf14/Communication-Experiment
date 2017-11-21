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
module system(
);

reg clk_wave,clk1,clk2,clk3;

reg reset;
reg clk; 
reg clk_div2; 
wire valid_send;
wire valid_wave;
reg data_send;
wire code_send;
wire bit_send;

wire [7:0]wav_send;
wire [5:0]wav_noise;
wire [7:0]wav_recv;
wire valid_recv;
wire valid_dein;
wire valid_deco;


wire bit_recv;
wire code_recv;
wire code_prob;
wire data_recv;

encoder enco(clk_div2,clk,reset,valid_send,valid_wave,data_send,code_send);

interleaver inter(clk, valid_send, reset, code_send, bit_send);

modulator modu (clk_wave, clk, reset, valid_wave, bit_send, wav_send);
pseudo_random noise (clk_wave, reset, wav_noise);
assign wav_recv = (~wav_noise[4])? wav_send + wav_noise[3:0] * 2:
                 (wav_noise[3:0] * 2 < wav_send)? wav_send - wav_noise[3:0] * 2:
                 8'd0;
demodulator demodu (clk_wave, clk, reset, wav_recv, bit_recv, valid_recv);

deinterleaver deinter(clk, reset,valid_recv,valid_dein,valid_deco,bit_recv, code_recv);

decoder deco(clk,clk_div2,reset,valid_deco,code_recv,code_prob,data_recv);

initial begin

clk_wave=0;
clk1=0;
clk2=0;
clk3=0;
clk = 0;
clk_div2 = 0; 
reset = 0; 
#32; 
data_send = 1; 
#32; 
reset = 1; 
end

//clk generator
always #1 clk_wave = ~clk_wave;

always@(posedge clk_wave)begin 
clk1 <= ~clk1; 
end 

always@(posedge clk1)begin 
clk2 <= ~clk2; 
end 

always@(posedge clk2)begin 
clk3 <= ~clk3; 
end 

always@(posedge clk3)begin 
clk <= ~clk; 
end 

always@(posedge clk)begin 
clk_div2 <= ~clk_div2; 
end 

//test data

initial 
begin 
#64; 
data_send = 1; 
#64; 
data_send = 0; 
#64; 
data_send = 0; 
#64; 
data_send = 1; 
#64; 
data_send = 0; 
#64; 
data_send = 0; 
#64; 
data_send = 0; 
#64; 
data_send = 0; 
#64; 
data_send = 1; 
#64; 
data_send = 0; 
#64; 
data_send = 1; 
#64; 
data_send = 1; 
#64; 
data_send = 0; 
#64; 
data_send = 0; 
$stop;
end 


endmodule