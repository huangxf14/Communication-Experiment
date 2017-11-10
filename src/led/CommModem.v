/*******************A Simple Case********************/

`timescale 1ns / 1ps
module CommModem(
  /*	System IO			*/
  input 	sys_clk,
  input 	reset,
  input   lock, /* this signal is used to mark whether the input is valid*/
  input  wire data_in,
  output wire [7:0] led_1		/*	1st row of leds 	*/
  //output wire [7:0] led_2		/* 2nd row of leds 	*/

  );

  //reg [7:0]	led_1_reg;//, led_2_reg;
  reg [6:0] data; //save input;
  wire clk_1, 	clk_2, clk_4, clk_8, clk_16, clk_32;
  wire clk_64, clk_128, clk_256, clk_512, clk_30, 	clk_8k;

  assign led_1 = {1'b0,data};
  //assign led_2 = {led_2_reg[7], led_2_reg[6], led_2_reg[5], led_2_reg[4], led_2_reg[3], led_2_reg[2], led_2_reg[1], led_2_reg[0]};
  /* 
   *	Generate clk signals
   */
  ClkGen cg(
    .sys_clk	(	sys_clk	),
    .reset		(	reset		),
    .clk_1		(	clk_1		),
    .clk_2		(	clk_2		),
	 .clk_4		(	clk_4		),
	 .clk_8		(	clk_8		),
	 .clk_16		(	clk_16	),
	 .clk_32		(	clk_32	),
	 .clk_64		(	clk_64	),
	 .clk_128	(	clk_128	),
	 .clk_256	(	clk_256	),
	 .clk_512	(	clk_512	),
	 .clk_30		(	clk_30	),
	 .clk_8k		(	clk_8k	)
  );
  
  /* 
   * Generate led show
   */
  always @(posedge sys_clk or negedge reset)
  begin
		if (!reset) begin
			data <= 7'd0;
	//		led_2_reg <= 8'd0;
		end
		else if(!lock)
      begin
			data <= {data[5:0], data_in};
	//		led_2_reg <= led_2_reg + 8'd1;
		  end
  end

endmodule
