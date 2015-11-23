module ArithmeticLogicalUnit (
  input clock,
  input reset,
  input [15:0] finalFirstRegisterValue,
  input [15:0] finalSecondRegisterValue,
  input [15:0] currentProgramCounter,
  input [15:0] currentInstruction,
  output reg [15:0] targetValue,
  output reg tWriteEnable,
  output reg tToWrite
);

reg [15:0] programCounter;
reg [15:0] instruction;
reg [15:0] firstRegisterValue;
reg [15:0] secondRegisterValue;

wire [15:0] immediateSignExtend_8bit = {instruction[7] ? 8'hff : 8'h00, instruction[7:0]};
wire [15:0] immediateSignExtend_11bit = {instruction[10] ?  5'b11111 : 5'b00000, instruction[10:0]};
wire [15:0] immediateZeroExtend_8bit = {8'h00, instruction[7:0]};
wire [15:0] immediateSignExtend_4bit = {instruction[3] ? 12'hfff : 12'h000, instruction[3:0]};

wire [3:0] shiftImmediate = instruction[4:2] ? instruction[4:2] : 8;

`include "InstructionCode.h"
`include "Const.h"

always @ (negedge clock or negedge reset) begin
  if (!reset) begin
    programCounter = 0;
    instruction = OP_NOP;
    firstRegisterValue = 0;
    secondRegisterValue = 0;
  end else begin
    programCounter = currentProgramCounter;
    instruction = currentInstruction;
    firstRegisterValue = finalFirstRegisterValue;
    secondRegisterValue = finalSecondRegisterValue;
  end
end

always @(posedge clock or negedge reset) begin
  if (!reset) begin
    tWriteEnable = 1;
    tToWrite = 0;
    targetValue = 0;
  end else begin
    case (instruction[15:11])
      OP_ADDIU: begin
        targetValue = firstRegisterValue + immediateSignExtend_8bit;
      end
      OP_ADDIU3: begin
        targetValue = firstRegisterValue + immediateSignExtend_4bit;
      end
      // OP_B
      // OP_BEQZ      
      // OP_BNEZ
      OP_LI: begin
        targetValue = immediateZeroExtend_8bit;
      end
      // OP_LW
      OP_SW: begin
        targetValue = secondRegisterValue;
      end		  
      OP_ADDSP3: begin
        targetValue = secondRegisterValue + immediateSignExtend_8bit;
      end
      OP_CMPI: begin
        tToWrite = firstRegisterValue != immediateSignExtend_8bit;
        tWriteEnable = 0;
      end
      
      // OP_LW_SP
      OP_SW_SP: begin
		    targetValue = firstRegisterValue;
		  end

      OP_INT: begin
        case (instruction[7:4])
          // 0: 
          1: begin 
            targetValue = programCounter;
          end
          2: begin
            targetValue = firstRegisterValue;
          end
          3: begin
            targetValue = 16'hBF20;
          end
          4: begin
            targetValue = firstRegisterValue;
          end 
          5: begin
            targetValue = instruction[3:0];
          end
          6: begin
            targetValue = firstRegisterValue;
          end 
          // 7: 
          // 8:
          // 9: 
          // 10: 
        endcase
      end

      5'b01100: begin
        case (instruction[10:8])
          // OP_BTEQZ_SUFFIX
          OP_ADDSP_SUFFIX: begin
            targetValue = secondRegisterValue + immediateSignExtend_8bit;
          end
          OP_MTSP_SUFFIX: begin
            targetValue = secondRegisterValue;
          end
        endcase
      end

      5'b11101: begin
        case (instruction[4:0])
          OP_AND_SUFFIX: begin
            targetValue = firstRegisterValue & secondRegisterValue;
          end
          OP_CMP_SUFFIX: begin
            tToWrite = firstRegisterValue != secondRegisterValue;
            tWriteEnable = 0;
          end
          OP_OR_SUFFIX: begin
            targetValue = firstRegisterValue | secondRegisterValue;
          end
          OP_NOT_SUFFIX: begin
            targetValue = ~secondRegisterValue;
          end
          OP_SLLV_SUFFIX: begin
            targetValue = secondRegisterValue << firstRegisterValue;
          end
          OP_SLTU_SUFFIX: begin
            tToWrite = $unsigned(firstRegisterValue) < $unsigned(secondRegisterValue);
            tWriteEnable = 0;
          end
          5'b00000: begin
            case (instruction[7:5])
              // OP_JR_MIDFIX              
              OP_MFPC_MIDFIX: begin
                targetValue = programCounter;
              end
              OP_JALR_MIDFIX: begin
                targetValue = programCounter;
              end
              // OP_JRRA_MIDFIX
            endcase
          end
        endcase
      end

      5'b11110: begin
        case (instruction[7:0])
          OP_MFIH_SUFFIX: begin
            targetValue = firstRegisterValue;
          end
          OP_MTIH_SUFFIX: begin
            targetValue = firstRegisterValue;
          end
        endcase
      end

      5'b00110: begin
        case (instruction[1:0])
          OP_SLL_SUFFIX: begin
            targetValue = secondRegisterValue << shiftImmediate;
          end
          OP_SRA_SUFFIX: begin
            targetValue = secondRegisterValue >>> shiftImmediate;
          end
        endcase
      end

      5'b11100: begin
        case (instruction[1:0])
          OP_SUBU_SUFFIX: begin
            targetValue = firstRegisterValue - secondRegisterValue;
          end
          OP_ADDU_SUFFIX: begin
            targetValue = firstRegisterValue + secondRegisterValue;
          end
        endcase
      end

      // 5'b00001  -- NOP
      default: begin
			tWriteEnable = 1;
			targetValue = 0;
      end
    endcase
  end
end

endmodule
