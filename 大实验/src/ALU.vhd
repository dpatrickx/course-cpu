----------------------------------------------------------------------------------
-- 元件名称：ALU算术逻辑单元
-- 功能描述：根据运算控制信号AluOp对Op1和Op2进行相应的运算，将运算结果输出到AluRes或者Bool
-- 行为描述：
--		AluOp=0000 将两个操作数相加
-- 	AluOp=0001 第一操作数减第二操作数
--		AluOp=0010 将两操作数位与
-- 	AluOp=0011 将俩操作数位或
-- 	AluOp=0100 相等时Bool输出0，不等时Bool输出1（这是唯一修改Bool的操作）
-- 	AluOp=0101 取第二操作数的相反数
-- 	AluOp=0110 对第二操作数取反
--		AluOp=0111 第一操作数左移，左移位数为第二操作数
-- 	AluOp=1000 第一操作数算数右移，右移位数为第二操作数
-- 	AluOp=1001 第一操作数加1
--		AluOp=1010 第一操作数逻辑右移
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.all;

entity ALU is
    Port ( Op1 : in  STD_LOGIC_VECTOR(15 downto 0);
           Op2 : in  STD_LOGIC_VECTOR(15 downto 0);
           AluOp : in  STD_LOGIC_VECTOR(3 downto 0);
           AluRes : out  STD_LOGIC_VECTOR(15 downto 0);
           Bool : out  STD_LOGIC);
end ALU;

architecture Behavioral of ALU is
begin
	process(Op1, Op2, AluOp)
	begin
		AluRes <= "0000000000000000";
		Bool <= '0';
		case AluOp is
			when "0000" => -- Add
				AluRes <= Op1 + Op2;
			when "0001" => -- Subtract
				AluRes <= Op1 - Op2;
			when "0010" => -- And
				AluRes <= Op1 and Op2;
			when "0011" => -- Or
				AluRes <= Op1 or Op2;
			when "0100" => -- Equal test
				if Op1 = Op2 then
					Bool <= '0';
				else
					Bool <= '1';
				end if;
			when "0101" => -- Op2相反数
				AluRes <= (not Op2) + 1;
			when "0110" => -- ~Op2
				AluRes <= not Op2;
			when "0111" => -- Op1 << Op2
				case Op2(2 downto 0) is
					when "001" => AluRes(15 downto 1) <= Op1(14 downto 0); AluRes(0) <= '0';
					when "010" => AluRes(15 downto 2) <= Op1(13 downto 0); AluRes(1 downto 0) <= "00";
					when "011" => AluRes(15 downto 3) <= Op1(12 downto 0); AluRes(2 downto 0) <= "000";
					when "100" => AluRes(15 downto 4) <= Op1(11 downto 0); AluRes(3 downto 0) <= "0000";
					when "101" => AluRes(15 downto 5) <= Op1(10 downto 0); AluRes(4 downto 0) <= "00000";
					when "110" => AluRes(15 downto 6) <= Op1(9 downto 0); AluRes(5 downto 0) <= "000000";
					when "111" => AluRes(15 downto 7) <= Op1(8 downto 0); AluRes(6 downto 0) <= "0000000";
					when "000" => AluRes(15 downto 8) <= Op1(7 downto 0); AluRes(7 downto 0) <= "00000000";
					when others => -- 保持默认值
				end case;
			when "1000" => -- Op1 >>(arith) Op2
				-- 移动数据主体
				case Op2(2 downto 0) is
					when "001" => AluRes(14 downto 0) <= Op1(15 downto 1);
					when "010" => AluRes(13 downto 0) <= Op1(15 downto 2);
					when "011" => AluRes(12 downto 0) <= Op1(15 downto 3);
					when "100" => AluRes(11 downto 0) <= Op1(15 downto 4);
					when "101" => AluRes(10 downto 0) <= Op1(15 downto 5);
					when "110" => AluRes(9 downto 0) <= Op1(15 downto 6);
					when "111" => AluRes(8 downto 0) <= Op1(15 downto 7);
					when "000" => AluRes(7 downto 0) <= Op1(15 downto 8);
					when others => -- 保持默认值
				end case;
				-- 按符号位增补
				if Op1(15) = '1' then
					case Op2(2 downto 0) is
						when "001" => AluRes(15) <= '1';
						when "010" => AluRes(15 downto 14) <= "11";
						when "011" => AluRes(15 downto 13) <= "111";
						when "100" => AluRes(15 downto 12) <= "1111";
						when "101" => AluRes(15 downto 11) <= "11111";
						when "110" => AluRes(15 downto 10) <= "111111";
						when "111" => AluRes(15 downto 9) <= "1111111";
						when "000" => AluRes(15 downto 8) <= "11111111";
						when others => -- 保持默认值
					end case;
				else
					case Op2(2 downto 0) is
						when "001" => AluRes(15) <= '0';
						when "010" => AluRes(15 downto 14) <= "00";
						when "011" => AluRes(15 downto 13) <= "000";
						when "100" => AluRes(15 downto 12) <= "0000";
						when "101" => AluRes(15 downto 11) <= "00000";
						when "110" => AluRes(15 downto 10) <= "000000";
						when "111" => AluRes(15 downto 9) <= "0000000";
						when "000" => AluRes(15 downto 8) <= "00000000";
						when others => -- 保持默认值
					end case;
				end if;
			when "1001" => -- Op1 + 1
				AluRes <= Op1 + 1;
			when "1010" => -- Op1 >> Op2
				-- 移动数据主体
				case Op2(2 downto 0) is
					when "001" => AluRes(14 downto 0) <= Op1(15 downto 1);
					when "010" => AluRes(13 downto 0) <= Op1(15 downto 2);
					when "011" => AluRes(12 downto 0) <= Op1(15 downto 3);
					when "100" => AluRes(11 downto 0) <= Op1(15 downto 4);
					when "101" => AluRes(10 downto 0) <= Op1(15 downto 5);
					when "110" => AluRes(9 downto 0) <= Op1(15 downto 6);
					when "111" => AluRes(8 downto 0) <= Op1(15 downto 7);
					when "000" => AluRes(7 downto 0) <= Op1(15 downto 8);
					when others => -- 保持默认值
				end case;
				-- 增补0
				case Op2(2 downto 0) is
					when "001" => AluRes(15) <= '0';
					when "010" => AluRes(15 downto 14) <= "00";
					when "011" => AluRes(15 downto 13) <= "000";
					when "100" => AluRes(15 downto 12) <= "0000";
					when "101" => AluRes(15 downto 11) <= "00000";
					when "110" => AluRes(15 downto 10) <= "000000";
					when "111" => AluRes(15 downto 9) <= "0000000";
					when "000" => AluRes(15 downto 8) <= "00000000";
					when others => -- 保持默认值
				end case;
			when others => -- 保持默认值
		end case;
	end process;
end Behavioral;

