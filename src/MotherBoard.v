module motherBoard (
  input clk, rst, clkHand, clkUART,
  inout [15:0] memDataBus,
  output [17:0] memAddrBus,
  output memRead, memWrite, memEnable,
//  output vgaHs, vgaVs,
//  output [2:0] vgaR, vgaG, vgaB,
//  output [15:0] leddebug,
  input tbre, tsre, dataReady,    // wires linked with CPLD
  inout [7:0] ram1DataBus,       // bus
  output rdn, wrn,
  output ram1Oe, ram1We, ram1En,
  // Communicate with VGA
  output [2:0] R,
  output [2:0] G,
  output [2:0] B,
  output Hs,
  output Vs
);

wire [175:0] registerValue;
wire [15:0] memAaddr, memBaddr, memAdataRead, memBdataRead, MeMemResult;
wire [1:0] memRW;
wire [15:0] IfPC, IfIR;
wire [15:0] ExCalResult, MeCalResult;

wire [1:0] memoryControl;
wire [2:0] jumpControl;

wire [3:0] registerS, registerM, IdRegisterT, MeRegisterT;
wire [2:0] index;
wire [6:0] interruptDebug;


reg clk25M, clk12M, clk6M;

always @ (negedge clk, negedge rst)
begin
  if (!rst)
    clk25M = 0;
  else
    clk25M = ~ clk25M;
end

always @ (negedge clk25M or negedge rst)
  if (!rst)
    clk12M = 0;
  else
    clk12M = ~ clk12M;
	 
always @ (negedge clk12M or negedge rst)
  if (!rst)
    clk6M = 0;
  else
    clk6M = ~ clk6M;

assign leddebug = {8'h00, jumpControl, 1'b0, interruptDebug};

CentralProcessingUnit naive (
  .clock(clkUART), 
  .reset(rst),
  .handInterruptSignalIn(clkHand),
  .MEM_memory_address(memAaddr), 
  .IF_address(memBaddr),
  .MEM_target_value(MeMemResult), 
  .MEM_memory_control(memRW),
  .MEM_memory_read(memAdataRead), 
  .IF_memory_read(memBdataRead),
  .register_value(registerValue),
  .programCounter_0(IfPC), 
  .instruction_1_selected(IfIR),
  .firstRegisterAddress(registerS), 
  .secondRegisterAddress(registerM),
  .targetRegisterAddress_2(IdRegisterT), 
  .targetRegisterAddress_4(MeRegisterT),
  .targetValue_4(MeCalResult), 
  .firstRegisterValueFinal(ExCalResult), 
  .memoryControl(memoryControl),
  .jumpControl(jumpControl),
  .interruptDebug(interruptDebug)
);

GraphicCard graphic (
  .CLK_0(clk),
  .clk(clkUART),
  .reset(rst),
  .index(index),
  .ram_data(MeMemResult),
  .R(R),
  .G(G),
  .B(B),
  .Hs(Hs),
  .Vs(Vs)
);

MemoryWrapper memoryHandler(
	clkUART, rst,
	clkUART,
   memAaddr, memBaddr, MeMemResult, 
	memRW,
	memAdataRead,
	memBdataRead,
	index,
	memDataBus,
	memAddrBus,
   ram1DataBus,       // bus
   tbre, tsre, dataReady, 
   rdn, wrn,
   ram1Oe, ram1We, ram1En,
   memRead, memWrite, memEnable
);


endmodule
