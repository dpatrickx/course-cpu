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

entity MEM is
	port(clk: in std_logic;
		 rst: in std_logic;

		 ex: in std_logic_vector(15 downto 0);
		 ans: in std_logic_vector(15 downto 0);
		 MemRead: in std_logic;
		 MemWrite: in std_logic;
		 MemtoReg: in std_logic;
		 ram_oe: out std_logic;
		 ram_we: out std_logic;
		 ram_en: out std_logic;
		 addr_ram: out std_logic_vector(17 downto 0);
		 data_ram: inout std_logic_vector(15 downto 0);

		 data: out std_logic_vector(15 downto 0);
		 rd: out std_logic_vector(15 downto 0));
end MEM;

architecture behavior of MEM is
	type step is(mem, choose);
	type state is(ready, reading, writing, loading);
	signal current_state: state: = ready;
	signal data0 : std_logic_vector(15 downto 0);
begin
	process(clk)
	begin
	if clk = '1' and clk'event then
		if MemWrite = '1' then
			case current_state is
				when ready =>
					ram_oe <= 1;
					ram_we <= 1;
					ram_en <= 1;
					addr_ram <= ans;
					current_state <= loading;
				when loading =>
					data_ram <= ex;
					current_state <= writing;
				when writing =>
					ram_we <= '0';
					current_state <= ready;
			end case;
		end if;
		if MemRead = '1' then
			case current_state is
				when ready =>
					ram_oe <= 1;
					ram_we <= 1;
					ram_en <= 1;
					data_ram <= "ZZZZZZZZZZZZZZZZ";
					addr_ram <= ans;
					current_state <= loading;
				when loading =>
					ram_oe <= '0';
					current_state <= reading;
				when reading =>
					data0 <= data_ram;
					current_state <= ready;
			end case;
		end if;
	end if;
	end process;

end behavior;