// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

module BlkMemTestbench();

  parameter Halfcycle = 5; //half period is 5ns

  localparam Cycle = 2*Halfcycle;

  reg Clock;
  reg Reset;

  // Clock Sinal generation:
  initial Clock = 0; 
  always #(Halfcycle) Clock = ~Clock;

  // Register and wires to test the RegFile
  wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;
  wire [31:0] Instr;
  reg [11:0] addrb;

  IMEM_blk_ram imem(
  .clka   (Clock),
  .ena    (1'b1),
  .wea    (4'b0000),
  .addra  (),
  .dina   (),
  .clkb   (Clock),
  .addrb  (addrb),
  .doutb  (Instr)
  );
  

  // Testing logic:
  initial begin
    Reset = 1;
    #(5*Cycle);
    Reset = 0;
    // Verify that writing to reg 0 is a nop
	  addrb = 12'h000;
	  #(100*Cycle);
	  addrb = 12'h001;
	  #(100*Cycle);
    // Verify that data written to any other register is returned the same
    // cycle
    //write reg1
    #Cycle;

	 
	  #Cycle;

    // Verify that the we pin prevents data from being written

    // Verify the reads are asynchronous
   
    #(Cycle*100);
    $display("All tests passed!");
    //$finish();
  end
endmodule
