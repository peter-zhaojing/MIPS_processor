module MIPS150(
	input 	clk, rst,
	input		FPGA_SERIAL_RX,
	output	FPGA_SERIAL_TX
);

// Use this as the top-level module for your CPU. You
// will likely want to break control and datapath out
// into separate modules that you instantiate here.

//declare signals for connection
wire	[31:0]	Instr;
wire	[3:0]		ALUControl;
wire				RegWrite;
wire	[2:0]		Mask;
wire  [1:0]		MemWrite;
wire				MemtoReg;
wire				LUItoReg;
wire				SignOrZero;
wire				ALUSrc;
wire				RegDst;

//instantiate datapath
MIPS150_datapath mips_datapath(
	.clk			(clk),
	.rst			(rst),
	.Instr		(Instr),
	.ALUControl	(ALUControl),
	.RegWrite	(RegWrite),
	.Mask			(Mask),
	.MemWrite	(MemWrite),
	.MemtoReg	(MemtoReg),
	.LUItoReg	(LUItoReg),
	.SignOrZero	(SignOrZero),
	.ALUSrc		(ALUSrc),
	.RegDst		(RegDst)
);


//instantiate control unit
MIPS150_control mips_control(
	 .Instr			(Instr),
	 .ALUControl	(ALUControl),
	 .RegWrite		(RegWrite),
	 .Mask			(Mask),
	 .MemWrite		(MemWrite),
	 .MemtoReg		(MemtoReg),
	 .LUItoReg		(LUItoReg),
	 .SignOrZero	(SignOrZero),
	 .ALUSrc			(ALUSrc),
	 .RegDst			(RegDst)
);

endmodule
