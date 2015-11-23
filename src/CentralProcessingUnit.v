//Just a start

module CentralProcessingUnit (
  input clock,
  input reset,
  input handInterruptSignalIn,
  // Used by InstructionFetcher. Details are below.
  input [15:0] IF_memory_read,
  output [15:0] IF_address,

  // Used by MemoryInterface. Details are below.
  input [15:0] MEM_memory_read,
  output [1:0] MEM_memory_control,
  output [15:0] MEM_memory_address,
  output [15:0] MEM_target_value,
  
  // VGA Debug Signals
  output [175:0] register_value,
  output [15:0] programCounter_0, instruction_1_selected,
  output [3:0] firstRegisterAddress, secondRegisterAddress, targetRegisterAddress_2,
  output [3:0] targetRegisterAddress_4,
  output [15:0] targetValue_4,
  //output [15:0] targetValue_3,
  output [15:0] firstRegisterValueFinal,
  output [1:0] memoryControl,
  output [2:0] jumpControl,
  output [6:0] interruptDebug
);

//programCounter
//wire [15:0] programCounter_0;  //Next PC
wire [15:0] programCounter_1;  //Instruction Fetch
wire [15:0] programCounter_2;  //Instruction Decoding
wire [15:0] programCounter_3;  //Execute
wire [15:0] programCounter_4;  //Memory Access
wire [15:0] programCounter_5;  //Write Back

//instruction
wire [15:0] instruction_1_origin;
wire [15:0] instruction_2;
wire [15:0] instruction_3;
wire [15:0] instruction_4;

//firstRegister
//wire [3:0] firstRegisterAddress;
//firstRegisterValue
wire [15:0] firstRegisterValueOrigin;
wire [15:0] firstRegisterValueMiddle;
//wire [15:0] firstRegisterValueFinal;

//secondRegister
//wire [3:0] secondRegisterAddress;
//secondRegisterValue
wire [15:0] secondRegisterValueOrigin;
wire [15:0] secondRegisterValueMiddle;
wire [15:0] secondRegisterValueFinal;

//targetRegisterAddress
//wire [3:0] targetRegisterAddress_2;
wire [3:0] targetRegisterAddress_3;
//wire [3:0] targetRegisterAddress_4;

//targetValue
wire [15:0] targetValue_3;
//wire [15:0] targetValue_4;

wire t;
wire tWriteEnable;
wire tToWrite;

//wire [2:0] jumpControl;

//wire [1:0] memoryControl;
wire [15:0] dataMemoryAddress;
wire [15:0] dataFetched;


// For Interrupt Use
wire [3:0] interruptIndex;
wire interruptSignalDecoder;
wire interruptSignalHandler;
wire interruptSignalHardware;
wire interruptInstructionSignal;
wire [15:0] interruptInstruction;

assign interruptDebug = {
  interruptIndex,
  interruptSignalDecoder,
  interruptSignalHandler,
  interruptInstructionSignal
};

//previous and the second phase
ProgramCounterAdder pcAdder (
  clock,
  reset,
  programCounter_0,
  instruction_1_selected,
  firstRegisterValueFinal,
  t,
  interruptSignalHandler,
  interruptInstructionSignal,
  jumpControl,
  programCounter_0
);

/* ---------------------- First phase (Instruction Fetch) -----------------*/
// InstructionFetcher.v: created by Jiaming.
//
// Instruction Fetcher requires two ports to communicate with the memory:
//   IF_address, which gives the memory controller the address at NEGEDGE CLK
//   IF_memory_read, which reads from the memory controller at POSEDGE CLK
//
InstructionFetcher fetcher (
  .clk(clock),
  .rst(reset),
  .current_PC(programCounter_0),
  .mem_read(IF_memory_read),
  .current_IR_addr(IF_address),
  .current_IR(instruction_1_origin)
);

/* --------------------- Second phase (Instruction Decode) -----------------*/
InstructionDecoder decoder (
  clock,
  reset,
  instruction_1_selected,
  firstRegisterAddress,
  secondRegisterAddress,
  targetRegisterAddress_2,
  jumpControl,
  interruptIndex,
  interruptSignalDecoder,
  interruptInstructionSignal
);

