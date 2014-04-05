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
	 output	reg [3:0]	StoreMaskX,
	 output	[31:0]	ALUOutX,
	 output	[31:0]	ForwardBOutX,
	 input	[3:0]		StoreMaskDMEMX,
	 input	[3:0]		StoreMaskIMEMX,
	 input				LoadDMEMorIOX,
	 input	[31:0]	DataFromIOX,
	
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
	 input	[2:0]		BranchCtrl,
	 input				Jump,
	 input				JAL,
	 input				JLink,
	 input				JumpReg
    );

/**********************************************************/
//signal declaration
/**********************************************************/

//I stage
wire	[31:0]	InstrI;	
reg	[31:0]	PC_OUT;
wire	[31:0]	PC_IN;
wire	[31:0]	PCPlus4I;
reg	[31:0]	PC_OUT_Branch;
reg	[31:0]	PC_OUT_Jump;
reg	[31:0]	PC_OUT_SyncIMEM;

//X stage
reg	[31:0]	InstrX;
wire				RegWriteX;
wire	[4:0]		WriteRegX;
wire	[31:0]	RFout1, RFout2;
//wire	[31:0]	ALUOutX;
wire	[3:0]		ALUControlX;
wire	[31:0]	SrcAX, SrcBX;
wire	[1:0]		ByteAddrX;
wire	[2:0]		MaskX;
wire	[1:0]		MemWriteX;
//reg	[3:0]		StoreMaskX;
//wire	[3:0]		StoreMaskDMEMX;
//wire	[3:0]		StoreMaskIMEMX;
//wire				LoadDMEMorIOX;
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
//wire	[31:0]	ForwardBOutX;
wire	[2:0]		BranchCtrlX;
reg	[31:0]	PC_OUTX;
wire	[31:0]	PCBranchX;
wire				JumpX;
wire	[31:0]	JumpAddrX;
wire				JALX;
wire	[4:0]		WriteRegRorIX;
wire				JLinkX;
wire				JumpRegX;
wire	[31:0]	JumpAddrPCX;
reg	[31:0]	StoreDataX;
wire	[5:0]		OpcodeX;

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
reg	[31:0]	DataFromIOM;
reg				MemtoRegM;
reg				PCSrcX;
reg				JLinkM;
reg	[31:0]	PC_OUTM;
wire	[31:0]	ResultDMEMorIOorALUOutM;

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
assign JumpX			= Jump;
assign JALX				= JAL;
assign JLinkX			= JLink;
assign JumpRegX		= JumpReg;

//assign DataFromIOM	= 32'hf0f0f0f0;				//assign dummy data from IO
//assign DataFromIOM	= 32'h00f0f0f0;				//assign dummy data from IO



/**********************************************************/
//I stage datapath
/**********************************************************/

//model PC
always@(posedge clk)	begin
	if(rst)	PC_OUT	<=	32'h0000_0000;
	else		PC_OUT	<=	PC_IN;
end

//model PC+4
assign PCPlus4I = PC_OUT_Jump + 32'd4;
assign PC_IN = PCPlus4I;

//model MUX for Branch
//assign PC_OUT_MUX = (PCSrcX) ? PCBranchX : PC_OUT;
always@(*)	begin
	case (PCSrcX)
		1'b1:	PC_OUT_Branch = PCBranchX;
		1'b0:	PC_OUT_Branch = PC_OUT;
		default:	PC_OUT_Branch = PC_OUT;
	endcase
end

//model MUX for Jump
always@(*)	begin
	case (JumpX)
		1'b1:	PC_OUT_Jump = JumpAddrX;
		1'b0: PC_OUT_Jump = PC_OUT_Branch;
		default:	PC_OUT_Jump = PC_OUT_Branch;
	endcase
end

//model a register that used to sync up PC_OUT with corresponding instruction. It is necessary because IMEM is synchronous read.
always@(posedge clk)	begin
	if(!rst)	PC_OUT_SyncIMEM <= PC_OUT;
end


//instantiate IMEM
IMEM_blk_ram	MIPS150_imem(
	.clka		(clk),
	.ena		(~rst),						//Port Clock Enable (ena)
	.wea		(StoreMaskIMEMX),					//Port A Write Enable. Used to change contents that stored in IMEM?
	.addra	(ALUOutX[13:2]),					//Write Address, 12 bits wide
	.dina		(StoreDataX),			//The contents to be written, 32 bits wide
	.clkb		(clk),
	.enb		(~rst),
	.addrb	(PC_OUT_Jump[13:2]),			//addrb is 12 bits. One instruction takes one word (4 bytes), so the address is 0,4,8,12...Therefore, not need the two LSBs
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
		3'b010:	PCSrcX = ($signed(SrcAX) <= $signed(32'h0000_0000));	//BLEZ
		3'b011:	PCSrcX = ($signed(SrcAX) > $signed(32'h0000_0000));	//BGTZ
		3'b100:	PCSrcX = ($signed(SrcAX) < $signed(32'h0000_0000));	//BLTZ
		3'b101:	PCSrcX = ($signed(SrcAX) >= $signed(32'h0000_0000));	//BGEZ
		default:	PCSrcX = 1'b0;
	endcase
