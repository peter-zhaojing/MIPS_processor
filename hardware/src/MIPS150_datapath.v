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
	 input				RegWrite
    );

/**********************************************************/
//signal declaration
/**********************************************************/

//I stage
wire	[31:0]	InstrI;	
reg	[31:0]	PC_OUT;
wire	[31:0]	PC_IN;


//X stage
reg	[31:0]	InstrX;
wire				RegWriteX;
wire	[4:0]		WriteRegX;
wire	[31:0]	RFout1, RFout2;
wire	[31:0]	ALUOutX;
wire	[3:0]		ALUControlX;
wire	[31:0]	SrcAX, SrcBX;

//M stage
reg				RegWriteM;
reg	[4:0]		WriteRegM;
wire	[31:0]	ResultM;
reg	[31:0]	ALUOutM;
wire  [31:0]	ALUOutPadding;
wire	[31:0]	ReadDateM;
reg				tempRegWriteM;
reg	[3:0]		tempWriteRegM;
wire	[31:0]	ReadDataM;


/**********************************************************/
//Connecting signals to module port
/**********************************************************/
assign Instr			= InstrI;
assign ALUControlX	= ALUControl;
assign RegWriteX		= RegWrite;



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
	.ena		(~rst),					//Port Clock Enable (ena)
	.wea		(4'b0000),					//Port A Write Enable. Used to change contents that stored in IMEM?
	.addra	(12'h000),					//Write Address, 12 bits wide
	.dina		(32'h0000_0000),					//The contents to be written, 32 bits wide
	.clkb		(clk),
	.addrb	(PC_OUT[13:2]),	//addrb is 12 bits. One instruction takes one word (4 bytes), so the address is 0,4,8,12...Therefore, not need the two LSBs
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

assign ALUOutPadding = ALUOutM;

//Write back to Register File
//ResultM has already connected to Register File via RegFile instantiation
assign ResultM = ReadDataM;

//Keep ResultM and RegWriteM,RegWriteM in sync
always@(posedge clk) begin
	RegWriteM	<= tempRegWriteM;
	WriteRegM	<=	tempWriteRegM;
end

/***********************************************************/
//I-X Pipeline Register
/***********************************************************/
always@(posedge clk)	begin
	if(!rst)	InstrX	<=	InstrI;
end

/***********************************************************/
//X-M Pipeline Register
/***********************************************************/
always@(posedge clk) begin
	if(!rst)	begin
	tempRegWriteM	<=	RegWriteX;
	tempWriteRegM	<=	WriteRegX;
	ALUOutM			<= ALUOutX;
	end
end

endmodule
