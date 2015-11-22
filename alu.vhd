----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:23:19 10/12/2015 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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

entity alu is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           num : in  STD_LOGIC_VECTOR (15 downto 0);
           fout : out  STD_LOGIC_VECTOR (15 downto 0));
end alu;

architecture Behavioral of alu is
	type stats is (init, inputa, inputb, inputop,outflag);
	signal current_state,next_state:stats := init;
	shared variable numa: std_logic_vector(15 downto 0);
	shared variable numb: std_logic_vector(15 downto 0);
	shared variable temp: std_logic_vector(15 downto 0);
	signal op: std_logic_vector(3 downto 0);
	signal boola: bit_vector(15 downto 0);
	shared variable boolb: integer;
	shared variable cflag,zflag,sflag,oflag: std_logic := '0';
	signal isNum: std_logic := '0';
	--component Show
	--	port ( A: in std_logic_vector(3 downto 0);
	--			 B: out std_logic_vector(6 downto 0));
	--end component;
begin
	REG:PROCESS(clk,rst,num)
	begin
		if rst='0' then
			current_state <= init;
		elsif clk='0' and clk'event then
			current_state <= next_state;
		end if;
	end process;
	
	COM:PROCESS(current_state)
	begin
		case current_state is
			when init =>
				fout<="0101010101010101";
				cflag := '0';
				zflag := '0';
				sflag := '0';
				oflag := '0';
				next_state <= inputa;
			when inputa =>
				numa := num;
				fout <= num;
				next_state <= inputb;
			when inputb =>
				numb := num;
				fout <= num;
				next_state <= inputop;
			when inputop =>
				op <= num(3 downto 0);
				case op is
					when "0000" =>
						-- 加法，正正溢出，负负溢出
						fout <= "0000000000000000";
						temp := (numa + numb);
						-- cflag
						cflag := (numa(15) and numb(15)) 
							or (not temp(15) and numa(15))
							or (not temp(15) and numb(15));
						-- oflag
						oflag := (temp(15)and not numa(15) and not numb(15))
							or (not temp(15) and numa(15) and numb(15));
						-- sflag
						sflag := temp(15);
						-- zflag
						case temp is
							when "0000000000000000" =>
								zflag := '1';
							when others =>
								zflag := '0';
						end case;						
						fout <= temp;
					when "0001" =>
						-- 减法，正负溢出，负正溢出
						temp := numa - numb;
						-- cflag
						cflag := (numa(15) and not numb(15)) 
							or (not temp(15) and numa(15))
							or (not temp(15) and not numb(15));
						-- oflag:
						oflag := (temp(15)and not numa(15) and numb(15))
							or (not temp(15) and numa(15) and not numb(15));
						-- sflag
						sflag := temp(15);
						-- zflag
						case temp(15 downto 0) is
							when "0000000000000000" =>
								zflag := '1';
							when others =>
								zflag := '0';
						end case;			
								
						fout <= temp(15 downto 0);
					when "0010" =>
						-- AND
						fout <= numa AND numb;
					when "0011" =>
						-- OR
						fout <= numa OR numb;
					when "0100" =>
						-- XOR
						fout <= numa XOR numb;
					when "0101" =>
						-- NOT
						fout <= NOT numa;
					when "0110" =>
						-- SLL，逻辑左移
						boola <= to_bitvector(numa);
						boolb := conv_integer(numb);
						fout <= to_stdlogicvector(boola SLL boolb);
					when "0111" =>
						-- SRL，逻辑右移
						boola <= to_bitvector(numa);
						boolb := conv_integer(numb);
						fout <= to_stdlogicvector(boola SRL boolb);
					when "1000" =>
						-- SRA，算术右移
						boola <= to_bitvector(numa);
						boolb := conv_integer(numb);
						fout <= to_stdlogicvector(boola SRA boolb);
					when "1001" =>
						-- ROL，循环左移
						boola <= to_bitvector(numa);
						boolb := conv_integer(numb);
						fout <= to_stdlogicvector(boola ROL boolb);		
					when others =>
						fout <= "1111111111111111";
				end case;
				next_state <= outflag;
			when outflag =>
				fout(0) <= cflag;
				fout(1) <= zflag;
				fout(2) <= sflag;
				fout(3) <= oflag;
				next_state <= inputa;
		end case;
	end process;
end Behavioral;

