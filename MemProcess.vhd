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

		 ram1_oe: out std_logic;
		 ram1_we: out std_logic;
		 ram1_en: out std_logic;
		 addr_ram1: out std_logic_vector(17 downto 0);
		 data_ram1: inout std_logic_vector(15 downto 0);

		 ComDataReady : in  STD_LOGIC;
         ComRdn : out  STD_LOGIC;
         ComTbre : in  STD_LOGIC;
         ComTsre : in  STD_LOGIC;
         ComWrn : out  STD_LOGIC;

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
	ram2_oe <= '1';
	ram2_we <= '1';
	ram2_en <= '1';
	ram1_oe <= '1';
	ram1_we <= '1';
	ram1_en <= '1';
	ComWrn <= '1';
	ComRdn <= '1';
	process(clk_50m)
	begin
		if clk_50m = '1' and clk_50m'event then
			case current_state is
				when ready =>
					if ans = "1011111100000000" or ans = "1011111100000001" then
						ram2_oe <= '1';
						ram2_we <= '1';
						ram2_en <= '1';
						ram1_oe <= '1';
						ram1_we <= '1';
						ram1_en <= '1';
					else
						ram2_oe <= '1';
						ram2_we <= '1';
						ram2_en <= '0';
						ram1_oe <= '1';
						ram1_we <= '1';
						ram1_en <= '1';
					end if;
					current_state <= writing;
				when writing =>
					if ans = "1011111100000000" then
						data_ram1 <= ex_data;
						ComWrn <= not MemWrite;
					elsif ans = "1011111100000001" then
						ComWrn <= '1';
					else
						addr_ram2(15 downto 0) <= ans;
						data_ram2 <= ex_data;
						ram2_we <= not MemWrite;
					end if;
					current_state <= reading;
				when reading =>
					if MemRead = '1' then
						if ans = "1011111100000000" then
							ComWrn <= '1';
							data_ram1 <= "ZZZZZZZZZZZZZZZZ";
							ComRdn <= not MemRead;
							data <= data_ram1;
						elsif ans = "1011111100000001"  then
							ComWrn <= '1';
							ComRdn <= '1';
							data(15 downto 2) <= (others => '0');
							data(0) <= ComTbre and ComTsre; ---写信号ready
							data(1) <= ComDataReady; ---读信号ready
						else
							ram2_we <= '1';
							data_ram2 <= "ZZZZZZZZZZZZZZZZ";
							ram2_oe <= not MemRead;
							data <= data_ram2;
						end if;
					end if;
					current_state <= get;
				when get =>
					ram2_oe <= '1';
					ComRdn <= '1';
					if PCaddr_in = "1011111100000000" then
						data_ram1 <= "ZZZZZZZZZZZZZZZZ";
						ComRdn <= '0';
						PC <= data_ram1;
					elsif PCaddr_in = "1011111100000001" then
					else
						addr_ram2 <= "00"&PCaddr_in;
						data_ram2 <= "ZZZZZZZZZZZZZZZZ";
						ram2_oe <= '0';
						PC <= data_ram2;
					end if;
					current_state <= ready;
				when others =>
					current_state <= ready;
			end case;
		end if;
	end process;

end behavior;