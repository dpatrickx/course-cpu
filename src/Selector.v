module Selector (
  input clk, rst,
  input [1:0] memory_control,
  input [15:0] mem_data_read,
  input [15:0] alu_cal_result,
  output [15:0] select_cal_result
);

reg [15:0] temp_result;
reg [1:0] memory_control_temp;



// I modified this place
always @ (negedge clk or negedge rst) begin
  if (!rst) begin
    temp_result = 0;
  end
  else begin
    temp_result = alu_cal_result;
	 memory_control_temp = memory_control;
  end
end

assign select_cal_result = memory_control_temp[1]? mem_data_read : temp_result;

endmodule
