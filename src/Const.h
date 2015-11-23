// Basic Vectors
parameter Z_2 = 2'bZZ;
parameter Z_4 = 4'bZZZZ;
parameter Z_8 = 8'bZZZZZZZZ;
parameter Z_16 = 16'bZZZZZZZZZZZZZZZZ;
// For Memory Control
parameter IDLE = 2'b00;
parameter WRITE_CONTROL = 2'b01;
parameter READ_CONTROL = 2'b10;

// Special Register Address
parameter REG_SP = 4'b1000;
parameter REG_EPC = 4'b1001;
parameter REG_ESP = 4'b1010;
parameter REG_IH = 4'b1011;
parameter REG_RA = 4'b1100;
