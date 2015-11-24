LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IDEX is
    port(clk: in std_logic;
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
         pcWriteOut_in : in std_logic;

         PC_out     : out std_logic_vector(15 downto 0);
         OP_out     : out std_logic_vector(4 downto 0);
         A_out      : out std_logic_vector(15 downto 0);
         B_out      : out std_logic_vector(15 downto 0);
         rd_out     : out std_logic_vector(2 downto 0);
         rs_out     : out std_logic_vector(2 downto 0);
         rt_out     : out std_logic_vector(2 downto 0);
         im_out     : out std_logic_vector(15 downto 0);
         SpAns_out  : out std_logic_vector(15 downto 0);
         pcWriteOut_out : out std_logic);
end IDEX;

architecture behavior of IDEX is
begin
    process(clk)
    begin
        if rst='0' then
            OP_out <= "00000";
        elsif clk = '1' and clk'event then
            PC_out      <= PC_in;
            OP_out      <= OP_in;
            A_out       <= A_in;
            B_out       <= B_in;
            rd_out      <= rd_in;
            rs_out      <= rs_in;
            rt_out      <= rt_in;
            im_out      <= im_in;
            SpAns_out   <= SpAns_in;
            pcWriteOut_out <= pcWriteOut_in;
        end if;
    end process;
end behavior;