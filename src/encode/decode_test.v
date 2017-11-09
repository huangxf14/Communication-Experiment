`timescale 1ns/1ps
module viterbi_tb( 
); 
reg clk; 
reg clk_div2; 
reg reset; 
reg x;

wire y; 
wire c; 

viterbi dut(clk,clk_div2,reset,x,y,c);

initial begin

clk = 0;
clk_div2 = 0; 
reset = 0; 
#10; 
x = 1; 
#15; 
reset = 1; 
end

always #5 clk = ~clk; 
always@(posedge clk)begin 
clk_div2 <= ~clk_div2; 
end 
initial 
begin 
#25; 
x = 1; 
#10; 
x = 0; 
#10; 
x = 0; 
#10; 
x = 1; 
#10; 
x = 0; 
#10; 
x = 1; 
#10; 
x = 0; 
#10; 
x = 0; 
#10; 
x = 1; 
#10; 
x = 0; 
#10; 
x = 1; 
#10; 
x = 1; 
#10; 
x = 0; 
#10; 
x = 0; 
end 
endmodule