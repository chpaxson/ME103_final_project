`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2024 11:49:05 PM
// Design Name: 
// Module Name: led_blinky
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led_blinky(
    input clk, 
    input btn,
    output reg led);

    always @(posedge clk) begin
        if (btn) begin
            led <= 1'b1;
        end else begin
            led <= 1'b0;
        end
        
    end
endmodule
