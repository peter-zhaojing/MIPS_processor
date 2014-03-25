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
	 input	[2:0]		Mask,
	 input	[1:0]		MemWrite,
	 input				MemtoReg,
	 input				LUItoReg,
	 input				SignOrZero,
	 input				ALUSrc,
	 input				RegDst,
	 input				VarOrShamt,
	 input	[2:0]		BranchCtrl
    );

/**********************************************************/
//signal declaration
/**********************************************************/

//I stage
wire	[31:0]	InstrI;	
reg	[31:0]	PC_OUT;
wire	[31:0]	PC_IN;
wire	[31:0]	PCPlus4I;
reg				PCStarterI;


//X stage
reg	[31:0]	InstrX;
wire				RegWriteX;
wire	[4:0]		WriteRegX;
wire	[31:0]	RFout1, RFout2;
wire	[31:0]	ALUOutX;
wire	[3:0]		ALUControlX;
wire	[31:0]	SrcAX, SrcBX;
wire	[1:0]		ByteAddrX;
wire	[2:0]		MaskX;
wire	[1:0]		MemWriteX;
reg	[3:0]		StoreMaskX;
wire	[3:0]		StoreMaskDMEMX;
wire	[3:0]		StoreMaskIMEMX;
wire	[3:0]		StoreMaskIOX;
wire				LoadDMEMorIOX;
wire				MemtoRegX;
wire				LUItoRegX;
wire	[31:0]	SignOutImmX;
wire	[31:0]	ZeroOutImmX;
wire				SignOrZeroX;
wire	[31:0]	PostSorZImmX;
wire				ALUSrcX;
wire				RegDstX;
wire				VarOrShamtX;
wire				ForwardAX;
wire				ForwardBX;
wire	[31:0]	ForwardAOutX;
wire	[31:0]	ForwardBOutX;
wire	[2:0]		BranchCtrlX;
reg	[31:0]	PCPlus4X;
wire	[31:0]	PCBranchX;

//M stage
reg				RegWriteM;
reg	[4:0]		WriteRegM;
wire	[31:0]	ResultM;
reg	[31:0]	ALUOutM;
wire   [31:0]	ALUOutPadding;
reg				tempRegWriteM;
reg	[3:0]		tempWriteRegM;
wire	[31:0]	ReadDataM;
reg	[2:0]		MaskM;
reg	[31:0]	MaskOutM;
reg	[1:0]		ByteAddrM;
reg				LoadDMEMorIOM;
wire	[31:0]	ResultDMEMorIOM;
wire	[31:0]	DataFromIOM;				//dummy data from IO
reg				MemtoRegM;
reg				PCSrcX;

/**********************************************************/
//Connecting signals to module port
/**********************************************************/
assign Instr			= InstrX;
assign ALUControlX	= ALUControl;
assign RegWriteX		= RegWrite;
assign MaskX			= Mask;
assign MemWriteX		= MemWrite;
assign MemtoRegX		= MemtoReg;
assign LUItoRegX		= LUItoReg;
assign SignOrZeroX	= SignOrZero;
assign ALUSrcX			= ALUSrc;
assign RegDstX			= RegDst;
assign VarOrShamtX	= VarOrShamt;
assign BranchCtrlX	= BranchCtrl;

//assign DataFromIOM	= 32'hf0f0f0f0;				//assign dummy data from IO
assign DataFromIOM	= 32'h00f0f0f0;				//assign dummy data from IO

/**********************************************************/
//I stage datapath
/**********************************************************/

//model PCStarter
always@(posedge clk) begin
	if(rst)	PCStarterI	<= 1'b0;
	else		PCStarterI	<= 1'b1;
end


//model PC
always@(posedge clk)	begin
	if(rst)	PC_OUT	<=	32'h0000_0000;
	else		PC_OUT	<=	PC_IN;
end

assign PCPlus4I = PC_OUT + 32'd4;

//model PC+4
assign PC_IN = (PCSrcX & PCStarterI) ? PCBranchX : PCPlus4I;

//instantiate IMEM
IMEM_blk_ram	MIPS150_imem(
	.clka		(clk),
	.ena		(~rst),						//Port Clock Enable (ena)
	.wea		(StoreMaskIMEMX),					//Port A Write Enable. Used to change contents that stored in IMEM?
	.addra	(ALUOutX[13:2]),					//Write Address, 12 bits wide
	.dina		(RFout2),			//The contents to be written, 32 bits wide
	.clkb		(clk),
	.enb		(~rst),
	.addrb	(PC_OUT[13:2]),			//addrb is 12 bits. One instruction takes one word (4 bytes), so the address is 0,4,8,12...Therefore, not need the two LSBs
	.doutb	(InstrI)
);

