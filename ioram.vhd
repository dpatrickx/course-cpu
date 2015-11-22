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

entity ioram is
	port(clk: in std_logic;
		  rst: in std_logic;
		  
		  input: in std_logic_vector(15 downto 0);
		  led: out std_logic_vector(15 downto 0);
		  addr_ram1: out std_logic_vector(17 downto 0):="000000000000000000";
		  data_ram1: inout std_logic_vector(15 downto 0);
		  ram1oe: out std_logic;
		  ram1we: out std_logic;
		  ram1en: out std_logic;
		  
		  addr_ram2: out std_logic_vector(17 downto 0):="000000000000000000";
		  data_ram2: inout std_logic_vector(15 downto 0);
		  ram2oe: out std_logic;
		  ram2we: out std_logic;
		  ram2en: out std_logic;
		  
		  digital: out std_logic_vector(6 downto 0);
		  seri_rdn: out STD_LOGIC := '1';
		  seri_wrn: out STD_LOGIC := '1');
		  
end ioram;

architecture behavior of ioram is
	type step is(read1, write1, read2, write2);
	type state is(input_addr, input_data, add_addr, add_data, dec_data, reading, writing, loading);
	
	signal current_step: step:= read1;
	signal current_state: state:= input_addr;
	
	signal addr : std_logic_vector(15 downto 0);
	signal data : std_logic_vector(15 downto 0);
	
	signal start_addr : std_logic_vector(15 downto 0);
	
begin
	addr_ram1(16) <= '0';
	addr_ram1(17) <= '0';
	ram1en <= '0';
	addr_ram2(16) <= '0';
	addr_ram2(17) <= '0';
	ram2en <= '0';
	seri_rdn<= '1';
	seri_wrn<= '1';
	process(clk, rst, input)
	begin
		if rst='0' then
			case input(1 downto 0) is
				when "00" =>
					current_step <= read1;
				when "01" => 
					current_step <= write1;
				when "10" =>
					current_step <= read2;
					data <= "0101010101010101";
				when "11" =>
					current_step <= write2;
				when others =>
					current_step <= read1;
			end case;
			current_state <= input_addr;
			ram1oe <= '1';
			ram1we <= '1';
			ram2oe <= '1';
			ram2we <= '1';
		elsif clk = '1' and clk'event then
			case current_step is
				when write1 => --input_addr -> input_data -> writing -> add_addr -> add_data -> writing
					case current_state is
						when input_addr =>
							addr_ram1(15 downto 0) <= input;
							addr <= input;
							start_addr <= input;
							current_state <= input_data;
						when input_data =>
							data_ram1 <= input;
							data <= input;
							current_state <= writing;
						when writing =>
							ram1we <= '0';
							current_state <= add_addr;
						when add_addr =>
							ram1we <= '1';
							addr_ram1(15 downto 0) <= addr + 1;
							addr <= addr + 1;
							current_state <= add_data;
						when add_data =>
							data_ram1 <= data + 1;
							data <= data + 1;
							current_state <= writing;
						when others =>
							null;
					end case;
				when read1 => --input_addr -> loading -> reading -> add_addr -> loading
					case current_state is
						when input_addr =>
							addr_ram1(15 downto 0) <= start_addr;
							addr <= start_addr;
							data_ram1 <= "ZZZZZZZZZZZZZZZZ";
							current_state <= loading;
						when loading =>
							ram1oe <= '0';
							current_state <= reading;
						when reading =>
							ram1oe <= '1';
							data <= data_ram1;
							current_state <= add_addr;
						when add_addr =>
							addr_ram1(15 downto 0) <= addr + 1;
							addr <= addr + 1;
							data_ram1 <= "ZZZZZZZZZZZZZZZZ";
							current_state <= loading;
						when others =>
							null;
					end case;
				when write2 => --input_addr -> loading -> dec_data -> writing -> add_addr
					case current_state is
						when input_addr =>
							addr_ram2(15 downto 0) <= start_addr;
							addr_ram1(15 downto 0) <= start_addr;
							addr <= start_addr;
							data_ram1 <= "ZZZZZZZZZZZZZZZZ";
							current_state <= loading;
						when loading =>
							ram1oe <= '0';
							current_state <= dec_data;
						when dec_data =>
							ram1oe <= '1';
							data_ram2 <= data_ram1 - 1;
							data <= data_ram1 - 1;
							current_state <= writing;
						when writing =>							
							ram2we <= '0';
							current_state <= add_addr;
						when add_addr =>
							ram2we <= '1';
							addr_ram2(15 downto 0) <= addr + 1;
							addr_ram1(15 downto 0) <= addr + 1;
							addr <= addr + 1;
							data_ram1 <= "ZZZZZZZZZZZZZZZZ";
							current_state <= loading;
						when others =>
							null;
					end case;
				when read2 => --input_addr -> loading -> reading -> add_addr -> loading
					case current_state is
						when input_addr =>
							addr_ram2(15 downto 0) <= start_addr;
							addr <= start_addr;
							data_ram2 <= "ZZZZZZZZZZZZZZZZ";
							current_state <= loading;
						when loading =>
							ram2oe <= '0';
							current_state <= reading;
						when reading =>
							ram2oe <= '1';
							data <= data_ram2;
							current_state <= add_addr;
						when add_addr =>
							addr_ram2(15 downto 0) <= addr + 1;
							addr <= addr + 1;
							data_ram2 <= "ZZZZZZZZZZZZZZZZ";
							current_state <= loading;
						when others =>
							null;
					end case;
			end case;
		end if;
	end process;
	
	process (data)
	begin
		led <= data; 
	end process;
	
	process (current_state)
	begin
		case current_state is
			when input_addr => 	
				if(current_step = write1) then
					digital <= "0000110"; -- 1
				elsif(current_step = read1) then
					digital <= "0000001"; -- a
				elsif(current_step = write2) then
					digital <= "1000000"; -- g
				elsif(current_step = read2) then
					digital <= "0001000"; -- d
				end if;
			when add_addr   => 	   digital <= "1100110"; -- 4
			when input_data => 		digital <= "1011011"; -- 2
			when writing    => 		digital <= "1001111"; -- 3
			when dec_data   => 		digital <= "1111101"; -- 6
			when add_data   => 		digital <= "1101101"; -- 5
			when loading    => 		digital <= "0000111"; -- 7
			when reading    =>		digital <= "1111111"; -- 8
			-- write1 : input_addr -> input_data -> writing -> add_addr -> add_data -> writing 
			-- write2 : input_addr -> loading -> dec_data -> writing -> add_addr -> loading
			-- read1 : input_addr -> loading -> reading -> add_addr -> loading
			-- read2 : input_addr -> loading -> reading -> add_addr -> loading
		end case;
	end process;
end behavior;