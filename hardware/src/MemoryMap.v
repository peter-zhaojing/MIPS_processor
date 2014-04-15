`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:21:54 03/01/2014 
// Design Name: 
// Module Name:    MemoryMap 
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

module MemoryMap(
	input	[3:0]				StoreMask,
	input	[31:0]			MemMapAddress,
	input						DataInReady,
	input						DataOutValid,
	input	[7:0]				DataOut,
	input	[7:0]				IODataFromCPU,
	input [31:0]			Instr,
	output reg	[3:0]		StoreMaskDMEM,
	output reg	[3:0]		StoreMaskIMEM,
	output reg				LoadDMEMorIO,
	output reg	[31:0]	DataFromIO,
	output reg	[7:0]		DataToIO,
	output reg				DataInValid,
	output reg				DataOutReady
	);

	//declare signals
	wire [3:0]	TopAddr;
	wire [5:0]	Opcode;
	
	assign TopAddr = MemMapAddress [31:28];
	assign Opcode = Instr[31:26];

always@(*)	begin
	casez (TopAddr)
	
		4'b0??1:	begin			//DMEM Read/Write
			StoreMaskDMEM	= 	StoreMask;
			StoreMaskIMEM	= 	4'b0000;
			LoadDMEMorIO	= 	1'b0;
			DataFromIO		=	32'hxxxxxxxx;
			DataToIO			=	8'hxx;
			DataInValid		=	1'b0;
			DataOutReady	=	1'b0;
		end
		
		4'b0?1?:	begin			//IMEM Write
			StoreMaskDMEM	= 	4'b0000;
			StoreMaskIMEM	= 	StoreMask;
			LoadDMEMorIO	= 	1'bx;
			DataFromIO		=	32'hxxxxxxxx;
			DataToIO			=	8'hxx;
			DataInValid		=	1'b0;
			DataOutReady	=	1'b0;
		end
		
		4'b1000:	begin			//IO Read/Write
			case (MemMapAddress[3:0])
			
				4'h0:	begin			//lw from 32'h80000000	DataInReady (1bit)
					if(Opcode == `LW)	begin
						StoreMaskDMEM	=	4'b0000;
						StoreMaskIMEM	= 	4'b0000;
						LoadDMEMorIO	= 	1'b1;
						DataFromIO		=	{31'b0, DataInReady};
						DataToIO			=	8'hxx;
						DataInValid		=	1'b0;
						DataOutReady	=	1'b0;
					end
					else	begin
						StoreMaskDMEM	=	4'b0000;
						StoreMaskIMEM	= 	4'b0000;
						LoadDMEMorIO	= 	1'bx;
						DataFromIO		=	32'hxxxxxxxx;
						DataToIO			=	8'hxx;
						DataInValid		=	1'b0;
						DataOutReady	=	1'b0;
					end
				end
			
				4'h4:	begin			//lw from 32'h80000004	DataOutValid (1 bit)
					if(Opcode == `LW)	begin
						StoreMaskDMEM	=	4'b0000;
						StoreMaskIMEM	= 	4'b0000;
						LoadDMEMorIO	= 	1'b1;
						DataFromIO		=	{31'b0, DataOutValid};
						DataToIO			=	8'hxx;
						DataInValid		=	1'b0;
						DataOutReady	=	1'b0;
					end
					else	begin
						StoreMaskDMEM	=	4'b0000;
						StoreMaskIMEM	= 	4'b0000;
						LoadDMEMorIO	= 	1'bx;
						DataFromIO		=	32'hxxxxxxxx;
						DataToIO			=	8'hxx;
						DataInValid		=	1'b0;
						DataOutReady	=	1'b0;
					end
				end
				
				4'hc:	begin			//lw from 32'h8000000c	DataOut (8 bits)
					if(Opcode == `LW)	begin
						StoreMaskDMEM	=	4'b0000;
						StoreMaskIMEM	= 	4'b0000;
						LoadDMEMorIO	=	1'b1;
						DataFromIO		=	{24'b0, DataOut};
						DataToIO			=	8'hxx;
						DataInValid		=	1'b0;
						DataOutReady	=	1'b1;
					end
					else	begin
						StoreMaskDMEM	=	4'b0000;
						StoreMaskIMEM	= 	4'b0000;
						LoadDMEMorIO	= 	1'bx;
						DataFromIO		=	32'hxxxxxxxx;
						DataToIO			=	8'hxx;
						DataInValid		=	1'b0;
						DataOutReady	=	1'b0;
					end
				end
				
				4'h8:	begin			//sw to 32'h80000008	DataIn (8 bits)
					if(Opcode == `SW)	begin
						StoreMaskDMEM	=	4'b0000;
						StoreMaskIMEM	= 	4'b0000;
						LoadDMEMorIO	=	1'bx;
						DataFromIO		=	32'hxxxxxxxx;
						DataToIO			=	IODataFromCPU;
						DataInValid		=	1'b1;		//When there is data ready to write to UART, set DataInValid (at Transmit) = 1; DataInReady (at Transmit) is checked using lw (case 4'h0). lw is put inside while loop in echo.c 
						DataOutReady	=	1'b0;
					end
					else	begin
						StoreMaskDMEM	=	4'b0000;
						StoreMaskIMEM	= 	4'b0000;
						LoadDMEMorIO	= 	1'bx;
						DataFromIO		=	32'hxxxxxxxx;
						DataToIO			=	8'hxx;
						DataInValid		=	1'b0;
						DataOutReady	=	1'b0;
					end
				end
				
				default:	begin
					StoreMaskDMEM	=	4'b0000;
					StoreMaskIMEM	= 	4'b0000;
					LoadDMEMorIO	=	1'bx;
					DataFromIO		=	32'hxxxxxxxx;
					DataToIO			=	8'hxx;
					DataInValid		=	1'b0;
					DataOutReady	=	1'b0;
				end
			endcase
		end
		
		default:	begin
			StoreMaskDMEM	=	4'b0000;
			StoreMaskIMEM	= 	4'b0000;
			LoadDMEMorIO	=	1'bx;
			DataFromIO		=	32'hxxxxxxxx;
			DataToIO			=	8'hxx;
			DataInValid		=	1'b0;
			DataOutReady	=	1'b0;
		end
	endcase

end

endmodule
