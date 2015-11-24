----------------------------------------------------------------------------------
-- 元件名称：CPU顶层元件
-- 端口描述：
--		Clk		时钟信号
--		Rst		复位信号
--		Ram2Data	RAM2的数据线
--		Ram2Addr	RAM2的地址线
--		Ram2OE	RAM2的输出使能
--		Ram2WE	RAM2的写使能
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

	-- 所有需要被例化的元件
	
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
	
	-- 流水线段内信号
	
	-- PC->VM的待取指令地址
	signal IfVa : std_logic_vector(15 downto 0);
	-- PC->BRCH与PC->IF/ID的PC值（当前PC寄存器值+1）
	signal IfPc : std_logic_vector(15 downto 0);
	-- BRCH->PC的下一个PC值
	signal IfNPc : std_logic_vector(15 downto 0);
	-- MMIO->IF/ID的指令
	-- 是否取指令信号
	signal IfRd : std_logic;
	signal IfInsn : std_logic_vector(15 downto 0);
	-- VM->IF/ID的异常信号
	signal IfPf : std_logic;
	-- VM->IF/ID的异常信号
	signal IfTlb : std_logic;
	-- VM->MMIO的物理地址
	signal IfPa : std_logic_vector(8 downto 0);
	-- IF/ID->MUX_INSN的指令
	signal IdInsn : std_logic_vector(15 downto 0);
	-- MUX_INSN->ID的指令
	signal IdExInsn : std_logic_vector(19 downto 0);
	-- IF/ID->ID/EXE的PC值
	signal IdPc : std_logic_vector(15 downto 0);
	-- IF/ID->ID/EXE的页异常
	signal IdIfPf : std_logic;
	-- IF/ID->ID/EXE的TLB Miss
	signal IdIfTlb : std_logic;
	-- ID->REGS的Reg1信号
	signal IdReg1 : std_logic_vector(3 downto 0);
	-- ID->REGS的Reg2信号
	signal IdReg2 : std_logic_vector(3 downto 0);
	-- ID->ID/EXE的Imm操作数
	signal IdImm : std_logic_vector(15 downto 0);
	-- ID->ID/EXE的RegDst信号
	signal IdRegDst : std_logic_vector(3 downto 0);
	-- ID->ID/EXE的Op1Src信号
	signal IdOp1Src : std_logic;
	-- ID->ID/EXE的Op2Src信号
	signal IdOp2Src : std_logic;
	-- ID->ID/EXE的AluOp信号
	signal IdAluOp : std_logic_vector(3 downto 0);
	-- ID->ID/EXE的TWr信号
	signal IdTWr : std_logic;
	-- ID->ID/EXE的Jcond信号
	signal IdJcond : std_logic_vector(2 downto 0);
	-- ID->ID/EXE的MemRd信号
	signal IdMemRd : std_logic;
	-- ID->ID/EXE的MemWr信号
	signal IdMemWr : std_logic;
	-- ID->ID/EXE的RegWr信号
	signal IdRegWr : std_logic;
	-- ID->ID/EXE的非法指令异常
	signal IdInval : std_logic;
	-- ID->ID/EXE的权限指令异常
	signal IdPriv : std_logic;
	-- ID->ID/EXE的INT指令信号
	signal IdInt : std_logic;
	-- ID->ID/EXE的降低运行级信号
	signal IdDegrade : std_logic;
	-- ID->ID/EXE的刷新流水线信号
	signal IdReload : std_logic;
	-- ID->ID/EXE的刷新TLB
	signal IdTlbClr : std_logic;
	-- ID->ID/EXE的RET
	signal IdRet : std_logic;
	-- REGS->ID/EXE的Data1数据
	signal IdData1 : std_logic_vector(15 downto 0);
	-- REGS->ID/EXE的Data2数据
	signal IdData2 : std_logic_vector(15 downto 0);
	-- ID/EXE->MUX1的Data1数据
	signal ExeData1 : std_logic_vector(15 downto 0);
	-- ID/EXE->MUX2和MUX3的Data2数据
	signal ExeData2 : std_logic_vector(15 downto 0);
	-- ID/EXE->FWD和HAZD的Reg1信号
	signal ExeReg1 : std_logic_vector(3 downto 0);
	-- ID/EXE->FWD和HAZD的Reg2信号
	signal ExeReg2 : std_logic_vector(3 downto 0);
	-- ID/EXE->EXE/MEM的RegDst信号
	signal ExeRegDst : std_logic_vector(3 downto 0);
	-- ID/EXE->MUX3的Imm值
	signal ExeImm : std_logic_vector(15 downto 0);
	-- ID/EXE->FWD的Op1Src信号
	signal ExeOp1Src : std_logic;
	-- ID/EXE->FWD的Op2Src信号
	signal ExeOp2Src : std_logic;
	-- ID/EXE->MUX1和EXE_MEM的PC值
	signal ExePc : std_logic_vector(15 downto 0);
	-- ID/EXE->ALU的AluOp信号
	signal ExeAluOp : std_logic_vector(3 downto 0);
	-- ID/EXE->EXE/MEM的Jcond信号
	signal ExeJcond : std_logic_vector(2 downto 0);
	-- ID/EXE->EXE/MEM的TWr信号
	signal ExeTWr : std_logic;
	-- ID/EXE->EXE/MEM的MemRd信号
	signal ExeMemRd : std_logic;
	-- ID/EXE->EXE/MEM的MemWr信号
	signal ExeMemWr : std_logic;
	-- ID/EXE->EXE/MEM的RegWr信号
	signal ExeRegWr : std_logic;
	-- ID/EXE->EXE/MEM的IfPf异常
	signal ExeIfPf : std_logic;
	-- ID/EXE->EXE/MEM的非法指令异常
	signal ExeInval : std_logic;
	-- ID/EXE->EXE/MEM的权限指令异常
	signal ExePriv : std_logic;
	-- ID/EXE->EXE/MEM的Ret
	signal ExeRet : std_logic;
	-- ID/EXE->EXE/MEM的INT
	signal ExeInt : std_logic;
	-- ID/EXE->EXE/MEM的降低运行级
	signal ExeDegrade : std_logic;
	-- ID/EXE->EXE/MEM的异常
	signal ExeIfTlb : std_logic;
	-- ID/EXE->EXE/MEM的刷新流水线
	signal ExeReload : std_logic;
	-- ID/EXE->EXE/MEM的刷新TLB
	signal ExeTlbClr : std_logic;
	-- ALU->EXE/MEM的AluRes计算结果
	signal ExeAluRes : std_logic_vector(15 downto 0);
	-- ALU->EXE/MEM的Bool布尔运算结果
	signal ExeBool : std_logic;
	-- FWD->MUX1的选择信号
	signal ExeFwd1 : std_logic_vector(1 downto 0);
	-- FWD->MUX2的选择信号
	signal ExeFwd2 : std_logic_vector(1 downto 0);
	-- FWD->MUX3的选择信号
	signal ExeFwd3 : std_logic_vector(1 downto 0);
	-- MUX1->ALU的第一操作数
	signal ExeOp1 : std_logic_vector(15 downto 0);
	-- MUX2->ALU的第二操作数
	signal ExeOp2 : std_logic_vector(15 downto 0);
	-- MUX3->EXE/MEM和ZCMP的Data2数据
	signal ExeFData2 : std_logic_vector(15 downto 0);
	-- ZCMP->EXE/MEM的零标志位
	signal ExeZf : std_logic;
	-- EXE/MEM->COND的PC值
	signal MemPc : std_logic_vector(15 downto 0);
	-- EXE/MEM->T的新标志
	signal MemBool : std_logic;
	-- EXE/MEM->BRCH和MEM/WB和VM的新PC/ALU计算结果/内存地址
	signal MemAluRes : std_logic_vector(15 downto 0);
	-- EXE/MEM->MMIO和BRCH的待写入数据/新PC
	signal MemData2 : std_logic_vector(15 downto 0);
	-- EXE/MEM->TFLAG的写入信号
	signal MemTWr : std_logic;
	-- EXE/MEM->COND的跳转条件
	signal MemJcond : std_logic_vector(2 downto 0);
	-- EXE/MEM->MMIO和MEM/WB和FWD和HAZD的MemRd信号
	signal MemMemRd : std_logic;
	-- EXE/MEM->MMIO和FWD和HAZD的MemWr信号
	signal MemMemWr : std_logic;
	-- EXE/MEM->MEM/WB和FWD的RegWr信号
	signal MemRegWr : std_logic;
	-- EXE/MEM->MEM/WB和FWD和HAZD的RegDst信号
	signal MemRegDst : std_logic_vector(3 downto 0);
	-- EXE/MEM->EXCP的IfPf异常
	signal MemIfPf : std_logic;
	-- EXE/MEM->EXCP的II异常
	signal MemInval : std_logic;
	-- EXE/MEM->EXCP的特权指令异常
	signal MemPriv : std_logic;
	-- EXE/MEM->EXCP的INT异常
	signal MemInt : std_logic;
	-- EXE/MEM->LFLAG的降低运行级信号
	signal MemDegrade : std_logic;
	-- EXE/MEM->EXCP的Tlb Miss
	signal MemIfTlb : std_logic;
	-- EXE/MEM->EXCP的Ret
	signal MemRet : std_logic;
	-- EXE/MEM->BRCH的刷新流水线
	signal MemReload : std_logic;
	-- EXE/MEM->VM的刷新TLB
	signal MemTlbClr : std_logic;
	-- VM->EXCP的Page Fault
	signal MemMemPf : std_logic;
	-- VM->EXCP的TLB MISS
	signal MemMemTlb : std_logic;
	-- VM->MMIO的物理地址
	signal MemPa : std_logic_vector(8 downto 0);
	-- T->COND的条件信号
	signal MemTf : std_logic;
	-- COND->BRCH的指令跳转信号
	signal MemJFlag : std_logic;
	-- COND->BRCH的新PC信号
	signal MemNPc : std_logic_vector(15 downto 0); 
	-- EXE/MEM->COND的ZCMP输出
	signal MemZf : std_logic;
	-- MMIO->MEM/WB的读出数据
	signal MemMemData : std_logic_vector(15 downto 0);
	-- MEM/WB->MUX4的ALU计算结果
	signal WbAluRes : std_logic_vector(15 downto 0);
	-- MEM/WB->MUX4的内存数据
	signal WbMemData : std_logic_vector(15 downto 0);
	-- MEM/WB->MUX4的选择信号
	signal WbMemRd : std_logic;
	-- MEM/WB->REGS和FWD的RegDst信号
	signal WbRegDst : std_logic_vector(3 downto 0);
	-- MEM/WB->REGS和FWD的RegWr信号
	signal WbRegWr : std_logic;
	-- MUX4->REGS和MUX1和MUX2和MUX3的写回数据
	signal WbData : std_logic_vector(15 downto 0);
	
	-- 全局信号
	-- EXCP->LF运行级降低信号
	signal ExcpDoDegrade : std_logic;
	-- REGS->EXCP的IntEn标志
	signal IntEn : std_logic;
	-- REGS->VM的启用分页信号
	signal PE : std_logic;
	-- HAZD->PC的保持信号
	signal HoldPc : std_logic;
	-- HAZD->IF/ID和ID/EXE的保持信号
	signal HoldReg : std_logic;
	-- HAZD->BUBBLE的气泡信号
	signal BubHz : std_logic_vector(2 downto 0);
	-- BUBBLE->IF/ID的气泡信号
	signal BubFD : std_logic;
	-- BUBBLE->ID/EXE的气泡信号
	signal BubDE : std_logic;
	-- BUBBLE->EXE/MEM的气泡信号
	signal BubEM : std_logic;
	-- BRCH->BUBBLE的气泡信号
	signal BubBr : std_logic_vector(2 downto 0);
	-- EXCP->BUBBLE的气泡信号
	signal BubEx : std_logic_vector(2 downto 0);
	-- EXCP->MUX_INSN和BRCH的ExcpPrep信号
	signal ExcpPrep : std_logic;
	-- EXCP->MUX_INSN的指令
	signal ExcpInsn : std_logic_vector(19 downto 0);
	-- EXCP->LFLAG和REGS的ExcpTr信号
	signal ExcpTr : std_logic;
	-- EXCP->BRCH的BrchPc
	signal BrchPc : std_logic_vector(15 downto 0);
	-- EXCP->VM的不使用VM信号
	signal IgnTlb : std_logic;
	-- EXCP->VM的写入TLB下标
	signal TlbWr : std_logic;
	-- EXCP->VM的写入TLB下标
	signal TlbVa : std_logic_vector(5 downto 0);
	-- LFLAG->ID和EXCP的特权级
	signal Lf : std_logic;
	-- MMIO的内存访问冲突信号
	signal MemConflict : std_logic;

	-- ps2键盘数据信号,Debug用
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
	
	-- 内部中断信号
	signal IntTimer : std_logic;
	constant IntKb : std_logic := '0';
	
	-- 计数器变量：2^20
	signal TimerCount : std_logic_vector(19 downto 0);
begin
	-- 给CLK降频为12.5MHz
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
	
	-- 时钟中断
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

