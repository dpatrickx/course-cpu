module InterruptSelector (
  input [15:0] normalInstruction,
  input [15:0] interruptInstruction,
  input interruptSignal,
  output [15:0] selectedInstruction
);

assign selectedInstruction = interruptSignal ? interruptInstruction : normalInstruction;

endmodule
