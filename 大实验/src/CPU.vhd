----------------------------------------------------------------------------------
-- Ԫ�����ƣ�CPU����Ԫ��
-- �˿�������
--		Clk		ʱ���ź�
--		Rst		��λ�ź�
--		Ram2Data	RAM2��������
--		Ram2Addr	RAM2�ĵ�ַ��
--		Ram2OE	RAM2�����ʹ��
--		Ram2WE	RAM2��дʹ��
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity CPU is
    Port ( Rst : in  STD_LOGIC;			  
			  RealClk : in  STD_LOGIC;
			  
			  Ps2KbClock : in  STD_LOGIC;
			  Ps2KbData : in  STD_LOGIC;
			  
			  VgaR : out  STD_LOGIC_VECTOR (2 downto 0);
           VgaG : out  STD_LOGIC_VECTOR (2 downto 0);
           VgaB : out  STD_LOGIC_VECTOR (2 downto 0);
           VgaHS : out  STD_LOGIC;
           VgaVS : out  STD_LOGIC;

			  Ram1Data : inout  STD_LOGIC_VECTOR(15 downto 0);
			  Ram1Addr : out  STD_LOGIC_VECTOR(17 downto 0);
			  Ram1En : out  STD_LOGIC;
			  Ram1OE : out  STD_LOGIC;
			  Ram1WE : out  STD_LOGIC;
			  
			  Ram2Data : inout  STD_LOGIC_VECTOR(15 downto 0);
			  Ram2Addr : out  STD_LOGIC_VECTOR(17 downto 0);
			  Ram2En : out  STD_LOGIC;
			  Ram2OE : out  STD_LOGIC;
			  Ram2WE : out  STD_LOGIC;
			  
			  ComDataReady : in  STD_LOGIC;
           ComRdn : out  STD_LOGIC;
           ComTbre : in  STD_LOGIC;
           ComTsre : in  STD_LOGIC;
           ComWrn : out  STD_LOGIC;
			  
			  DbOut : out  STD_LOGIC_VECTOR(15 downto 0)
			  );
end CPU;

