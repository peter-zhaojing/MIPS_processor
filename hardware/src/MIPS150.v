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


//instantiate datapath
MIPS150_datapath mips_datapath(
	.clk			(clk),
	.rst			(rst),
	.Instr		(Instr),
	.ALUControl	(ALUControl),
	.RegWrite	(RegWrite)
);


//instantiate control unit
MIPS150_control mips_control(
	 .Instr			(Instr),
	 .ALUControl	(ALUControl),
	 .RegWrite		(RegWrite)
);

endmodule
