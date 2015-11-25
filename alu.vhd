LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.control.ALL;
use work.my_data_types.ALL;

entity ALU is
    Port ( aluOp : in  STD_LOGIC_VECTOR (3 downto 0);
           input_A : in  STD_LOGIC_VECTOR (15 downto 0);
           input_B : in  STD_LOGIC_VECTOR (15 downto 0);
           output : out  STD_LOGIC_VECTOR (15 downto 0));
end ALU;

architecture Behavioral of ALU is
begin
	process(aluOp, input_A, input_B)
	begin
		case aluOp is
			when "0000" =>
				output <= input_A + input_B;
			when "0001" =>
				output <= input_A - input_B;
			when "0010" =>
				output <= input_A AND input_B;
			when "0011" =>
				output <= input_A OR input_B;
            when "0100" =>
                output <= 0 - input_B;
			when "0101" =>
				output <= NOT input_B;
			when "1000" =>
				output <= input_A;
			when "0111" =>
				output <= input_B;
			when "0110" =>
				if input_A /= input_B then
					output <= "0000000000000001";
				else
					output <= "0000000000000000";
				end if;
			when "1001" =>
				-- SLL
				if input_A(4 downto 2) = "000" then
					output <= to_stdlogicvector(to_bitvector(input_B) SLL 8);
				else
					output <= to_stdlogicvector(to_bitvector(input_B) SLL conv_integer(input_A(4 downto 2)));
				end if;
			when "1010" =>
				-- SRL
				if input_A(4 downto 2) = "000" then
					output <= to_stdlogicvector(to_bitvector(input_B) SRL 8);
				else
					output <= to_stdlogicvector(to_bitvector(input_B) SRL conv_integer(input_A(4 downto 2)));
				end if;
			when "1011" =>
				-- SRA
				if input_A(4 downto 2) = "000" then
					output <= to_stdlogicvector(to_bitvector(input_B) SRA 8);
				else
					output <= to_stdlogicvector(to_bitvector(input_B) SRA conv_integer(input_A(4 downto 2)));
				end if;
			when others =>
				output <= input_A;
		end case;
	end process;

end Behavioral;
