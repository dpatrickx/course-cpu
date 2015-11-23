module Forwarder (
	input clk,
	input rst,
	input [15:0] in,
	output reg [15:0] out
);

reg [15:0] temp;

always @ (negedge clk or negedge rst) begin
	if (!rst) begin
		temp = 0;
	end else begin
		temp = in;
	end
end

always @ (posedge clk or negedge rst) begin
	if (!rst) begin
		out = 0;
	end else begin
		out = temp;
	end
end
endmodule

module Forwarder4Bit (
	input clk,
	input rst,
	input [3:0] in,
	output reg [3:0] out
);

reg [3:0] temp;

always @ (negedge clk or negedge rst) begin
	if (!rst) begin
		temp = 0;
	end else begin
		temp = in;
	end
end

always @ (posedge clk or negedge rst) begin
	if (!rst) begin
		out = 0;
	end else begin
		out = temp;
	end
end
endmodule

