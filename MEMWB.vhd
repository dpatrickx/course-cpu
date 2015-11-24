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

entity IDEX is
	port(clk: in std_logic;
		 rst: in std_logic;

		 PC_in: in std_logic_vector(15 downto 0);
		 OP_in: in std_logic_vector(4 downto 0);
		 func1_in: in std_logic_vector(4 downto 0);
		 func2_in: in std_logic_vector(1 downto 0);
		 ex_in: in std_logic_vector(15 downto 0);
		 ans_in: in std_logic_vector(15 downto 0);
		 rd_in: in std_logic_vector(2 downto 0);
		 rs_in: in std_logic_vector(2 downto 0);
		 rt_in: in std_logic_vector(2 downto 0);
		 data_in: in std_logic_vector(15 downto 0);

		 PC_out: out std_logic_vector(15 downto 0);
		 OP_out: out std_logic_vector(4 downto 0);
		 func1_out: out std_logic_vector(4 downto 0);
		 func2_out: out std_logic_vector(1 downto 0);
		 ex_out: out std_logic_vector(15 downto 0);
		 ans_out: out std_logic_vector(15 downto 0);
		 rd_out: out std_logic_vector(2 downto 0);
		 rs_out: out std_logic_vector(2 downto 0);
		 rt_out: out std_logic_vector(2 downto 0);
		 data_out: out std_logic_vector(15 downto 0)
		 );
end IDEX;

architecture behavior of IDEX is
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
			ex_out <= A_in;
			ans_out <= B_in;
			rd_out <= rd_in;
			rs_out <= rs_in;
			rt_out <= rt_in;
			data_out <= data_in;
		end if;
	end process;

end behavior;