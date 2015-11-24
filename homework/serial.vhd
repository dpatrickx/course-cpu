----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:05:39 11/04/2015 
-- Design Name: 
-- Module Name:    serial - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serial is
	Port (
		clk : in std_logic;
		rst : in std_logic;
		sw  : in std_logic_vector(7 downto 0);
		dataReady : in std_logic;
		ram1Data : inout std_logic_vector(7 downto 0);
		l : out std_logic_vector(7 downto 0);
		digital : out std_logic_vector(6 downto 0);
		ram1OE : out std_logic := '1';
		ram1WE : out std_logic := '1';
		ram1EN : out std_logic := '1';
		rdn : out std_logic;
		wrn : out std_logic;
		tbre : in std_logic;
		tsre : in std_logic
	);
end serial;

architecture Behavioral of serial is
	type seriState is (init, readData, writeData, modifyData);
	type exeState is (write0, write1, write2, write3, write4, read0, read1, read2, read3, modify);
	signal seState : seriState := init;
	signal exState : exeState := write0;
	signal temp : std_logic_vector(7 downto 0);
	signal data : std_logic_vector(7 downto 0) := "00000000";
	
	procedure writeSerial(signal input : in std_logic_vector; back : exeState) is
	begin
		case exState is
			when write0 =>
				wrn <= '1';
				exState <= write1;
			when write1 =>				
				ram1Data <= input;
				data <= input;
				wrn <= '0';
				exState <= write2;
			when write2 =>
				wrn <= '1';
				exState <= write3;
			when write3 =>
				if (tbre = '1') then
					exState <= write4;
				end if;
			when write4 =>
				if (tsre = '1') then
					exState <= back;
				end if;
			when others =>
				null;
			end case;
		end procedure;
		
	procedure readSerial(signal output : out std_logic_vector; back : exeState) is
	begin
		case exState is
			when read0 =>
				exState <= read1;
			when read1 =>
				rdn <= '1';
				ram1Data <= "ZZZZZZZZ";
				exState <= read2;
			when read2 =>
				if (dataReady = '1') then
					rdn <= '0';
					exState <= read3;
				else
					exState <= read1;
				end if;
			when read3 =>
				output <= ram1Data;
				rdn <= '1';
				exState <= back;
			when others =>
				null;
		end case;
	end procedure;
begin
	ram1OE <= '1';
	ram1WE <= '1';
	ram1EN <= '1';
	
	REG:PROCESS(clk, rst, sw)
	begin
		if rst='0' then
			case sw (1 downto 0) is
				when "00" =>
					seState <= init;
					exState <= write0;
				when "01" =>
					seState <= writeData;
					exState <= write0;
				when "10" =>
					seState <= readData;
					exState <= read0;
				when "11" =>
					seState <= modifyData;
					exState <= read0;
				when others =>
					null;
			end case;
		elsif clk='0' and clk'event then
			case seState is
				when writeData =>
					writeSerial(sw, write0);
				when readData =>
					readSerial(data, read0);
				when modifyData =>
					case exState is
						when read0 | read1 | read2 | read3 =>
							readSerial(temp, modify);
						when modify =>
							data <= temp;
							temp <= temp + 1;
							exState <= write0;
						when write0 | write1 | write2 | write3 | write4 =>
							writeSerial(temp, read0);
						when others =>
							null;
					end case;
				when others =>
					null;
			end case;
		end if;
	end process;
	
	process (seState)
	begin
		-- init - 0 readData - 1, writeData - 2, modifyData - 3
		case seState is
		when init =>
			digital <= "0111111";
		when readData =>
			digital <= "0000110";
		when writeData =>
			digital <= "1011011";
		when modifyData =>
			digital <= "1001111";
		when others =>
			digital <= "1111111";
		end case;
	end process;
	
	process (data)
	begin
		l <= data;
	end process;
end Behavioral;

