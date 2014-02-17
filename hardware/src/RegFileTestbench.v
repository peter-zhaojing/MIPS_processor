// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

module RegFileTestbench();

  parameter Halfcycle = 5; //half period is 5ns

  localparam Cycle = 2*Halfcycle;

  reg Clock;

  // Clock Sinal generation:
  initial Clock = 0; 
  always #(Halfcycle) Clock = ~Clock;

  // Register and wires to test the RegFile
  reg [4:0] ra1;
  reg [4:0] ra2;
  reg [4:0] wa;
  reg we;
  reg [31:0] wd;
  wire [31:0] rd1;
  wire [31:0] rd2;

  (* ram_style = "distributed" *) RegFile regfile(.clk(Clock),			//Peter: force synthesizer tool to use "distributed" ram
              .we(we),
              .ra1(ra1),
              .ra2(ra2),
              .wa(wa),
              .wd(wd),
              .rd1(rd1),
              .rd2(rd2));
  

  // Testing logic:
  initial begin
    #1;
    // Verify that writing to reg 0 is a nop
    ra1 = 5'b0000;
	  we = 1;
	  wa = 5'b00000;
	  wd = 32'h0000_0001;
	 
	  #Cycle;
	  we = 0;
    // Verify that data written to any other register is returned the same
    // cycle
    //write reg1
    #Cycle;
    ra1 = 5'b0001;
    we = 1;
    wa = 5'b00001;
    wd = 32'h1111_1111;
	 
	  #Cycle;
	  we = 0;
    // Verify that the we pin prevents data from being written
	  wd = 32'h1010_1010;
    // Verify the reads are asynchronous
   
   #(Cycle*100);
    $display("All tests passed!");
    $finish();
  end
endmodule
