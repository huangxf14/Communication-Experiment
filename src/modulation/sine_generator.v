`timescale 1ns/1ps

module sine_lut #(parameter N = 32)
(
    index,
    value
);

function integer f_ceil_log2 (input integer x);
    integer acc;
    begin
        acc=0;
        while ((2**acc) < x)
        acc = acc + 1;
        f_ceil_log2 = acc;
    end
endfunction

localparam MAX_WIDTH = f_ceil_log2(32);
localparam WIDTH = f_ceil_log2(N);
localparam SHIFT_WIDTH = MAX_WIDTH - WIDTH;

input wire [WIDTH-1:0] index;
output reg [7:0] value;
always@(*) begin
    case (index << SHIFT_WIDTH)
        5'd0 : value <= 8'h40;
        5'd1 : value <= 8'h4c;
        5'd2 : value <= 8'h58;
        5'd3 : value <= 8'h64;
        5'd4 : value <= 8'h6d;
        5'd5 : value <= 8'h75;
        5'd6 : value <= 8'h7b;
        5'd7 : value <= 8'h7f;
        5'd8 : value <= 8'h80;
        5'd9 : value <= 8'h7f;
        5'd10 : value <= 8'h7b;
        5'd11 : value <= 8'h75;
        5'd12 : value <= 8'h6d;
        5'd13 : value <= 8'h64;
        5'd14 : value <= 8'h58;
        5'd15 : value <= 8'h4c;
        5'd16 : value <= 8'h40;
        5'd17 : value <= 8'h34;
        5'd18 : value <= 8'h28;
        5'd19 : value <= 8'h1c;
        5'd20 : value <= 8'h13;
        5'd21 : value <= 8'hb;
        5'd22 : value <= 8'h5;
        5'd23 : value <= 8'h1;
        5'd24 : value <= 8'h0;
        5'd25 : value <= 8'h1;
        5'd26 : value <= 8'h5;
        5'd27 : value <= 8'hb;
        5'd28 : value <= 8'h13;
        5'd29 : value <= 8'h1c;
        5'd30 : value <= 8'h28;
        5'd31 : value <= 8'h34;
        default: value <= 8'h0;
    endcase
end
endmodule