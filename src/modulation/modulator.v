`timescale 1ns/1ps

/**
 * Since the delay of this module is slightly more than 2 slow clock cycles
 * (more precisely, 2 slow clock cycles + 3 fast clock cycles), two neighboring packets,
 * i.e. two HIGH valid signals should be at least 3 slow clock cycles apart.
 *             __    __    __    __    __
 * clk:     __|  |__|  |__|  |__|  |__|  |__
 *          _______                   _______
 * valid:   Packet |_________________| Packet
 * comment:        {   >= 3*cycles   }
 *
 * For detailed interface description, see comments below
 */
module modulator (
    clk_fast,   // Provided by the global clock module. clk_fast is 16 times faster than clk_slow for generating sine wave.
    clk_slow,   // Provided by the global clock module. clk_slow is the **same** clk input as in decoder/interleaver/etc.
    rst,        // Global reset signal
    valid,      // Provided by a signal generator (UART, sampling, etc.). Input valid signal.
    bit_in,     // Provided by a signal generator. Input bit stream.
    wav_out     // Output sine wave. After added with noise, the new wave output should drive a DAC.
);

input wire clk_fast, clk_slow, rst;
input wire valid;
input wire bit_in;
output reg [7:0] wav_out;
localparam a00 = 5'd0, a01 = 5'd8, a11 = 5'd16, a10 = 5'd24;

/* For data input buffers, need to deal with `valid` signal properly */
localparam BITS_IN_GROUP = 2'd2, GROUPS_IN_SHIFTER = 3'd3;
reg [1:0] bit_count;        // Keep count of current buffered group bits
reg group_flag;             // HIGH group_flag indicates a group of bits have arrived;

reg [5:0] bit_shifter;      // shift registers that keeps N/2 groups of bits.
reg [1:0] group_latched;    // current group of bits
reg [2:0] group_count;      // count of data group (excluding preamble group)

wire bit_in_i;              // When valid is HIGH, it's `bit_in`, else it's cleared 0.
assign bit_in_i = (~valid)? 1'b0 : bit_in;

always@(posedge clk_slow or negedge rst) begin
    // When reset, or valid is LOW and all groups buffered in the shifter has runned out
    if ( (!rst) || ((!valid) && (group_count == 3'd0)) ) begin
        group_flag  <= 1'b0;
        bit_count   <= 2'd0;
    end else begin
        if (bit_count == BITS_IN_GROUP - 1'd1) begin
            group_flag  <= 1'b1;
            bit_count   <= 1'd0;
        end else begin
            group_flag  <= 1'b0;
            bit_count   <= bit_count + 1'd1;
        end
    end
end

always@(posedge clk_slow or negedge rst) begin
    if (!rst) begin
        bit_shifter     <= 6'b0;
        group_latched   <= 2'b00;
        group_count     <= 3'd0;
    end else begin

        if (group_flag) begin
            group_latched   <= bit_shifter[5:4];
            if (valid && (group_count != GROUPS_IN_SHIFTER)) begin
                group_count <= group_count + 3'd1;
            end else if (!valid && (group_count != 3'd0)) begin
                group_count <= group_count - 3'd1;
            end
        end
        bit_shifter     <= {bit_shifter[4:0], bit_in_i};

    end
end

reg rst_clear;
reg [4:0] wav_count;        // Sine wave offset index (updated per fast clk cycle)
reg group_flag_d1;          // Delay group_flag by 1 fast clk cycle
reg [1:0] group_latched_d1; // Delay group_latched by 1 fast clk cycle
wire wav_count_rstp;
assign wav_count_rstp = (~group_flag) & (group_flag_d1);

// generate wav_count: the offset index for sine wave
always@(posedge clk_fast or negedge rst) begin
    if ( (!rst) || ((!valid) && (group_count == 3'd0)) ) begin
        rst_clear <= 1'b0;
        group_flag_d1 <= 1'b0;
        wav_count   <= 5'd0;
        group_latched_d1 <= 2'b0;
    end else begin
        group_flag_d1 <= group_flag;
        group_latched_d1 <= group_latched;

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
    if (rst_clear) begin
        case (group_latched_d1)
            2'b00: wav_base <= a00;
            2'b01: wav_base <= a01;
            2'b11: wav_base <= a11;
            2'b10: wav_base <= a10;
            default: wav_base <= 5'd0;
        endcase
    end else begin
        wav_base <= 5'd0;
    end
end

always@(posedge clk_fast or negedge rst) begin
    if ( (!rst) || ( (!valid) && group_count == 3'd0) ) begin
        wav_index <= 5'd0;
    end else begin
        wav_index <= wav_base + wav_count;
    end
    if (rst_clear) begin
        wav_out <= wav_out_temp;
    end else begin
        wav_out <= 8'd0;
    end
end

endmodule 