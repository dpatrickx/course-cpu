LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity register is
	port(
		regWrite : in std_logic_vector(2 downto 0);
		regDst : in std_logic_vector(1 downto 0);
		data : in std_logic_vector(15 downto 0);

		valueA : out std_logic_vector(15 downto 0) := "0000000000000000";
		valueB : out std_logic_vector(15 downto 0) := "0000000000000000");
end register;

architecture behavior of register is
begin
	-- read/write register array according to commands
end behavior