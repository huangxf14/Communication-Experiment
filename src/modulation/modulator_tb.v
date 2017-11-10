`timescale 1ns/1ps

module modulator_tb;

localparam HALF_PERIOD = 5;
localparam TIMES_SLOW = 5'd16;
localparam SET_RSTH = 18;
reg clk_fast, clk_slow, rst;
reg valid;
reg bit_in;
wire [7:0]wav_sine;
wire [4:0]wav_noise;
wire [7:0]wav_out;
wire bit_out, dem_valid;

initial begin
    clk_fast <= 1'b0;
    clk_slow <= 1'b0;
    rst <= 1'b0;
    valid <= 1'b0;
    forever begin
        #HALF_PERIOD clk_fast <= ~clk_fast;
    end
end

initial fork
    #SET_RSTH rst <= 1'b1;
    #80 valid <= 1'b1;
    #8000 valid <= 1'b0;
    #8800 valid <= 1'b1;
join

// generate clk_slow from clk_fast
reg [4:0] slow_clkcount;
always@(posedge clk_fast or negedge rst) begin
    if(!rst) begin
        slow_clkcount <= 5'd0;
    end else begin
        if (slow_clkcount == TIMES_SLOW/2 - 1) begin
            slow_clkcount <= 5'd0;
            clk_slow <= ~clk_slow;
        end else begin
            slow_clkcount <= slow_clkcount + 5'd1;
        end
    end
end

// generate random input bit stream
always@(posedge clk_slow or negedge rst) begin
    if(!rst) begin
        bit_in <= 1'b0;
    end else begin
        bit_in <= $urandom%2 + 1'b1;
    end
end

modulator M0 (clk_fast, clk_slow, rst, valid, bit_in, wav_sine);
pseudo_random PRandom0 (clk_fast, rst, wav_noise);
assign wav_out = (~wav_noise[4])? wav_sine + wav_noise[3:0]:
                 (wav_noise[3:0] < wav_sine)? wav_sine - wav_noise[3:0]:
                 8'd0;
demodulator DeM0 (clk_fast, clk_slow, rst, wav_out, bit_out, dem_valid);
endmodule