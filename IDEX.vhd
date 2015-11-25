LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IDEX is
    port(
        clk: in std_logic;
        rst: in std_logic;

        PC_in      : in std_logic_vector(15 downto 0);
        OP_in      : in std_logic_vector(4 downto 0);
        A_in       : in std_logic_vector(15 downto 0);
        B_in       : in std_logic_vector(15 downto 0);
        rd_in      : in std_logic_vector(2 downto 0);
        rs_in      : in std_logic_vector(2 downto 0);
        rt_in      : in std_logic_vector(2 downto 0);
        im_in      : in std_logic_vector(15 downto 0);
        SpAns_in   : in std_logic_vector(15 downto 0);

        alusrcA_in : in std_logic;
        alusrcB_in : in std_logic_vector(2 downto 0);
        aluOp_in   : in std_logic_vector(3 downto 0);

        memRead_in    : in std_logic;
        memToReg_in   : in std_logic;
        memWrite_in   : in std_logic;
        memData_in    : in std_logic;

        regDst_in     : in std_logic_vector(1 downto 0);
        regWrite_in   : in std_logic_vector(2 downto 0);

        pcWrite_in : in std_logic;

        PC_out      : out std_logic_vector(15 downto 0);
        OP_out      : out std_logic_vector(4 downto 0);
        A_out       : out std_logic_vector(15 downto 0);
        B_out       : out std_logic_vector(15 downto 0);
        rd_out      : out std_logic_vector(2 downto 0);
        rs_out      : out std_logic_vector(2 downto 0);
        rt_out      : out std_logic_vector(2 downto 0);
        im_out      : out std_logic_vector(15 downto 0);
        SpAns_out   : out std_logic_vector(15 downto 0);

        alusrcA_out : out std_logic;
        alusrcB_out : out std_logic_vector(2 downto 0);
        aluOp_out   : out std_logic_vector(3 downto 0);

        memRead_out    : out std_logic;
        memToReg_out   : out std_logic;
        memWrite_out   : out std_logic;
        memData_out    : out std_logic;

        regDst_out     : out std_logic_vector(1 downto 0);
        regWrite_out   : out std_logic_vector(2 downto 0);

        pcWrite_out : out std_logic);
end IDEX;

architecture behavior of IDEX is
signal opValue : std_logic_vector(4 downto 0) := OP_in;
begin
    process(clk, rst)
    begin
        if rst='0' then
            opValue <= "00000";
        elsif clk = '1' and clk'event then
            OP_out          <=  opValue;

            PC_out          <=  PC_in;
            A_out           <=  A_in;
            B_out           <=  B_in;
            rd_out          <=  rd_in;
            rs_out          <=  rs_in;
            rt_out          <=  rt_in;
            im_out          <=  im_in;
            SpAns_out       <=  SpAns_in;

            alusrcA_out     <=  alusrcA_in;
            alusrcB_out     <=  alusrcB_in;
            aluOp_out       <=  aluOp_in;

            memRead_out     <=  memRead_in;
            memToReg_out    <=  memToReg_in;
            memWrite_out    <=  memWrite_in;
            memData_out     <=  memData_in;

            regDst_out      <=  regDst_in;
            regWrite_out    <=  regWrite_in;

            pcWrite_out     <=  pcWrite_in;
        else
            -- nothing
        end if;
    end process;
end behavior;