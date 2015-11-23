module InstructionFetcher (
	input clk,
	input rst,
	input [15:0] current_PC, // address required by CPU
	input [15:0] mem_read, // value read from memory 
	output reg [15:0] current_IR_addr,
	output reg [15:0] current_IR
);

`include "InstructionCode.h"

always @ (negedge clk) begin
	current_IR_addr = current_PC;
end

always @ (negedge rst or posedge clk) begin
	if (!rst) begin
		current_IR = OP_NOP;
	end else begin
		current_IR = mem_read;
	end
end

endmodule