// 
// Created By Yue Shichao
// Nov 29, 2014
//


/* -------- Commands have 5bit Suffix --------*/

//ADDIU
parameter OP_ADDIU = 5'b01001;

//ADDIU3
parameter OP_ADDIU3 = 5'b01000;

//B
parameter OP_B = 5'b00010;

//BEQZ
parameter OP_BEQZ = 5'b00100;

//BNEZ
parameter OP_BNEZ = 5'b00101;

//LI
parameter OP_LI = 5'b01101;

//LW
parameter OP_LW = 5'b10011;

//SW
parameter OP_SW = 5'b11011;

//ADDSP3
parameter OP_ADDSP3 = 5'b00000;

//CMPI
parameter OP_CMPI = 5'b01110;

//LW_SP
parameter OP_LW_SP = 5'b10010;


//SW_SP
parameter OP_SW_SP = 5'b11010;

//INT
parameter OP_INT = 5'b11111;


/* --------- 01100 ----------------------*/

//BTEQZ
parameter OP_BTEQZ_PREFIX = 5'b01100;
parameter OP_BTEQZ_SUFFIX = 3'b000;

//ADDSP
parameter OP_ADDSP_PREFIX = 5'b01100;
parameter OP_ADDSP_SUFFIX = 3'b011;

//MTSP
parameter OP_MTSP_PREFIX = 5'b01100;
parameter OP_MTSP_SUFFIX = 3'b100;



/* ----------- 11101 -------------------- */


//AND
parameter OP_AND_PREFIX = 5'b11101;
parameter OP_AND_SUFFIX = 5'b01100;

//CMP
parameter OP_CMP_PREFIX = 5'b11101;
parameter OP_CMP_SUFFIX = 5'b01010;

//OR
parameter OP_OR_PREFIX = 5'b11101;
parameter OP_OR_SUFFIX = 5'b01101;

//NOT
parameter OP_NOT_PREFIX = 5'b11101;
parameter OP_NOT_SUFFIX = 5'b01111;

//SLLV
parameter OP_SLLV_PREFIX = 5'b11101;
parameter OP_SLLV_SUFFIX = 5'b00100;

//SLTU
parameter OP_SLTU_PREFIX = 5'b11101;
parameter OP_SLTU_SUFFIX = 5'b00011;


//JR
parameter OP_JR_PREFIX = 5'b11101;
parameter OP_JR_MIDFIX = 3'b000;
parameter OP_JR_SUFFIX = 5'b00000;

//MFPC
parameter OP_MFPC_PREFIX = 5'b11101;
parameter OP_MFPC_MIDFIX = 3'b010;
parameter OP_MFPC_SUFFIX = 5'b00000;

//JALR
parameter OP_JALR_PREFIX = 5'b11101;
parameter OP_JALR_MIDFIX = 3'b110;
parameter OP_JALR_SUFFIX = 5'b00000;

//JRRA
parameter OP_JRRA_PREFIX = 5'b11101;
parameter OP_JRRA_MIDFIX = 3'b001;
parameter OP_JRRA_SUFFIX = 5'b00000;



/* -------------- 11110 --------------- */

//MFIH
parameter OP_MFIH_PREFIX = 5'b11110;
parameter OP_MFIH_SUFFIX = 8'b00000000;


//MTIH
parameter OP_MTIH_PREFIX = 5'b11110;
parameter OP_MTIH_SUFFIX = 8'b00000001;


/* -------------- 00110 --------------- */

//SLL
parameter OP_SLL_PREFIX = 5'b00110;
parameter OP_SLL_SUFFIX = 2'b00;

//SRA
parameter OP_SRA_PREFIX = 5'b00110;
parameter OP_SRA_SUFFIX = 2'b11;


/* ------------- 11100 ---------------- */

//SUBU
parameter OP_SUBU_PREFIX = 5'b11100;
parameter OP_SUBU_SUFFIX = 2'b11;

//ADDU
parameter OP_ADDU_PREFIX = 5'b11100;
parameter OP_ADDU_SUFFIX = 2'b01;


/* ----------- Special Commands -------------*/

//NOP
parameter OP_NOP = 16'b0000100000000000;


