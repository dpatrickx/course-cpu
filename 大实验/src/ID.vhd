----------------------------------------------------------------------------------
-- 元件名称：ID指令解码器
-- 功能描述：输入一个16位THCO MIPS指令，分析这条指令，并输出控制信号和寄存器编号。
-- 行为描述：指令解码器为组合逻辑电路，输出随着输入的变化而变化，不需要时钟信号和复位信号。
-- 端口描述：
-- 	Insn		待解码的指令
-- 	Reg1		第一寄存器的编号
-- 	Reg2		第二寄存器的编号
--		RegDst	写回的寄存器编号
--		Imm		立即数
-- 	Op1Src	ALU第一操作数来源的控制信号
-- 	Op2Src	ALU第二操作数来源的控制信号
-- 	AluOp		ALU运算操作
--		TWr		写入T寄存器控制信号
--		Jcond		跳转控制条件
--		MemRd		内存读取控制信号
--		MemWr		内存写入控制信号
--		RegWr		写回寄存器控制信号
--		Inval		非法指令异常
--		Priv		特权指令异常
--		Lf			运行级
--		Degrade	降低运行级
--		Int		INT指令
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ID is
    Port ( Lf : in  STD_LOGIC;
			  Insn : in  STD_LOGIC_VECTOR(19 downto 0);
           Reg1 : out  STD_LOGIC_VECTOR(3 downto 0);
           Reg2 : out  STD_LOGIC_VECTOR(3 downto 0);
           RegDst : out  STD_LOGIC_VECTOR(3 downto 0);
			  Imm : out  STD_LOGIC_VECTOR(15 downto 0);
			  Op1Src : out  STD_LOGIC;
			  Op2Src : out  STD_LOGIC;
			  AluOp : out  STD_LOGIC_VECTOR(3 downto 0);
			  TWr : out  STD_LOGIC;
			  Jcond : out  STD_LOGIC_VECTOR(2 downto 0);
			  MemRd : out  STD_LOGIC;
			  MemWr : out  STD_LOGIC;
			  RegWr : out  STD_LOGIC;
			  Inval : out  STD_LOGIC;
			  Priv : out  STD_LOGIC;
			  Int : out  STD_LOGIC;
			  Reload : out  STD_LOGIC;
			  TlbClr : out  STD_LOGIC;
			  Degrade : out  STD_LOGIC;
			  Ret : out  STD_LOGIC);
end ID;

architecture Behavioral of ID is

