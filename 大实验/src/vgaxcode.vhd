----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:38:55 12/07/2014 
-- Design Name: 
-- Module Name:    vgaxcode - Behavioral 
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

entity vgaxcode is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  ADDRIN : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			  DATAIN : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			  R : out  STD_LOGIC_VECTOR (2 downto 0);
           G : out  STD_LOGIC_VECTOR (2 downto 0);
           B : out  STD_LOGIC_VECTOR (2 downto 0);
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC);
end vgaxcode;

architecture Behavioral of vgaxcode is

signal halfclk : std_logic := '0';
signal ws : std_logic_vector(0 downto 0) := "0";
signal posx : std_logic_vector(9 downto 0) := "0000000000";
signal posy : std_logic_vector(9 downto 0) := "0000000000";
signal letter_addr : std_logic_vector(15 downto 0) := "0000000100000000";
signal dic_addr0 : std_logic_vector(15 downto 0) := "0000000000000000";
signal dic_addr1 : std_logic_vector(15 downto 0) := "0000000000000000";
signal dic_addr2 : std_logic_vector(15 downto 0) := "0000000000000000";
signal dic_addr3 : std_logic_vector(15 downto 0) := "0000000000000000";
signal letter_color0 : std_logic_vector(15 downto 0) := "0000000000000000";
signal letter_color1 : std_logic_vector(15 downto 0) := "0000000000000000";
signal letter_color2 : std_logic_vector(15 downto 0) := "0000000000000000";
signal letter_color3 : std_logic_vector(15 downto 0) := "0000000000000000";
signal garbagein : std_logic_vector(15 downto 0):= "0000000000000000";
signal garbageout0 : std_logic_vector(15 downto 0):= "0000000000000000";
signal garbageout1 : std_logic_vector(15 downto 0):= "0000000000000000";
signal garbageout2 : std_logic_vector(15 downto 0):= "0000000000000000";
signal garbageout3 : std_logic_vector(15 downto 0):= "0000000000000000";
signal garbageout4 : std_logic_vector(15 downto 0):= "0000000000000000";

component vga_obj
	port( clka : in std_logic;
			wea : in std_logic_vector(0 downto 0);
			addra : in std_logic_vector(11 downto 0);
			dina : in std_logic_vector(15 downto 0);
			douta : out std_logic_vector(15 downto 0);
			clkb : in std_logic;
			web : in std_logic_vector(0 downto 0);
			addrb : in std_logic_vector(11 downto 0);
			dinb : in std_logic_vector(15 downto 0);
			doutb : out std_logic_vector(15 downto 0));
end component;

begin