InterruptHandler handler (
  clock,
  reset,
  interruptIndex,
  interruptSignalHardware,
  interruptSignalHandler,
  interruptInstruction
);

InterruptSelector interruptSelector (
  instruction_1_origin,
  interruptInstruction,
  interruptSignalHandler,
  instruction_1_selected
);

HardwareInterruptHandler hardwareHandler (
  clock, 
  reset,
  interruptSignalDecoder,
  handInterruptSignalIn,
  interruptSignalHardware
);


//Here we pass the next round pc to the ALU
Forwarder programCounterForwarder_2 (
  clock,
  reset,
  programCounter_0,
  programCounter_2
);

Forwarder instructionForwarder_2 (
  clock,
  reset,
  instruction_1_selected,
  instruction_2
);

//Access to Register

ByPass firstRegisiterByPass_II (
  firstRegisterAddress,
  firstRegisterValueOrigin,
  targetRegisterAddress_4,
  targetValue_4,
  firstRegisterValueMiddle
);
ByPass firstRegisiterByPass_I (
  firstRegisterAddress,
  firstRegisterValueMiddle,
  targetRegisterAddress_3,
  targetValue_3,
  firstRegisterValueFinal
);
ByPass secondRegisterByPass_II (
  secondRegisterAddress,
  secondRegisterValueOrigin,
  targetRegisterAddress_4,
  targetValue_4,
  secondRegisterValueMiddle
);
ByPass secondRegisterByPass_I (
  secondRegisterAddress,
  secondRegisterValueMiddle,
  targetRegisterAddress_3,
  targetValue_3,
  secondRegisterValueFinal
);

/* --------------------- Third phase (Execute) -----------------*/
ArithmeticLogicalUnit alu (
  clock,
  reset,
  firstRegisterValueFinal,
  secondRegisterValueFinal,
  programCounter_2,
  instruction_2,
  targetValue_3,
  tWriteEnable,
  tToWrite
);

MemoryAddressCalculator addressCalculator (
  clock,
  reset,
  instruction_2,
  firstRegisterValueFinal,
  secondRegisterValueFinal,
  memoryControl,
  dataMemoryAddress
);

Forwarder4Bit targetRegisterAddressForwarder_3 (
  clock,
  reset,
  targetRegisterAddress_2,
  targetRegisterAddress_3
);

/* ------------------ Fourth phase (Memory Access) ---------------*/
// MemoryInterface.v: created by Jiaming.
//
// Memory Interface passes data between CPU and memory.
// Three states: READ, WRITE, and IDLE are all processed by MemoryController.
// The signals are determined by the CPU.
// Control signals will be sent when posedge is triggered.
// Read result will be sent at any time.
//
MemoryInterface memoryCommunicator (
// Input
  .clk(clock),
  .rst(reset),
  .memory_address_from_cpu(dataMemoryAddress), // address
  .target_value_from_cpu(targetValue_3), // 
  .memory_control_signal_from_cpu(memoryControl), // read and write
  .data_fetched_from_memory(MEM_memory_read),
// Output
  .memory_address_to_memory(MEM_memory_address),
  .memory_control_signal_to_memory(MEM_memory_control),
  .target_value_to_memory(MEM_target_value),
  .data_fetched_to_cpu(dataFetched)    // read result
);

//

Selector selector (
  .clk(clock),
  .rst(reset),
  .memory_control(memoryControl),
  .mem_data_read(dataFetched),
  .alu_cal_result(targetValue_3),
  .select_cal_result(targetValue_4)
);

Forwarder4Bit targetRegisterAddressForwarder_4 (
  clock,
  reset,
  targetRegisterAddress_3,
  targetRegisterAddress_4
);

/* --------------------- Fifth phase (Write Back) ----------------*/

Register register (
  clock,
  reset,
  firstRegisterAddress,
  secondRegisterAddress,
  tWriteEnable,
  tToWrite,
  targetRegisterAddress_4,
  targetValue_4,
  firstRegisterValueOrigin,
  secondRegisterValueOrigin,
  t,
  register_value
);


endmodule

