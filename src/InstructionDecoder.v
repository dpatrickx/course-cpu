// 
//
// Instruction Decoder
// Created By Yue Shichao
// Nov 29, 2014
//
//

module InstructionDecoder (
  input clock,
  input reset,
  input [15:0] currentInstruction,
  output reg [3:0] firstRegisiterAddress,
  output reg [3:0] secondRegisiterAddress,  // Memory Address
  output reg [3:0] targetRegisiterAddress,
  output reg [2:0] jumpControl,
  output reg [3:0] interruptIndex,
  output reg interruptSignal,
  output reg interruptInstructionSignal
);

`include "InstructionCode.h"
`include "Const.h"

localparam NONE_CONTROL = 3'b000;
localparam B_CONTROL = 3'b001;
localparam BEQZ_CONTROL = 3'b010;
localparam BNEZ_CONTROL = 3'b011;
localparam BTEQZ_CONTROL = 3'b100;
localparam JR_CONTROL = 3'b101;
localparam JALR_CONTROL = 3'b110;
localparam JRRA_CONTROL = 3'b111;

reg [15:0] instruction;

wire [3:0] firstParameter = {0, instruction[10:8]};
wire [3:0] secondParameter = {0, instruction[7:5]};
wire [3:0] thirdParameter = {0, instruction[4:2]};

always @ (negedge clock or negedge reset) begin
  if (!reset) begin
    instruction = OP_NOP;
  end else begin
    instruction = currentInstruction;
  end
end

