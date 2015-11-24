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
		 func1_in: in std_logic_vector(4 downto 0);
		 func2_in: in std_logic_vector(1 downto 0);
		 reg10_8_in: in std_logic_vector(2 downto 0);
		 reg7_5_in: in std_logic_vector(2 downto 0);
		 reg4_2_in: in std_logic_vector(2 downto 0);
		 reg3_0_in: in std_logic_vector(3 downto 0);
		 reg4_0_in: in std_logic_vector(4 downto 0);
		 reg7_0_in: in std_logic_vector(7 downto 0);
		 reg10_0_in: in std_logic_vector(10 downto 0);

		 PC_out: out std_logic_vector(15 downto 0);
		 OP_out: out std_logic_vector(4 downto 0);
		 func1_out: out std_logic_vector(4 downto 0);
		 func2_out: out std_logic_vector(1 downto 0);
		 reg10_8_out: out std_logic_vector(2 downto 0);
		 reg7_5_out: out std_logic_vector(2 downto 0);
		 reg4_2_out: out std_logic_vector(2 downto 0);
		 reg3_0_out: out std_logic_vector(3 downto 0);
		 reg4_0_out: out std_logic_vector(4 downto 0);
		 reg7_0_out: out std_logic_vector(7 downto 0);
		 reg10_0_out: out std_logic_vector(10 downto 0)
		 );
end IFID;

architecture behavior of IFID is
begin
	process(clk)
	begin
		if rst='0' then
			OP_in <= "00000";
			func1_in <= "00000";
			func2_in <= "00";
		elsif clk = '1' and clk'event then
			PC_out <= PC_in;
			OP_out <= OP_in;
			func1_out <= func1_in;
			func2_out <= func2_in;
			reg10_8_out <= reg10_8_in;
			reg7_5_out <= reg7_5_in;
			reg4_2_out <= reg4_2_in;
			reg3_0_out <= reg3_0_in;
			reg4_0_out <= reg4_0_in;
			reg7_0_out <= reg7_0_in;
			reg10_0_out <= reg10_0_in;
		end if;
	end process;

end behavior;