/***********************************************************/
//X stage datapath
/***********************************************************/
 
//instantiate Register File
 (* ram_style = "distributed" *) RegFile MIPS150_regfile(		//Peter: force synthesizer tool to use "distributed" ram
	.clk		(clk),			
   .we		(RegWriteM),
   .ra1		(InstrX[25:21]),
   .ra2		(InstrX[20:16]),		//used for "Store"
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

//model Sign Extension
assign SignOutImmX = {{16{InstrX[15]}},InstrX[15:0]};

//model Zero Extension
assign ZeroOutImmX = {16'b0,InstrX[15:0]};

//model Mux to choose Sign Extension or Zero Extension
assign PostSorZImmX = SignOrZeroX ? SignOutImmX : ZeroOutImmX;


//model Mux to choose SrcA from RegisterFile or Shamt
//assign SrcAX = RFout1
assign SrcAX = VarOrShamtX ? ForwardAOutX : InstrX[10:6];


//assign SrcBX = RFout2;
//assign SrcBX = PostSorZImmX;
//model Mux to choose SrcB from Imm or RegisterFile
assign SrcBX = ALUSrcX ? PostSorZImmX : ForwardBOutX;


//model two MUXs for Data Forwarding
assign ForwardAOutX = ForwardAX ?	ALUOutM : RFout1;
assign ForwardBOutX = ForwardBX ?	ALUOutM : RFout2;


//model Branch Detection circuit
always @(*) begin
	case (BranchCtrlX)
		3'b000:	PCSrcX = (ALUOutX == 32'h0000_0000);			//BEQ
		3'b001:	PCSrcX = (ALUOutX != 32'h0000_0000);			//BNE
		3'b010:	PCSrcX = ($signed(SrcAX) <= 32'h0000_0000);	//BLEZ
		3'b011:	PCSrcX = ($signed(SrcAX) > 32'h0000_0000);	//BGTZ
		3'b100:	PCSrcX = ($signed(SrcAX) < 32'h0000_0000);	//BLTZ
		3'b101:	PCSrcX = ($signed(SrcAX) >= 32'h0000_0000);	//BGEZ
		default:	PCSrcX = 1'b0;
	endcase
end

