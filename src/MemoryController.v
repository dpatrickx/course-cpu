module MemoryController (
  input clk,
  input [15:0] address_A,
  input [15:0] data_write, 
  input [1:0] mem_control, 
  output reg [15:0] AdataRead,
  input [15:0] address_B,
  output reg [15:0] BdataRead,

  inout [15:0] data_bus,
  output [17:0] addr_bus,
  output mem_read, mem_write,
  output mem_enable
);

reg [15:0] addr;
wire [15:0] data_read;
reg [1:0] control;

always @ (clk, address_A, mem_control, address_B)
begin
  if (clk) // negedge
  begin
    addr = address_A;
    control = mem_control;
  end
  else // posedge
  begin
    addr = address_B;
    control = 2'b10;
  end
end

always @ (clk, data_read)
begin
  if (clk) // negedge
    AdataRead = data_read;
  else // posedge
    BdataRead = data_read;
end

Memory mem (
  control,
  addr, data_write,
  data_bus, addr_bus,
  data_read,
  mem_read, mem_write, mem_enable
);

endmodule
