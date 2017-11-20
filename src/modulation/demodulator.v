`timescale 1ns/1ps

module demodulator
#(parameter HIGH_TH = 24'd200000,
  parameter LOW_TH = 24'd120000)
(
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
localparam CORR_DELAY = DEPTH + 1;
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

// Definitions for frame header synchronization and symbol detection
localparam IDLE = 4'd0, MATCH = 4'd1, SYNC_END = 4'd2, POST_SYNC = 4'd3;
reg [3:0] sync_state;
reg sync_pulse;
reg [23:0] max_corr;
reg [4:0] wav_count_i;
reg [1:0] assure_times;

localparam HIGH = 2'd0, MIDIUM = 2'd1, LOW = 2'd2;
reg [4:0] wav_count;
reg [2:0] pre_valid_count;
wire [1:0] sin_corr_judge_i;
wire [1:0] cos_corr_judge_i;
reg [1:0] sin_corr_judge;
reg [1:0] cos_corr_judge;
reg [1:0] bit_out_i;
reg serial_count;

// State machine for frame header synchronization
always@(posedge clk_fast or negedge rst) begin
    if (!rst) begin
        sync_state      <= IDLE;
        sync_pulse      <= 1'b0;

        max_corr        <= 24'd0;
        wav_count_i     <= 6'd0;
        assure_times    <= 2'd0;
    end else begin
        case(sync_state)
        IDLE: begin
            if (sin_corr >= HIGH_TH) begin
                // State leaps to FIRST_MATCH if sin_corr is above HIGH_TH 2 times
                if (assure_times != 2'd2)
                    assure_times <= assure_times + 2'd1;
                else begin
                    assure_times<= 2'd0;
                    sync_state   <= MATCH;
                end
                // If corr is larger than current max, reset wav_count
                if (sin_corr > max_corr) begin
                    max_corr    <= sin_corr;
                    wav_count_i <= 5'd0;
                end else begin
                    wav_count_i <= wav_count_i + 5'd1;
                end
            end else begin
                max_corr        <= 24'd0;
                wav_count_i     <= 5'd0;
                assure_times    <= 2'd0;
            end
        end
        MATCH: begin
            if (sin_corr > max_corr) begin
                max_corr        <= sin_corr;
                wav_count_i     <= 5'd0;
            end else begin
                if (sin_corr < HIGH_TH) begin
                    // State leaps to SECOND_MATCH if sin_corr is below HIGH_TH 2 times
                    if (assure_times != 2'd2)
                        assure_times   <= assure_times + 2'd1;
                    else begin
                        sync_state     <= SYNC_END;
                        max_corr       <= 24'd0;
                        assure_times   <= 2'd0;
                    end 
                end
                wav_count_i      <= wav_count_i + 5'd1;
            end
        end
        SYNC_END: begin
            sync_pulse <= 1'b1;
            if (sync_pulse) begin
                sync_pulse <= 1'b0;
                sync_state <= POST_SYNC;
            end
        end
        // After synchronization finishes, do nothing
        POST_SYNC: sync_state <= sync_state;
        default: sync_state <= sync_state;
        endcase
    end
end

// symbol detection
assign sin_corr_judge_i = (sin_corr >= HIGH_TH)? HIGH:
                        (sin_corr < LOW_TH)? LOW: MIDIUM;
assign cos_corr_judge_i = (cos_corr >= HIGH_TH)? HIGH:
                        (cos_corr < LOW_TH)? LOW: MIDIUM;
always@(posedge clk_fast or negedge rst) begin
    if (!rst) begin
        sin_corr_judge <= 2'b0;
        cos_corr_judge <= 2'b0;
    end else begin
        sin_corr_judge <= sin_corr_judge_i;
        cos_corr_judge <= cos_corr_judge_i;
    end
end
always@(posedge clk_fast or negedge rst) begin
    if (!rst) begin
        wav_count       <= 5'd0;
        pre_valid_count <= 3'b0;
        valid           <= 1'b0;
        bit_out_i       <= 2'b0;
        serial_count    <= 1'b0;
    end else begin
        if (sync_pulse) begin
            wav_count   <= wav_count_i + 5'd8;
        end
        if (sync_state == POST_SYNC) begin
            wav_count   <= wav_count + 5'd1;
        end
        // drive valid signal
        if ((!valid) && (wav_count == 5'd5) && (pre_valid_count != 3'd2)) begin
            pre_valid_count <= pre_valid_count + 3'b1;
        end
        if ((!valid) && (wav_count == 5'd5) && (pre_valid_count == 3'd1)) begin
             valid <= 1'b1;
        end
        // symbol detection
        if ( ((pre_valid_count == 5'd1) || valid) && (wav_count == 5'd5)) begin
            if (sin_corr_judge == HIGH) begin
                bit_out_i <= 2'b00;
            end else if (cos_corr_judge == HIGH) begin
                bit_out_i <= 2'b01;
            end else if (sin_corr_judge == LOW) begin
                bit_out_i <= 2'b11;
            end else if (cos_corr_judge == LOW) begin
                bit_out_i <= 2'b10;
            end else begin
                bit_out_i <= 2'b00;
            end
        end
    end
end
always@(posedge clk_slow or negedge rst) begin
    if (!rst) begin
        serial_count <= 2'b0;
        bit_out     <= 1'b0;
    end else begin
        if (valid) begin
            serial_count <= serial_count + 1'b1;
            if (serial_count == 2'b0) begin
                bit_out <= bit_out_i[1];
            end else begin
                bit_out <= bit_out_i[0];
            end
        end
    end
end
endmodule