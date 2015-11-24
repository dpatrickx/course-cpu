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

entity MemDataTrans is
	port(clk: in std_logic;

		 data_transfer: in std_logic;
		 data_from_wb: in std_logic_vector(15 downto 0); --data_WB
		 data_from_ex: in std_logic_vector(15 downto 0); --ex

		 data_input: out std_logic_vector(15 downto 0)
		 );
end MemDataTrans;

architecture behavior of MemDataTrans is
begin
	process(data_from_ex, data_from_wb)
	begin
		if data_transfer='1' then
			data_input <= data_from_ex;
		else
			data_input <= data_from_wb;
		end if;
	end process;

end behavior;