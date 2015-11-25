LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EXMEM is
    port(
        clk: in std_logic;
        rst: in std_logic;

        PC_in      : in std_logic_vector(15 downto 0);
        OP_in      : in std_logic_vector(4 downto 0);
        ex_in      : in std_logic_vector(15 downto 0);
        ans_in     : in std_logic_vector(15 downto 0);
        rd_in      : in std_logic_vector(2 downto 0);

        memRead_in    : in std_logic;
        memToReg_in   : in std_logic;
        memWrite_in   : in std_logic;

        regDst_in     : in std_logic_vector(1 downto 0);
        regWrite_in   : in std_logic_vector(2 downto 0);

        PC_out      : out std_logic_vector(15 downto 0);
        OP_out      : out std_logic_vector(4 downto 0);
        ex_out      : out std_logic_vector(15 downto 0);
        ans_out     : out std_logic_vector(15 downto 0);
        rd_out      : out std_logic_vector(2 downto 0);

        memRead_out    : out std_logic;
        memToReg_out   : out std_logic;
        memWrite_out   : out std_logic;

        regDst_out     : out std_logic_vector(1 downto 0);
        regWrite_out   : out std_logic_vector(2 downto 0));

end EXMEM;

architecture behavior of EXMEM is
signal opValue : std_logic_vector(4 downto 0) := OP_in;
begin
    process(clk, rst)
    begin
        if rst='0' then
            opValue <= "00000";
        elsif clk = '1' and clk'event then
            OP_out          <=  opValue;
            PC_out          <=  PC_in;
            ex_out          <=  ex_in;
            ans_out         <=  ans_in;
            rd_out          <=  rd_in;

            memRead_out     <=  memRead_in;
            memToReg_out    <=  memToReg_in;
            memWrite_out    <=  memWrite_in;

            regDst_out      <=  regDst_in;
            regWrite_out    <=  regWrite_in;
        else
            -- nothing
        end if;
    end process;
end behavior;