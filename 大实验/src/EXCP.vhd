----------------------------------------------------------------------------------
-- 元件名称：EXCP中断异常处理器
-- 功能描述：对中断与异常进行相应，准备并调用中断服务程序
-- 行为描述：EXCP对MEM阶段指令进行监控，如果该阶段的指令产生异常（或者该指令在之前的阶段已经产生异常，
--		但是直到这个阶段才进行处理），那么就将异常触发信号ExcpTr置为1（该操作导致CPU进入内核态，
--		也就是LFLAG在下一个时钟上升沿被置为0，也导致IH最高位清零），通过BubExcp信号将前三个阶段作废。在时钟上升沿到来时，
--		检测是否有异常发生，如果有，就从状态0进入状态3（Lf为0时）或者状态1(Lf为1时)，并将InExcp置为1。这时，异常
-- 	处理器进入异常准备状态机。
--		状态0：无异常状态。ExcpPrep置0。如果有异常信号，就起泡化前三个阶段，并进入异常状态1或3。否则，维持无异常状态。
--		非零状态中ExcpPrep置1，导致BRCH以EPc为跳转目的地址
--		01: SVUP
--		02: LDKP
--		03: ADDSP -5 
--		04: IH2ER 
--		05: ExcpTr = 1, SW_ER 4
--		06: LI_ER <EPc>
--		07: SW_ER 3
--		08: LI_ER <ENo>
--		09: SW_ER 2
--		0A: LI_ER <Reason>
--		0B: SW_ER 1
--		0C: LI_ER <Addr>
--		OD: SW_ER 0 ===> 状态0
--		0E: InTlb = 1, LTLB <TlbIdx>
--		OF: InTlb = 1, NOP
--		10: InTlb = 1, NOP
--		11: InTlb = 1, TlbWr = 1, TlbVa = <Va>, NOP ===> 0
--		12: InRet = 1, LW_ER 4
--		13: InRet = 1, NOP
--		14: InRet = 1, ER2IH
--		15: InRet = 1, LW_ER 2
--		16: InRet = 1, NOP
--		17: InRet = 1, LW_ER 3
--		18: InRet = 1, ADDSP 5
--		19: InRet = 1, NOP, ===> 1A/1C
--		1A: InRet = 1, DoDegrade <= 1, LDUP
--		1B: InRet = 1, DoDegrade <= 0, NOP ===> 00
--		1C: InRet = 1, NOP
--		1D: InRet = 1, NOP ===> 00
--		
--		对于外部中断，处理方法与异常类似。只有当外部中断存在且IntEn标志位1时，才进入状态0或者3.
--
-- 端口描述：
--		IfPf		从IF阶段一直传递而来的PageFault信号
--		MemPc		MEM阶段的PC值
--		NPc		MEM阶段得知的下一个指令地址
--		IdInval	从ID阶段一直传递而来的非法指令信号
--		IdPriv	在用户级执行内核级指令
--		Insn     异常指令内容
--		MemPf		MEM阶段产生的PageFault信号
--		MemVA		MEM阶段所访问的虚拟内存地址
--		MemWr		MEM阶段是否为写内存
--		IntInsn	运行到INT指令
--		IntEn		中断允许标志位
--		IntTimer	外部时钟中断管脚
--		IntKb		外部键盘中断管脚
--		IfTlb		IF阶段TLB Miss
--		MemTlb	MEM阶段TLB Miss
--		BubExcp	气泡化段寄存器的信号
--		ExcpPrep	异常处理准备阶段信号
--		ExcpInsn	异常处理器传递出的指令
-- 	ExcpTr	异常产生时的信号，表明进入异常处理过程
--		IgnTlb	跳过TLB翻译阶段
--		TlbVa		需要修改的TLB项的地址b
--		InsnDegrade  需要降低运行级
--		DoDegrade 确实降低运行级
--		Lf			CPU运行级
--		Clk		时钟信号
--
--	异常与中断号与指令处理方法：
--		0 		非法指令，重新执行 II = Invalid Instruction
-- 	1		页异常，重新执行 PF = Page Fault
--		2		特权指令，重新执行 PI = Privileged Instruction
--		3		中断指令，从下一条指令执行 INT = Interrupt Instruction
--		16		计数器中断，从下一条指令执行
--		17		键盘中断，从下一条指令执行
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity EXCP is
    Port ( IfPf : in  STD_LOGIC;
           MemPc : in  STD_LOGIC_VECTOR(15 downto 0);
			  NPc : in  STD_LOGIC_VECTOR(15 downto 0);
           IdInval : in  STD_LOGIC;
			  IdPriv : in  STD_LOGIC;
           MemPf : in  STD_LOGIC;
           MemVA : in  STD_LOGIC_VECTOR(15 downto 0);
			  MemWr : in  STD_LOGIC;
			  IntInsn : in  STD_LOGIC;
           IntEn : in  STD_LOGIC;
           IntTimer : in  STD_LOGIC;
           IntKb : in  STD_LOGIC;
			  IfTlb : in  STD_LOGIC;
			  MemTlb : in  STD_LOGIC;
			  Lf : in  STD_LOGIC;
			  Ret : in  STD_LOGIC;
			  ER : in  STD_LOGIC_VECTOR(15 downto 0);
           BubExcp : out  STD_LOGIC_VECTOR(2 downto 0);
           ExcpTr : out  STD_LOGIC;
           ExcpInsn : out  STD_LOGIC_VECTOR(19 downto 0);
			  ExcpPrep : out  STD_LOGIC;
			  BrchPc : out  STD_LOGIC_VECTOR(15 downto 0);
			  IgnTlb : out  STD_LOGIC;
			  Clk : in  STD_LOGIC;
			  DoDegrade : out  STD_LOGIC;
			  TlbVa : out  STD_LOGIC_VECTOR(5 downto 0);
			  TlbWr : out  STD_LOGIC;
			  Rst : in  STD_LOGIC);
