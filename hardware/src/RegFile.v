//-----------------------------------------------------------------------------
//  Module: RegFile
//  Desc: An array of 32 32-bit registers
//  Inputs Interface:
//    clk: Clock signal
//    ra1: first read address (asynchronous)
//    ra2: second read address (asynchronous)
//    wa: write address (synchronous)
//    we: write enable (synchronous)
//    wd: data to write (synchronous)
//  Output Interface:
//    rd1: data stored at address ra1
//    rd2: data stored at address ra2
//  Author: Jing Peter Zhao
//-----------------------------------------------------------------------------

module RegFile(input clk,
               input we,
               input  [4:0] ra1, ra2, wa,
               input  [31:0] wd,
               output [31:0] rd1, rd2);

// Implement your register file here, then delete this comment.
reg [31:0]	ram [31:0];			//Peter: reg [31:0] should be width; ram [31:0] stand for how many registers inside the ram. For MIPS, needs 32 registers


//for synchronous write
always @(posedge clk)	begin
	if(we && wa != 5'd0)	ram[wa] <= wd;		//Peter: don't write Reg 0
end

//for asynchronous read
assign rd1 = (ra1 == 5'b0000) ? 32'h0000_0000 : ram[ra1];
assign rd2 = (ra2 == 5'b0000) ? 32'h0000_0000 : ram[ra2];


endmodule