architecture Behavioral of CPU is

	-- ������Ҫ��������Ԫ��
	
	component ALU is
		 Port ( Op1 : in  STD_LOGIC_VECTOR(15 downto 0);
				  Op2 : in  STD_LOGIC_VECTOR(15 downto 0);
				  AluOp : in  STD_LOGIC_VECTOR(3 downto 0);
				  AluRes : out  STD_LOGIC_VECTOR(15 downto 0);
				  Bool : out  STD_LOGIC);
	end component;
	
	component BRCH is
		 Port ( Pc : in  STD_LOGIC_VECTOR(15 downto 0);
				  NPc : out  STD_LOGIC_VECTOR(15 downto 0);
				  MemPc : in  STD_LOGIC_VECTOR(15 downto 0);
				  MemNPc : in  STD_LOGIC_VECTOR(15 downto 0);
				  Jcond : in  STD_LOGIC_VECTOR(2 downto 0);
				  JFlag : in  STD_LOGIC;
				  ExcpPrep : in  STD_LOGIC;
				  EPc : in  STD_LOGIC_VECTOR(15 downto 0);
				  Bubble : out  STD_LOGIC_VECTOR(2 downto 0);
				  Reload : in  STD_LOGIC;
				  Clk : in  STD_LOGIC;
				  Rst : in  STD_LOGIC);
	end component;
	
	component BUBBLE is
		 Port ( BubBr : in  STD_LOGIC_VECTOR(2 downto 0);
				  BubHz : in  STD_LOGIC_VECTOR(2 downto 0);
				  BubEx : in  STD_LOGIC_VECTOR(2 downto 0);
				  BubFD : out  STD_LOGIC;
				  BubDE : out  STD_LOGIC;
				  BubEM : out  STD_LOGIC);
	end component;
	
	component COND is
		 Port ( TF : in  STD_LOGIC;
				  ZF : in  STD_LOGIC;
				  Jcond : in  STD_LOGIC_VECTOR(2 downto 0);
				  Pc : in  STD_LOGIC_VECTOR(15 downto 0);
				  AluRes : in  STD_LOGIC_VECTOR(15 downto 0);
				  Data2 : in  STD_LOGIC_VECTOR(15 downto 0);
				  NPc : out  STD_LOGIC_VECTOR(15 downto 0);
				  JFlag : out  STD_LOGIC);
	end component;
	
	component EXE_MEM is
    Port ( RegDstWr : in  STD_LOGIC_VECTOR(3 downto 0);
           PcWr : in  STD_LOGIC_VECTOR(15 downto 0);
           BoolWr : in  STD_LOGIC;
           AluResWr : in  STD_LOGIC_VECTOR(15 downto 0);
           ZFWr : in  STD_LOGIC;
           Data2Wr : in  STD_LOGIC_VECTOR(15 downto 0);
           TWrWr : in  STD_LOGIC;
           JcondWr : in  STD_LOGIC_VECTOR(2 downto 0);
           MemRdWr : in  STD_LOGIC;
           MemWrWr : in  STD_LOGIC;
           RegWrWr : in  STD_LOGIC;
			  IfPfWr : in  STD_LOGIC;
			  IdInvalWr : in  STD_LOGIC;
			  IdPrivWr : in  STD_LOGIC;
			  IntWr : in  STD_LOGIC;
			  IfTlbWr : in  STD_LOGIC;
			  ReloadWr : in  STD_LOGIC;
			  TlbClrWr : in  STD_LOGIC;
			  DegradeWr : in  STD_LOGIC;
			  RetWr : in  STD_LOGIC;
           RegDstRd : out  STD_LOGIC_VECTOR(3 downto 0);
           PcRd : out  STD_LOGIC_VECTOR(15 downto 0);
           BoolRd : out  STD_LOGIC;
           AluResRd : out  STD_LOGIC_VECTOR(15 downto 0);
           ZFRd : out  STD_LOGIC;
           Data2Rd : out  STD_LOGIC_VECTOR(15 downto 0);
           TWrRd : out  STD_LOGIC;
           JcondRd : out  STD_LOGIC_VECTOR(2 downto 0);
           MemRdRd : out  STD_LOGIC;
           MemWrRd : out  STD_LOGIC;
           RegWrRd : out  STD_LOGIC;
			  IfPfRd : out  STD_LOGIC;
			  IdInvalRd : out  STD_LOGIC;
			  IdPrivRd : out  STD_LOGIC;
			  IntRd : out  STD_LOGIC;
			  DegradeRd : out  STD_LOGIC;
			  IfTlbRd : out  STD_LOGIC;
			  ReloadRd : out  STD_LOGIC;
			  TlbClrRd : out  STD_LOGIC;
			  RetRd : out  STD_LOGIC;
           Bubble : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC);
	end component;
	
	component FWD is
		 Port ( MemRdM : in  STD_LOGIC;
				  RegDstM : in  STD_LOGIC_VECTOR(3 downto 0);
				  RegWrM : in  STD_LOGIC;
				  RegDstW : in  STD_LOGIC_VECTOR(3 downto 0);
				  RegWrW : in  STD_LOGIC;
				  Reg1 : in  STD_LOGIC_VECTOR(3 downto 0);
				  Reg2 : in  STD_LOGIC_VECTOR(3 downto 0);
				  Op1Src : in  STD_LOGIC;
				  Op2Src : in  STD_LOGIC;
				  Fwd1 : out  STD_LOGIC_VECTOR(1 downto 0);
				  Fwd2 : out  STD_LOGIC_VECTOR(1 downto 0);
				  Fwd3 : out  STD_LOGIC_VECTOR(1 downto 0);
				  WbFwd : out  STD_LOGIC);
	end component;
	
	component HAZD is
		 Port ( MemRd : in  STD_LOGIC;
				  MemConflict : in  STD_LOGIC;
				  WbFwd : in  STD_LOGIC;
				  RegDst : in  STD_LOGIC_VECTOR(3 downto 0);
				  Reg1 : in  STD_LOGIC_VECTOR(3 downto 0);
				  Reg2 : in  STD_LOGIC_VECTOR(3 downto 0);
				  HoldReg : out  STD_LOGIC;
				  HoldPc : out  STD_LOGIC;
				  Reload : out  STD_LOGIC;
				  Bubble : out  STD_LOGIC_VECTOR(2 downto 0));
	end component;
	
	component ID_EXE is
    Port ( Data1Wr : in  STD_LOGIC_VECTOR(15 downto 0);
           Data2Wr : in  STD_LOGIC_VECTOR(15 downto 0);
           Reg1Wr : in  STD_LOGIC_VECTOR(3 downto 0);
           Reg2Wr : in  STD_LOGIC_VECTOR(3 downto 0);
			  RegDstWr : in  STD_LOGIC_VECTOR(3 downto 0);
           ImmWr : in  STD_LOGIC_VECTOR(15 downto 0);
           PcWr : in  STD_LOGIC_VECTOR(15 downto 0);
           Op1SrcWr : in  STD_LOGIC;
           Op2SrcWr : in  STD_LOGIC;
           AluOpWr : in  STD_LOGIC_VECTOR(3 downto 0);
           TWrWr : in  STD_LOGIC;
			  JcondWr : in  STD_LOGIC_VECTOR(2 downto 0);
           MemRdWr : in  STD_LOGIC;
           MemWrWr : in  STD_LOGIC;
           RegWrWr : in  STD_LOGIC;
			  IfPfWr : in  STD_LOGIC;
			  IdInvalWr : in  STD_LOGIC;
			  IdPrivWr : in  STD_LOGIC;
			  IntWr : in  STD_LOGIC;
			  DegradeWr : in  STD_LOGIC;
			  IfTlbWr : in  STD_LOGIC;
			  ReloadWr : in  STD_LOGIC;
			  TlbClrWr : in  STD_LOGIC;
			  RetWr : in  STD_LOGIC;
           Data1Rd : out  STD_LOGIC_VECTOR(15 downto 0);
           Data2Rd : out  STD_LOGIC_VECTOR(15 downto 0);
           Reg1Rd : out  STD_LOGIC_VECTOR(3 downto 0);
           Reg2Rd : out  STD_LOGIC_VECTOR(3 downto 0);
			  RegDstRd : out  STD_LOGIC_VECTOR(3 downto 0);
           ImmRd : out  STD_LOGIC_VECTOR(15 downto 0);
           PcRd : out  STD_LOGIC_VECTOR(15 downto 0);
           Op1SrcRd : out  STD_LOGIC;
           Op2SrcRd : out  STD_LOGIC;
           AluOpRd : out  STD_LOGIC_VECTOR(3 downto 0);
           TWrRd : out  STD_LOGIC;
			  JcondRd : out  STD_LOGIC_VECTOR(2 downto 0);
           MemRdRd : out  STD_LOGIC;
           MemWrRd : out  STD_LOGIC;
           RegWrRd : out  STD_LOGIC;
			  IfPfRd : out  STD_LOGIC;
			  IdInvalRd : out  STD_LOGIC;
			  IdPrivRd : out  STD_LOGIC;
			  IntRd : out  STD_LOGIC;
			  DegradeRd : out  STD_LOGIC;
			  IfTlbRd : out  STD_LOGIC;
			  ReloadRd : out  STD_LOGIC;
			  TlbClrRd : out  STD_LOGIC;
			  RetRd : out  STD_LOGIC;
           Bubble : in  STD_LOGIC;
           Hold : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC);
	end component;
	
	component ID is
		 Port ( Insn : in  STD_LOGIC_VECTOR(19 downto 0);
				  Lf : in  STD_LOGIC;
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
				  Degrade : out  STD_LOGIC;
				  Reload : out  STD_LOGIC;
				  TlbClr : out  STD_LOGIC;
				  Ret : out  STD_LOGIC);
	end component;
	
	component IF_ID is
		 Port ( InsnWr : in  STD_LOGIC_VECTOR(15 downto 0);
				  InsnRd : out  STD_LOGIC_VECTOR(15 downto 0);
				  PcWr : in  STD_LOGIC_VECTOR(15 downto 0);
				  PcRd : out  STD_LOGIC_VECTOR(15 downto 0);
				  IfPfWr : in  STD_LOGIC;
				  IfPfRd : out  STD_LOGIC;
				  IfTlbWr : in  STD_LOGIC;
			     IfTlbRd : out  STD_LOGIC;
				  Bubble : in  STD_LOGIC;
				  Hold : in  STD_LOGIC;
				  Clk : in  STD_LOGIC;
				  Rst : in  STD_LOGIC);
	end component;
	
	component MEM_WB is
		 Port ( AluResWr : in  STD_LOGIC_VECTOR(15 downto 0);
				  MemDataWr : in  STD_LOGIC_VECTOR(15 downto 0);
				  RegDstWr : in  STD_LOGIC_VECTOR(3 downto 0);
				  MemRdWr : in  STD_LOGIC;
				  RegWrWr : in  STD_LOGIC;
				  AluResRd : out  STD_LOGIC_VECTOR(15 downto 0);
				  MemDataRd : out  STD_LOGIC_VECTOR(15 downto 0);
				  RegDstRd : out  STD_LOGIC_VECTOR(3 downto 0);
				  MemRdRd : out  STD_LOGIC;
				  RegWrRd : out  STD_LOGIC;
				  Bubble : in  STD_LOGIC;
				  Clk : in  STD_LOGIC;
				  Rst : in  STD_LOGIC);
	end component;
	
	component MMIO is
    Port ( IfAddr : in  STD_LOGIC_VECTOR(18 downto 0);
           Insn : out  STD_LOGIC_VECTOR(15 downto 0);
           MemAddr : in  STD_LOGIC_VECTOR(18 downto 0);
           MemDataWr : in  STD_LOGIC_VECTOR(15 downto 0);
           MemDataRd : out  STD_LOGIC_VECTOR(15 downto 0);
           MemRd : in  STD_LOGIC;
           MemWr : in  STD_LOGIC;
			  Cnflc : out STD_LOGIC;

			  Ram2Addr : out  STD_LOGIC_VECTOR(17 downto 0);
			  Ram2Data : inout  STD_LOGIC_VECTOR(15 downto 0);
			  Ram2WE :  out STD_LOGIC;
			  Ram2OE :  out STD_LOGIC;
			  Ram2EN :  out STD_LOGIC;

			  Ram1Addr : out  STD_LOGIC_VECTOR(17 downto 0);
			  Ram1Data : inout  STD_LOGIC_VECTOR(15 downto 0);
			  Ram1WE :  out STD_LOGIC;
			  Ram1OE :  out STD_LOGIC;
			  Ram1EN :  out STD_LOGIC;

			  ComDataReady : in  STD_LOGIC;
           ComRdn : out  STD_LOGIC;
           ComTbre : in  STD_LOGIC;
           ComTsre : in  STD_LOGIC;
           ComWrn : out  STD_LOGIC;
			  
			  PS2CLK : in  STD_LOGIC;
           PS2DATA : in  STD_LOGIC;
			  
			  Clk50 : in STD_LOGIC;
			  VgaR : out  STD_LOGIC_VECTOR (2 downto 0);
           VgaG : out  STD_LOGIC_VECTOR (2 downto 0);
           VgaB : out  STD_LOGIC_VECTOR (2 downto 0);
           VgaHS : out  STD_LOGIC;
           VgaVS : out  STD_LOGIC;
			  
			  Ps2Readyy : out STD_LOGIC;

			  Clk :  in STD_LOGIC);
	end component;
	
	component Mux2 is
		 Port ( X0 : in  STD_LOGIC_VECTOR(15 downto 0);
				  X1 : in  STD_LOGIC_VECTOR(15 downto 0);
				  Y : out  STD_LOGIC_VECTOR(15 downto 0);
				  Sel : in  STD_LOGIC);
	end component;
	
	component Mux4 is
		 Port ( X0 : in  STD_LOGIC_VECTOR(15 downto 0);
				  X1 : in  STD_LOGIC_VECTOR(15 downto 0);
				  X2 : in  STD_LOGIC_VECTOR(15 downto 0);
				  X3 : in  STD_LOGIC_VECTOR(15 downto 0);
				  Y : out  STD_LOGIC_VECTOR(15 downto 0);
				  Sel : in  STD_LOGIC_VECTOR(1 downto 0));
	end component;
	
	component PC is
		 Port ( Rst: in  STD_LOGIC;
				  Clk: in  STD_LOGIC;
				  PcValueRd : out  STD_LOGIC_VECTOR(15 downto 0);
				  PcPlus1 : out  STD_LOGIC_VECTOR(15 downto 0);
				  PcValueWr : in  STD_LOGIC_VECTOR(15 downto 0);
				  Hold : in STD_LOGIC);
	end component;
	
	component REGS is
		 Port ( Reg1 : in  STD_LOGIC_VECTOR(3 downto 0);
				  Reg2 : in  STD_LOGIC_VECTOR(3 downto 0);
				  Data1 : out  STD_LOGIC_VECTOR(15 downto 0);
				  Data2 : out  STD_LOGIC_VECTOR(15 downto 0);
				  RegWr : in  STD_LOGIC;
				  RegDataWr : in  STD_LOGIC_VECTOR(15 downto 0);
				  RegDst : in  STD_LOGIC_VECTOR(3 downto 0);
				  IntEn : out  STD_LOGIC;
				  IntHdl : in  STD_LOGIC;
				  EROut : out  STD_LOGIC_VECTOR(15 downto 0);
				  PE : out  STD_LOGIC;
				  Clk : in  STD_LOGIC;
				  Rst : in  STD_LOGIC);
	end component;
	
	component TFLAG is
		 Port ( TValueWr : in  STD_LOGIC;
				  TValueRd : out  STD_LOGIC;
				  TWr : in  STD_LOGIC;
				  Clk : in  STD_LOGIC;
				  Rst : in  STD_LOGIC);
	end component;
	
	component ZCMP is
    Port ( Data : in  STD_LOGIC_VECTOR(15 downto 0);
           ZF : out  STD_LOGIC);
	end component;
	
	component EXCP is
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
           BubExcp : out  STD_LOGIC_VECTOR(2 downto 0);
           ExcpTr : out  STD_LOGIC;
           ExcpInsn : out  STD_LOGIC_VECTOR(19 downto 0);
			  ExcpPrep : out  STD_LOGIC;
			  BrchPc : out  STD_LOGIC_VECTOR(15 downto 0);
			  IgnTlb : out  STD_LOGIC;
			  Clk : in  STD_LOGIC;
			  TlbVa : out  STD_LOGIC_VECTOR(5 downto 0);
			  TlbWr : out  STD_LOGIC;
			  Ret : in  STD_LOGIC;
			  DoDegrade : out  STD_LOGIC;
			  ER : in  STD_LOGIC_VECTOR(15 downto 0);
			  Rst : in  STD_LOGIC);
	end component;
	
	component LFLAG is
		 Port ( Degrade : in  STD_LOGIC;
				  ExcpTr : in  STD_LOGIC;
				  Lf : out  STD_LOGIC;
				  Clk : in  STD_LOGIC;
				  Rst : in  STD_LOGIC);
	end component;
	
	component VM is
    Port ( 
		Lf : in  STD_LOGIC;
		IfVa : in  STD_LOGIC_VECTOR(5 downto 0);
		IfRd : in  STD_LOGIC;
		IfPa : out  STD_LOGIC_VECTOR(8 downto 0);
		IfTlb : out  STD_LOGIC;
		IfPf : out  STD_LOGIC;
		MemVa : in  STD_LOGIC_VECTOR(5 downto 0);
		MemRd : in  STD_LOGIC;
		MemWr : in  STD_LOGIC;
		MemPa : out  STD_LOGIC_VECTOR(8 downto 0);
		MemTlb : out  STD_LOGIC;
		MemPf : out  STD_LOGIC;
		TlbVa : in  STD_LOGIC_VECTOR(5 downto 0);
		TlbData : in  STD_LOGIC_VECTOR(15 downto 0);
		TlbWr : in  STD_LOGIC;
		TlbClr : in  STD_LOGIC;
		PE : in  STD_LOGIC;
		Clk : in  STD_LOGIC;
		Rst : in  STD_LOGIC
		);
	end component;
	
	-- ��ˮ�߶����ź�
	
	-- PC->VM�Ĵ�ȡָ���ַ
	signal IfVa : std_logic_vector(15 downto 0);
	-- PC->BRCH��PC->IF/ID��PCֵ����ǰPC�Ĵ���ֵ+1��
	signal IfPc : std_logic_vector(15 downto 0);
	-- BRCH->PC����һ��PCֵ
	signal IfNPc : std_logic_vector(15 downto 0);
	-- MMIO->IF/ID��ָ��
	-- �Ƿ�ȡָ���ź�
	signal IfRd : std_logic;
	signal IfInsn : std_logic_vector(15 downto 0);
	-- VM->IF/ID���쳣�ź�
	signal IfPf : std_logic;
	-- VM->IF/ID���쳣�ź�
	signal IfTlb : std_logic;
	-- VM->MMIO�������ַ
	signal IfPa : std_logic_vector(8 downto 0);
	-- IF/ID->MUX_INSN��ָ��
	signal IdInsn : std_logic_vector(15 downto 0);
	-- MUX_INSN->ID��ָ��
	signal IdExInsn : std_logic_vector(19 downto 0);
	-- IF/ID->ID/EXE��PCֵ
	signal IdPc : std_logic_vector(15 downto 0);
	-- IF/ID->ID/EXE��ҳ�쳣
	signal IdIfPf : std_logic;
	-- IF/ID->ID/EXE��TLB Miss
	signal IdIfTlb : std_logic;
	-- ID->REGS��Reg1�ź�
	signal IdReg1 : std_logic_vector(3 downto 0);
	-- ID->REGS��Reg2�ź�
	signal IdReg2 : std_logic_vector(3 downto 0);
	-- ID->ID/EXE��Imm������
	signal IdImm : std_logic_vector(15 downto 0);
	-- ID->ID/EXE��RegDst�ź�
	signal IdRegDst : std_logic_vector(3 downto 0);
	-- ID->ID/EXE��Op1Src�ź�
	signal IdOp1Src : std_logic;
	-- ID->ID/EXE��Op2Src�ź�
	signal IdOp2Src : std_logic;
	-- ID->ID/EXE��AluOp�ź�
	signal IdAluOp : std_logic_vector(3 downto 0);
	-- ID->ID/EXE��TWr�ź�
	signal IdTWr : std_logic;
	-- ID->ID/EXE��Jcond�ź�
	signal IdJcond : std_logic_vector(2 downto 0);
	-- ID->ID/EXE��MemRd�ź�
	signal IdMemRd : std_logic;
	-- ID->ID/EXE��MemWr�ź�
	signal IdMemWr : std_logic;
	-- ID->ID/EXE��RegWr�ź�
	signal IdRegWr : std_logic;
	-- ID->ID/EXE�ķǷ�ָ���쳣
	signal IdInval : std_logic;
	-- ID->ID/EXE��Ȩ��ָ���쳣
	signal IdPriv : std_logic;
	-- ID->ID/EXE��INTָ���ź�
	signal IdInt : std_logic;
	-- ID->ID/EXE�Ľ������м��ź�
	signal IdDegrade : std_logic;
	-- ID->ID/EXE��ˢ����ˮ���ź�
	signal IdReload : std_logic;
	-- ID->ID/EXE��ˢ��TLB
	signal IdTlbClr : std_logic;
	-- ID->ID/EXE��RET
	signal IdRet : std_logic;
	-- REGS->ID/EXE��Data1����
	signal IdData1 : std_logic_vector(15 downto 0);
	-- REGS->ID/EXE��Data2����
	signal IdData2 : std_logic_vector(15 downto 0);
	-- ID/EXE->MUX1��Data1����
	signal ExeData1 : std_logic_vector(15 downto 0);
	-- ID/EXE->MUX2��MUX3��Data2����
	signal ExeData2 : std_logic_vector(15 downto 0);
	-- ID/EXE->FWD��HAZD��Reg1�ź�
	signal ExeReg1 : std_logic_vector(3 downto 0);
	-- ID/EXE->FWD��HAZD��Reg2�ź�
	signal ExeReg2 : std_logic_vector(3 downto 0);
	-- ID/EXE->EXE/MEM��RegDst�ź�
	signal ExeRegDst : std_logic_vector(3 downto 0);
	-- ID/EXE->MUX3��Immֵ
	signal ExeImm : std_logic_vector(15 downto 0);
	-- ID/EXE->FWD��Op1Src�ź�
	signal ExeOp1Src : std_logic;
	-- ID/EXE->FWD��Op2Src�ź�
	signal ExeOp2Src : std_logic;
	-- ID/EXE->MUX1��EXE_MEM��PCֵ
	signal ExePc : std_logic_vector(15 downto 0);
	-- ID/EXE->ALU��AluOp�ź�
	signal ExeAluOp : std_logic_vector(3 downto 0);
	-- ID/EXE->EXE/MEM��Jcond�ź�
	signal ExeJcond : std_logic_vector(2 downto 0);
	-- ID/EXE->EXE/MEM��TWr�ź�
	signal ExeTWr : std_logic;
	-- ID/EXE->EXE/MEM��MemRd�ź�
	signal ExeMemRd : std_logic;
	-- ID/EXE->EXE/MEM��MemWr�ź�
	signal ExeMemWr : std_logic;
	-- ID/EXE->EXE/MEM��RegWr�ź�
	signal ExeRegWr : std_logic;
	-- ID/EXE->EXE/MEM��IfPf�쳣
	signal ExeIfPf : std_logic;
	-- ID/EXE->EXE/MEM�ķǷ�ָ���쳣
	signal ExeInval : std_logic;
	-- ID/EXE->EXE/MEM��Ȩ��ָ���쳣
	signal ExePriv : std_logic;
	-- ID/EXE->EXE/MEM��Ret
	signal ExeRet : std_logic;
	-- ID/EXE->EXE/MEM��INT
	signal ExeInt : std_logic;
	-- ID/EXE->EXE/MEM�Ľ������м�
	signal ExeDegrade : std_logic;
	-- ID/EXE->EXE/MEM���쳣
	signal ExeIfTlb : std_logic;
	-- ID/EXE->EXE/MEM��ˢ����ˮ��
	signal ExeReload : std_logic;
	-- ID/EXE->EXE/MEM��ˢ��TLB
	signal ExeTlbClr : std_logic;
	-- ALU->EXE/MEM��AluRes������
	signal ExeAluRes : std_logic_vector(15 downto 0);
	-- ALU->EXE/MEM��Bool����������
	signal ExeBool : std_logic;
	-- FWD->MUX1��ѡ���ź�
	signal ExeFwd1 : std_logic_vector(1 downto 0);
	-- FWD->MUX2��ѡ���ź�
	signal ExeFwd2 : std_logic_vector(1 downto 0);
	-- FWD->MUX3��ѡ���ź�
	signal ExeFwd3 : std_logic_vector(1 downto 0);
	-- MUX1->ALU�ĵ�һ������
	signal ExeOp1 : std_logic_vector(15 downto 0);
	-- MUX2->ALU�ĵڶ�������
	signal ExeOp2 : std_logic_vector(15 downto 0);
	-- MUX3->EXE/MEM��ZCMP��Data2����
	signal ExeFData2 : std_logic_vector(15 downto 0);
	-- ZCMP->EXE/MEM�����־λ
	signal ExeZf : std_logic;
	-- EXE/MEM->COND��PCֵ
	signal MemPc : std_logic_vector(15 downto 0);
	-- EXE/MEM->T���±�־
	signal MemBool : std_logic;
	-- EXE/MEM->BRCH��MEM/WB��VM����PC/ALU������/�ڴ��ַ
	signal MemAluRes : std_logic_vector(15 downto 0);
	-- EXE/MEM->MMIO��BRCH�Ĵ�д������/��PC
	signal MemData2 : std_logic_vector(15 downto 0);
	-- EXE/MEM->TFLAG��д���ź�
	signal MemTWr : std_logic;
	-- EXE/MEM->COND����ת����
	signal MemJcond : std_logic_vector(2 downto 0);
	-- EXE/MEM->MMIO��MEM/WB��FWD��HAZD��MemRd�ź�
	signal MemMemRd : std_logic;
	-- EXE/MEM->MMIO��FWD��HAZD��MemWr�ź�
	signal MemMemWr : std_logic;
	-- EXE/MEM->MEM/WB��FWD��RegWr�ź�
	signal MemRegWr : std_logic;
	-- EXE/MEM->MEM/WB��FWD��HAZD��RegDst�ź�
	signal MemRegDst : std_logic_vector(3 downto 0);
	-- EXE/MEM->EXCP��IfPf�쳣
	signal MemIfPf : std_logic;
	-- EXE/MEM->EXCP��II�쳣
	signal MemInval : std_logic;
	-- EXE/MEM->EXCP����Ȩָ���쳣
	signal MemPriv : std_logic;
	-- EXE/MEM->EXCP��INT�쳣
	signal MemInt : std_logic;
	-- EXE/MEM->LFLAG�Ľ������м��ź�
	signal MemDegrade : std_logic;
	-- EXE/MEM->EXCP��Tlb Miss
	signal MemIfTlb : std_logic;
	-- EXE/MEM->EXCP��Ret
	signal MemRet : std_logic;
	-- EXE/MEM->BRCH��ˢ����ˮ��
	signal MemReload : std_logic;
	-- EXE/MEM->VM��ˢ��TLB
	signal MemTlbClr : std_logic;
	-- VM->EXCP��Page Fault
	signal MemMemPf : std_logic;
	-- VM->EXCP��TLB MISS
	signal MemMemTlb : std_logic;
	-- VM->MMIO�������ַ
	signal MemPa : std_logic_vector(8 downto 0);
	-- T->COND�������ź�
	signal MemTf : std_logic;
	-- COND->BRCH��ָ����ת�ź�
	signal MemJFlag : std_logic;
	-- COND->BRCH����PC�ź�
	signal MemNPc : std_logic_vector(15 downto 0); 
	-- EXE/MEM->COND��ZCMP���
	signal MemZf : std_logic;
	-- MMIO->MEM/WB�Ķ�������
	signal MemMemData : std_logic_vector(15 downto 0);
	-- MEM/WB->MUX4��ALU������
	signal WbAluRes : std_logic_vector(15 downto 0);
	-- MEM/WB->MUX4���ڴ�����
	signal WbMemData : std_logic_vector(15 downto 0);
	-- MEM/WB->MUX4��ѡ���ź�
	signal WbMemRd : std_logic;
	-- MEM/WB->REGS��FWD��RegDst�ź�
	signal WbRegDst : std_logic_vector(3 downto 0);
	-- MEM/WB->REGS��FWD��RegWr�ź�
	signal WbRegWr : std_logic;
	-- MUX4->REGS��MUX1��MUX2��MUX3��д������
	signal WbData : std_logic_vector(15 downto 0);
	
	-- ȫ���ź�
	-- EXCP->LF���м������ź�
	signal ExcpDoDegrade : std_logic;
	-- REGS->EXCP��IntEn��־
	signal IntEn : std_logic;
	-- REGS->VM�����÷�ҳ�ź�
	signal PE : std_logic;
	-- HAZD->PC�ı����ź�
	signal HoldPc : std_logic;
	-- HAZD->IF/ID��ID/EXE�ı����ź�
	signal HoldReg : std_logic;
	-- HAZD->BUBBLE�������ź�
	signal BubHz : std_logic_vector(2 downto 0);
	-- BUBBLE->IF/ID�������ź�
	signal BubFD : std_logic;
	-- BUBBLE->ID/EXE�������ź�
	signal BubDE : std_logic;
	-- BUBBLE->EXE/MEM�������ź�
	signal BubEM : std_logic;
	-- BRCH->BUBBLE�������ź�
	signal BubBr : std_logic_vector(2 downto 0);
	-- EXCP->BUBBLE�������ź�
	signal BubEx : std_logic_vector(2 downto 0);
	-- EXCP->MUX_INSN��BRCH��ExcpPrep�ź�
	signal ExcpPrep : std_logic;
	-- EXCP->MUX_INSN��ָ��
	signal ExcpInsn : std_logic_vector(19 downto 0);
	-- EXCP->LFLAG��REGS��ExcpTr�ź�
	signal ExcpTr : std_logic;
	-- EXCP->BRCH��BrchPc
	signal BrchPc : std_logic_vector(15 downto 0);
	-- EXCP->VM�Ĳ�ʹ��VM�ź�
	signal IgnTlb : std_logic;
	-- EXCP->VM��д��TLB�±�
	signal TlbWr : std_logic;
	-- EXCP->VM��д��TLB�±�
	signal TlbVa : std_logic_vector(5 downto 0);
	-- LFLAG->ID��EXCP����Ȩ��
	signal Lf : std_logic;
	-- MMIO���ڴ���ʳ�ͻ�ź�
	signal MemConflict : std_logic;

	-- ps2���������ź�,Debug��
	signal Ps2Ready : std_logic;
	signal MemActRd : std_logic;
	signal MemActWr : std_logic;
	
	signal ER : std_logic_vector(15 downto 0);
	
	signal IfAddr : std_logic_vector(18 downto 0);
	signal MemAddr : std_logic_vector(18 downto 0);
	
	signal BubbleMW : std_logic;
	
	signal BrchReload : std_logic;
	
	signal BubFD2 : std_logic;
	
	signal VmPe : std_logic;
	
	signal HazdReload : std_logic;
	
	signal WbFwd : std_logic;
	
	signal Clk : std_logic;
	
	signal ClkCnt : std_logic;

   signal IdLf : std_logic;
	
	-- �ڲ��ж��ź�
	signal IntTimer : std_logic;
	constant IntKb : std_logic := '0';
	
	-- ������������2^20
	signal TimerCount : std_logic_vector(19 downto 0);
