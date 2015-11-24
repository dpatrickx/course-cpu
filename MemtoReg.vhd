LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MemReg is
	port(clk: in std_logic;

		 MemtoReg: in std_logic;
		 data_from_mem: in std_logic_vector(15 downto 0); --data0
		 data_from_alu: in std_logic_vector(15 downto 0); --ans

		 data: out std_logic_vector(15 downto 0)
		 );
end MemReg;

architecture behavior of MemReg is
begin
	process(clk)
	begin
		if clk = '1' and clk'event then
			if MemtoReg='1' then
				data <= data_from_mem;
			else
				data <= data_from_alu;
			end if;
		end if;
	end process;

end behavior;