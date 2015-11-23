module Register (
  input clock,
  input reset,
  input [3:0] firstRegisterAddress,
  input [3:0] secondRegisterAddress,
  input tWriteEnable,
  input tToWrite,
  input [3:0] targetRegisterAddress,
  input [15:0] targetValue,
  output [15:0] firstRegisterValueOrigin,
  output [15:0] secondRegisterValueOrigin,
  output tRead,
  output [175:0] debug_registers
);

reg [15:0] registers [0:12];
reg tRegister;

// 0000 - 0111 R0 - R7
// 1000 - SP
// 1001 - EPC
// 1010 - ESP
// 1011 - IH
// 1100 - RA

assign debug_registers = {
    registers[0],
    registers[1],
    registers[2],
    registers[3],
    registers[4],
    registers[5],
    registers[6],
    registers[7],
    registers[8],
    registers[9],
    registers[10]
};
assign firstRegisterValueOrigin = registers[firstRegisterAddress];
assign secondRegisterValueOrigin = registers[secondRegisterAddress];
assign tRead = tRegister;

always @ (negedge tWriteEnable) begin
  if (!tWriteEnable) begin
    tRegister = tToWrite;
  end
end

always @ (negedge clock, negedge reset) begin
  if (!reset) begin
    registers[0] = 0;
    registers[1] = 0;
    registers[2] = 0;
    registers[3] = 0;
    registers[4] = 0;
    registers[5] = 0;
    registers[6] = 0;
    registers[7] = 0;
    registers[8] = 0;
    registers[9] = 0;
    registers[10] = 0;
  end else begin
    if (targetRegisterAddress <= 12) begin
      registers[targetRegisterAddress] = targetValue;
    end
  end
end

endmodule




