module MemoryMapping (
  input [15:0] virtual_address,
  output reg [15:0] actual_ram_address,
  input [15:0] ramData,
  input [7:0] serialPortData,
  input [1:0] serialPortState,
  output reg [15:0] realData,
  output reg [1:0] index
);

localparam RAM = 2'b00,
  SERIALPORT_DATA = 2'b10,
  SERIALPORT_STATE = 2'b11,
  GRAPHIC_CARD = 2'b01;

always @ (virtual_address)
begin
  actual_ram_address = virtual_address;
  if (virtual_address == 16'hbf00)
    index = SERIALPORT_DATA;
  else if (virtual_address == 16'hbf01)
    index = SERIALPORT_STATE;
  else if (virtual_address == 16'hbf0a)
	 index = GRAPHIC_CARD;
  else
    index = RAM;
end

always @ (*)
  case (index)
    RAM:
      realData = ramData;
    SERIALPORT_DATA:
      realData = {8'h00, serialPortData};
    SERIALPORT_STATE:
      realData = {14'b00000000000000, serialPortState};
    default:
      realData = 0;
  endcase

endmodule
