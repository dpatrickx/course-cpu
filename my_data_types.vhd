LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- author : dpatrickx
-- define some data types

PACKAGE my_data_types IS
    subtype WORD is std_logic_vector(15 downto 0);
    type  REGISTERARRAY is array(0 to 7) of WORD;
    constant ZERO_16    : std_logic_vector(15 downto 0) := "0000000000000000";
    constant ZERO_13    : std_logic_vector(12 downto 0) := "00000000000000";
    constant ZERO_12    : std_logic_vector(11 downto 0) := "0000000000000";
    constant ZERO_11    : std_logic_vector(10 downto 0) := "000000000000";
    constant ZERO_8     : std_logic_vector(7 downto 0)  := "00000000000";
    constant ZERO_3     : std_logic_vector(2 downto 0)  := "000";
    constant ONE_16     : std_logic_vector(15 downto 0) := "1111111111111111";
    constant ONE_13     : std_logic_vector(12 downto 0) := "11111111111111";
    constant ONE_12     : std_logic_vector(11 downto 0) := "1111111111111";
    constant ONE_11     : std_logic_vector(10 downto 0) := "111111111111";
    constant ONE_8      : std_logic_vector(7 downto 0)  := "11111111111";
    constant ONE_3      : std_logic_vector(2 downto 0)  := "111";

    constant ADDU_      : std_logic_vector(3 downto 0)  := "0000";
    constant SUBU_      : std_logic_vector(3 downto 0)  := "0001";
    constant AND_       : std_logic_vector(3 downto 0)  := "0010";
    constant OR_        : std_logic_vector(3 downto 0)  := "0011";
    constant NEG_       : std_logic_vector(3 downto 0)  := "0100";
    constant NOT_       : std_logic_vector(3 downto 0)  := "0101";
    constant CMP_       : std_logic_vector(3 downto 0)  := "0110";
    constant PASSA_     : std_logic_vector(3 downto 0)  := "0111";
    constant PASSB_     : std_logic_vector(3 downto 0)  := "1000";
    constant SLL_       : std_logic_vector(3 downto 0)  := "1001";
    constant SRA_       : std_logic_vector(3 downto 0)  := "1010";
    constant SRL_       : std_logic_vector(3 downto 0)  := "1010";

    constant Srcb_PC : std_logic_vector(2 downto 0)  := "010";
    constant Srcb_IH : std_logic_vector(2 downto 0)  := "100";
    constant Srcb_SP : std_logic_vector(2 downto 0)  := "111";
    constant Srcb_B  : std_logic_vector(2 downto 0)  := "000";
    constant Srcb_IM : std_logic_vector(2 downto 0)  := "111";

    constant Srca_A  : std_logic  := "0";
    constant Srca_IM : std_logic  := "1";

    constant Regw_NO : std_logic_vector(2 downto 0)  := "000";
    constant Regw_RD : std_logic_vector(2 downto 0)  := "001";
    constant Regw_T  : std_logic_vector(2 downto 0)  := "011";
    constant Regw_IH : std_logic_vector(2 downto 0)  := "101";
    constant Regw_SP : std_logic_vector(2 downto 0)  := "010";

    constant Regd_RX  : std_logic_vector(1 downto 0)  := "00";
    constant Regd_RY  : std_logic_vector(1 downto 0)  := "01";
    constant Regd_RZ  : std_logic_vector(1 downto 0)  := "10";
    constant Regd_SP  : std_logic_vector(1 downto 0)  := "11";

    constant Imms_10  : std_logic_vector(2 downto 0)  := "000";
    constant Imms_70  : std_logic_vector(2 downto 0)  := "001";
    constant Imms_40  : std_logic_vector(2 downto 0)  := "010";
    constant Imms_30  : std_logic_vector(2 downto 0)  := "011";
    constant Imms_42  : std_logic_vector(2 downto 0)  := "100";
    constant Imms_00  : std_logic_vector(2 downto 0)  := "111";

    constant Pcs_NR   : std_logic  := "0";
    constant Pcs_ID   : std_logic  := "1";

    constant Memd_A   : std_logic := "0";
    constant Memd_B   : std_logic := "1";

    constant NO    : std_logic := "0";
    constant YES   : std_logic := "1";
END my_data_types;
