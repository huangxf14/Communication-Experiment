/*******************A Simple Case********************/

`timescale 1ns / 1ps
module CommModem(
  /*	System IO			*/
  input 	clk,
  input 	reset,
  input   lock, /* this signal is used to mark whether the input is valid*/
  input  wire data_in,
  output wire [7:0] led_1		/*	1st row of leds 	*/
  //output wire [7:0] led_2		/* 2nd row of leds 	*/

  );
  //reg [7:0]	led_1_reg;//, led_2_reg;
  reg [7:0] data; //save input;

  assign led_1 = data;
  //assign led_2 = {led_2_reg[7], led_2_reg[6], led_2_reg[5], led_2_reg[4], led_2_reg[3], led_2_reg[2], led_2_reg[1], led_2_reg[0]};
  /* 
   *	Generate clk signals
   */
  
  /* 
   * Generate led show
   */
  always @(posedge clk or negedge reset)
  begin
		if (!reset) begin
			data <= 8'd0;
	//		led_2_reg <= 8'd0;
		end
		else if(!lock)
      begin
			data <= {data[6:0], data_in};
	//		led_2_reg <= led_2_reg + 8'd1;
		  end
  end

endmodule
