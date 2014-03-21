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
module MemoryMap(
	input	[3:0]	StoreMask,
	input	[3:0]	TopAddr,
	output	reg	[3:0]	StoreMaskDMEM,
	output	reg	[3:0]	StoreMaskIMEM,
	output	reg	[3:0]	StoreMaskIO,
	output	reg	LoadDMEMorIO
	);


always@(*)	begin
	casez (TopAddr)
	
		4'b0??1:	begin			//DMEM Read/Write
			StoreMaskDMEM = 	StoreMask;
			StoreMaskIMEM = 	4'b0000;
			StoreMaskIO = 		4'b0000;
			LoadDMEMorIO = 	1'b0;
		end
		
		4'b0?1?:	begin			//IMEM Write
			StoreMaskDMEM = 	4'b0000;
			StoreMaskIMEM = 	StoreMask;
			StoreMaskIO = 		4'b0000;
			LoadDMEMorIO = 	1'bx;
		end
		
		4'b1000:	begin			//IO Read/Write
			StoreMaskDMEM = 	4'b0000;
			StoreMaskIMEM = 	4'b0000;
			StoreMaskIO =  	StoreMask;
			LoadDMEMorIO = 	1'b1;
		end
		
		default:	begin
			StoreMaskDMEM = 	4'bxxxx;
			StoreMaskIMEM = 	4'bxxxx;
			StoreMaskIO =  	4'bxxxx;
			LoadDMEMorIO = 	4'bxxxx;
		end
	
	endcase

end

endmodule
