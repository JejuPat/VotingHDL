`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.07.2025 16:35:30
// Design Name: 
// Module Name: swap_tb
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

   
module top_module ();
    reg clk, reset;
    reg [15:0] i_record;
    reg [15:0] secret_key;
    wire [15:0] o_record;
    always #10 clk = ~clk;  // Create clock with period=10
	initial begin
	    clk = 0;
        secret_key = 16'b1110100001011001;
		i_record = 16'b0100001101101000;
		#20
		secret_key = 16'b0000011000011001;
		i_record = 16'b1100011110011111;	
	end

    
    swap swap1(.clk(clk), .reset(reset), .i_record(i_record), .secret_key(secret_key), .o_record(o_record));
endmodule