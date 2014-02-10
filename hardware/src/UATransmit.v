module UATransmit(
  input   Clock,
  input   Reset,

  input   [7:0] DataIn,
  input         DataInValid,
  output        DataInReady,

  output        SOut
);
  // for log2 function
  `include "util.vh"



  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq         =   100_000_000;
  parameter   BaudRate          =   115_200;

  // See diagram in the lab guide
  localparam  SymbolEdgeTime    =   ClockFreq / BaudRate;
  localparam  ClockCounterWidth =   log2(SymbolEdgeTime);


  //2/3/2014
  //declaration
  wire Start;
  wire TXRunning;
  wire SymbolEdge;
  wire [9:0]	DataOut;
  
  reg     [9:0]                   TXShift;
  reg     [3:0]                   BitCounter;
  reg     [ClockCounterWidth-1:0] ClockCounter;
  
  
  //assign signals
  assign Start = DataInValid; //Peter: need DataInValid && !TXRunning?
  assign TXRunning = BitCounter != 4'd0;
  assign SymbolEdge = (ClockCounter == SymbolEdgeTime - 1);
  
  //Peter: 2/6/2014 I forgot to assign DataInReady signal...
  assign DataInReady = !TXRunning;
  
  
  //model registers(counters in this design)
  
  // Counts clock cycles for each single symbol
  always@(posedge Clock) begin
		ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter + 1;
  end
  
  always@(posedge Clock) begin
		if(Reset)			BitCounter <= 0;
		else if(Start)		BitCounter <= 10;
		else if(SymbolEdge && TXRunning)		BitCounter <= BitCounter - 1;
  end
  
  //model shift registers
  assign DataOut = {1'b1,DataIn,1'b0};    //padding with start and stop bits
  always@(posedge Clock) begin
		if(DataInValid)	TXShift <= DataOut;   //load data
		else if (TXRunning && SymbolEdge)	TXShift <= {1'b1,TXShift[9:1]};		//Peter: should use 1? otherwise if 0, SOut = 0 and that's start bit
  end
  assign SOut = TXShift[0];

endmodule
