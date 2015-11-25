LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEMWB is
    port(
        clk: in std_logic;
        rst: in std_logic;

        PC_in      : in std_logic_vector(15 downto 0);
        OP_in      : in std_logic_vector(4 downto 0);
        data_in    : in std_logic_vector(15 downto 0);
        rd_in      : in std_logic_vector(2 downto 0);
        regAdd_in  : in std_logic_vector(2 downto 0);

        regDst_in     : in std_logic_vector(1 downto 0);
        regWrite_in   : in std_logic_vector(2 downto 0);

        PC_out      : out std_logic_vector(15 downto 0);
        OP_out      : out std_logic_vector(4 downto 0);
        data_out    : out std_logic_vector(15 downto 0);
        rd_out      : out std_logic_vector(2 downto 0);
        regAdd_out  : out std_logic_vector(2 downto 0);

        regDst_out     : out std_logic_vector(1 downto 0);
        regWrite_out   : out std_logic_vector(2 downto 0));

end MEMWB;

architecture behavior of MEMWB is
signal opValue : std_logic_vector(4 downto 0) := OP_in;
begin
    process(clk, rst)
    begin
        if rst='0' then
            opValue <= "00000";
        elsif clk = '1' and clk'event then
            OP_out          <=  opValue;
            PC_out          <=  PC_in;
            data_out        <=  data_in;
            regAdd_out      <=  regAdd_in;
            rd_out          <=  rd_in;

            regDst_out      <=  regDst_in;
            regWrite_out    <=  regWrite_in;
        else
            -- nothing
        end if;
    end process;
end behavior;