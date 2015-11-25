LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IFID is
    port(clk: in std_logic;
         rst: in std_logic;

         PC_in: in std_logic_vector(15 downto 0);
         OP_in: in std_logic_vector(4 downto 0);
         reg10_0_in: in std_logic_vector(10 downto 0);

         PC_out: out std_logic_vector(15 downto 0);
         OP_out: out std_logic_vector(4 downto 0);
         reg10_0_out: out std_logic_vector(10 downto 0)
         );
end IFID;

architecture behavior of IFID is
begin
    process(clk)
    begin
        if rst='0' then
            OP_out <= "00000";
        elsif clk = '1' and clk'event then
            PC_out <= PC_in;
            OP_out <= OP_in;
            reg10_0_out <= reg10_0_in;
        end if;
    end process;

end behavior;