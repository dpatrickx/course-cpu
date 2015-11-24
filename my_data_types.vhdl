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
END my_data_types;
