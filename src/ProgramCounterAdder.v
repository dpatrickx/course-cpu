// Program Counter Adder
//

module ProgramCounterAdder (
  input clock,
  input reset,
  input [15:0] currentPC,
  input [15:0] currentInstruction,
  input [15:0] finalRegisterValue,
  input t,
  input interruptSignal,
  input interruptInstructionSignal,
  input [2:0] jumpControl,
  output [15:0] nextPC
);

localparam NONE_CONTROL = 3'b000;
localparam B_CONTROL = 3'b001;
localparam BEQZ_CONTROL = 3'b010;
localparam BNEZ_CONTROL = 3'b011;
localparam BTEQZ_CONTROL = 3'b100;
localparam JR_CONTROL = 3'b101;

reg [15:0] instruction, jumpPC;
reg [15:0] programCounterRegister;
reg jump;

wire [15:0] immediateSignExtend_8bit = {instruction[7] ? 8'hff : 8'h00, instruction[7:0]};
wire [15:0] immediateSignExtend_11bit = {instruction[10] ?  5'b11111 : 5'b00000, instruction[10:0]};

always @ (negedge clock or negedge reset) begin
  if (!reset) begin
    instruction = 16'h8000; //BIOS Address
    programCounterRegister = 16'hffff; //IDLE
  end else begin
    instruction = currentInstruction;
    programCounterRegister = currentPC;
  end
end

always @ (*) begin
  jumpPC = 0;
  jump = 0;
  if (!reset) begin
    jumpPC = 0;
    jump = 0;
  end else begin
    case (jumpControl)
      NONE_CONTROL: begin
        jumpPC = 0;
        jump = 0;
      end
      B_CONTROL: begin
        jumpPC = programCounterRegister + immediateSignExtend_11bit;
        jump = 1;
      end
      BEQZ_CONTROL: begin
        if (finalRegisterValue == 0) begin
          jumpPC = programCounterRegister + immediateSignExtend_8bit;
          jump = 1;
        end
      end
      BNEZ_CONTROL: begin
        if (finalRegisterValue != 0) begin
          jumpPC = programCounterRegister + immediateSignExtend_8bit;
          jump = 1;
        end
      end
      BTEQZ_CONTROL: begin
        if (t == 0) begin
          jumpPC = programCounterRegister + immediateSignExtend_8bit;
          jump = 1;
        end
      end
      JR_CONTROL: begin
        jumpPC = finalRegisterValue;
        jump = 1;
      end
    endcase
  end
end

// assign normalNextPC = jump ? jumpPC : programCounterRegister + 1;
// assign interruptRealPC = interruptSignal ? programCounterRegister : (jump ? jumpPC : programCounterRegister + 1);
assign nextPC = interruptInstructionSignal ? finalRegisterValue : (interruptSignal ? programCounterRegister : (jump ? jumpPC : programCounterRegister + 1));


endmodule




    