begin
	-- ��CLK��ƵΪ12.5MHz
	process(Rst,RealClk)
	begin
		if Rst = '0' then
			Clk <= '1';
			ClkCnt <= '0';
		elsif rising_edge(RealClk) then
			case ClkCnt is
				when '0' => ClkCnt <= '1';
				when '1' => ClkCnt <= '0'; Clk <= not Clk;
				when others => ClkCnt <= '0';
			end case;
		end if;
	end process;
	
	-- ʱ���ж�
	process(Rst,Clk)
	begin
		if Rst = '0' then
			TimerCount <= "00000000000000000000";
			IntTimer <= '0';
		elsif rising_edge(Clk) then
			if TimerCount = "11111111111111111111" then
				TimerCount <= "00000000000000000000";
				IntTimer <= '1';
			else
				TimerCount <= TimerCount + 1;
				IntTimer <= '0';
			end if;
		end if;	
	end process;

	PC1 : PC port map (
		Rst => Rst,
		Clk => Clk,
		PcValueRd => IfVa,
		PcPlus1 => IfPc,
		PcValueWr => IfNPc,
		Hold => HoldPc
	);
	
	MemActRd <= '1' when MemMemRd = '1' and MemMemTlb = '0' and MemMemPf = '0' else '0';
	MemActWr <= '1' when MemMemWr = '1' and MemMemTlb = '0' and MemMemPf = '0' else '0';
	
	IfAddr <= IfPa & IfVa(9 downto 0);
	MemAddr <= MemPa & MemAluRes(9 downto 0);
	
	MMIO1 : MMIO port map (
		IfAddr => IfAddr,
		Insn => IfInsn,
		MemAddr => MemAddr,
		MemDataWr => MemData2,
		MemDataRd => MemMemData,
		MemRd => MemActRd,
		MemWr => MemActWr,
		Cnflc => MemConflict,

		Ram2Addr => Ram2Addr,
		Ram2Data => Ram2Data,
		Ram2WE => Ram2WE,
		Ram2OE => Ram2OE,
		Ram2EN => Ram2EN,

		Ram1Addr => Ram1Addr,
		Ram1Data => Ram1Data,
		Ram1WE => Ram1WE,
		Ram1OE => Ram1OE,
		Ram1EN => Ram1EN,

		ComDataReady => ComDataReady,
		ComRdn => ComRdn,
		ComTbre => ComTbre,
		ComTsre => ComTsre,
		ComWrn => ComWrn,
		
		PS2CLK => Ps2KbClock,
      PS2DATA => Ps2KbData,
		
		Clk50 => RealClk,
	   VgaR => VgaR,
      VgaG => VgaG,
      VgaB => VgaB,
      VgaHS => VgaHS,
      VgaVS => VgaVS,
		
		Ps2Readyy => Ps2Ready,

		Clk => Clk
	);
	
	BubFD2 <= '1' when BubFD = '1' or IfTlb = '1' or IfPf = '1' else '0'; 
	
	IF_ID1 : IF_ID port map (
		InsnWr => IfInsn,
		InsnRd => IdInsn,
		PcWr => IfPc,
		PcRd => IdPc,
		IfPfWr => IfPf,
		IfPfRd => IdIfPf,
		IfTlbWr => IfTlb,
		IfTlbRd => IdIfTlb,
		Bubble => BubFD2,
		Hold => HoldReg,
		Clk => Clk,
		Rst => Rst
	);
	
	IdExInsn <= "0000" & IdInsn when ExcpPrep = '0' else
					ExcpInsn;

   IdLf <= Lf and (not ExcpPrep);
	
	ID1 : ID port map (
		Lf => IdLf,
		Insn => IdExInsn,
		Reg1 => IdReg1,
		Reg2 => IdReg2,
		RegDst => IdRegDst,
		Imm => IdImm,
		Op1Src => IdOp1Src,
		Op2Src => IdOp2Src,
		AluOp => IdAluOp,
		TWr => IdTWr,
		Jcond => IdJcond,
		MemRd => IdMemRd,
		MemWr => IdMemWr,
		RegWr => IdRegWr,
		Inval => IdInval,
		Priv => IdPriv,
		Int => IdInt,
		Degrade => IdDegrade,
		Reload => IdReload,
		TlbClr => IdTlbClr,
		Ret => IdRet
	);
	
	REGS1 : REGS port map (
		Reg1 => IdReg1,
		Reg2 => IdReg2,
		Data1 => IdData1,
		Data2 => IdData2,
		RegWr => WbRegWr,
		RegDataWr => WbData,
		RegDst => WbRegDst,
		IntEn => IntEn,
		IntHdl => ExcpTr,
		EROut => ER,
		PE => PE,
		Clk => Clk,
		Rst => Rst
	);
	
	ID_EXE1 : ID_EXE port map (
		Data1Wr => IdData1,
		Data2Wr => IdData2,
		Reg1Wr => IdReg1,
		Reg2Wr => IdReg2,
		RegDstWr => IdRegDst,
		ImmWr => IdImm,
		PcWr => IdPc,
		Op1SrcWr => IdOp1Src,
		Op2SrcWr => IdOp2Src,
		AluOpWr => IdAluOp,
		TWrWr => IdTWr,
		JcondWr => IdJcond,
		MemRdWr => IdMemRd,
		MemWrWr => IdMemWr,
		RegWrWr => IdRegWr,
		IfPfWr => IdIfPf,
		IdInvalWr => IdInval,
		IdPrivWr => IdPriv,
		IntWr => IdInt,
		DegradeWr => IdDegrade,
		IfTlbWr => IdIfTlb,
		ReloadWr => IdReload,
		TlbClrWr => IdTlbClr,
		RetWr => IdRet,
		Data1Rd => ExeData1,
		Data2Rd => ExeData2,
		Reg1Rd => ExeReg1,
		Reg2Rd => ExeReg2,
		RegDstRd => ExeRegDst,
		ImmRd => ExeImm,
		PcRd => ExePc,
		Op1SrcRd => ExeOp1Src,
		Op2SrcRd => ExeOp2Src,
		AluOpRd => ExeAluOp,
		TWrRd => ExeTWr,
		JcondRd => ExeJcond,
		MemRdRd => ExeMemRd,
		MemWrRd => ExeMemWr,
		RegWrRd => ExeRegWr,
		IfPfRd => ExeIfPf,
		IdInvalRd => ExeInval,
		IdPrivRd => ExePriv,
		IntRd => ExeInt,
		DegradeRd => ExeDegrade,
		IfTlbRd => ExeIfTlb,
		ReloadRd => ExeReload,
		TlbClrRd => ExeTlbClr,
		RetRd => ExeRet,
		Bubble => BubDE,
		Hold => HoldReg,
		Clk => Clk,
		Rst => Rst
	);
	
	MUX_1 : MUX4 port map (
		X0 => ExeData1,
		X1 => ExePc,
		X2 => MemAluRes,
		X3 => WbData,
		Y => ExeOp1,
		Sel => ExeFwd1
	);
	
	MUX_2 : MUX4 port map (
		X0 => ExeData2,
		X1 => ExeImm,
		X2 => MemAluRes,
		X3 => WbData,
		Y => ExeOp2,
		Sel => ExeFwd2
	);
	
	MUX_3 : MUX4 port map (
		X0 => ExeData2,
		X1 => MemAluRes,
		X2 => WbData,
		X3 => "0000000000000000",
		Y => ExeFData2,
		Sel => ExeFwd3
	);
	
	ZCMP1 : ZCMP port map (
		Data => ExeFData2,
		ZF => ExeZf
	);
	
	FWD1 : FWD port map (
		MemRdM => MemMemRd,
		RegDstM => MemRegDst,
		RegWrM => MemRegWr,
		RegDstW => WbRegDst,
		RegWrW => WbRegWr,
		Reg1 => ExeReg1,
		Reg2 => ExeReg2,
		Op1Src => ExeOp1Src,
		Op2Src => ExeOp2Src,
		Fwd1 => ExeFwd1,
		Fwd2 => ExeFwd2,
		Fwd3 => ExeFwd3,
		WbFwd => WbFwd
	);
	
	ALU1 : ALU port map (
		Op1 => ExeOp1,
		Op2 => ExeOp2,
		AluOp => ExeAluOp,
		AluRes => ExeAluRes,
		Bool => ExeBool
	);
	
	EXE_MEM1 : EXE_MEM port map (
		RegDstWr => ExeRegDst,
		PcWr => ExePc,
		BoolWr => ExeBool,
		AluResWr => ExeAluRes,
		ZFWr => ExeZf,
		Data2Wr => ExeFData2,
		TWrWr => ExeTWr,
		JcondWr => ExeJcond,
		MemRdWr => ExeMemRd,
		MemWrWr => ExeMemWr,
		RegWrWr => ExeRegWr,
		IfPfWr => ExeIfPf,
		IdInvalWr => ExeInval,
		IdPrivWr => ExePriv,
		IntWr => ExeInt,
		DegradeWr => ExeDegrade,
		IfTlbWr => ExeIfTlb,
		ReloadWr => ExeReload,
		TlbClrWr => ExeTlbClr,
		RetWr => ExeRet,
		RegDstRd => MemRegDst,
		PcRd => MemPc,
		BoolRd => MemBool,
		AluResRd => MemAluRes,
		ZFRd => MemZf,
		Data2Rd => MemData2,
		TWrRd => MemTWr,
		JcondRd => MemJcond,
		MemRdRd => MemMemRd,
		MemWrRd => MemMemWr,
		RegWrRd => MemRegWr,
		IfPfRd => MemIfPf,
		IdInvalRd => MemInval,
		IdPrivRd => MemPriv,
		IntRd => MemInt,
		DegradeRd => MemDegrade,
		IfTlbRd => MemIfTlb,
		ReloadRd => MemReload,
		TlbClrRd => MemTlbClr,
		RetRd => MemRet,
		Bubble => BubEM,
		Clk => Clk,
		Rst => Rst
	);
	
	TFLAG1 : TFLAG port map (
		TValueWr => MemBool,
		TValueRd => MemTf,
		TWr => MemTWr,
		Clk => Clk,
		Rst => Rst
	);
	
	COND1 : COND port map (
		TF => MemTf,
		ZF => MemZf,
		Jcond => MemJcond,
		Pc => MemPc,
		AluRes => MemAluRes,
		Data2 => MemData2,
		NPc => MemNPc,
		JFlag => MemJFlag
	);
	
	BubbleMW <= '1' when MemMemTlb = '1' or MemMemPf = '1' else '0';
	
	MEM_WB1 : MEM_WB port map (
		AluResWr => MemAluRes,
		MemDataWr => MemMemData,
		RegDstWr => MemRegDst,
		MemRdWr => MemMemRd,
		RegWrWr => MemRegWr,
		AluResRd => WbAluRes,
		MemDataRd => WbMemData,
		RegDstRd => WbRegDst,
		MemRdRd => WbMemRd,
		RegWrRd => WbRegWr,
		Bubble => BubbleMW,
		Clk => Clk,
		Rst => Rst
	);
	
	MUX_4 : MUX2 port map (
		X0 => WbAluRes,
		X1 => WbMemData,
		Y => WbData,
		Sel => WbMemRd
	);
	
	BrchReload <= MemReload or HazdReload;
	
	BRCH1 : BRCH port map (
		Pc => IfPc,
		NPc => IfNPc,
		MemPc => MemPc,
		MemNPc => MemNPc,
		Jcond => MemJcond,
		JFlag => MemJFlag,
		ExcpPrep => ExcpPrep,
		EPc => BrchPc,
		Bubble => BubBr,
		Reload => BrchReload,
		Clk => Clk,
		Rst => Rst
	);
	
	BUBBLE1 : BUBBLE port map (
		BubBr => BubBr,
		BubHz => BubHz,
		BubEx => BubEx,
		BubFD => BubFD,
		BubDE => BubDE,
		BubEM => BubEM
	);
	
	HAZD1 : HAZD port map (
		MemRd => MemMemRd,
		MemConflict => MemConflict,
		RegDst => MemRegDst,
		Reg1 => ExeReg1,
		Reg2 => ExeReg2,
		HoldReg => HoldReg,
		HoldPc => HoldPc,
		Bubble => BubHz,
		WbFwd => WbFwd,
		Reload => HazdReload
	);
	
	EXCP1 : EXCP port map (
		IfPf => MemIfPf,
		MemPc => MemPc,
		NPc => MemNPc,
		BrchPc => BrchPc,
		IdInval => MemInval,
		IdPriv => MemPriv,
		MemPf => MemMemPf,
		MemVA => MemAluRes,
		MemWr => MemMemWr,
		IntInsn => MemInt,
		IntEn => IntEn,
		IntTimer => IntTimer,
		IfTlb => MemIfTlb,
		MemTlb => MemMemTlb,
		IgnTlb => IgnTlb,
		TlbVa => TlbVa,
		TlbWr => TlbWr,
		IntKb => IntKb,
		BubExcp => BubEx,
		ExcpPrep => ExcpPrep,
		ER => ER,
		Lf => Lf,
		ExcpTr => ExcpTr,
		ExcpInsn => ExcpInsn,
		Ret => MemRet,
		DoDegrade => ExcpDoDegrade,
		Clk => Clk,
		Rst => Rst
	);
	
	LFLAG1 : LFLAG port map (
		Degrade => ExcpDoDegrade,
		ExcpTr => ExcpTr,
		Lf => Lf,
		Clk => Clk,
		Rst => Rst
	);
	
	IfRd <= '1' when BubFD = '0' else '0';
	VmPe <= PE and (not IgnTlb);
	VM1 : VM port map (
		Lf => Lf,
		IfVa => IfVa(15 downto 10),
		IfRd => IfRd,
		IfPa => IfPa,
		IfTlb => IfTlb,
		IfPf => IfPf,
		MemVa => MemAluRes(15 downto 10),
		MemRd => MemMemRd,
		MemWr => MemMemWr,
		MemPa => MemPa,
		MemTlb => MemMemTlb,
		MemPf => MemMemPf,
		TlbVa => TlbVa,
		TlbData => WbData,
		TlbWr => TlbWr,
		TlbClr => MemTlbClr,
		PE => VmPe,
		Clk => Clk,
		Rst => Rst
	);
	DbOut <= "000000000000"& PS2READY & ComTbre& ComTsre & ComDataReady;
end Behavioral;

