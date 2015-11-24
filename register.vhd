LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use my_data_types.ALL;

-- author : daptrickx
-- ID : read/write to registers

entity register is
	port(
		regWrite 	: in std_logic_vector(2 downto 0);
		regWriteAdd : in std_logic_vector(2 downto 0); -- addr of rd
		data 		: in std_logic_vector(15 downto 0);
		op 			: in std_logic_vector(4 downto 0);
		instruction : in std_logic_vector(15 downto 0);

		regT : inout std_logic_vector(15 downto 0);
		regIH : inout std_logic_vector(15 downto 0);
		regSP : inout std_logic_vector(15 downto 0);
		regiArr : inout REGISTERARRAY;

		valueA : out std_logic_vector(15 downto 0) := "0000000000000000";
		valueB : out std_logic_vector(15 downto 0) := "0000000000000000");
end register;

architecture behavior of register is
signal rs : std_logic_vector(2 downto 0);
signal rt : std_logic_vector(2 downto 0);
begin
	readReg: process(op)
	begin
	-- read register
		-- ADDU SUBU AND OR NEG NOT CMP MOVE
		rs <= instruction(10 downto 8);
		rt <= instruction(7 downto 5);
		valueA <= regiArr(conv_integer(rs));
		valueB <= regiArr(conv_integer(rs));
	end process;

	writeReg: process(regWrite, regWriteAdd, data)
	begin
		if regWrite = "001" then
			-- write to register array
			regiArr(conv_integer(regWriteAdd)) <= data;
		elsif regWrite = "011" then
			-- write to register T
			regT <= data;
		elsif regWrite = "101" then
			-- write to register IH
			regIH <= data;
		elsif regWrite = "010" then
			-- write to register SP
			regSP <= data;
		else
			-- nothing
		end if;
	end process;
end behavior