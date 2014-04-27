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
wire				SignOrZero;
wire				ALUSrc;
wire				RegDst;
wire				VarOrShamt;
wire	[2:0]		BranchCtrl;
wire				Jump;
wire				JAL;
wire				JLink;
wire				JumpReg;
wire				DataInReady;
wire				DataOutValid;
wire	[7:0]		DataOut;
wire	[31:0]	ForwardBOutX;
wire	[3:0]		StoreMaskX;
wire	[3:0]		StoreMaskDMEMX;
wire	[3:0]		StoreMaskIMEMX;
wire				LoadDMEMorIOX;
wire	[31:0]	DataFromIOX;
wire				DataOutReady;
wire	[7:0]		DataToIO;
wire	[31:0]	ALUOutX;

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
	.SignOrZero	(SignOrZero),
	.ALUSrc		(ALUSrc),
	.RegDst		(RegDst),
	.VarOrShamt	(VarOrShamt),
	.BranchCtrl	(BranchCtrl),
	.Jump			(Jump),
	.JAL			(JAL),
	.JLink		(JLink),
	.JumpReg		(JumpReg),
	.ForwardBOutX		(ForwardBOutX),
	.StoreMaskX		(StoreMaskX),
	.StoreMaskDMEMX		(StoreMaskDMEMX),
	.StoreMaskIMEMX		(StoreMaskIMEMX),
	.LoadDMEMorIOX		(LoadDMEMorIOX),
	.DataFromIOX		(DataFromIOX),
	.ALUOutX				(ALUOutX),
	.DataOutValid		(DataOutValid),
	.DataInValid		(DataInValid)
);


//instantiate control unit
MIPS150_control mips_control(
	 .Instr			(Instr),
	 .ALUControl	(ALUControl),
	 .RegWrite		(RegWrite),
	 .Mask			(Mask),
	 .MemWrite		(MemWrite),
	 .MemtoReg		(MemtoReg),
	 .SignOrZero	(SignOrZero),
	 .ALUSrc			(ALUSrc),
	 .RegDst			(RegDst),
	 .VarOrShamt	(VarOrShamt),
	 .BranchCtrl	(BranchCtrl),
	 .Jump			(Jump),
	 .JAL				(JAL),
	 .JLink			(JLink),
	 .JumpReg		(JumpReg)
);

//instantiate UART
UART	mips_uart(
	 .Clock			(clk),
	 .Reset			(rst),
	 .DataIn			(DataToIO),
	 .DataInValid	(DataInValid),
	 .DataInReady	(DataInReady),
	 .DataOut		(DataOut),
	 .DataOutValid	(DataOutValid),
	 .DataOutReady	(DataOutReady),
	 .SIn				(FPGA_SERIAL_RX),
	 .SOut			(FPGA_SERIAL_TX)
);


//instantiate Memory Map
MemoryMap mips_memmap(
	.StoreMask		(StoreMaskX),
	.MemMapAddress	(ALUOutX),
	.DataInReady	(DataInReady),
	.DataOutValid	(DataOutValid),
	.DataOut			(DataOut),
	.StoreMaskDMEM	(StoreMaskDMEMX),
	.StoreMaskIMEM	(StoreMaskIMEMX),
	.LoadDMEMorIO	(LoadDMEMorIOX),
	.DataFromIO		(DataFromIOX),
	.DataInValid	(DataInValid),
	.DataOutReady	(DataOutReady),
	.DataToIO		(DataToIO),
	.IODataFromCPU	(ForwardBOutX[7:0]),
	.Instr			(Instr)
);


endmodule
