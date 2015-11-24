----------------------------------------------------------------------------------
-- Ԫ�����ƣ�EXCP�ж��쳣������
-- �������������ж����쳣������Ӧ��׼���������жϷ������
-- ��Ϊ������EXCP��MEM�׶�ָ����м�أ�����ý׶ε�ָ������쳣�����߸�ָ����֮ǰ�Ľ׶��Ѿ������쳣��
--		����ֱ������׶βŽ��д�������ô�ͽ��쳣�����ź�ExcpTr��Ϊ1���ò�������CPU�����ں�̬��
--		Ҳ����LFLAG����һ��ʱ�������ر���Ϊ0��Ҳ����IH���λ���㣩��ͨ��BubExcp�źŽ�ǰ�����׶����ϡ���ʱ�������ص���ʱ��
--		����Ƿ����쳣����������У��ʹ�״̬0����״̬3��LfΪ0ʱ������״̬1(LfΪ1ʱ)������InExcp��Ϊ1����ʱ���쳣
-- 	�����������쳣׼��״̬����
--		״̬0�����쳣״̬��ExcpPrep��0��������쳣�źţ������ݻ�ǰ�����׶Σ��������쳣״̬1��3������ά�����쳣״̬��
--		����״̬��ExcpPrep��1������BRCH��EPcΪ��תĿ�ĵ�ַ
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
--		OD: SW_ER 0 ===> ״̬0
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
--		�����ⲿ�жϣ����������쳣���ơ�ֻ�е��ⲿ�жϴ�����IntEn��־λ1ʱ���Ž���״̬0����3.
--
-- �˿�������
--		IfPf		��IF�׶�һֱ���ݶ�����PageFault�ź�
--		MemPc		MEM�׶ε�PCֵ
--		NPc		MEM�׶ε�֪����һ��ָ���ַ
--		IdInval	��ID�׶�һֱ���ݶ����ķǷ�ָ���ź�
--		IdPriv	���û���ִ���ں˼�ָ��
--		Insn     �쳣ָ������
--		MemPf		MEM�׶β�����PageFault�ź�
--		MemVA		MEM�׶������ʵ������ڴ��ַ
--		MemWr		MEM�׶��Ƿ�Ϊд�ڴ�
--		IntInsn	���е�INTָ��
--		IntEn		�ж������־λ
--		IntTimer	�ⲿʱ���жϹܽ�
--		IntKb		�ⲿ�����жϹܽ�
--		IfTlb		IF�׶�TLB Miss
--		MemTlb	MEM�׶�TLB Miss
--		BubExcp	���ݻ��μĴ������ź�
--		ExcpPrep	�쳣����׼���׶��ź�
--		ExcpInsn	�쳣���������ݳ���ָ��
-- 	ExcpTr	�쳣����ʱ���źţ����������쳣�������
--		IgnTlb	����TLB����׶�
--		TlbVa		��Ҫ�޸ĵ�TLB��ĵ�ַb
--		InsnDegrade  ��Ҫ�������м�
--		DoDegrade ȷʵ�������м�
--		Lf			CPU���м�
--		Clk		ʱ���ź�
--
--	�쳣���жϺ���ָ�������
--		0 		�Ƿ�ָ�����ִ�� II = Invalid Instruction
-- 	1		ҳ�쳣������ִ�� PF = Page Fault
--		2		��Ȩָ�����ִ�� PI = Privileged Instruction
--		3		�ж�ָ�����һ��ָ��ִ�� INT = Interrupt Instruction
--		16		�������жϣ�����һ��ָ��ִ��
--		17		�����жϣ�����һ��ָ��ִ��
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
	
	-- ����߼�λ�����쳣״̬�ı�־
	signal ExcpFlag : std_logic;
	
	-- �Ĵ������쳣��
	signal ENo : std_logic_vector(15 downto 0);
	
	-- �Ĵ�����EPc������Ϊ�����쳣��ָ�Ҳ����Ϊ��һ��ָ���֮�����Ǵ��쳣�лָ���Ӧ��ִ�е�ָ��
	signal EPc : std_logic_vector(15 downto 0);
	
	-- �Ĵ�����Reason�����ڴ���ָ��ͷǷ�ָ��洢��ָ�����ҳ�쳣�洢�쳣״̬��0λΪ���м���1λΪд�������
	signal Reason : std_logic_vector(15 downto 0);

	-- �Ĵ�����Addr������ҳ�쳣�洢���ʵ��ڴ浥Ԫ��ַ
	signal Addr : std_logic_vector(15 downto 0);
	
	-- �Ĵ�����״̬������һ״̬
	signal NextState : std_logic_vector(4 downto 0);
	
	-- ���ڴ���TLB Miss�쳣��
	signal InTlb : std_logic;
	
	-- ���ڴ��жϷ���
	signal InRet : std_logic;
	
	-- �����쳣״̬����
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
				--		OD: SW_ER 0 ===> ״̬0
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
					if ER(15) = '0' then -- �ص�0��
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

