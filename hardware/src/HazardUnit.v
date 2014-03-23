`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:00:59 03/23/2014 
// Design Name: 
// Module Name:    HazardUnit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module HazardUnit(
    input	[4:0]	Rs,
    input 	[4:0]	Rt,
	 input			RegWrite,
	 input	[4:0]	WriteReg,
	 output	reg	ForwardA,
	 output	reg	ForwardB
    );

always @(*)	begin
	if ((Rs != 5'b00000) && (Rs == WriteReg) && RegWrite)		ForwardA = 1'b1;
	else																		ForwardA = 1'b0;
end

always @(*) begin
	if ((Rt != 5'b00000) && (Rt == WriteReg) && RegWrite)		ForwardB = 1'b1;
	else																		ForwardB = 1'b0;
end

endmodule
