module MemoryAddressCalculator (
	input clk,
	input rst,
	input [15:0] instruction_in,
	input [15:0] first_register_value,
	input [15:0] second_reigster_value,
	output reg [1:0] memory_control,
	output reg [15:0] memory_address
);

wire [15:0] immediate_from_5;
wire [15:0] immediate_from_8;

reg [15:0] instruction;
reg [15:0] rm_1, rm_2;

`include "InstructionCode.h"
`include "Const.h"
assign immediate_from_5 = {instruction[4]? 11'b11111111111: 11'b00000000000, instruction[4:0]};
assign immediate_from_8 = {instruction[7]? 8'hFF: 8'h00, instruction[7:0]};

always @ (negedge clk or negedge rst) begin
	if (!rst) begin
		instruction = 16'b0000100000000000;
		rm_1 = 0;
		rm_2 = 0;
	end else begin
		instruction = instruction_in;
		rm_1 = first_register_value;
		rm_2 = second_reigster_value;
	end
end

always @ (posedge clk or negedge rst) begin
	if (!rst) begin
		memory_address = 16'hFFFF;
		memory_control = IDLE;
	end else begin
		case (instruction[15:11])
			OP_LW_SP: begin
				memory_address = rm_2 + immediate_from_8;
				memory_control = READ_CONTROL;
			end
			OP_LW: begin
				memory_address = rm_1 + immediate_from_5;
				memory_control = READ_CONTROL;
			end
			OP_SW_SP: begin
				memory_address = rm_2 + immediate_from_8;
				memory_control = WRITE_CONTROL;
			end
			OP_SW: begin
				memory_address = rm_1 + immediate_from_5;
				memory_control = WRITE_CONTROL;
			end
      OP_INT: begin
        case (instruction[7:4])
          // 0: 
          // 1: 
          // 2: 
          // 3: 
          4: begin
            memory_address = rm_2;
            memory_control = WRITE_CONTROL;
          end
          5: begin
            memory_address = rm_2 + 1;
            memory_control = WRITE_CONTROL;
          end
          6: begin
            memory_address = rm_2 + 2;
            memory_control = WRITE_CONTROL;
          end 
          // 7: 
          // 8:
          // 9: 
          // 10: 
        endcase
      end
			default begin
				memory_address = 16'hFFFF;
				memory_control = IDLE;
			end
		endcase
	end
end

endmodule