//model Branch Address
assign PCBranchX = PCPlus4X + (SignOutImmX << 2'd2);


//Register write address
//assign WriteRegX = InstrX[20:16];
//model Mux to choose write address. For R-type, choose InstrX[15:11]. For I-type, choose InstrX[20:16]
assign WriteRegX = RegDstX ? InstrX[15:11] : InstrX[20:16];


//For Byte, Half, Word, Address is same at this point because DMEM is word-addressable. Masks will be applied on Dout to address BYTE, HALF or WORD
//assign ALUOutPadding = {ALUOutX[31:2],2'b0};

assign ByteAddrX = ALUOutX[1:0];

/*********************/
//MemAlign 00 => Byte
//MemAlign 01 => Half
//MemAlign 10 => Word
/*********************/
/*
always@(*) begin
	case(MemAlignX)
		2'b00:	ALUOutPadding = ALUOutX;
		2'b01:	ALUOutPadding = {ALUOutX[31:1],1'b0};
		2'b10:	ALUOutPadding = {ALUOutX[31:2],2'b0};
		default: ALUOutPadding = 32'bx;
	endcase
end
*/

//For "Store", generate WEA bus
always@(*)	begin
	case(MemWriteX)
		2'b00:	StoreMaskX = 4'b0000;		//Not "Store" Instr
		
		2'b01:	begin								//SB
			if(ByteAddrX[1:0] == 2'b00)			StoreMaskX = 4'b1000;		//byte0
			else if(ByteAddrX[1:0] == 2'b01)		StoreMaskX = 4'b0100;		//byte1
			else if(ByteAddrX[1:0] == 2'b10)		StoreMaskX = 4'b0010;		//byte2
			else if(ByteAddrX[1:0] == 2'b11)		StoreMaskX = 4'b0001;		//byte3
		end
		
		2'b10:	begin								//SH
			if(ByteAddrX[1] == 1'b0)				StoreMaskX = 4'b1100;
			else if(ByteAddrX[1] == 1'b1)			StoreMaskX = 4'b0011;
		end
		
		2'b11:	begin								//SW
			StoreMaskX = 4'b1111;
		end
		
	endcase
end


//instantiate Memory Map
MemoryMap MIPS150_memmap(
	.StoreMask			(StoreMaskX),
	.TopAddr				(ALUOutX[31:28]),
	.StoreMaskDMEM		(StoreMaskDMEMX),
	.StoreMaskIMEM		(StoreMaskIMEMX),
	.StoreMaskIO		(StoreMaskIOX),
	.LoadDMEMorIO		(LoadDMEMorIOX)
);


/***********************************************************/
//M stage datapath
/***********************************************************/

//instantiate DMEM
DMEM_blk_ram MIPS150_dmem(
	.clka		(clk),
	.ena		(1'b1),						//Port Clock Enable (ena) is kinda global enable. If desserted, no Read, Write, or Reset operation are performed on the port
	.wea		(StoreMaskDMEMX),				//Port A Write Enable. This is the write_enble. It's a bus, each bit correponds one byte. dina is 4 bytes, wea = 4
	.addra	(ALUOutX[13:2]),			//The two LSB are 0, don't parse as address. Actually no need padding, just use ALUOutX[13:2]
	.dina		(RFout2),					//Used for "Store"
	.douta	(ReadDataM)
);


//Sign or Zero extention, chopping DMEM output
//Mask order: LB, LH, LW, LBU, LHU
//RAM is big-endian!
//TODO: maybe need to improve the code in order to get simpler circuit?
always@(*)	begin
	case(MaskM)
		3'b000:			begin		//LB
			if		  (ByteAddrM == 2'b00)	MaskOutM = {{24{ReadDataM[31]}},ReadDataM[31:24]};	//Byte0
			else if (ByteAddrM == 2'b01)	MaskOutM = {{24{ReadDataM[23]}},ReadDataM[23:16]};	//Byte1
			else if (ByteAddrM == 2'b10)	MaskOutM = {{24{ReadDataM[15]}},ReadDataM[15:8]};	//Byte2
			else if (ByteAddrM == 2'b11)	MaskOutM = {{24{ReadDataM[7]}},ReadDataM[7:0]};	//Byte3
		end
		3'b001:			begin		//LH
			if			(ByteAddrM[1] == 1'b0)	MaskOutM = {{16{ReadDataM[31]}},ReadDataM[31:16]};	//Half 0
			else if	(ByteAddrM[1] == 1'b1)	MaskOutM = {{16{ReadDataM[15]}},ReadDataM[15:0]};	//Half 1
		end
		3'b010:		MaskOutM = ReadDataM;	//LW
		3'b011:			begin		//LBU
			if		  (ByteAddrM == 2'b00)	MaskOutM = {24'b0,ReadDataM[31:24]};	//Byte0
			else if (ByteAddrM == 2'b01)	MaskOutM = {24'b0,ReadDataM[23:16]};	//Byte1
			else if (ByteAddrM == 2'b10)	MaskOutM = {24'b0,ReadDataM[15:8]};	//Byte2
			else if (ByteAddrM == 2'b11)	MaskOutM = {24'b0,ReadDataM[7:0]};	//Byte3
		end
		3'b100:			begin		//LHU
			if			(ByteAddrM[1] == 1'b0)	MaskOutM = {16'b0,ReadDataM[31:16]};	//Half 0
			else if	(ByteAddrM[1] == 1'b1)	MaskOutM = {16'b0,ReadDataM[15:0]};	//Half 1
		end
		default:		MaskOutM = 32'bx;
	endcase
end


//Write back to Register File
//ResultM has already connected to Register File via RegFile instantiation
//One MUX used to select sigals from DMEM or IO
assign ResultDMEMorIOM = LoadDMEMorIOM? DataFromIOM : MaskOutM;

//Another MUX used to select signal from DMEM/IO or ALUOutM
assign ResultM = MemtoRegM? ResultDMEMorIOM : ALUOutM;


/***********************************************************/
//Hazard Unit
/***********************************************************/
HazardUnit MIPS150_hazardunit(
	.Rs			(InstrX[25:21]),
	.Rt			(InstrX[20:16]),
	.RegWrite	(RegWriteM),
	.WriteReg	(WriteRegM),
	.ForwardA	(ForwardAX),
	.ForwardB	(ForwardBX)
);


/***********************************************************/
//I-X Pipeline Register
/***********************************************************/
always@(posedge clk)	begin
	if(!rst)	begin
		InstrX	<=	InstrI;
		PCPlus4X <= PCPlus4I;
	end
end

/***********************************************************/
//X-M Pipeline Register
/***********************************************************/
always@(posedge clk) begin
	if(!rst)	begin
		RegWriteM		<=	RegWriteX;
		WriteRegM		<=	WriteRegX;
		ByteAddrM		<= ByteAddrX;
		MaskM				<= MaskX;
		LoadDMEMorIOM 	<= LoadDMEMorIOX;
		MemtoRegM		<= MemtoRegX;
		ALUOutM			<= ALUOutX;
	end
end

endmodule
