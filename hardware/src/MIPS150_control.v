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
	 output	reg			VarOrShamt,
	 output	reg [2:0]	BranchCtrl,
	 output	reg			Jump,
	 output	reg			JAL,
	 output	reg			JumpReg,
	 output	reg			JLink
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
					BranchCtrl = 3'bxxx;		//in datapath, this signal generates PCSrc
					Jump = 1'b0;
					JAL = 1'b0;
					JLink = 1'b0;								
					JumpReg = 1'bx;
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
					BranchCtrl = 3'bxxx;
					Jump = 1'b0;
					JAL = 1'b0;
					JLink = 1'b0;								
					JumpReg = 1'bx;
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
					BranchCtrl = 3'bxxx;
					Jump = 1'b0;
					JAL = 1'b0;
					JLink = 1'b0;								
					JumpReg = 1'bx;
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
					BranchCtrl = 3'bxxx;
					Jump = 1'b0;
					JAL = 1'b0;
					JLink = 1'b0;					
					JumpReg = 1'bx;
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
					BranchCtrl = 3'bxxx;
					Jump = 1'b0;
					JAL = 1'b0;
					JLink = 1'b0;						
					JumpReg = 1'bx;
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
					BranchCtrl = 3'bxxx;
					Jump = 1'b0;
					JAL = 1'bx;
					JLink = 1'bx;
					JumpReg = 1'bx;
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
					BranchCtrl = 3'bxxx;
					Jump = 1'b0;
					JAL = 1'bx;
					JLink = 1'bx;
					JumpReg = 1'bx;
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
					BranchCtrl = 3'bxxx;
					Jump = 1'b0;
					JAL = 1'bx;
					JLink = 1'bx;								
					JumpReg = 1'bx;
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
						BranchCtrl = 3'bxxx;
						Jump = 1'b0;
						JAL = 1'b0;
						JLink = 1'b0;
						JumpReg = 1'bx;
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
						BranchCtrl = 3'bxxx;
						Jump = 1'b0;
						JAL = 1'b0;
						JLink = 1'b0;								
						JumpReg = 1'bx;
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
						BranchCtrl = 3'bxxx;
						Jump = 1'b0;
						JAL = 1'b0;
						JLink = 1'b0;
						JumpReg = 1'bx;
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
						BranchCtrl = 3'bxxx;
						Jump = 1'b0;
						JAL = 1'b0;
						JLink = 1'b0;
						JumpReg = 1'bx;
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
						BranchCtrl = 3'bxxx;
						Jump = 1'b0;
						JAL = 1'b0;
						JLink = 1'b0;
						JumpReg = 1'bx;
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
						BranchCtrl = 3'bxxx;
						Jump = 1'b0;
						JAL = 1'b0;
						JLink = 1'b0;
						JumpReg = 1'bx;
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
						BranchCtrl = 3'bxxx;
						Jump = 1'b0;
						JAL = 1'b0;
						JLink = 1'b0;
						JumpReg = 1'bx;
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
								BranchCtrl = 3'bxxx;
								Jump = 1'b0;
								JAL = 1'b0;
								JLink = 1'b0;
								JumpReg = 1'bx;
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
								BranchCtrl = 3'bxxx;
								Jump = 1'b0;
								JAL = 1'b0;
								JLink = 1'b0;
								JumpReg = 1'bx;
							end
							
							`JR:	begin
								RegWrite = 1'b0;
								Mask = 3'bxxx;
								MemWrite = 2'b00;
								MemtoReg = 1'bx;
								SignOrZero = 1'bx;
								ALUSrc = 1'bx;
								RegDst = 1'bx;
								VarOrShamt = 1'b1;
								BranchCtrl = 3'bxxx;
								Jump = 1'b1;
								JAL = 1'bx;
								JLink = 1'bx;
								JumpReg = 1'b1;
							end
							
							`JALR:	begin
								RegWrite = 1'b1;
								Mask = 3'bxxx;
								MemWrite = 2'b00;
								MemtoReg = 1'bx;
								SignOrZero = 1'bx;
								ALUSrc = 1'bx;
								RegDst = 1'b1;
								VarOrShamt = 1'b1;
								BranchCtrl = 3'bxxx;
								Jump = 1'b1;
								JAL = 1'b0;
								JLink = 1'b1;
								JumpReg = 1'b1;
							end
							
							
							default:	begin
								RegWrite = 1'b0;
								Mask = 3'bxxx;
								MemWrite = 2'b00;
								MemtoReg = 1'bx;
								SignOrZero = 1'bx;
								ALUSrc = 1'bx;
								RegDst = 1'bx;
								VarOrShamt = 1'bx;
								BranchCtrl = 3'bxxx;
								Jump = 1'b0;
								JAL = 1'bx;
								JLink = 1'bx;
								JumpReg = 1'bx;
							end
						endcase
					end
		
		// Jump and Branch Instructions
		 `BEQ:	begin
						RegWrite = 1'b0;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'bx;
						SignOrZero = 1'bx;
						ALUSrc = 1'b0;
						RegDst = 1'bx;
						VarOrShamt = 1'b1;
						BranchCtrl = 3'b000;
						Jump = 1'b0;
						JAL = 1'bx;
						JLink = 1'bx;
						JumpReg = 1'bx;						
					end
		 `BNE:	begin
						RegWrite = 1'b0;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'bx;
						SignOrZero = 1'bx;
						ALUSrc = 1'b0;
						RegDst = 1'bx;
						VarOrShamt = 1'b1;
						BranchCtrl = 3'b001;
						Jump = 1'b0;
						JAL = 1'bx;
						JLink = 1'bx;
						JumpReg = 1'bx;
					end
		 `BLEZ:	begin
						RegWrite = 1'b0;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'bx;
						SignOrZero = 1'bx;
						ALUSrc = 1'bx;
						RegDst = 1'bx;
						VarOrShamt = 1'b1;
						BranchCtrl = 3'b010;
						Jump = 1'b0;
						JAL = 1'bx;
						JLink = 1'bx;
						JumpReg = 1'bx;
					end		 
		 `BGTZ:	begin
						RegWrite = 1'b0;
						Mask = 3'bxxx;
						MemWrite = 2'b00;
						MemtoReg = 1'bx;
						SignOrZero = 1'bx;
						ALUSrc = 1'bx;
						RegDst = 1'bx;
						VarOrShamt = 1'b1;
						BranchCtrl = 3'b011;
						Jump = 1'b0;
						JAL = 1'bx;
						JLink = 1'bx;
						JumpReg = 1'bx;
					end
		 `REGIMM: begin	//BLTZ abd BGEZ
						case (Instr[20:16])
							`BLTZ:	begin
											RegWrite = 1'b0;
											Mask = 3'bxxx;
											MemWrite = 2'b00;
											MemtoReg = 1'bx;
											SignOrZero = 1'bx;
											ALUSrc = 1'bx;
											RegDst = 1'bx;
											VarOrShamt = 1'b1;
											BranchCtrl = 3'b100;
											Jump = 1'b0;
											JAL = 1'bx;
											JLink = 1'bx;
											JumpReg = 1'bx;
										end
							 `BGEZ:	begin
							 				RegWrite = 1'b0;
											Mask = 3'bxxx;
											MemWrite = 2'b00;
											MemtoReg = 1'bx;
											SignOrZero = 1'bx;
											ALUSrc = 1'bx;
											RegDst = 1'bx;
											VarOrShamt = 1'b1;
											BranchCtrl = 3'b101;
											Jump = 1'b0;
											JAL = 1'bx;
											JLink = 1'bx;
											JumpReg = 1'bx;
										end
							default:	begin
											RegWrite = 1'b0;
											Mask = 3'bxxx;
											MemWrite = 2'b00;
											MemtoReg = 1'bx;
											SignOrZero = 1'bx;
											ALUSrc = 1'bx;
											RegDst = 1'bx;
											VarOrShamt = 1'bx;
											BranchCtrl = 3'bxxx;
											Jump = 1'b0;
											JAL = 1'bx;
											JLink = 1'bx;								
											JumpReg = 1'bx;
										end
						endcase
					 end
					 
		 `J:	begin
					RegWrite = 1'b0;
					Mask = 3'bxxx;
					MemWrite = 2'b00;
					MemtoReg = 1'bx;
					SignOrZero = 1'bx;
					ALUSrc = 1'bx;
					RegDst = 1'bx;
					VarOrShamt = 1'bx;
					BranchCtrl = 3'bxxx;
					Jump = 1'b1;
					JAL = 1'bx;
					JLink = 1'bx;
					JumpReg = 1'b0;
				end
				
		 `JAL: begin
					RegWrite = 1'b1;
					Mask = 3'bxxx;
					MemWrite = 2'b00;
					MemtoReg = 1'bx;
					SignOrZero = 1'bx;
					ALUSrc = 1'bx;
					RegDst = 1'bx;
					VarOrShamt = 1'bx;
					BranchCtrl = 3'bxxx;
					Jump = 1'b1;
					JAL = 1'b1;
					JLink = 1'b1;
					JumpReg = 1'b0;
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
					BranchCtrl = 3'bxxx;
					Jump = 1'b0;
					JAL = 1'bx;
					JLink = 1'bx;
					JumpReg = 1'bx;
		 end
		 
		 
	endcase
end

endmodule