always @ (posedge clock or negedge reset) begin
  firstRegisiterAddress = 0;
  secondRegisiterAddress = 0;
  targetRegisiterAddress = 4'hf;
  interruptSignal = 0;
  interruptIndex = 0;
  interruptInstructionSignal = 0;
  jumpControl = NONE_CONTROL;
  
  if (!reset) begin
    firstRegisiterAddress = 0;
    secondRegisiterAddress = 0;
    interruptSignal = 0;
    interruptIndex = 0;
    interruptInstructionSignal = 0;
    targetRegisiterAddress = 4'hf;
    jumpControl = NONE_CONTROL;
  end else begin
    case (instruction[15:11])
      OP_ADDIU: begin
        targetRegisiterAddress = firstParameter;
        firstRegisiterAddress = firstParameter;
      end
      OP_ADDIU3: begin
        targetRegisiterAddress = secondParameter;
        firstRegisiterAddress = firstParameter;
      end
      OP_B: begin
        jumpControl = B_CONTROL;
      end
      OP_BEQZ: begin
        jumpControl = BEQZ_CONTROL;
        firstRegisiterAddress = firstParameter;
      end
      OP_BNEZ: begin
        jumpControl = BNEZ_CONTROL;
        firstRegisiterAddress = firstParameter;
      end
      OP_LI: begin
        targetRegisiterAddress = firstParameter;
      end
      OP_LW: begin
        targetRegisiterAddress = secondParameter;
        firstRegisiterAddress = firstParameter;
      end
      OP_SW: begin
        firstRegisiterAddress = firstParameter;
        secondRegisiterAddress = secondParameter;
      end
      OP_ADDSP3: begin
        targetRegisiterAddress = firstParameter;
        secondRegisiterAddress = REG_SP;
      end
      OP_CMPI: begin
        firstRegisiterAddress = firstParameter;
      end
      OP_LW_SP: begin
        targetRegisiterAddress = firstParameter;
        secondRegisiterAddress = REG_SP;
      end
      OP_SW_SP: begin
        firstRegisiterAddress = firstParameter;
        secondRegisiterAddress = REG_SP;
      end

      OP_INT: begin
        case (instruction[7:4])
          0: begin
            interruptSignal = 1;
            interruptIndex = instruction[3:0];
          end
          1: begin 
            targetRegisiterAddress = REG_EPC;
          end
          2: begin
            targetRegisiterAddress = REG_ESP;
            firstRegisiterAddress = REG_SP;
          end
          3: begin
            targetRegisiterAddress = REG_SP;
          end
          4: begin
            firstRegisiterAddress = REG_EPC;
            secondRegisiterAddress = REG_SP;
          end
          5: begin
            secondRegisiterAddress = REG_SP;
          end
          6: begin
            firstRegisiterAddress = REG_ESP;
            secondRegisiterAddress = REG_SP;
          end
          7: begin
				interruptInstructionSignal = 1;
            firstRegisiterAddress = REG_IH;
          end
          // 8:
          // 9:
          // 10: 
        endcase
      end

      
      5'b01100: begin
        case (instruction[10:8])
          OP_BTEQZ_SUFFIX: begin
            jumpControl = BTEQZ_CONTROL;
          end
          OP_ADDSP_SUFFIX: begin
            targetRegisiterAddress = REG_SP;
            secondRegisiterAddress = REG_SP;
          end
          OP_MTSP_SUFFIX: begin
            targetRegisiterAddress = REG_SP;
            secondRegisiterAddress = secondParameter;
          end
        endcase
      end

      5'b11101: begin
        case (instruction[4:0])
          OP_AND_SUFFIX: begin
            targetRegisiterAddress = firstParameter;
            firstRegisiterAddress  = firstParameter;
            secondRegisiterAddress = secondParameter;
          end
          OP_CMP_SUFFIX: begin
            firstRegisiterAddress = firstParameter;
            secondRegisiterAddress = secondParameter;
          end
          OP_OR_SUFFIX: begin
            targetRegisiterAddress = firstParameter;
            firstRegisiterAddress = firstParameter;
            secondRegisiterAddress = secondParameter;
          end
          OP_NOT_SUFFIX: begin
            targetRegisiterAddress = firstParameter;
            secondRegisiterAddress = secondParameter;
          end
          OP_SLLV_SUFFIX: begin
            targetRegisiterAddress = secondParameter;
            firstRegisiterAddress = firstParameter;
            secondRegisiterAddress = secondParameter;
          end
          OP_SLTU_SUFFIX: begin
            firstRegisiterAddress = firstParameter;
            secondRegisiterAddress = secondParameter;
          end
          5'b00000: begin
            case (instruction[7:5])
              OP_JR_MIDFIX: begin
				    jumpControl = JR_CONTROL;
                firstRegisiterAddress = firstParameter;
              end
              OP_MFPC_MIDFIX: begin
                targetRegisiterAddress = firstParameter;
              end
              OP_JALR_MIDFIX: begin
				    jumpControl = JALR_CONTROL;
                targetRegisiterAddress = REG_RA;
                firstRegisiterAddress = firstParameter;
              end
              OP_JRRA_MIDFIX: begin
				    jumpControl = JRRA_CONTROL;
                firstRegisiterAddress = REG_RA;
              end
            endcase
          end
        endcase
      end

      5'b11110: begin
        case (instruction[7:0])
          OP_MFIH_SUFFIX: begin
            targetRegisiterAddress = firstParameter;
            firstRegisiterAddress = REG_IH;
          end
          OP_MTIH_SUFFIX: begin
            targetRegisiterAddress = REG_IH;
            firstRegisiterAddress = firstParameter;
          end
        endcase
      end

      5'b00110: begin
        case (instruction[1:0])
          OP_SLL_SUFFIX: begin
            targetRegisiterAddress = firstParameter;
            secondRegisiterAddress = secondParameter;
          end
          OP_SRA_SUFFIX: begin
            targetRegisiterAddress = firstParameter;
            secondRegisiterAddress = secondParameter;
          end
        endcase
      end

      5'b11100: begin
        case (instruction[1:0])
          OP_SUBU_SUFFIX: begin
            targetRegisiterAddress = thirdParameter;
            firstRegisiterAddress = firstParameter;
            secondRegisiterAddress = secondParameter;
          end
          OP_ADDU_SUFFIX: begin
            targetRegisiterAddress = thirdParameter;
            firstRegisiterAddress = firstParameter;
            secondRegisiterAddress = secondParameter;
          end
        endcase
      end

      // 5'b00001  -- NOP
      default: begin

      end

    endcase
  end
end
    

endmodule
