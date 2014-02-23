`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:02:16 02/17/2014 
// Design Name: 
// Module Name:    MIPS150_datapath 
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
module MIPS150_datapath(
    input 				clk,
    input 				rst,
	 output	[31:0]	Instr,
	
	 //Control Signals
	 input	[3:0]		ALUControl,
	 input				RegWrite,
	 input	[1:0]		MemAlign,
	 input	[2:0]		SignZeroChop
    );

/**********************************************************/
//signal declaration
/**********************************************************/

//I stage
wire	[31:0]	InstrI;	
reg	[31:0]	PC_OUT;
wire	[31:0]	PC_IN;


//X stage
wire	[31:0]	InstrX;
wire				RegWriteX;
wire	[4:0]		WriteRegX;
wire	[31:0]	RFout1, RFout2;
wire	[31:0]	ALUOutX;
wire	[3:0]		ALUControlX;
wire	[31:0]	SrcAX, SrcBX;
wire  [1:0]		MemAlignX;

//M stage
reg				RegWriteM;
reg	[4:0]		WriteRegM;
wire	[31:0]	ResultM;
reg	[31:0]	ALUOutM;
reg   [31:0]	ALUOutPadding;
reg				tempRegWriteM;
reg	[3:0]		tempWriteRegM;
wire	[31:0]	ReadDataM;
wire	[2:0]		SignZeroChopM;
reg	[31:0]	SignZeroExDMEM;

/**********************************************************/
//Connecting signals to module port
/**********************************************************/
assign Instr			= InstrX;
assign ALUControlX	= ALUControl;
assign RegWriteX		= RegWrite;
assign MemAlignX		= MemAlign;
assign SignZeroChopM	= SignZeroChop;


/**********************************************************/
//I stage datapath
/**********************************************************/

//model PC
always@(posedge clk)
	if(rst)	PC_OUT	<=	32'h0000_0000;
	else		PC_OUT	<=	PC_IN;

//model PC+4
assign PC_IN = PC_OUT + 32'd4;

//instantiate IMEM
IMEM_blk_ram	MIPS150_imem(
	.clka		(clk),
	.ena		(1'b1),					//Port Clock Enable (ena)
	.wea		(4'b0000),					//Port A Write Enable. Used to change contents that stored in IMEM?
	.addra	(12'h000),					//Write Address, 12 bits wide
	.dina		(32'h0000_0000),					//The contents to be written, 32 bits wide
	.clkb		(clk),
	.addrb	(PC_OUT[13:2]),	//addrb is 12 bits. One instruction takes one word (4 bytes), so the address is 0,4,8,12...Therefore, not need the two LSBs
	.doutb	(InstrX)
);


/***********************************************************/
//X stage datapath
/***********************************************************/
 
//instantiate Register File
 (* ram_style = "distributed" *) RegFile MIPS150_regfile(		//Peter: force synthesizer tool to use "distributed" ram
	.clk		(clk),			
   .we		(RegWriteM),
   .ra1		(InstrX[25:21]),
   .ra2		(),						//not used for "Load"
   .wa		(WriteRegM),
   .wd		(ResultM),				//Write back
   .rd1		(RFout1),
   .rd2		(RFout2)
);

//instantiate ALU
ALU MIPS150_alu(
    .A		(SrcAX),
	 .B		(SrcBX),
    .ALUop	(ALUControlX),
    .Out		(ALUOutX)
);

assign SrcAX = RFout1;
//assign SrcBX = RFout2;

//model Sign Extention
assign SrcBX = {{16{InstrX[15]}},InstrX[15:0]};

assign WriteRegX = InstrX[20:16];


//For Byte, Half, Word, ALUOutPadding is different

/*********************/
//MemAlign 00 => Byte
//MemAlign 01 => Half
//MemAlign 10 => Word
/*********************/
always@(*) begin
	case(MemAlignX)
		2'b00:	ALUOutPadding = ALUOutX;
		2'b01:	ALUOutPadding = {ALUOutX[31:1],1'b0};
		2'b10:	ALUOutPadding = {ALUOutX[31:2],2'b0};
		default: ALUOutPadding = 32'bx;
	endcase
end


/***********************************************************/
//M stage datapath
/***********************************************************/

//instantiate DMEM
DMEM_blk_ram MIPS150_dmem(
	.clka		(clk),
	.ena		(1'b1),							//Port Clock Enable (ena) is kinda global enable. If desserted, no Read, Write, or Reset operation are performed on the port
	.wea		(),							//Port A Write Enable. This is the write_enble. It's a bus, each bit correponds one byte. dina is 4 bytes, wea = 4
	.addra	(ALUOutPadding[11:0]),	//TODO: let's put 11:0 first
	.dina		(),							//Not used for "Load"
	.douta	(ReadDataM)
);


//Sign or Zero extention, chopping DMEM output
always@(*)	begin
	case(SignZeroChopM)
		3'b000:			SignZeroExDMEM = {{24{ReadDataM[7]}},ReadDataM[7:0]};
		3'b001:			SignZeroExDMEM = {{16{ReadDataM[7]}},ReadDataM[15:0]};
		3'b010:			SignZeroExDMEM = ReadDataM;
		3'b011:			SignZeroExDMEM = {24'b0,ReadDataM[7:0]};
		3'b100:			SignZeroExDMEM = {16'b0,ReadDataM[15:0]};
		default:			SignZeroExDMEM = 32'bx;
	endcase
end

//Write back to Register File
//ResultM has already connected to Register File via RegFile instantiation
assign ResultM = SignZeroExDMEM;


/***********************************************************/
//I-X Pipeline Register
/***********************************************************/

/*
always@(posedge clk)	begin
	if(!rst)	InstrX	<=	InstrI;
end
*/

/***********************************************************/
//X-M Pipeline Register
/***********************************************************/
always@(posedge clk) begin
	if(!rst)	begin
		RegWriteM	<=	RegWriteX;
		WriteRegM	<=	WriteRegX;
	end
end

endmodule
