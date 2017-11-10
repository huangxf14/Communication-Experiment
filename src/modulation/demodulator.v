`timescale 1ns/1ps

module demodulator(
    clk_fast,
    clk_slow,
    rst,
    wav_in,

    bit_out,
    valid
);

input wire clk_fast, clk_slow, rst;
input wire [7:0] wav_in;

output reg bit_out;
output reg valid;

function integer f_ceil_log2 (input integer x);
    integer acc;
    begin
        acc=0;
        while ((2**acc) < x)
        acc = acc + 1;
        f_ceil_log2 = acc;
    end
endfunction

localparam N = 32;
localparam DEPTH = f_ceil_log2(N);
localparam [7:0] sine_value[31:0] = '{
    8'h40, 8'h4c, 8'h58, 8'h64, 8'h6d, 8'h75, 8'h7b, 8'h7f, 8'h80, 8'h7f, 8'h7b, 8'h75, 8'h6d, 8'h64, 8'h58, 8'h4c,
    8'h40, 8'h34, 8'h28, 8'h1c, 8'h13, 8'hb,  8'h5,  8'h1,  8'h0,  8'h1,  8'h5,  8'hb,  8'h13, 8'h1c, 8'h28, 8'h34
};
localparam [7:0] cosine_value[31:0] = '{
    8'h80, 8'h7f, 8'h7b, 8'h75, 8'h6d, 8'h64, 8'h58, 8'h4c, 8'h40, 8'h34, 8'h28, 8'h1c, 8'h13, 8'hb,  8'h5,  8'h1,
    8'h0,  8'h1,  8'h5,  8'hb,  8'h13, 8'h1c, 8'h28, 8'h34, 8'h40, 8'h4c, 8'h58, 8'h64, 8'h6d, 8'h75, 8'h7b, 8'h7f
};

// Buffer for ADC wave inputs
reg [7:0] wav_in_buffer[N - 1 : 0];
integer i;
always@(posedge clk_fast or negedge rst) begin
    if (!rst) begin
        for (i = 0; i < N; i = i + 1)
            wav_in_buffer[i] <= 8'd0;
    end else begin
        for (i = 0; i < N; i = i + 1)
            wav_in_buffer[N-i] <= wav_in_buffer[N-i-1];
        wav_in_buffer[0] <= wav_in;
    end
end

// Multiply-and-Adder-tree for correlation calculation; delay is 5 fast clock cycles
reg [23:0] adder_regsine[DEPTH : 0][N - 1:0];
reg [23:0] adder_regcosine[DEPTH : 0][N - 1:0];

always@(posedge clk_fast) begin
    if (!rst) begin
        for (i = 0; i < N; i = i + 1)
            adder_regsine[DEPTH][i] <= 24'd0;
    end else begin
        for (i = 0; i < N; i = i + 1) begin
            adder_regsine[DEPTH][N - i - 1] <= wav_in_buffer[N - i - 1] * sine_value[N - i - 1];
        end
    end
end
always@(posedge clk_fast) begin
    if (!rst) begin
        for (i = 0; i < N; i = i + 1)
            adder_regcosine[DEPTH][i] <= 24'd0;
    end else begin
        for (i = 0; i < N; i = i + 1) begin
            adder_regcosine[DEPTH][N - i - 1] <= wav_in_buffer[N - i - 1] * cosine_value[N - i - 1];
        end
    end
end

genvar adder_i;
generate
for (adder_i = 0; adder_i < DEPTH; adder_i = adder_i + 1) begin: level_i
    always@(posedge clk_fast) begin
        for (i = 0; i < N / (2**(adder_i+1)); i = i + 1) begin
            adder_regsine[DEPTH - adder_i - 1][N - i - 1] <= adder_regsine[DEPTH - adder_i][N - 2*i - 1] + adder_regsine[DEPTH - adder_i][N - 2*i - 2]; 
        end
    end
    always@(posedge clk_fast) begin
        for (i = 0; i < N / (2**(adder_i+1)); i = i + 1) begin
            adder_regcosine[DEPTH - adder_i - 1][N - i - 1] <= adder_regcosine[DEPTH - adder_i][N - 2*i - 1] + adder_regcosine[DEPTH - adder_i][N - 2*i - 2]; 
        end
    end
end
endgenerate

wire [23:0] sin_corr;
wire [23:0] cos_corr;
assign sin_corr = adder_regsine[0][N-1];
assign cos_corr = adder_regcosine[0][N-1];

// TODO: wave phase detection based on corr; incoming symbol detection (main part of demodulator)
endmodule