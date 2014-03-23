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
	 output	reg			LUItoReg,
	 output	reg			SignOrZero,
	 output	reg			ALUSrc,
	 output	reg			RegDst,
	 output	reg			VarOrShamt
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
		
		// Load/store Instructions
		
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
					SignOrZero = 1'b1;
					ALUSrc = 1'b1;
					RegDst = 1'b0;
					VarOrShamt = 1'b1;
				end
		`LH:	begin
					RegWrite = 1'b1;
					Mask = 3'b001;
					MemWrite = 2'b00;
					MemtoReg = 1'b1;
					SignOrZero = 1'b1;
					ALUSrc = 1'b1;
					RegDst = 1'b0;
					VarOrShamt = 1'b1;
				end
		`LW:	begin
					RegWrite = 1'b1;
					Mask = 3'b010;
					MemWrite = 2'b00;
					MemtoReg = 1'b1;
					SignOrZero = 1'b1;
					ALUSrc = 1'b1;
					RegDst = 1'b0;
					VarOrShamt = 1'b1;
				end
		`LBU:	begin
					RegWrite = 1'b1;
					Mask = 3'b011;
					MemWrite = 2'b00;
					MemtoReg = 1'b1;
					SignOrZero = 1'b1;
					ALUSrc = 1'b1;
					RegDst = 1'b0;
					VarOrShamt = 1'b1;
				end
		`LHU:	begin
					RegWrite = 1'b1;
					Mask = 3'b100;
					MemWrite = 2'b00;
					MemtoReg = 1'b1;
					SignOrZero = 1'b1;
					ALUSrc = 1'b1;
					RegDst = 1'b0;
					VarOrShamt = 1'b1;
				end
		`SB:	begin
					RegWrite = 1'b0;
					Mask = 3'bxxx;
					MemWrite = 2'b01;
					MemtoReg = 1'bx;
					SignOrZero = 1'b1;
					ALUSrc = 1'b1;
					RegDst = 1'b0;
					VarOrShamt = 1'b1;
				end
		`SH:	begin
					RegWrite = 1'b0;
					Mask = 3'bxxx;
					MemWrite = 2'b10;
					MemtoReg = 1'bx;
					SignOrZero = 1'b1;
					ALUSrc = 1'b1;
					RegDst = 1'b0;
					VarOrShamt = 1'b1;
				end
		`SW:	begin
					RegWrite = 1'b0;
					Mask = 3'bxxx;
					MemWrite = 2'b11;
					MemtoReg = 1'bx;
					SignOrZero = 1'b1;
					ALUSrc = 1'b1;
					RegDst = 1'b0;
					VarOrShamt = 1'b1;
				end
		 
		 // I-type Computational Instructions
		 `ADDIU:	begin
						RegWrite = 1'b1;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'b0;
						SignOrZero = 1'b1;
						ALUSrc = 1'b1;
						RegDst = 1'b0;
						VarOrShamt = 1'b1;
					end
		 `LUI:	begin
						RegWrite = 1'b1;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'b0;
						SignOrZero = 1'bx;	//TODO: is 1'bx ok here?
						ALUSrc = 1'b1;
						RegDst = 1'b0;
						VarOrShamt = 1'b1;
					end
		 `SLTI:	begin
						RegWrite = 1'b1;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'b0;
						SignOrZero = 1'b1;
						ALUSrc = 1'b1;
						RegDst = 1'b0;
						VarOrShamt = 1'b1;
					end
		 `SLTIU:	begin
						RegWrite = 1'b1;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'b0;
						SignOrZero = 1'b1;
						ALUSrc = 1'b1;
						RegDst = 1'b0;
						VarOrShamt = 1'b1;
					end
		 `ANDI:	begin
						RegWrite = 1'b1;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'b0;
						SignOrZero = 1'b0;
						ALUSrc = 1'b1;
						RegDst = 1'b0;
						VarOrShamt = 1'b1;
					end
		 `ORI:	begin
						RegWrite = 1'b1;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'b0;
						SignOrZero = 1'b0;
						ALUSrc = 1'b1;
						RegDst = 1'b0;
						VarOrShamt = 1'b1;
					end
		 `XORI:	begin
		 				RegWrite = 1'b1;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'b0;
						SignOrZero = 1'b0;
						ALUSrc = 1'b1;
						RegDst = 1'b0;
						VarOrShamt = 1'b1;
					end
					
		// R-type Computational Instructions
		 `RTYPE:	begin
						case (funct)
							`SLLV, `SRLV, `SRAV, `ADDU, `SUBU, `AND, `OR, `XOR, `NOR, `SLT, `SLTU:	begin
								//SLLV, SRLV, SRAV, ADDU, SUBU, AND, OR, XOR, NOR, SLT, SLTU. They use value from RegisterFile
								RegWrite = 1'b1;
								Mask = 3'bxxx;
								MemWrite = 2'b00;
								MemtoReg = 1'b0;
								SignOrZero = 1'bx;
								ALUSrc = 1'b0;
								RegDst = 1'b1;
								VarOrShamt = 1'b1;
							end
							
							`SLL, `SRL, `SRA:	begin
								//SLL, SRL, SRA. They use shamt
								RegWrite = 1'b1;
								Mask = 3'bxxx;
								MemWrite = 2'b00;
								MemtoReg = 1'b0;
								SignOrZero = 1'bx;
								ALUSrc = 1'b0;
								RegDst = 1'b1;
								VarOrShamt = 1'b0;
							end
						endcase
					end

					
		 default:	begin
					//TODO: add default values for all signals
					RegWrite = 1'b0;
					Mask = 3'bxxx;
					MemWrite = 2'b00;
					MemtoReg = 1'bx;		//TODO: put don't care or 0 or 1?
					SignOrZero = 1'bx;
					ALUSrc = 1'bx;
					RegDst = 1'bx;
					VarOrShamt = 1'bx;
		 end
		 
		 
	endcase
end

endmodule
