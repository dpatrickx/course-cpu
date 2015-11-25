LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.control.ALL;
use work.my_data_types.ALL;

entity exe is
port(
PC_in     : in std_logic_vector(15 downto 0);
OP_in     : in std_logic_vector(4 downto 0);
A_in      : in std_logic_vector(15 downto 0);
B_in      : in std_logic_vector(15 downto 0);
rd_in     : in std_logic_vector(2 downto 0);
rs_in     : in std_logic_vector(2 downto 0);
rt_in     : in std_logic_vector(2 downto 0);
im_in     : in std_logic_vector(15 downto 0);
SpAns_in  : in std_logic_vector(15 downto 0);
IH_in     : in std_logic_vector(15 downto 0);
pcWriteOut_in : in std_logic;


PC_out : out std_logic_vector(15 downto 0);
OP_out : out std_logic_vector(4 downto 0);
ex_out : out std_logic_vector(15 downto 0);
A_out : out std_logic_vector(15 downto 0);
B_out : out std_logic_vector(15 downto 0);
rd_out : out std_logic_vector(2 downto 0);
rs_out : out std_logic_vector(2 downto 0);
rt_out : out std_logic_vector(2 downto 0);
im_out : out std_logic_vector(15 downto 0));
end exe;

architecture behavior of exe is
begin
    PC_in <= PC_out;
    OP_in <= OP_out;
    rd_in <= rd_out;
    rs_in <= rs_out;
    rt_in <= rt_out;
    im_in <= im_out;
    process(PC_in, OP_in, A_in, B_in, rd_in, rs_in, rt_in, im_in, IH_in, SpAns_in, pcWriteOut_in)
    begin
    -- MUX : exSrc
        case exSrc is
            when '0' =>
                ex_out <= B_in;
            when '1' =>
                ex_out <= rd_in;
        end case;
    -- MUX : ALUSrc1
        case aluSrcA is
            when '0' =>
                A_out <= A_in;
            when '1' =>
                A_out <= im_in;
    --MUX : ALUSrc2
        case aluSrcB is
            when "010" =>
                B_out <= PC_in;
            when "100" =>
                B_out <= IH_in;
            when "111" =>
                B_out <= SpAns_in;
            when "000" =>
                B_out <= B_in;
            when "111" =>
                B_out <= im_in;
end process;

end behavior;
