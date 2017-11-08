`timescale 1ns/1ps

module modulator (
    clk_fast,   // clk_fast is 16 times faster than clk_slow
    clk_slow,   // clk_slow is the same clk of input bit stream
    rst,
    valid,
    bit_in,
    wav_out
);

input wire clk_fast, clk_slow, rst;
input wire valid;
input wire bit_in;
output reg [7:0] wav_out;
localparam a00 = 5'd0, a01 = 5'd8, a11 = 5'd16, a10 = 5'd24;
localparam GROUP_NUM = 2'd2;

reg [1:0]bit_group, bit_latched;
reg group_flag;         // HIGH group_flag indicates a group of bits have arrived;
reg [1:0] group_count;  // Keep count of current buffered group bits

always@(posedge clk_slow or negedge rst) begin
    if (!rst || !valid) begin
        bit_group <= 2'b00;
        bit_latched <= 2'b00;
        group_flag <= 1'b0;
        group_count <= 2'd0;
    end else begin
        bit_group <= {bit_group[0], bit_in};
        if (group_flag)
            bit_latched <= bit_group;

        if (group_count == GROUP_NUM - 1'd1) begin
            group_flag <= 1'b0;
            group_count <= 1'd0;
        end else if (group_count == GROUP_NUM - 2'd2) begin
            group_flag <= 1'b1;
            group_count <= group_count + 1'd1;
        end else begin
            group_flag <= 1'b0;
            group_count <= group_count + 1'd1;
        end
    end
end

reg rst_clear;
reg [4:0] wav_count;        // Sine wave offset index count
reg group_flag_d1;          // Delay group_flag by 1 fast clk cycle
reg [1:0] bit_latched_d1;   // Delay bit_latched by 2 fast clk cycle
wire wav_count_rstp;
assign wav_count_rstp = (~group_flag) & (group_flag_d1);

// generate wav_count: the offset index for sine wave
integer i;
always@(posedge clk_fast or negedge rst) begin
    if (!rst || !valid) begin
        rst_clear <= 1'b0;
        group_flag_d1 <= 1'b0;
        wav_count   <= 5'd0;
        bit_latched_d1 <= 2'b0;
    end else begin
        group_flag_d1 <= group_flag;
        bit_latched_d1 <= bit_latched;

        // after group_flag is first set HIGH, rst_clear keeps HIGH
        if (wav_count_rstp & ~rst_clear)
            rst_clear <= 1'b1;

        if (!rst_clear || wav_count_rstp) begin
            wav_count <= 5'd0;
        end else begin
            wav_count <= wav_count + 5'd1;
        end
    end
end
// generate wav_base the base index for sine wave
reg [4:0] wav_base;
reg [4:0] wav_index;
wire [7:0] wav_out_temp;
sine_lut #(.N(32)) SLUT_0(wav_index, wav_out_temp);
always@(*) begin
    case (bit_latched_d1)
        2'b00: wav_base <= a00;
        2'b01: wav_base <= a01;
        2'b11: wav_base <= a11;
        2'b10: wav_base <= a10;
        default: wav_base <= 5'd0;
    endcase
end
always@(posedge clk_fast or negedge rst) begin
    if (!rst || !valid) begin
        wav_index <= 5'd0;
        wav_out <= 8'd0;
    end else begin
        wav_index <= wav_base + wav_count;
        wav_out <= wav_out_temp;
    end
end

endmodule 