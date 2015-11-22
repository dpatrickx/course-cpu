LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY Alu IS
		GENERIC ( 
			n : INTEGER := 16
		);
		Port (  Input1, Input2 :IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				Carryin :IN STD_LOGIC;
				CarryOut :OUT STD_LOGIC;
				Operation :IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				Output :OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
				);
END Alu;

Architecture stats Of Alu IS 
	component  AluSlice is
			Port (  Input1, Input2, Carryin, AInvert, BInvert, Op1, Op2 :IN STD_LOGIC;
					Output, Carryout :OUT STD_LOGIC
				); 
    end component;
    
    signal CarryOuts, tempOutput : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    signal COUT : STD_LOGIC;
    
   -- Command constants --
    constant ADD_FUNC : std_logic_vector(3 downto 0) := "0010";
	constant SUB_FUNC : std_logic_vector(3 downto 0) := "0011";
	constant AND_FUNC : std_logic_vector(3 downto 0) := "0000";
	constant OR_FUNC  : std_logic_vector(3 downto 0) := "0001";
	constant GEQ_FUNC : std_logic_vector(3 downto 0) := "0101";
	constant NOT_FUNC : std_logic_vector(3 downto 0) := "0110";
	constant MFPC_FUNC : std_logic_vector(3 downto 0) := "0111";
	constant MULT_FUNC : std_logic_vector(3 downto 0) := "0100";
	constant SLL_FUNC : std_logic_vector(3 downto 0) := "1000";
	constant SRL_FUNC : std_logic_vector(3 downto 0) := "1001";
begin
	process(Operation)
		variable temp: std_logic_vector(n-1 downto 0);
		variable temp2: std_logic_vector(2*n-1 downto 0);
		variable temp3, temp4: std_logic;
	begin
		case Operation is
			when ADD_FUNC =>
				temp := tempOutput;
			when SUB_FUNC =>
				temp := Input1 - Input2;
			when AND_FUNC =>
				temp := tempOutput;
			when OR_FUNC =>
				temp := tempOutput;
			when MULT_FUNC =>
				temp2 := Input1 * Input2;
				temp := temp2(n-1 downto 0);
			when MFPC_FUNC =>
				temp := Input1;
			when GEQ_FUNC =>
				temp := (OTHERS => NOT(Input1(n-1)));
				temp4 := '0';
				temp3 := NOT(Input1(n-1));
			when NOT_FUNC =>
				temp := (OTHERS => '0');
				if (Input1 = (n-1 downto 0 => '0')) then
					temp(0) := '1';
				end if;
			when SLL_FUNC =>
				if Input2 = std_logic_vector( to_unsigned(0, Input2'length) ) then
					temp := Input1;
				elsif Input2 = std_logic_vector( to_unsigned(1, Input2'length) ) then
					temp := Input1(n-2 downto 0) & "0";
				elsif Input2 = std_logic_vector( to_unsigned(2, Input2'length) ) then
					temp := Input1(n-3 downto 0) & "00";
				elsif Input2 = std_logic_vector( to_unsigned(3, Input2'length) ) then
					temp := Input1(n-4 downto 0) & "000";
				elsif Input2 = std_logic_vector( to_unsigned(4, Input2'length) ) then
					temp := Input1(n-5 downto 0) & "0000";	
				elsif Input2 = std_logic_vector( to_unsigned(5, Input2'length) ) then
					temp := Input1(n-6 downto 0) & "00000";
				elsif Input2 = std_logic_vector( to_unsigned(6, Input2'length) ) then
					temp := Input1(n-7 downto 0) & "000000";
				elsif Input2 = std_logic_vector( to_unsigned(7, Input2'length) ) then
					temp := Input1(n-8 downto 0) & "0000000";
				elsif Input2 = std_logic_vector( to_unsigned(8, Input2'length) ) then
					temp := Input1(n-9 downto 0) & "00000000";
				elsif Input2 = std_logic_vector( to_unsigned(9, Input2'length) ) then
					temp := Input1(n-10 downto 0) & "000000000";
				elsif Input2 = std_logic_vector( to_unsigned(10, Input2'length) ) then
					temp := Input1(n-11 downto 0) & "0000000000";
				elsif Input2 = std_logic_vector( to_unsigned(11, Input2'length) ) then
					temp := Input1(n-12 downto 0) & "00000000000";
				elsif Input2 = std_logic_vector( to_unsigned(12, Input2'length) ) then
					temp := Input1(n-13 downto 0) & "000000000000";
				elsif Input2 = std_logic_vector( to_unsigned(13, Input2'length) ) then
					temp := Input1(n-14 downto 0) & "0000000000000";
				elsif Input2 = std_logic_vector( to_unsigned(14, Input2'length) ) then
					temp := Input1(n-15 downto 0) & "00000000000000";
				elsif Input2 = std_logic_vector( to_unsigned(15, Input2'length) ) then
					temp := Input1(0) & "000000000000000";
				else
					temp := (OTHERS => '0');
				end if;
			when SRL_FUNC =>
				if Input2 = std_logic_vector( to_unsigned(0, Input2'length) ) then
					temp := Input1;
				elsif Input2 = std_logic_vector( to_unsigned(1, Input2'length) ) then
					temp := "0" & Input1(n-1 downto 1);
				elsif Input2 = std_logic_vector( to_unsigned(2, Input2'length) ) then
					temp := "00" & Input1(n-1 downto 2);
				elsif Input2 = std_logic_vector( to_unsigned(3, Input2'length) ) then
					temp := "000" & Input1(n-1 downto 3);
				elsif Input2 = std_logic_vector( to_unsigned(4, Input2'length) ) then
					temp := "0000" & Input1(n-1 downto 4);
				elsif Input2 = std_logic_vector( to_unsigned(5, Input2'length) ) then
					temp := "00000" & Input1(n-1 downto 5);
				elsif Input2 = std_logic_vector( to_unsigned(6, Input2'length) ) then
					temp := "000000" & Input1(n-1 downto 6);
				elsif Input2 = std_logic_vector( to_unsigned(7, Input2'length) ) then
					temp := "0000000" & Input1(n-1 downto 7);
				elsif Input2 = std_logic_vector( to_unsigned(8, Input2'length) ) then
					temp := "00000000" & Input1(n-1 downto 8);
				elsif Input2 = std_logic_vector( to_unsigned(9, Input2'length) ) then
					temp := "000000000" & Input1(n-1 downto 9);
				elsif Input2 = std_logic_vector( to_unsigned(10, Input2'length) ) then
					temp := "0000000000" & Input1(n-1 downto 10);
				elsif Input2 = std_logic_vector( to_unsigned(11, Input2'length) ) then
					temp := "00000000000" & Input1(n-1 downto 11);
				elsif Input2 = std_logic_vector( to_unsigned(12, Input2'length) ) then
					temp := "000000000000" & Input1(n-1 downto 12);
				elsif Input2 = std_logic_vector( to_unsigned(13, Input2'length) ) then
					temp := "0000000000000" & Input1(n-1 downto 13);
				elsif Input2 = std_logic_vector( to_unsigned(14, Input2'length) ) then
					temp := "00000000000000" & Input1(n-1 downto 14);
				elsif Input2 = std_logic_vector( to_unsigned(15, Input2'length) ) then
					temp := "000000000000000" & Input1(n-1);
				else
					temp := (OTHERS => '0');
				end if;
			when others =>
				temp := Input1 - Input2;
		end case;
		
		IF (temp4 = '0') THEN
			Carryout <= temp3;
		ELSE
			Carryout <= COUT;
		END IF;
		
		Output <= temp;
	end process;
END stats;