end

//model Branch Address
assign PCBranchX = PC_OUTX + 32'd4 + (SignOutImmX << 2'd2);

//model Jump Address
assign JumpAddrPCX = {PC_OUTX[31:28],InstrX[25:0], 2'b0};

//model a MUX for Jump address to choose from PC+? or Register
assign JumpAddrX = JumpRegX ? SrcAX : JumpAddrPCX;


//Register write address
//assign WriteRegX = InstrX[20:16];
//model Mux to choose write address. For R-type, choose InstrX[15:11]. For I-type, choose InstrX[20:16]
assign WriteRegRorIX = RegDstX ? InstrX[15:11] : InstrX[20:16];

//model Mux to select R[31] for JAL instr
assign WriteRegX = JALX ? 5'd31 : WriteRegRorIX;

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
			case(ByteAddrX[1:0])
				2'b00:			StoreMaskX = 4'b1000;		//byte0
				2'b01:			StoreMaskX = 4'b0100;		//byte1
				2'b10:			StoreMaskX = 4'b0010;		//byte2
				2'b11:			StoreMaskX = 4'b0001;		//byte3
			endcase
		end
		
		2'b10:	begin								//SH
			if	(ByteAddrX[1] == 1'b0)			StoreMaskX = 4'b1100;
			else										StoreMaskX = 4'b0011;
		end
		
		2'b11:	begin								//SW
			StoreMaskX = 4'b1111;
		end
		
		default:	StoreMaskX = 4'b0000;
		
	endcase
end

/*
//instantiate Memory Map
MemoryMap MIPS150_memmap(
	.StoreMask			(StoreMaskX),
	.MemMapAddress		(ALUOutX[31:0]),
	.StoreMaskDMEM		(StoreMaskDMEMX),
	.StoreMaskIMEM		(StoreMaskIMEMX),
	.StoreMaskIO		(StoreMaskIOX),
	.LoadDMEMorIO		(LoadDMEMorIOX)
);
*/


//model StoreData module
assign OpcodeX = InstrX[31:26];

always@(*)	begin
	case (OpcodeX)
		6'b101000:	begin		//SB
			case(ByteAddrX)
				2'b00:	StoreDataX = {ForwardBOutX[7:0], 24'h000000};
				2'b01:	StoreDataX = {8'h00, ForwardBOutX[7:0], 16'h0000};
				2'b10:	StoreDataX = {16'h0000, ForwardBOutX[7:0], 8'h00};
				2'b11:	StoreDataX = {24'h000000, ForwardBOutX[7:0]};
			endcase
		end
		
		6'b101001:	begin		//SH
			case(ByteAddrX[1])
				1'b0:		StoreDataX = {ForwardBOutX[15:0], 16'h0000};
				1'b1:		StoreDataX = {16'h0000, ForwardBOutX[15:0]};
			endcase
		end

		6'b101011:	begin		//SW
			StoreDataX = ForwardBOutX;
		end
		default:	StoreDataX = ForwardBOutX;
		
	endcase
end




/***********************************************************/
//M stage datapath
/***********************************************************/

//instantiate DMEM
DMEM_blk_ram MIPS150_dmem(
	.clka		(clk),
	.ena		(1'b1),						//Port Clock Enable (ena) is kinda global enable. If desserted, no Read, Write, or Reset operation are performed on the port
	.wea		(StoreMaskDMEMX),			//Port A Write Enable. This is the write_enble. It's a bus, each bit correponds one byte. dina is 4 bytes, wea = 4
	.addra	(ALUOutX[13:2]),			//The two LSB are 0, don't parse as address. Actually no need padding, just use ALUOutX[13:2]
	.dina		(StoreDataX),			//Used for "Store"
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
assign ResultDMEMorIOorALUOutM = MemtoRegM ? ResultDMEMorIOM : ALUOutM;

//Another MUX used to select signal from DMEM/IO/ALUOutM or PC+8 (for JAL instr)
assign ResultM = JLinkM ? (PC_OUTM + 32'd8) : ResultDMEMorIOorALUOutM;




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
		PC_OUTX	<= PC_OUT_SyncIMEM;
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
		MemtoRegM		<= MemtoRegX;
		ALUOutM			<= ALUOutX;
		JLinkM			<= JLinkX;
		PC_OUTM			<= PC_OUTX;
		LoadDMEMorIOM 	<= LoadDMEMorIOX;
		DataFromIOM		<=	DataFromIOX;
	end
end

endmodule
