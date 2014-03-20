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
    input	[31:0]		Instr,
	 output	[3:0]			ALUControl,
	 output	reg			RegWrite,
	 output	reg [2:0]	Mask,
	 output	reg [1:0]	MemWrite,
	 output  reg			MemtoReg,
	 output	reg			LUItoReg
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
		
		/*********************/
		//MemAlign 00 => Byte
		//MemAlign 01 => Half
		//MemAlign 10 => Word
		/*********************/
		`LB:	begin
					RegWrite = 1'b1;
					Mask = 3'b000;
					MemWrite = 2'b00;
					MemtoReg = 1'b1;
					LUItoReg = 1'b0;
				end
		`LH:	begin
					RegWrite = 1'b1;
					Mask = 3'b001;
					MemWrite = 2'b00;
					MemtoReg = 1'b1;
					LUItoReg = 1'b0;
				end
		`LW:	begin
					RegWrite = 1'b1;
					Mask = 3'b010;
					MemWrite = 2'b00;
					MemtoReg = 1'b1;
					LUItoReg = 1'b0;
				end
		`LBU:	begin
					RegWrite = 1'b1;
					Mask = 3'b011;
					MemWrite = 2'b00;
					MemtoReg = 1'b1;
					LUItoReg = 1'b0;
				end
		`LHU:	begin
					RegWrite = 1'b1;
					Mask = 3'b100;
					MemWrite = 2'b00;
					MemtoReg = 1'b1;
					LUItoReg = 1'b0;
				end
		`SB:	begin
					RegWrite = 1'b0;
					Mask = 3'bxxx;
					MemWrite = 2'b01;
					MemtoReg = 1'bx;
					LUItoReg = 1'bx;
				end
		`SH:	begin
					RegWrite = 1'b0;
					Mask = 3'bxxx;
					MemWrite = 2'b10;
					MemtoReg = 1'bx;
					LUItoReg = 1'bx;
				end
		`SW:	begin
					RegWrite = 1'b0;
					Mask = 3'bxxx;
					MemWrite = 2'b11;
					MemtoReg = 1'bx;
					LUItoReg = 1'bx;
				end
		 
		 // I-type Computational Instructions
		 `ADDIU:	begin
						RegWrite = 1'b1;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'b0;
						LUItoReg = 1'b0;
					end
		 `LUI:	begin
						RegWrite = 1'b1;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'bx;
						LUItoReg = 1'b1;
					end
		
		 default:	begin
					//TODO: add default values for all signals
					RegWrite = 1'b0;
					Mask = 3'bxxx;
					MemWrite = 2'b00;
					MemtoReg = 1'bx;		//TODO: put don't care or 0 or 1?
					LUItoReg = 1'bx;
		 end
		 
		 
	endcase
end

endmodule
