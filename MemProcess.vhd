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

entity MemProcess is
	port(clk_50m: in std_logic;

		 ex_data: in std_logic_vector(15 downto 0);
		 ans: in std_logic_vector(15 downto 0);
		 MemRead: in std_logic;
		 MemWrite: in std_logic;
		 MemtoReg: in std_logic;
		 ram2_oe: out std_logic;
		 ram2_we: out std_logic;
		 ram2_en: out std_logic;
		 addr_ram2: out std_logic_vector(17 downto 0);
		 data_ram2: inout std_logic_vector(15 downto 0);

		 data: out std_logic_vector(15 downto 0);
		 rd: out std_logic_vector(15 downto 0)
		 PC: out std_logic_vector(15 downto 0));
end MemProcess;

architecture behavior of MemProcess is
	type state is(ready, reading, writing, loading, get);
	signal current_state: state: = ready;
	signal data0 : std_logic_vector(15 downto 0);
begin
	process(clk)
	begin
		if clk = '1' and clk'event then
			case current_state is
				when ready =>
					if MemWrite = '1' then
						ram2_oe <= '1';
						ram2_we <= '1';
						ram2_en <= '0';
						addr_ram2 <= ans;
						current_state <= writing;
					else
						ram2_oe <= '1';
						ram2_we <= '1';
						ram2_en <= '0';
						data_ram2 <= "ZZZZZZZZZZZZZZZZ";
						addr_ram2 <= ans;
						current_state <= reading;
					end if;
				when writing =>
					data_ram2 <= ex_data;
					ram2_we <= '0';
					current_state <= get;
				when reading =>
					ram2_oe <= '0';
					data0 <= data_ram2;
					current_state <= get;
				when get =>
					data_ram2 <= "ZZZZZZZZZZZZZZZZ";
					ram2_we <= '1';
					ram2_oe <= '0';
					current_state <= get;
				when loading =>
					PC <= data_ram2;
					current_state <= ready;
			end case;
		end if;
	end process;

end behavior;