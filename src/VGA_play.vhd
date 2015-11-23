library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_play is
	Port(
		-- common port
		CLK_0: in std_logic; -- must 50M
		clkout: out std_logic; -- used to sync
		reset: in std_logic;
		
		-- vga port
		R: out std_logic_vector(2 downto 0) := "000";
		G: out std_logic_vector(2 downto 0) := "000";
		B: out std_logic_vector(2 downto 0) := "000";
		Hs: out std_logic := '0';
		Vs: out std_logic := '0';
		
		-- fifo memory
		wctrl: in std_logic_vector(0 downto 0); -- 1 is write
		waddr: in std_logic_vector(10 downto 0);
		wdata : in std_logic_vector(7 downto 0)
	);
end VGA_play;

architecture Behavioral of VGA_play is
	signal clk: std_logic; -- div 50M to 25M
	signal vector_x : std_logic_vector(9 downto 0);		--X 10b 640
	signal vector_y : std_logic_vector(8 downto 0);		--Y 9b 480
	signal r0 : std_logic_vector(2 downto 0);
	signal g0 : std_logic_vector(2 downto 0);
	signal b0 : std_logic_vector(2 downto 0);
	signal hs1 : std_logic;
	signal vs1 : std_logic;
	
	component char_mem
		PORT (
			clka : IN STD_LOGIC;
			addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
		);
	end component;
	
	component fifo_mem
		PORT (
			-- a for write
			clka : IN STD_LOGIC;
			-- enable, 1 is write signal
			wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
			dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			-- b for read
			clkb : IN STD_LOGIC;
			addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
			doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	end component;
	
	signal char: std_logic_vector(7 downto 0) := "00000000";
	signal pr: STD_LOGIC_VECTOR(0 DOWNTO 0);
	signal char_addr: std_logic_vector(14 downto 0);
	signal caddr: std_logic_vector(10 downto 0);
	
begin

	ram: char_mem port map(clka => clk, addra => char_addr, douta => pr);
	
	-- display cache
	cache: fifo_mem port map(
		-- a for write
		clka => clk,
		-- enable, 1 is write signal
		wea => wctrl,
		addra => waddr,
		dina => wdata,
		-- b for read
		clkb => clk,
		addrb => caddr,
		doutb => char
	);
	
	-- cache addr 5 + 6 = 11
	caddr <= vector_y(8 downto 4) & vector_x(9 downto 4);
	
	-- char acess addr 7 + 4 + 4 = 15
	-- last 2 control the display(x, y)
	-- first char control which char
	char_addr <=  char(6 downto 0) & vector_y(3 downto 0) & vector_x(3 downto 0);

-- 25 MHz Sync
clkout <= clk;
-- 50 MHz -> 25 MHz
process(CLK_0)
begin
	if(CLK_0'event and CLK_0 = '1') then
		clk <= not clk;
	end if;
end process;

process(clk, reset)	-- ������������ (800)
begin
	if reset = '0' then
		vector_x <= (others => '0');
	elsif clk'event and clk = '1' then
		if vector_x = 799 then
			vector_x <= (others => '0');
		else
			vector_x <= vector_x + 1;
		end if;
	end if;
end process;

process(clk, reset)	-- ���������� (525)
begin
	if reset = '0' then
		vector_y <= (others => '0');
	elsif clk'event and clk = '1' then
		if vector_x = 799 then
			if vector_y = 524 then
				vector_y <= (others => '0');
			else
				vector_y <= vector_y + 1;
			end if;
		end if;
	end if;
end process;

process(clk, reset) -- ��ͬ���źţ�640+��������16��+96��+48�գ�
begin
	if reset='0' then
		hs1 <= '1';
	elsif clk'event and clk='1' then
		if vector_x >= 656 and vector_x < 752 then
			hs1 <= '0';
		else
			hs1 <= '1';
		end if;
	end if;
end process;

process(clk, reset) -- ��ͬ���źţ�480+��������10��+2��+33�գ�
begin
	if reset = '0' then
		vs1 <= '1';
	elsif clk'event and clk = '1' then
		if vector_y >= 490 and vector_y < 492 then
			vs1 <= '0';
		else
			vs1 <= '1';
		end if;
	end if;
end process;

process(clk, reset)
begin
	if reset = '0' then
		hs <= '0';
		vs <= '0';
	elsif clk'event and clk = '1' then
		hs <= hs1;
		vs <= vs1;
	end if;
end process;

process(reset, clk, vector_x, vector_y) -- X, Y �������
begin
	if reset = '0' then
		r0 <= "000";
		g0 <= "000";
		b0 <= "000";
	elsif clk'event and clk = '1' then
		if vector_x > 639 or vector_y > 479 then
			r0 <= "000";
			g0 <= "000";
			b0 <= "000";
		else
			-- play-ground		
			-- play-ground
			
			if pr(0) = '1' then
				r0 <= "000";
				g0 <= "000";
				b0 <= "000";
			else
				r0 <= "111";
				g0 <= "111";
				b0 <= "111";
			end if;
			
			-- play-ground
			-- play-ground
		end if;
	end if;
end process;

process(hs1, vs1, r0, g0, b0) -- ��͵�ɫ�����
begin
	if hs1 = '1' and vs1 = '1' then
		R <= r0;
		G <= g0;
		B <= b0;
	else
		R <= (others => '0');
		G <= (others => '0');
		B <= (others => '0');
	end if;
end process;

end Behavioral;

