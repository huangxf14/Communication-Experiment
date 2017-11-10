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
    input clk,
    input rst,
    input data_in,
    input ADC_in,

    output data_out,
    output DAC_out,
);

endmodule