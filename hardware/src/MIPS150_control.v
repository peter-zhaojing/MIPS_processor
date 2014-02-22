`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:00:18 02/17/2014 
// Design Name: 
// Module Name:    MIPS150_control 
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

`include "Opcode.vh"

module MIPS150_control(
    input	[31:0]	Instr,
	 output	[3:0]		ALUControl,
	 output	reg		RegWrite
    );

wire [5:0]	opcode, funct;

//signal declaration
assign opcode	=	Instr[31:26];
assign funct	=	Instr[5:0];

//instantiate ALUdec. ALUdec takes care of ALUControl signal
ALUdec MIPS150_aludec(
	.funct	(funct),
	.opcode	(opcode),
   .ALUop	(ALUControl)

);

//generate rest of the control signals
always@(*) begin
	case(opcode)
		// Load/store
		`LB,`LH,`LW,`LBU,`LHU:	begin
			RegWrite = 1;
		
		end
		
	
	
	endcase
end

endmodule
