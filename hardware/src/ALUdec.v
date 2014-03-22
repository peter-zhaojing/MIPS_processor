// UC Berkeley CS150
// Lab 3, Spring 2012
// Module: ALUdecoder
// Desc:   Sets the ALU operation
// Inputs: opcode: the top 6 bits of the instruction
//         funct: the funct, in the case of r-type instructions
// Outputs: ALUop: Selects the ALU's operation

`include "Opcode.vh"
`include "ALUop.vh"

module ALUdec(
  input [5:0] funct, opcode,
  output reg [3:0] ALUop		//Peter: ALUop is not the same as in the textbook! in book, it should be 2 bits. 1/19/2014: I think ALUop here is not same thing in the textbook. ALUop here means ALU control lines in the textbook
);
 
  //Peter: 1/21/2013
  always@(*) begin
	case(opcode)
		`RTYPE:		begin		//Peter: 1/21/2013, use macro, defined in Opcode.vh(the header file)
			/*
			1/19/2014
			sll	 Shift left logical by a constant number of bits
			sllv	 Shift left logical by a variable number of bits
			srl	 Shift right logical by a constant number of bits
			srlv	 Shift right logical by a variable number of bits
			sra	 Shift right arithmetic by a constant number of bits
			srav	 Shift right arithmetic by a variable number of bits
			*/
			case(funct)
				`SLL:		ALUop = `ALU_SLL;
				`SRL:		ALUop = `ALU_SRL;
				`SRA:		ALUop = `ALU_SRA;
				`SLLV:		ALUop = `ALU_SLL;		//Peter: not sure. 1/19/2014, should be correct
				`SRLV:		ALUop = `ALU_SRL;		//Peter: not sure. 1/19/2014, should be correct
				`SRAV:		ALUop = `ALU_SRA;		//Peter: not sure. 1/19/2014, should be correct
				`ADDU:		ALUop = `ALU_ADDU;
				`SUBU:		ALUop = `ALU_SUBU;
				`AND:		ALUop = `ALU_AND;
				`OR:		ALUop = `ALU_OR;
				`XOR:		ALUop = `ALU_XOR;
				`NOR:		ALUop = `ALU_NOR;
				`SLT:		ALUop = `ALU_SLT;
				`SLTU:		ALUop = `ALU_SLTU;
				default:	ALUop = 4'bx;
			endcase
		end
		
		// Load/store
		`LB,`LH,`LW,`LBU,`LHU,`SB,`SH,`SW:		ALUop = `ALU_ADDU;
		
		// I-type
		`ADDIU:		ALUop = `ALU_ADDU;
		`SLTI:		ALUop = `ALU_SLT;
		`SLTIU:		ALUop = `ALU_SLTU;
		`ANDI:		ALUop = `ALU_AND;
		`ORI:			ALUop = `ALU_OR;
		`XORI:		ALUop = `ALU_XOR;
		`LUI:			ALUop = `ALU_LUI;			//Peter: Load upper immediate; The immediate value is shifted left 16 bits and stored in the register. The lower 16 bits are zeroes.
		default:		ALUop = 4'bx;
	endcase
  
  end

    // Implement your ALU decoder here, then delete this comment

endmodule
