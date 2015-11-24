LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- author : dpatrickx
-- ID : compute pc of jump instructions

entity branchPc is
	port(
		pcIn : in std_logic_vector(15 downto 0);
		op : in std_logic_vector(4 downto 0);

		pcOut : out std_logic_vector(15 downto 0));
end branchPc;

architecture behavior of branchPc is
begin
	-- get new pc according to different jump command
end behavior