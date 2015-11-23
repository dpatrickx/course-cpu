module MemoryWrapper (
// clock
	input clk, rst, clkUART,
// input
   input [15:0] memAaddr, memBaddr, MeMemResult, 
	input [1:0] memRW,

// Return to CPUs
	output [15:0] memAdataRead,
	output [15:0] memBdataRead,

// Communicate with GraphicCard
	output [1:0] index,
	
// Directly contact with RAM. Don't touch!
	inout [15:0] memDataBus,
	output [17:0] memAddrBus,

//serial port
  inout [7:0] ram1DataBus,       // bus
  input tbre, tsre, dataReady, 
  output rdn, wrn,
  output ram1Oe, ram1We, ram1En,
  output memRead, memWrite, memEnable
);

wire [7:0] serialPortDataRead;
wire [3:0] serialPortState;
wire [15:0] physicalMemAaddr, physicalMemBaddr;
wire [15:0] ramAdataRead, ramBdataRead;


MemoryMapping mapingA (
  memAaddr,
  physicalMemAaddr,
  ramAdataRead,
  serialPortDataRead,
  serialPortState[1:0],
  memAdataRead,
  index
);

MemoryMapping mapingB (
  memBaddr,
  physicalMemBaddr,
  ramBdataRead,
  serialPortDataRead,
  serialPortState[1:0],
  memBdataRead
);

MemoryController memory(
  clk,
  physicalMemAaddr, MeMemResult,
  memRW,
  ramAdataRead,
  physicalMemBaddr,
  ramBdataRead,
  memDataBus,
  memAddrBus,
  memRead, memWrite, memEnable
);

serial_port uart(
  clkUART, rst,
  tbre, tsre, dataReady,
  memRW, index,
  MeMemResult,
  ram1DataBus,
  rdn, wrn,
  ram1Oe, ram1We, ram1En,
  serialPortDataRead,
  serialPortState
);
endmodule
