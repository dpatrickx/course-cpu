module InterruptHandler (
  input clock,
  input reset,
  input [3:0] interruptIndexIn,
  input interruptSignalIn,
  output reg interruptSignalOut,
  output reg [15:0] interruptInstructionOut
);

`include "InstructionCode.h"


reg [3:0] interruptState;
reg [3:0] interruptIndex;
reg insideInterrupt;

localparam STATE_TOTAL = 10;

always @ (negedge clock or negedge reset) begin
  if (!reset) begin
    interruptState = 1;
    interruptIndex = 0;
    insideInterrupt = 0;
  end else begin
    if (interruptSignalIn == 1 && insideInterrupt == 0 && interruptState == 1) begin
      interruptIndex = interruptIndexIn;
      insideInterrupt = 1;
    end else if (interruptState < STATE_TOTAL && insideInterrupt == 1) begin
      interruptState = interruptState + 1;
    end else if (interruptState == STATE_TOTAL) begin
      interruptState = 1;
      insideInterrupt = 0;
      interruptIndex = 0;
    end
  end
end


always @ (posedge clock or negedge reset) begin
  if (!reset) begin
    interruptInstructionOut = OP_NOP;
  end else begin
    if (insideInterrupt == 1) begin 
	    interruptInstructionOut = {8'hF8, interruptState, interruptIndex};
		  interruptSignalOut = 1;
	  end else begin
	    interruptInstructionOut = OP_NOP;
		  interruptSignalOut = 0;
	  end
  end
end


endmodule

