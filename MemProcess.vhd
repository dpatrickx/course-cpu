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
		 rd_in: in std_logic_vector(15 downto 0);

		 PCaddr_in: in std_logic_vector(15 downto 0);

		 ex_data: in std_logic_vector(15 downto 0);
		 ans: in std_logic_vector(15 downto 0);
		 MemRead: in std_logic;
		 MemWrite: in std_logic;
		 ram2_oe: out std_logic;
		 ram2_we: out std_logic;
		 ram2_en: out std_logic;
		 addr_ram2: out std_logic_vector(17 downto 0);
		 data_ram2: inout std_logic_vector(15 downto 0);

		 data: out std_logic_vector(15 downto 0);
		 rd: out std_logic_vector(15 downto 0);
		 clk: out std_logic_vector(15 downto 0)
		 PC: out std_logic_vector(15 downto 0));
end MemProcess;

architecture behavior of MemProcess is
	type state is(ready, reading, writing, get);
	signal current_state: state: = ready;
	signal data0 : std_logic_vector(15 downto 0);
begin
	with state select
		clk <= '1' when reading, writing,
			   '0' when others;
	addr_ram2 <= "000000000000000000";
	rd <= rd_in;
	process(clk_50m)
	begin
		if clk_50m = '1' and clk_50m'event then
			case current_state is
				when ready =>
					ram2_oe <= '1';
					ram2_we <= '1';
					ram2_en <= '0';
					addr_ram2(15 downto 0) <= ans;
					data_ram2 <= ex_data;
					ram2_we <= not MemWrite;
					current_state <= writing;
				when writing =>
					data_ram2 <= "ZZZZZZZZZZZZZZZZ";
					ram2_oe <= not MemRead;
					current_state <= reading;
				when reading =>
					ram2_we <= '1';
					if MemRead = '1' then
						data0 <= data_ram2;
					end if;
					addr_ram2(15 downto 0) <= PCaddr_in;
					data_ram2 <= "ZZZZZZZZZZZZZZZZ";
					ram2_oe <= '0';
					current_state <= get;
				when get =>
					PC <= data_ram2;
					current_state <= ready;
				when others =>
					current_state <= ready;
			end case;
		end if;
	end process;

end behavior;