begin
	process(Insn,Lf)
	begin
		-- 以下为各控制信号的默认值，与NOP指令相同。
		Reg1 <= "1111"; -- Reg1 <= ZERO
		Reg2 <= "1111"; -- Reg2 <= ZERO
		RegDst <= "1111"; -- RegDst <= R0
		Imm <= "0000000000000000";
		Op1Src <= '0'; -- Data1
		Op2Src <= '0'; -- Data2
		AluOp <= "0000"; -- Add
		TWr <= '0'; -- No
		Jcond <= "000"; -- No
		MemRd <= '0'; -- No
		MemWr <= '0'; -- No
		RegWr <= '0'; -- No
		Inval <= '0'; -- No
		Priv <= '0'; -- No
		Degrade <= '0'; -- No
		Int <= '0'; -- No
		Reload <= '0'; -- No
		TlbClr <= '0'; -- No
		Ret <= '0'; -- No
		
		case Insn(19) is
			when '1' => -- CPU异常特殊长指令
				case Insn(18 downto 16) is
					when "000" => -- LI_ER
						RegDst <= "1011"; -- RegDst <= ER
						Imm <= Insn(15 downto 0);
						Op2Src <= '1'; -- Imm
						RegWr <= '1'; -- Yes
					when "001" => -- SW_ER
						Reg1 <= "1000"; -- Reg1 <= SP
						Reg2 <= "1011"; -- Reg2 <= ER
						Imm <= Insn(15 downto 0);
						Op2Src <= '1'; -- Imm
						MemWr <= '1'; -- Yes
					when "010" => -- LTLB
						Reg1 <= "1110"; -- Reg1 <= PD
						Imm <= Insn(15 downto 0);
						Op2Src <= '1'; -- Imm
						MemRd <= '1'; -- Yes
					when "011" => -- LW_ER
						Reg1 <= "1000"; -- Reg1 <= SP
						RegDst <= "1011"; -- RegDst <= ER
						Imm <= Insn(15 downto 0);
						Op2Src <= '1'; -- Imm
						MemRd <= '1'; -- Yes
						RegWr <= '1'; -- Yes
					when "100" => -- ER2IH
						Reg1 <= "1011"; -- Reg1 <= ER
						RegDst <= "1001"; -- RegDst <= IH
						RegWr <= '1';
					when "101" => -- IH2ER
						Reg1 <= "1001"; -- Reg1 <= IH
						RegDst <= "1011"; -- RegDst <= ER
						RegWr <= '1';
					when others => -- 非法指令
				end case;
			when others => -- 普通16位指令
				case Insn(15 downto 11) is
					when "10000" => -- 特权指令
						if Lf = '0' then
							case Insn(3 downto 0) is
								when "0000" => -- MTUP
									Reg1(3) <= '0';
									Reg1(2 downto 0) <= Insn(10 downto 8);
									RegDst <= "1101";
									RegWr <= '1';
								when "0001" => -- MTKP
									Reg1(3) <= '0';
									Reg1(2 downto 0) <= Insn(10 downto 8);
									RegDst <= "1100";
									RegWr <= '1';
								when "0010" => -- MFUP
									Reg1 <= "1101";
									RegDst(3) <= '0';
									RegDst(2 downto 0) <= Insn(10 downto 8);
									RegWr <= '1';
								when "0011" => -- MFKP
									Reg1 <= "1100";
									RegDst(3) <= '0';
									RegDst(2 downto 0) <= Insn(10 downto 8);
									RegWr <= '1';
								when "0100" => -- SVUP
									Reg1 <= "1000";
									RegDst <= "1101";
									RegWr <= '1';
								when "0101" => -- LDKP
									Reg1 <= "1100";
									RegDst <= "1000";
									RegWr <= '1';
								when "1011" => -- LDUP
									Reg1 <= "1101";
									RegDst <= "1000";
									RegWr <= '1';
								when "0111" => -- MTPD
									Reg1(3) <= '0';
									Reg1(2 downto 0) <= Insn(10 downto 8);
									RegDst <= "1110";
									RegWr <= '1';
									Reload <= '1'; -- 刷新流水线
									TlbClr <= '1'; -- 刷新TLB
								when "1000" => -- CLI
									Reg1 <= "1001";
									RegDst <= "1001";
									Imm <= "0111111111111111";
									Op2Src <= '1';
									AluOp <= "0010";
									RegWr <= '1';
								when "1001" => -- STI
									Reg1 <= "1001";
									RegDst <= "1001";
									Imm <= "1000000000000000";
									Op2Src <= '1';
									AluOp <= "0011";
									RegWr <= '1';
								when "1010" => -- ERET
									Ret <= '1'; -- Yes
								when others => -- 非法指令
									Inval <= '1';
							end case;
						else -- 特权异常
							Priv <= '1';
						end if;
					when "11111" => -- INT
						Int <= '1';
					when "01001" => -- ADDIU
						Reg1(3) <= '0';
						Reg1(2 downto 0) <= Insn(10 downto 8); -- Reg1 <= Rx
						RegDst(3) <= '0'; 							-- RegDst <= Rx
						RegDst(2 downto 0) <= Insn(10 downto 8);
						-- 对立即数部分进行符号扩展 Imm <= SignExtend(Insn(7 downto 0))
						case Insn(7) is
							when '1' => Imm(15 downto 8) <= "11111111";
							when others => Imm(15 downto 8) <= "00000000";
						end case;
						Imm(7 downto 0) <= Insn(7 downto 0);
						Op2Src <= '1'; -- Imm
						RegWr <= '1'; -- Yes
					when "01000" => -- ADDIU3
						Reg1(3) <= '0'; -- Reg1 <= Rx
						Reg1(2 downto 0) <= Insn(10 downto 8);
						RegDst(3) <= '0'; -- RegDst <= Ry
						RegDst(2 downto 0) <= Insn(7 downto 5);
						-- 对立即数进行符号扩展 Imm <= SignExtend(Insn(3 downto 0))
						case Insn(3) is
							when '1' => Imm(15 downto 4) <= "111111111111";
							when others => Imm(15 downto 4) <= "000000000000";
						end case;
						Imm(3 downto 0) <= Insn(3 downto 0);
						Op2Src <= '1'; -- Imm
						RegWr <= '1'; -- Yes
					when "11100" => -- ADDU/SUBU
						case Insn(1 downto 0) is
						 when "01" => -- ADDU
							Reg1(3) <= '0'; -- Reg1 <= Rx
							Reg1(2 downto 0) <= Insn(10 downto 8);
							Reg2(3) <= '0'; -- Reg2 <= Ry
							Reg2(2 downto 0) <= Insn(7 downto 5);
							RegDst(3) <= '0'; -- RegDst <= Rz
							RegDst(2 downto 0) <= Insn(4 downto 2);
							RegWr <= '1'; -- Yes
						 when "11" => -- SUBU
							Reg1(3) <= '0'; -- Reg1 <= Rx
							Reg1(2 downto 0) <= Insn(10 downto 8);
							Reg2(3) <= '0'; -- Reg2 <= Ry
							Reg2(2 downto 0) <= Insn(7 downto 5);
							RegDst(3) <= '0'; -- RegDst <= Rz
							RegDst(2 downto 0) <= Insn(4 downto 2);
							AluOp <= "0001"; -- Subtract
							RegWr <= '1'; -- Yes
						 when others => -- 非法指令
							Inval <= '1';
						end case;
					when "11101" => -- AND/JALR/JR/JRRA/MFPC/NEG/NOT/OR/CMP
						case Insn(4 downto 0) is
							when "01100" => -- AND
								Reg1(3) <= '0'; -- Reg1 <= Rx
								Reg1(2 downto 0) <= Insn(10 downto 8);
								Reg2(3) <= '0'; -- Reg2 <= Ry
								Reg2(2 downto 0) <= Insn(7 downto 5);
								RegDst(3) <= '0'; -- RegDst <= Rx
								RegDst(2 downto 0) <= Insn(10 downto 8);
								AluOp <= "0010"; -- AND(2)
								RegWr <= '1'; -- Yes
							when "01011" => -- NEG
								Reg2(3) <= '0'; -- Reg2 <= Ry
								Reg2(2 downto 0) <= Insn(7 downto 5);
								RegDst(3) <= '0'; -- RegDst <= Rx
								RegDst(2 downto 0) <= Insn(10 downto 8);
								AluOp <= "0101"; -- NEG
								RegWr <= '1'; -- Yes
							when "01111" => -- NOT
								Reg2(3) <= '0'; -- Reg2 <= Ry
								Reg2(2 downto 0) <= Insn(7 downto 5);
								RegDst(3) <= '0'; -- RegDst <= Rx
								RegDst(2 downto 0) <= Insn(10 downto 8);
								AluOp <= "0110"; -- NOT
								RegWr <= '1'; -- Yes
							when "01101" => -- OR
								Reg1(3) <= '0'; -- Reg1 <= Rx
								Reg1(2 downto 0) <= Insn(10 downto 8);
								Reg2(3) <= '0'; -- Reg2 <= Ry
								Reg2(2 downto 0) <= Insn(7 downto 5);
								RegDst(3) <= '0'; -- RegDst <= Rx
								RegDst(2 downto 0) <= Insn(10 downto 8);
								AluOp <= "0011"; -- Or
								RegWr <= '1'; -- Yes
							when "01010" => -- CMP
								Reg1(3) <= '0'; -- Reg1 <= Rx
								Reg1(2 downto 0) <= Insn(10 downto 8);
								Reg2(3) <= '0'; -- Reg2 <= Rx
								Reg2(2 downto 0) <= Insn(7 downto 5);
								RegDst <= "1111"; -- RegDst <= ZERO
								AluOp <= "0100"; -- (4) Equal test
								TWr <= '1'; -- Yes
							when "00000" => -- JALR/JR/JRRA/MFPC
								case Insn(7 downto 5) is
									when "110" => -- JALR
										Reg2(3) <= '0'; -- Reg2 <= Rx
										Reg2(2 downto 0) <= Insn(10 downto 8);
										RegDst <= "1010"; -- RegDst <= RA
										Op1Src <= '1'; -- PC
										Op2Src <= '1'; -- Imm
										Jcond <= "110"; -- 无条件跳转，PC值来自Data2
										RegWr <= '1'; -- Yes
									when "000" => -- JR
										Reg2(3) <= '0'; -- Reg2 <= Rx
										Reg2(2 downto 0) <= Insn(10 downto 8);
										Jcond <= "110"; -- 无条件跳转，PC值来自Data2
									when "001" => -- JRRA
										Reg2 <= "1010"; -- Reg2 <= RA
										Jcond <= "110"; -- 无条件跳转，PC值来自Data2
									when "010" => -- MFPC
										RegDst(3) <= '0'; -- RegDst <= Rx
										RegDst(2 downto 0) <= Insn(10 downto 8);
										Op1Src <= '1'; -- PC
										RegWr <= '1'; -- Yes
									when others => -- 非法指令
										Inval <= '1';
								end case;
							when others => -- 错误指令
								Inval <= '1';
						end case;
					when "00010" => -- B
						-- Imm <= SignExtend(Insn(10 downto 0))
						case Insn(10) is
							when '1' => Imm(15 downto 11) <= "11111";
							when others => Imm(15 downto 11) <= "00000";
						end case;
						Imm(10 downto 0) <= Insn(10 downto 0);
						Op1Src <= '1'; -- PC
						Op2Src <= '1'; -- Imm
						Jcond <= "001"; -- Unconditional jump
					when "00100" => -- BEQZ
						Reg2(3) <= '0'; -- Reg2 <= Rx
						Reg2(2 downto 0) <= Insn(10 downto 8);
						RegDst <= "1111"; -- RegDst <= ZERO
						-- Imm <= SignExtend(Insn(7 downto 0));
						case Insn(7) is
							when '1' => Imm(15 downto 8) <= "11111111";
							when others => Imm(15 downto 8) <= "00000000";
						end case;
						Imm(7 downto 0) <= Insn(7 downto 0);
						Op1Src <= '1'; -- PC
						Op2Src <= '1'; -- Imm
						Jcond <= "101"; -- (5) Jump if Data2 is zero (ZCMP == 1)
					when "00101" => -- BNEZ
						Reg2(3) <= '0'; -- Reg2 <= Rx
						Reg2(2 downto 0) <= Insn(10 downto 8);
						-- Imm <= SignExtend(Insn(7 downto 0));
						case Insn(7) is
							when '1' => Imm(15 downto 8) <= "11111111";
							when others => Imm(15 downto 8) <= "00000000";
						end case;
						Imm(7 downto 0) <= Insn(7 downto 0);
						Op1Src <= '1'; -- PC
						Op2Src <= '1'; -- Imm
						Jcond <= "100"; -- (4) Jump if Data2 is nonzero (ZCMP == 0)
					when "01100" => -- BTEQZ/BTNEZ/MTSP
						case Insn(10 downto 8) is
							when "011" => -- ADDSP
								Reg1 <= "1000"; -- Reg1 <= SP
								RegDst <= "1000"; -- RegDst <= SP
								-- Imm <= SignExtend(Insn(7 downto 0))
								case Insn(7) is
									when '1' => Imm(15 downto 8) <= "11111111";
									when others => Imm(15 downto 8) <= "00000000";
								end case;
								Imm(7 downto 0) <= Insn(7 downto 0);
								Op2Src <= '1'; -- Imm
								RegWr <= '1'; -- Yes
							when "000" => -- BTEQZ
								-- Imm <= SignExtend(Insn(7 downto 0))
								case Insn(7) is
									when '1' => Imm(15 downto 8) <= "11111111";
									when others => Imm(15 downto 8) <= "00000000";
								end case;
								Imm(7 downto 0) <= Insn(7 downto 0);
								Op1Src <= '1'; -- PC
								Op2Src <= '1'; -- Imm
								Jcond <= "010"; -- (2) Jump if T == 0
							when "001" => -- BTNEZ
								-- Imm <= SignExtend(Insn(7 downto 0))
								case Insn(7) is
									when '1' => Imm(15 downto 8) <= "11111111";
									when others => Imm(15 downto 8) <= "00000000";
								end case;
								Imm(7 downto 0) <= Insn(7 downto 0);
								Op1Src <= '1'; -- PC
								Op2Src <= '1'; -- Imm
								Jcond <= "011"; -- (3) Jump if T != 0
							when "100" => -- MTSP
								Reg1(3) <= '0'; -- Reg1 <= Ry
								Reg1(2 downto 0) <= Insn(7 downto 5);
								RegDst <= "1000"; -- RegDst <= SP
								RegWr <= '1'; -- Yes
							when "101" => -- MFSP
								Reg1 <= "1000"; --- Rx <= SP
								RegDst(3) <= '0'; -- RegDst <= Ry
								RegDst(2 downto 0) <= Insn(7 downto 5);
								RegWr <= '1'; -- Yes
							when others => -- 非法指令
								Inval <= '1';
						end case;
					when "01101" => -- LI
						RegDst(3) <= '0'; -- RegDst <= Rx
						RegDst(2 downto 0) <= Insn(10 downto 8);
						-- Imm <= ZeroExtend(Insn(7 downto 0))
						Imm(15 downto 8) <= "00000000";
						Imm(7 downto 0) <= Insn(7 downto 0);
						Op2Src <= '1'; -- Imm
						RegWr <= '1'; -- Yes
					when "10011" => -- LW
						Reg1(3) <= '0'; -- Reg1 <= Rx
						Reg1(2 downto 0) <= Insn(10 downto 8);
						RegDst(3) <= '0'; -- RegDst <= Ry
						RegDst(2 downto 0) <= Insn(7 downto 5);
						-- Imm <= SignExtend(Insn(4 downto 0))
						case Insn(4) is
							when '1' => Imm(15 downto 5) <= "11111111111";
							when others => Imm(15 downto 5) <= "00000000000";
						end case;
						Imm(4 downto 0) <= Insn(4 downto 0);
						Op2Src <= '1'; -- Imm
						MemRd <= '1'; -- Yes
						RegWr <= '1'; -- Yes
					when "10010" => -- LW_SP
						Reg1 <= "1000"; -- Reg1 <= SP
						RegDst(3) <= '0'; -- RegDst <= Rx
						RegDst(2 downto 0) <= Insn(10 downto 8);
						-- Imm <= SignExtend(Insn(7 downto 0))
						case Insn(7) is
							when '1' => Imm(15 downto 8) <= "11111111";
							when others => Imm(15 downto 8) <= "00000000";
						end case;
						Imm(7 downto 0) <= Insn(7 downto 0);
						Op2Src <= '1'; -- Imm
						MemRd <= '1'; -- Yes
						RegWr <= '1'; -- Yes
					when "11110" => -- MFIH/MTIH
						if Lf = '0' then
							case Insn(7 downto 0) is
								when "00000000" => -- MFIH
									Reg1 <= "1001"; -- Reg1 <= IH
									RegDst(3) <= '0'; -- RegDst <= Rx
									RegDst(2 downto 0) <= Insn(10 downto 8);
									RegWr <= '1'; -- Yes
								when "00000001" => -- MTIH
									Reg1(3) <= '0'; -- Reg1 <= Rx
									Reg1(2 downto 0) <= Insn(10 downto 8);
									RegDst <= "1001"; -- RegDst <= IH
									RegWr <= '1'; -- Yes
									Reload <= '1'; -- Yes
								when others => -- 非法指令
									Inval <= '1';
							end case;
						else -- 特权指令异常
							Priv <= '1';
						end if;
					when "00001" => -- NOP
					when "00110" => -- SLL/SRA
						case Insn(1 downto 0) is
							when "00" => -- SLL
								Reg1(3) <= '0'; -- Reg1 <= Ry
								Reg1(2 downto 0) <= Insn(7 downto 5);
								RegDst(3) <= '0'; -- RegDst <= Rx
								RegDst(2 downto 0) <= Insn(10 downto 8);
								-- Imm <= ZeroExtend(Insn(4 downto 2))
								Imm(15 downto 3) <= "0000000000000";
								Imm(2 downto 0) <= Insn(4 downto 2);
								Op2Src <= '1'; -- Imm
								AluOp <= "0111"; -- SLL
								RegWr <= '1'; -- Yes
							when "10" => -- SRL
								Reg1(3) <= '0'; -- Reg1 <= Ry
								Reg1(2 downto 0) <= Insn(7 downto 5);
								RegDst(3) <= '0'; -- RegDst <= Rx
								RegDst(2 downto 0) <= Insn(10 downto 8);
								-- Imm <= ZeroExtend(Insn(4 downto 2))
								Imm(15 downto 3) <= "0000000000000";
								Imm(2 downto 0) <= Insn(4 downto 2);
								Op2Src <= '1'; -- Imm
								AluOp <= "1010"; -- Right Logical
								RegWr <= '1'; -- Yes
							when "11" => -- SRA
								Reg1(3) <= '0'; -- Reg1 <= Ry
								Reg1(2 downto 0) <= Insn(7 downto 5);
								RegDst(3) <= '0'; -- RegDst <= Rx
								RegDst(2 downto 0) <= Insn(10 downto 8);
								-- Imm <= ZeroExtend(Insn(4 downto 2))
								Imm(15 downto 3) <= "0000000000000";
								Imm(2 downto 0) <= Insn(4 downto 2);
								Op2Src <= '1'; -- Imm
								AluOp <= "1000"; -- Right
								RegWr <= '1'; -- Yes
							when others => --错误指令
								Inval <= '1';
						end case;
					when "11011" => -- SW
						Reg1(3) <= '0'; -- Reg1 <= Rx
						Reg1(2 downto 0) <= Insn(10 downto 8);
						Reg2(3) <= '0'; -- Reg2 <= Ry
						Reg2(2 downto 0) <= Insn(7 downto 5);
						-- Imm <= SignExtend(Insn(4 downto 0))
						case Insn(4) is
							when '1' => Imm(15 downto 5) <= "11111111111";
							when others => Imm(15 downto 5) <= "00000000000";
						end case;
						Imm(4 downto 0) <= Insn(4 downto 0);
						Op2Src <= '1'; -- Imm
						MemWr <= '1'; -- Yes
					when "11010" => -- SW_SP
						Reg1 <= "1000"; -- Reg1 <= SP
						Reg2(3) <= '0'; -- Reg2 <= Rx
						Reg2(2 downto 0) <= Insn(10 downto 8);
						-- Imm <= SignExtend(Insn(7 downto 0))
						case Insn(7) is
							when '1' => Imm(15 downto 8) <= "11111111";
							when others => Imm(15 downto 8) <= "00000000";
						end case;
						Imm(7 downto 0) <= Insn(7 downto 0);
						Op2Src <= '1'; -- Imm
						MemWr <= '1'; -- Yes
					when others => -- 非法指令
						Inval <= '1';
				end case;
		end case;
	end process;
end Behavioral;

