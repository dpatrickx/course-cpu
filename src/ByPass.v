module ByPass (
  input [3:0] sourceAddress,
  input [15:0] sourceValue,
  input [3:0] updatedAddress,
  input [15:0] updatedValue,
  output [15:0] selectedValue
);

assign selectedValue = updatedAddress == sourceAddress ? updatedValue : sourceValue;

endmodule
