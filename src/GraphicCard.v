module GraphicCard (
	input CLK_0,
	output clk_out,
	input clk,
	input reset,
	input [1:0] index,
	input [15:0] ram_data,

	output reg [2:0] R,
	output reg [2:0] G,
	output reg [2:0] B,
	output reg Hs,
	output reg Vs
);

localparam GRAPHIC_CARD = 2'b01;
localparam TWENTY_FIVE = 11'b00000011001;
localparam TWENTY_SIX  = 11'b00000011010;
localparam THIRTY_NINE = 11'b00000100111;
localparam THIRTY_EIGHT= 11'b00000100110;
localparam ZERO        = 11'b00000000000;
localparam ONE         = 11'b00000000001;
localparam TWO         = 11'b00000000010;
localparam FIFTEEN 	  = 11'b00000001111;
localparam THIRTY_TWO      = 11'b00000100000;
localparam SECOND_BIGGEST = {FIFTEEN[3:0], THIRTY_EIGHT[6:0]};
localparam BIGGEST     = {FIFTEEN[3:0], THIRTY_NINE[6:0]};
localparam START = 2'b00,
	FORWARD = 2'b01,
	BACKWARD = 2'b10;

wire dwctrl;
reg [7:0] dwdata;
reg [10:0] dwaddr;
reg dclk;

reg [10:0] counter;

initial begin
	R = 2'b00;
	G = 2'b00;
	B = 2'b00;
	Hs = 1'b0;
	Vs = 1'b0;
	counter = ZERO;
end

assign dwaddr_o = counter;
assign clk_out = dclk;
assign dwctrl = 1;
assign mode = 1;

VGA_play vga(
	.CLK_0(CLK_0),
	.clkout(dclk),
	.reset(reset),
	.R(R),
	.G(G),
	.B(B),
	.Hs(Hs),
	.Vs(Vs),
	.wctrl(dwctrl),
	.waddr(dwaddr),
	.wdata(dwdata)
);

always @(posedge clk) begin
	dwaddr = counter;
end

always @(negedge clk or negedge reset) begin
	if (reset == 0) begin
		counter = ZERO;
	end else if (index == GRAPHIC_CARD) begin
		if (ram_data[7:0] == 8'h60) begin
			dwdata = 8'b00000000;
				if (counter != ZERO) begin
					if (counter[5:0] != ZERO[5:0]) begin
						counter = counter - ONE;
					end else begin
						counter = counter - TWENTY_FIVE;
					end
				end
		end else begin
			dwdata = ram_data[7:0] - THIRTY_TWO[7:0];
				if (counter != BIGGEST) begin
					if (counter[5:0] != THIRTY_NINE[5:0]) begin
						counter = counter + ONE;
					end else begin 
						counter = counter + TWENTY_FIVE;
					end
				end
		end
	end else begin
		dwdata = 8'b00000000;
	end
end

endmodule




