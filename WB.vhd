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

entity WB is
	port(clk: in std_logic;

		 rd: in std_logic_vector(15 downto 0);
		 data: in std_logic_vector(15 downto 0);

		 data_reg: out std_logic_vector(15 downto 0);
		 addr_reg: out std_logic_vector(15 downto 0);
		 data_trans: out std_logic_vector(15 downto 0)
		 );
end WB;

architecture behavior of WB is
begin
	process(clk)
	begin
		if clk = '1' and clk'event then
			data_reg <= data;
			addr_reg <= rd;
			data_trans <= data;
		end if;
	end process;

end behavior;