end EXCP;

architecture Behavioral of EXCP is
	
	-- 组合逻辑位，有异常状态的标志
	signal ExcpFlag : std_logic;
	
	-- 寄存器，异常号
	signal ENo : std_logic_vector(15 downto 0);
	
	-- 寄存器，EPc，可能为触发异常的指令，也可能为下一条指令。总之，就是从异常中恢复后应该执行的指令
	signal EPc : std_logic_vector(15 downto 0);
	
	-- 寄存器，Reason，对于错误指令和非法指令存储该指令，对于页异常存储异常状态（0位为运行级，1位为写入操作）
	signal Reason : std_logic_vector(15 downto 0);

	-- 寄存器，Addr，对于页异常存储访问的内存单元地址
	signal Addr : std_logic_vector(15 downto 0);
	
	-- 寄存器，状态机的下一状态
	signal NextState : std_logic_vector(4 downto 0);
	
	-- 正在处理TLB Miss异常。
	signal InTlb : std_logic;
	
	-- 正在从中断返回
	signal InRet : std_logic;
	
	-- 正在异常状态机中
	signal InExcp : std_logic;
	
begin
	
	IgnTlb <= InTlb;
	
	ExcpPrep <= InExcp;
	
	ExcpFlag <= '1' when IfPf = '1' or IdInval = '1' or IdPriv = '1' or MemPf = '1' or IntInsn = '1' or IfTlb = '1' or MemTlb = '1' or Ret = '1' or (IntEn = '1' and InExcp = '0' and NextState = "00000" and (IntTimer = '1' or IntKb = '1')) else '0';
	BubExcp <= 	"111" when ExcpFlag = '1' and InExcp = '0' else
					"100" when ExcpFlag = '0' and (InExcp = '1' or NextState /= "00000") else
					"000";
					
	BrchPc <= EPc when InTlb = '1' and InRet = '0' else
				 ER when InTlb = '0' and InRet = '1' else 
				 "0000000000000001";
	
	process(Clk, Rst)
	begin
		if Rst = '0' then 
			NextState <= "00000";
			Addr <= "0000000000000000";
			Reason <= "0000000000000000";
			EPc <= "0000000000000000";
			ENo <= "0000000000000000";
			ExcpInsn <= "00000000100000000000";
			TlbVa <= "000000";
			TlbWr <= '0';
			InTlb <= '0';
			InRet <= '0';
			InExcp <= '0';
			DoDegrade <= '0';
			ExcpTr <= '0';
		elsif rising_edge(Clk) then
			TlbVa <= "000000";
			TlbWr <= '0';
			InTlb <= '0';
			InRet <= '0';
			InExcp <= '1';
			ExcpTr <= '0';
			
			case NextState is
				when "00000" =>
					NextState <= "00000";
					InExcp <= '0';
					ExcpInsn <= "00000000100000000000";
					
					if ExcpFlag = '1' then
						if Lf = '1' then
							NextState <= "00001";
						else 
							NextState <= "00011";
						end if;
						
						Reason <= "0000000000000000";
						Addr <= "0000000000000000";
						ENo <= "0000000000000000";
						EPc <= "0000000000000000";
						if IfTlb = '1' then -- IF TLB Miss
							EPc <= MemPc - 1;
							NextState <= "01110";
							Addr <= MemPc - 1;
						elsif MemTlb = '1' then -- MEM TLB Miss
							EPc <= MemPc - 1;
							NextState <= "01110";
							Addr <= MemVA;
						elsif Ret = '1' then -- Return from interrupt
							NextState <= "10010";
						elsif IfPf = '1' then -- Page fault during fetching an instruction
							ENo <= "0000000000000001";
							ENo(15) <= Lf;
							EPc <= MemPc - 1;
							Reason(0) <= Lf;
							Reason(2) <= '1';
							Addr <= MemPc - 1;
						elsif MemPf = '1' then -- Page fault during accessing memory
							ENo <= "0000000000000001";
							ENo(15) <= Lf;
							EPc <= MemPc - 1;
							Reason(0) <= Lf;
							Reason(1) <= MemWr;
							Addr <= MemVA;
						elsif IdInval = '1' then -- Invalid instruction
							ENo <= "0000000000000000";
							ENo(15) <= Lf;
							EPc <= MemPc - 1;
						elsif IdPriv = '1' then -- Privileged instruction
							ENo <= "0000000000000010";
							ENo(15) <= Lf;
							EPc <= MemPc - 1;
						elsif IntInsn = '1' then -- INT
							ENo <= "0000000000000011";
							ENo(15) <= Lf;
							EPc <= NPc;
						elsif IntTimer = '1' then -- Timer
							ENo <= "0000000000010000";
							ENo(15) <= Lf;
							EPc <= NPc;
						elsif IntKb = '1' then -- Keyboard
							ENo <= "0000000000010001";
							ENo(15) <= Lf;
							EPc <= NPc;
						end if;
					end if;
				when "00001" =>
				--		01: SVUP
					NextState <= "00010";
					ExcpInsn <= "00001000000000000100"; -- SVUP
				when "00010" =>
				--		02: LDKP
					NextState <= "00011";
					ExcpInsn <= "00001000000000000101"; -- LDKP
				when "00011" =>
				--		03: ADDSP -5
					NextState <= "00100";
					ExcpInsn <= "00000110001111111011"; -- ADDSP -5
				when "00100" =>
				--		04: IH2ER
					NextState <= "00101";
					ExcpInsn <= "11010000000000000000";
				when "00101" =>
				--		05: ExcpTr = 1, SW_ER 4
					NextState <= "00110";
					ExcpInsn <= "10010000000000000100";
					ExcpTr <= '1';
				when "00110" =>
				--		06: LI_ER <EPc>
					NextState <= "00111";
					ExcpInsn(19 downto 16) <= "1000";
					ExcpInsn(15 downto 0) <= EPc;
				when "00111" =>
				--		07: SW_ER 3
					NextState <= "01000";
					ExcpInsn <= "10010000000000000011";
				when "01000" =>
				--		08: LI_ER <ENo>
					NextState <= "01001";
					ExcpInsn(19 downto 16) <= "1000";
					ExcpInsn(15 downto 0) <= ENo;
				when "01001" =>
				--		09: SW_ER 2
					NextState <= "01010";
					ExcpInsn <= "10010000000000000010";
				when "01010" =>
				--		0A: LI_ER <Reason>
					NextState <= "01011";
					ExcpInsn(19 downto 16) <= "1000";
					ExcpInsn(15 downto 0) <= Reason;
				when "01011" =>
				--		0B: SW_ER 1
					NextState <= "01100";
					ExcpInsn <= "10010000000000000001";
				when "01100" =>
				--		0C: LI_ER <Addr>
					NextState <= "01101";
					ExcpInsn(19 downto 16) <= "1000";
					ExcpInsn(15 downto 0) <= Addr;
				when "01101" =>
				--		OD: SW_ER 0 ===> 状态0
					NextState <= "00000";
					ExcpInsn <= "10010000000000000000";
				when "01110" =>
				--		0E: InTlb = 1, LTLB <TlbIdx>
					NextState <= "01111";
					InTlb <= '1';
					ExcpInsn <= "10100000000000" & Addr(15 downto 10); 
				when "01111" =>
				--		OF: InTlb = 1, NOP
					NextState <= "10000";
					InTlb <= '1';
					ExcpInsn <= "00000000100000000000";
				when "10000" =>
				--		10: InTlb = 1, NOP
					NextState <= "10001";
					InTlb <= '1';
					ExcpInsn <= "00000000100000000000";
				when "10001" =>
				--		11: InTlb = 1, TlbWr = 1, TlbVa = <Va>, NOP ===> 0
					NextState <= "00000";
					InTlb <= '1';
					TlbVa <= Addr(15 downto 10);
					TlbWr <= '1';
					ExcpInsn <= "00000000100000000000";
				when "10010" =>
				--		12: InRet = 1, LW_ER 4
					NextState <= "10011";
					InRet <= '1';
					ExcpInsn <= "10110000000000000100";
				when "10011" =>
				--		13: InRet = 1, NOP
					NextState <= "10100";
					InRet <= '1';
					ExcpInsn <= "00000000100000000000";
				when "10100" =>
				--		14: InRet = 1, ER2IH
					NextState <= "10101";
					InRet <= '1';
					ExcpInsn <= "11000000000000000000";
				when "10101" =>
				--		15: InRet = 1, LW_ER 2
					NextState <= "10110";
					InRet <= '1';
					ExcpInsn <= "10110000000000000010";
				when "10110" =>
				--		16: InRet = 1, NOP
					NextState <= "10111";
					InRet <= '1';
					ExcpInsn <= "00000000100000000000";
				when "10111" =>
				--		17: InRet = 1, LW_ER 3
					NextState <= "11000";
					InRet <= '1';
					ExcpInsn <= "10110000000000000011";
				when "11000" =>
				--		18: InRet = 1, ADDSP 5
					NextState <= "11001";
					InRet <= '1';
					ExcpInsn <= "00000110001100000101";
				when "11001" =>
				--		19: InRet = 1, NOP, ===> 1A/1C
					NextState <= "11010";
					InRet <= '1';
					ExcpInsn <= "00000000100000000000";
					if ER(15) = '0' then -- 回到0级
						NextState <= "11100";
					end if;
				when "11010" =>
				--		1A: InRet = 1, DoDegrade <= 1, LDUP
					NextState <= "11011";
					InRet <= '1';
					DoDegrade <= '1';
					ExcpInsn <= "00001000000000001011";
				when "11011" =>
				--		1B: InRet = 1, DoDegrade <= 0, NOP ===> 00
					NextState <= "00000";
					InRet <= '1';
					DoDegrade <= '0';
					ExcpInsn <= "00000000100000000000";
				when "11100" =>
				--		1C: InRet = 1, NOP
					NextState <= "11101";
					InRet <= '1';
					ExcpInsn <= "00000000100000000000";
				when "11101" =>
				--		1D: InRet = 1, NOP ===> 00
					NextState <= "00000";
					InRet <= '1';
					ExcpInsn <= "00000000100000000000";
				when others =>
					InExcp <= '0';
					NextState <= "00000";
					ExcpInsn <= "00000000100000000000"; -- NOP
			end case;
		end if;
	end process;

end Behavioral;

