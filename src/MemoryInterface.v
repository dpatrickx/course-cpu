// MemoryInterface.v
// By Jiaming.
// Interface for data passing between memory and cpu in MEM stage.
// The signal will send to memory only when posedge clk;

module MemoryInterface (
	input clk,
	input rst,
	input [15:0] memory_address_from_cpu,
	input [15:0] target_value_from_cpu,
	input [1:0] memory_control_signal_from_cpu,
	input [15:0] data_fetched_from_memory,

	output reg [15:0] memory_address_to_memory,
	output [15:0] data_fetched_to_cpu,
	output reg [1:0] memory_control_signal_to_memory,
	output reg [15:0] target_value_to_memory
);

reg [15:0] memory_address_temp;
reg [1:0] memory_control_signal_temp;
reg [15:0] target_value_temp;

assign data_fetched_to_cpu = data_fetched_from_memory;

always @ (negedge clk or negedge rst) begin
	if (!rst) begin
		memory_address_temp = 0;
		memory_control_signal_temp = 0;
		target_value_temp = 0;
	end else begin
		memory_address_temp = memory_address_from_cpu;
		memory_control_signal_temp = memory_control_signal_from_cpu;
		target_value_temp = target_value_from_cpu;
	end
end

always @ (posedge clk or negedge rst) begin
	if (!rst) begin
		memory_address_to_memory = 0;
		memory_control_signal_to_memory = 0;
		target_value_to_memory = 0;
	end else begin
		memory_address_to_memory = memory_address_temp;
		memory_control_signal_to_memory = memory_control_signal_temp;
		target_value_to_memory = target_value_temp;
	end
end


endmodule