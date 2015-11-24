----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:42:30 12/05/2014 
-- Design Name: 
-- Module Name:    flash - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity flash is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SW : in  STD_LOGIC_VECTOR (15 downto 0);
           FlashDataDisplay : out  STD_LOGIC_VECTOR (15 downto 0);
           FlashAddrDisplay : out  STD_LOGIC_VECTOR (15 downto 0);
           FlashByte : out  STD_LOGIC;
           FlashVpen : out  STD_LOGIC;
           FlashCE : out  STD_LOGIC;
           FlashOE : out  STD_LOGIC;
           FlashWE : out  STD_LOGIC;
           FlashRP : out  STD_LOGIC;
           FlashAddr : out  STD_LOGIC_VECTOR (22 downto 0);
           FlashData : inout  STD_LOGIC_VECTOR (15 downto 0));
end flash;

architecture Behavioral of flash is

signal status : std_logic_vector(1 downto 0) := "00";
signal quanclk : std_logic_vector(1 downto 0) := "00";
signal sw_sig : std_logic_vector(15 downto 0);

begin

process(CLK, SW)
begin
	if rising_edge(CLK) then
		if not SW = "1111111111111111" then
			sw_sig <= SW
		end if;
	end if;
end process;

process(CLK, RST)
	begin
	FlashByte <= '1';
	FlashVpen <= '1';
	FlashRP <= '1';
	FlashCE <= '0';
	FlashAddr(0) <= '0';
	FlashAddr(22 downto 17) <= (others => '0');
	if rising_edge(CLK) then
		quanclk <= quanclk + 1;
		case quanclk is
			when "00" =>
				case status is 
					when "00" => 
						FlashWE <= '0';
						FlashOE <= '0';
					when "01" => 
						FlashData(15 downto 0) <= "0000000011111111"; 
						FlashWE <= '1';
					when "10" => 
						FlashOE <= '0'; 
						FlashAddr(16 downto 1) <= sw_sig;
						FlashAddrDisplay(15 downto 0) <= sw_sig;
						FlashData(15 downto 0) <= "ZZZZZZZZZZZZZZZZ";
					when "11" =>
						FlashDataDisplay(15 downto 0) <= FlashData(15 downto 0);
						FlashOE <= '1';
					when others =>
				end case;
				status <= status + 1;
			when others =>
		end case;
	end if;
	end process;
end Behavioral;

