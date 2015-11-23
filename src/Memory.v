module Memory (
  input [1:0] control,
  input [15:0] addr, data_write,
  inout [15:0] data_bus,
  output reg [17:0] address_bus,
  output reg [15:0] data_read,
  output reg mem_read, mem_write,
  output mem_enable
);

parameter IDLE = 2'b00,
  WRITE = 2'b01,
  READ = 2'b10;

assign data_bus = mem_write? 16'bZZZZZZZZZZZZZZZZ:data_write;

assign mem_enable = 0;

initial
begin
  data_read <= 0;
  mem_write <= 1;
  mem_read <= 1;
end

always @ (addr)
  address_bus = addr;

always @ (data_bus)
  data_read <= data_bus;

always @ (control)
begin
  begin
    case (control)
      WRITE:
      begin
        mem_read <= 1;
        mem_write <= 0;
      end
      READ:
      begin
        mem_write <= 1;
        mem_read <= 0;
      end
      default:
      begin
        mem_write <= 1;
        mem_read <= 1;
      end
    endcase
  end
end

endmodule
