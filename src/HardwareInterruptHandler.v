module HardwareInterruptHandler (
  input clock, 
  input reset,
  input interruptSignal,
  input handInterruptSignalIn,
  output interruptSignalOut
);

reg handSignalCache [0:3];

always @ (posedge clock or negedge reset) begin
  if (!reset) begin
    handSignalCache[0] <= 1;
    handSignalCache[1] <= 1;
    handSignalCache[2] <= 1;
    handSignalCache[3] <= 1;
  end else begin
    handSignalCache[0] <= handSignalCache[1];
    handSignalCache[1] <= handSignalCache[2];
    handSignalCache[2] <= handSignalCache[3];
    handSignalCache[3] <= handInterruptSignalIn;
  end
end

assign interruptSignalOut = (handSignalCache[0] && handSignalCache[1] && !handSignalCache[2] && !handSignalCache[3]) ?  1'b1   :  interruptSignal;

endmodule