V0: vga_obj port map(clka => CLK, wea => "0", addra => letter_addr(11 downto 0), dina => garbagein, douta => dic_addr0, clkb => CLK, web => ws, addrb => ADDRIN(11 downto 0), dinb => DATAIN, doutb => garbageout0);
V1: vga_obj port map(clka => CLK, wea => "0", addra => (dic_addr0(11 downto 0)), dina => garbagein, douta => letter_color0, clkb => CLK, web => ws, addrb => ADDRIN(11 downto 0), dinb => DATAIN, doutb => garbageout1);
V2: vga_obj port map(clka => CLK, wea => "0", addra => (dic_addr1(11 downto 0)), dina => garbagein, douta => letter_color1, clkb => CLK, web => ws, addrb => ADDRIN(11 downto 0), dinb => DATAIN, doutb => garbageout2);
V3: vga_obj port map(clka => CLK, wea => "0", addra => (dic_addr2(11 downto 0)), dina => garbagein, douta => letter_color2, clkb => CLK, web => ws, addrb => ADDRIN(11 downto 0), dinb => DATAIN, doutb => garbageout3);
V4: vga_obj port map(clka => CLK, wea => "0", addra => (dic_addr3(11 downto 0)), dina => garbagein, douta => letter_color3, clkb => CLK, web => ws, addrb => ADDRIN(11 downto 0), dinb => DATAIN, doutb => garbageout4);
process(CLK, RST)
	begin
		dic_addr1 <= dic_addr0 + 1;
		dic_addr2 <= dic_addr0 + 2;
		dic_addr3 <= dic_addr0 + 3;
		if rising_edge(CLK) then
			halfclk <= not halfclk;
			case posy(9 downto 7) is
				when "001" =>
					case posx(9 downto 6) is
						when "0000" => letter_addr(15 downto 0) <= "0000000100000000";
						when "0001" => letter_addr(15 downto 0) <= "0000000100000001";
						when "0010" => letter_addr(15 downto 0) <= "0000000100000010"; 
						when "0011" => letter_addr(15 downto 0) <= "0000000100000011";
						when "0100" => letter_addr(15 downto 0) <= "0000000100000100";
						when "0101" => letter_addr(15 downto 0) <= "0000000100000101";
						when "0110" => letter_addr(15 downto 0) <= "0000000100000110";
						when "0111" => letter_addr(15 downto 0) <= "0000000100000111";
						when others => letter_addr(15 downto 0) <= "0000000100001000";
					end case;
				when others =>
					letter_addr(15 downto 0) <= "0000000100001000";
			end case;
			--V0: vga_obj port map(clka => CLK, wea => "0", )
			case halfclk is
				when '1' =>
					ws <= not ws;
					case posx(5 downto 4) is
						when "00" =>
							case posx(3)&posy(6 downto 4) is
								when "0000" => 
									R(2 downto 0) <= letter_color0(15)&letter_color0(15)&letter_color0(15);
									G(2 downto 0) <= letter_color0(15)&letter_color0(15)&letter_color0(15);
									B(2 downto 0) <= letter_color0(15)&letter_color0(15)&letter_color0(15);
								when "0001" => 
									R(2 downto 0) <= letter_color0(14)&letter_color0(14)&letter_color0(14);
									G(2 downto 0) <= letter_color0(14)&letter_color0(14)&letter_color0(14);
									B(2 downto 0) <= letter_color0(14)&letter_color0(14)&letter_color0(14);
								when "0010" => 
									R(2 downto 0) <= letter_color0(13)&letter_color0(13)&letter_color0(13);
									G(2 downto 0) <= letter_color0(13)&letter_color0(13)&letter_color0(13);
									B(2 downto 0) <= letter_color0(13)&letter_color0(13)&letter_color0(13);
								when "0011" => 
									R(2 downto 0) <= letter_color0(12)&letter_color0(12)&letter_color0(12);
									G(2 downto 0) <= letter_color0(12)&letter_color0(12)&letter_color0(12);
									B(2 downto 0) <= letter_color0(12)&letter_color0(12)&letter_color0(12);
								when "0100" => 
									R(2 downto 0) <= letter_color0(11)&letter_color0(11)&letter_color0(11);
									G(2 downto 0) <= letter_color0(11)&letter_color0(11)&letter_color0(11);
									B(2 downto 0) <= letter_color0(11)&letter_color0(11)&letter_color0(11);
								when "0101" => 
									R(2 downto 0) <= letter_color0(10)&letter_color0(10)&letter_color0(10);
									G(2 downto 0) <= letter_color0(10)&letter_color0(10)&letter_color0(10);
									B(2 downto 0) <= letter_color0(10)&letter_color0(10)&letter_color0(10);
								when "0110" => 
									R(2 downto 0) <= letter_color0(9)&letter_color0(9)&letter_color0(9);
									G(2 downto 0) <= letter_color0(9)&letter_color0(9)&letter_color0(9);
									B(2 downto 0) <= letter_color0(9)&letter_color0(9)&letter_color0(9);
								when "0111" => 
									R(2 downto 0) <= letter_color0(8)&letter_color0(8)&letter_color0(8);
									G(2 downto 0) <= letter_color0(8)&letter_color0(8)&letter_color0(8);
									B(2 downto 0) <= letter_color0(8)&letter_color0(8)&letter_color0(8);
								when "1000" => 
									R(2 downto 0) <= letter_color0(7)&letter_color0(7)&letter_color0(7);
									G(2 downto 0) <= letter_color0(7)&letter_color0(7)&letter_color0(7);
									B(2 downto 0) <= letter_color0(7)&letter_color0(7)&letter_color0(7);
								when "1001" => 
									R(2 downto 0) <= letter_color0(6)&letter_color0(6)&letter_color0(6);
									G(2 downto 0) <= letter_color0(6)&letter_color0(6)&letter_color0(6);
									B(2 downto 0) <= letter_color0(6)&letter_color0(6)&letter_color0(6);
								when "1010" => 
									R(2 downto 0) <= letter_color0(5)&letter_color0(5)&letter_color0(5);
									G(2 downto 0) <= letter_color0(5)&letter_color0(5)&letter_color0(5);
									B(2 downto 0) <= letter_color0(5)&letter_color0(5)&letter_color0(5);
								when "1011" => 
									R(2 downto 0) <= letter_color0(4)&letter_color0(4)&letter_color0(4);
									G(2 downto 0) <= letter_color0(4)&letter_color0(4)&letter_color0(4);
									B(2 downto 0) <= letter_color0(4)&letter_color0(4)&letter_color0(4);
								when "1100" => 
									R(2 downto 0) <= letter_color0(3)&letter_color0(3)&letter_color0(3);
									G(2 downto 0) <= letter_color0(3)&letter_color0(3)&letter_color0(3);
									B(2 downto 0) <= letter_color0(3)&letter_color0(3)&letter_color0(3);
								when "1101" => 
									R(2 downto 0) <= letter_color0(2)&letter_color0(2)&letter_color0(2);
									G(2 downto 0) <= letter_color0(2)&letter_color0(2)&letter_color0(2);
									B(2 downto 0) <= letter_color0(2)&letter_color0(2)&letter_color0(2);
								when "1110" => 
									R(2 downto 0) <= letter_color0(1)&letter_color0(1)&letter_color0(1);
									G(2 downto 0) <= letter_color0(1)&letter_color0(1)&letter_color0(1);
									B(2 downto 0) <= letter_color0(1)&letter_color0(1)&letter_color0(1);
								when others => 
									R(2 downto 0) <= letter_color0(0)&letter_color0(0)&letter_color0(0);
									G(2 downto 0) <= letter_color0(0)&letter_color0(0)&letter_color0(0);
									B(2 downto 0) <= letter_color0(0)&letter_color0(0)&letter_color0(0);
							end case;
						when "01" =>
							case posx(3)&posy(6 downto 4) is
								when "0000" => 
									R(2 downto 0) <= letter_color1(15)&letter_color1(15)&letter_color1(15);
									G(2 downto 0) <= letter_color1(15)&letter_color1(15)&letter_color1(15);
									B(2 downto 0) <= letter_color1(15)&letter_color1(15)&letter_color1(15);
								when "0001" => 
									R(2 downto 0) <= letter_color1(14)&letter_color1(14)&letter_color1(14);
									G(2 downto 0) <= letter_color1(14)&letter_color1(14)&letter_color1(14);
									B(2 downto 0) <= letter_color1(14)&letter_color1(14)&letter_color1(14);
								when "0010" => 
									R(2 downto 0) <= letter_color1(13)&letter_color1(13)&letter_color1(13);
									G(2 downto 0) <= letter_color1(13)&letter_color1(13)&letter_color1(13);
									B(2 downto 0) <= letter_color1(13)&letter_color1(13)&letter_color1(13);
								when "0011" => 
									R(2 downto 0) <= letter_color1(12)&letter_color1(12)&letter_color1(12);
									G(2 downto 0) <= letter_color1(12)&letter_color1(12)&letter_color1(12);
									B(2 downto 0) <= letter_color1(12)&letter_color1(12)&letter_color1(12);
								when "0100" => 
									R(2 downto 0) <= letter_color1(11)&letter_color1(11)&letter_color1(11);
									G(2 downto 0) <= letter_color1(11)&letter_color1(11)&letter_color1(11);
									B(2 downto 0) <= letter_color1(11)&letter_color1(11)&letter_color1(11);
								when "0101" => 
									R(2 downto 0) <= letter_color1(10)&letter_color1(10)&letter_color1(10);
									G(2 downto 0) <= letter_color1(10)&letter_color1(10)&letter_color1(10);
									B(2 downto 0) <= letter_color1(10)&letter_color1(10)&letter_color1(10);
								when "0110" => 
									R(2 downto 0) <= letter_color1(9)&letter_color1(9)&letter_color1(9);
									G(2 downto 0) <= letter_color1(9)&letter_color1(9)&letter_color1(9);
									B(2 downto 0) <= letter_color1(9)&letter_color1(9)&letter_color1(9);
								when "0111" => 
									R(2 downto 0) <= letter_color1(8)&letter_color1(8)&letter_color1(8);
									G(2 downto 0) <= letter_color1(8)&letter_color1(8)&letter_color1(8);
									B(2 downto 0) <= letter_color1(8)&letter_color1(8)&letter_color1(8);
								when "1000" => 
									R(2 downto 0) <= letter_color1(7)&letter_color1(7)&letter_color1(7);
									G(2 downto 0) <= letter_color1(7)&letter_color1(7)&letter_color1(7);
									B(2 downto 0) <= letter_color1(7)&letter_color1(7)&letter_color1(7);
								when "1001" => 
									R(2 downto 0) <= letter_color1(6)&letter_color1(6)&letter_color1(6);
									G(2 downto 0) <= letter_color1(6)&letter_color1(6)&letter_color1(6);
									B(2 downto 0) <= letter_color1(6)&letter_color1(6)&letter_color1(6);
								when "1010" => 
									R(2 downto 0) <= letter_color1(5)&letter_color1(5)&letter_color1(5);
									G(2 downto 0) <= letter_color1(5)&letter_color1(5)&letter_color1(5);
									B(2 downto 0) <= letter_color1(5)&letter_color1(5)&letter_color1(5);
								when "1011" => 
									R(2 downto 0) <= letter_color1(4)&letter_color1(4)&letter_color1(4);
									G(2 downto 0) <= letter_color1(4)&letter_color1(4)&letter_color1(4);
									B(2 downto 0) <= letter_color1(4)&letter_color1(4)&letter_color1(4);
								when "1100" => 
									R(2 downto 0) <= letter_color1(3)&letter_color1(3)&letter_color1(3);
									G(2 downto 0) <= letter_color1(3)&letter_color1(3)&letter_color1(3);
									B(2 downto 0) <= letter_color1(3)&letter_color1(3)&letter_color1(3);
								when "1101" => 
									R(2 downto 0) <= letter_color1(2)&letter_color1(2)&letter_color1(2);
									G(2 downto 0) <= letter_color1(2)&letter_color1(2)&letter_color1(2);
									B(2 downto 0) <= letter_color1(2)&letter_color1(2)&letter_color1(2);
								when "1110" => 
									R(2 downto 0) <= letter_color1(1)&letter_color1(1)&letter_color1(1);
									G(2 downto 0) <= letter_color1(1)&letter_color1(1)&letter_color1(1);
									B(2 downto 0) <= letter_color1(1)&letter_color1(1)&letter_color1(1);
								when others => 
									R(2 downto 0) <= letter_color1(0)&letter_color1(0)&letter_color1(0);
									G(2 downto 0) <= letter_color1(0)&letter_color1(0)&letter_color1(0);
									B(2 downto 0) <= letter_color1(0)&letter_color1(0)&letter_color1(0);
							end case;
						when "10" =>
							case posx(3)&posy(6 downto 4) is
								when "0000" => 
									R(2 downto 0) <= letter_color2(15)&letter_color2(15)&letter_color2(15);
									G(2 downto 0) <= letter_color2(15)&letter_color2(15)&letter_color2(15);
									B(2 downto 0) <= letter_color2(15)&letter_color2(15)&letter_color2(15);
								when "0001" => 
									R(2 downto 0) <= letter_color2(14)&letter_color2(14)&letter_color2(14);
									G(2 downto 0) <= letter_color2(14)&letter_color2(14)&letter_color2(14);
									B(2 downto 0) <= letter_color2(14)&letter_color2(14)&letter_color2(14);
								when "0010" => 
									R(2 downto 0) <= letter_color2(13)&letter_color2(13)&letter_color2(13);
									G(2 downto 0) <= letter_color2(13)&letter_color2(13)&letter_color2(13);
									B(2 downto 0) <= letter_color2(13)&letter_color2(13)&letter_color2(13);
								when "0011" => 
									R(2 downto 0) <= letter_color2(12)&letter_color2(12)&letter_color2(12);
									G(2 downto 0) <= letter_color2(12)&letter_color2(12)&letter_color2(12);
									B(2 downto 0) <= letter_color2(12)&letter_color2(12)&letter_color2(12);
								when "0100" => 
									R(2 downto 0) <= letter_color2(11)&letter_color2(11)&letter_color2(11);
									G(2 downto 0) <= letter_color2(11)&letter_color2(11)&letter_color2(11);
									B(2 downto 0) <= letter_color2(11)&letter_color2(11)&letter_color2(11);
								when "0101" => 
									R(2 downto 0) <= letter_color2(10)&letter_color2(10)&letter_color2(10);
									G(2 downto 0) <= letter_color2(10)&letter_color2(10)&letter_color2(10);
									B(2 downto 0) <= letter_color2(10)&letter_color2(10)&letter_color2(10);
								when "0110" => 
									R(2 downto 0) <= letter_color2(9)&letter_color2(9)&letter_color2(9);
									G(2 downto 0) <= letter_color2(9)&letter_color2(9)&letter_color2(9);
									B(2 downto 0) <= letter_color2(9)&letter_color2(9)&letter_color2(9);
								when "0111" => 
									R(2 downto 0) <= letter_color2(8)&letter_color2(8)&letter_color2(8);
									G(2 downto 0) <= letter_color2(8)&letter_color2(8)&letter_color2(8);
									B(2 downto 0) <= letter_color2(8)&letter_color2(8)&letter_color2(8);
								when "1000" => 
									R(2 downto 0) <= letter_color2(7)&letter_color2(7)&letter_color2(7);
									G(2 downto 0) <= letter_color2(7)&letter_color2(7)&letter_color2(7);
									B(2 downto 0) <= letter_color2(7)&letter_color2(7)&letter_color2(7);
								when "1001" => 
									R(2 downto 0) <= letter_color2(6)&letter_color2(6)&letter_color2(6);
									G(2 downto 0) <= letter_color2(6)&letter_color2(6)&letter_color2(6);
									B(2 downto 0) <= letter_color2(6)&letter_color2(6)&letter_color2(6);
								when "1010" => 
									R(2 downto 0) <= letter_color2(5)&letter_color2(5)&letter_color2(5);
									G(2 downto 0) <= letter_color2(5)&letter_color2(5)&letter_color2(5);
									B(2 downto 0) <= letter_color2(5)&letter_color2(5)&letter_color2(5);
								when "1011" => 
									R(2 downto 0) <= letter_color2(4)&letter_color2(4)&letter_color2(4);
									G(2 downto 0) <= letter_color2(4)&letter_color2(4)&letter_color2(4);
									B(2 downto 0) <= letter_color2(4)&letter_color2(4)&letter_color2(4);
								when "1100" => 
									R(2 downto 0) <= letter_color2(3)&letter_color2(3)&letter_color2(3);
									G(2 downto 0) <= letter_color2(3)&letter_color2(3)&letter_color2(3);
									B(2 downto 0) <= letter_color2(3)&letter_color2(3)&letter_color2(3);
								when "1101" => 
									R(2 downto 0) <= letter_color2(2)&letter_color2(2)&letter_color2(2);
									G(2 downto 0) <= letter_color2(2)&letter_color2(2)&letter_color2(2);
									B(2 downto 0) <= letter_color2(2)&letter_color2(2)&letter_color2(2);
								when "1110" => 
									R(2 downto 0) <= letter_color2(1)&letter_color2(1)&letter_color2(1);
									G(2 downto 0) <= letter_color2(1)&letter_color2(1)&letter_color2(1);
									B(2 downto 0) <= letter_color2(1)&letter_color2(1)&letter_color2(1);
								when others => 
									R(2 downto 0) <= letter_color2(0)&letter_color2(0)&letter_color2(0);
									G(2 downto 0) <= letter_color2(0)&letter_color2(0)&letter_color2(0);
									B(2 downto 0) <= letter_color2(0)&letter_color2(0)&letter_color2(0);
							end case;
						when others =>
							case posx(3)&posy(6 downto 4) is
								when "0000" => 
									R(2 downto 0) <= letter_color3(15)&letter_color3(15)&letter_color3(15);
									G(2 downto 0) <= letter_color3(15)&letter_color3(15)&letter_color3(15);
									B(2 downto 0) <= letter_color3(15)&letter_color3(15)&letter_color3(15);
								when "0001" => 
									R(2 downto 0) <= letter_color3(14)&letter_color3(14)&letter_color3(14);
									G(2 downto 0) <= letter_color3(14)&letter_color3(14)&letter_color3(14);
									B(2 downto 0) <= letter_color3(14)&letter_color3(14)&letter_color3(14);
								when "0010" => 
									R(2 downto 0) <= letter_color3(13)&letter_color3(13)&letter_color3(13);
									G(2 downto 0) <= letter_color3(13)&letter_color3(13)&letter_color3(13);
									B(2 downto 0) <= letter_color3(13)&letter_color3(13)&letter_color3(13);
								when "0011" => 
									R(2 downto 0) <= letter_color3(12)&letter_color3(12)&letter_color3(12);
									G(2 downto 0) <= letter_color3(12)&letter_color3(12)&letter_color3(12);
									B(2 downto 0) <= letter_color3(12)&letter_color3(12)&letter_color3(12);
								when "0100" => 
									R(2 downto 0) <= letter_color3(11)&letter_color3(11)&letter_color3(11);
									G(2 downto 0) <= letter_color3(11)&letter_color3(11)&letter_color3(11);
									B(2 downto 0) <= letter_color3(11)&letter_color3(11)&letter_color3(11);
								when "0101" => 
									R(2 downto 0) <= letter_color3(10)&letter_color3(10)&letter_color3(10);
									G(2 downto 0) <= letter_color3(10)&letter_color3(10)&letter_color3(10);
									B(2 downto 0) <= letter_color3(10)&letter_color3(10)&letter_color3(10);
								when "0110" => 
									R(2 downto 0) <= letter_color3(9)&letter_color3(9)&letter_color3(9);
									G(2 downto 0) <= letter_color3(9)&letter_color3(9)&letter_color3(9);
									B(2 downto 0) <= letter_color3(9)&letter_color3(9)&letter_color3(9);
								when "0111" => 
									R(2 downto 0) <= letter_color3(8)&letter_color3(8)&letter_color3(8);
									G(2 downto 0) <= letter_color3(8)&letter_color3(8)&letter_color3(8);
									B(2 downto 0) <= letter_color3(8)&letter_color3(8)&letter_color3(8);
								when "1000" => 
									R(2 downto 0) <= letter_color3(7)&letter_color3(7)&letter_color3(7);
									G(2 downto 0) <= letter_color3(7)&letter_color3(7)&letter_color3(7);
									B(2 downto 0) <= letter_color3(7)&letter_color3(7)&letter_color3(7);
								when "1001" => 
									R(2 downto 0) <= letter_color3(6)&letter_color3(6)&letter_color3(6);
									G(2 downto 0) <= letter_color3(6)&letter_color3(6)&letter_color3(6);
									B(2 downto 0) <= letter_color3(6)&letter_color3(6)&letter_color3(6);
								when "1010" => 
									R(2 downto 0) <= letter_color3(5)&letter_color3(5)&letter_color3(5);
									G(2 downto 0) <= letter_color3(5)&letter_color3(5)&letter_color3(5);
									B(2 downto 0) <= letter_color3(5)&letter_color3(5)&letter_color3(5);
								when "1011" => 
									R(2 downto 0) <= letter_color3(4)&letter_color3(4)&letter_color3(4);
									G(2 downto 0) <= letter_color3(4)&letter_color3(4)&letter_color3(4);
									B(2 downto 0) <= letter_color3(4)&letter_color3(4)&letter_color3(4);
								when "1100" => 
									R(2 downto 0) <= letter_color3(3)&letter_color3(3)&letter_color3(3);
									G(2 downto 0) <= letter_color3(3)&letter_color3(3)&letter_color3(3);
									B(2 downto 0) <= letter_color3(3)&letter_color3(3)&letter_color3(3);
								when "1101" => 
									R(2 downto 0) <= letter_color3(2)&letter_color3(2)&letter_color3(2);
									G(2 downto 0) <= letter_color3(2)&letter_color3(2)&letter_color3(2);
									B(2 downto 0) <= letter_color3(2)&letter_color3(2)&letter_color3(2);
								when "1110" => 
									R(2 downto 0) <= letter_color3(1)&letter_color3(1)&letter_color3(1);
									G(2 downto 0) <= letter_color3(1)&letter_color3(1)&letter_color3(1);
									B(2 downto 0) <= letter_color3(1)&letter_color3(1)&letter_color3(1);
								when others => 
									R(2 downto 0) <= letter_color3(0)&letter_color3(0)&letter_color3(0);
									G(2 downto 0) <= letter_color3(0)&letter_color3(0)&letter_color3(0);
									B(2 downto 0) <= letter_color3(0)&letter_color3(0)&letter_color3(0);
							end case;
					end case;
					--	VGA HS SIGNAL
					if posx(9 downto 0) > "1010001110" and posx(9 downto 0) < "1011101111" then --654 751
						HS <= '0';
					else
						HS <= '1';
					end if;
					-- VGA VS SIGNAL
					if posy(9 downto 0) > "0111101000" and posy(9 downto 0) < "0111101011" then --488 491
						VS <= '0';
					else
						VS <= '1';
					end if;
					--updata posx and posy
					case posx is
						when "1100011111" => --799
							posx <= "0000000000";
							case posy is
								when "1000001100" => --524
									posy <= "0000000000";
								when others =>
									posy <= posy + 1;
							end case;
 						when others =>
							posx <= posx + 1;
					end case;
				when others =>
			end case;
		end if;
	end process;
end Behavioral;

