// UC Berkeley CS150
// Lab 3, Spring 2012
// Module: ALU.v
// Desc:   32-bit ALU for the MIPS150 Processor
// Inputs: A: 32-bit value
// B: 32-bit value
// ALUop: Selects the ALU's operation 
// 						
// Outputs:
// Out: The chosen function mapped to A and B.

`include "Opcode.vh"
`include "ALUop.vh"

module ALU(
    input [31:0] A,B,
    input [3:0] ALUop,			//Peter: 1/21/2013 ALUop is not the same as in the textbook, in book it should be 2 bits. 1/19/2014: I think ALUop here is not same thing in the textbook. ALUop here means ALU control lines in the textbook
    output reg [31:0] Out
);

//Peter: implement ALU
always@(*)	begin
	case(ALUop)
		`ALU_ADDU:		Out = A + B;
		`ALU_SUBU:		Out = A - B;
		`ALU_SLT:		Out = (A < B)? 16'h0001 : 16'h0000;		//Peter: Set on less than (signed)
		`ALU_SLTU:		Out = (A < B)? 16'h0001 : 16'h0000;		//Peter: Set on less than unsigned
		`ALU_AND:		Out = A & B;
		`ALU_OR:		Out = A | B;
		`ALU_XOR:		Out = A ^ B;
		`ALU_LUI:		Out = A << B;							//Peter: not sure!! Load upper immediate
		`ALU_SLL:		Out = A << B;							//Peter: not sure!! Shift left logical, sll $d, $t, h ($d = $t << h)
		`ALU_SRL:		Out = A >> B;							//Peter: not sure!! Shift right logical. Zeroes are shifted in.
																
																//Don¡¯t worry about sign extensions, they should take place outside of the ALU.
		`ALU_SRA:		Out = A >> B;							//Peter: not sure!! Shift right arithmetic. The sign bit is shifted in.
		`ALU_NOR:		Out = ~(A | B);
		default:		Out = 32'bx;
	endcase

end


endmodule
