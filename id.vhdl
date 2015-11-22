LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity id is
    port(
        pcIn: in std_logic_vector(15 downto 0);
        opIn: in std_logic_vector(4 downto 0);
        comBody: in std_logic_vector(10 downto 0);

        regDst : out std_logic_vector(1 downto 0);
        regWrite : out std_logic_vector(2 downto 0);
        memToReg : out std_logic;
        aluSrcA : out std_logic_vector(2 downto 0);     -- not decided
        aluSrcB : out std_logic_vector(2 downto 0);
        aluOp : out std_logic_vector(4 downto 0);       -- not decided
        memRead : out std_logic;
        memWrite : out std_logic;
        pcWrite : out std_logic;
        pcSrc : out std_logic_vector(2 downto 0);       -- not decided
        pcWriteCond : out std_logic_vector(2 downto 0); -- not decided
        immEx : out std_logic;
        immSrc : out std_logic_vector(2 downto 0);

        pcOut: out std_logic_vector(15 downto 0);
        opOut : out std_logic_vector(4 downto 0);
        rd : out std_logic_vector(2 downto 0);
        rs : out std_logic_vector(2 downto 0);
        rt : out std_logic_vector(2 downto 0);
        im : out std_logic_vector(15 downto 0);
        spVal : out std_logic_vector(15 downto 0);
        A : out std_logic_vector(15 downto 0);
        B : out std_logic_vector(15 downto 0);
        func1 : out std_logic_vector(4 downto 0);
        func2 : out std_logic_vector(2 downto 0));
end id;

architecture behavior of id is
begin
    -- get rd due to regDst
    process(opIn)
    begin
        case when
    end process;
    process(regDst, comBody)
    begin
        case regDst is
            when "00" =>
                rd <= comBody(10 downto 8);
            when "01" =>
                rd <= comBody(7 downto 5);
            when "10" =>
                rd <= comBody(4 downto 2);
            when "11" =>
                rd <= "0000000000000000";
        end case;
    end process;
    -- get im due to immSrc
    process(immSrc, comBody)
    begin
        case immSrc is
            when "000" =>
                if comBody(10) == "0"
                    im <= "00000" & comBody;
                else
                    im <= "11111" & comBody;
                end if;
            when "001" =>
                if comBody(7) == "0"
                    im <= "00000000" & comBody(7 downto 0);
                else
                    im <= "11111111" & comBody(7 downto 0);
                end if;
            when "010" =>
                if comBody(4) == "0"
                    im <= "00000000000" & comBody(4 downto 0);
                else
                    im <= "11111111111" & comBody(4 downto 0);
                end if;
            when "011" =>
                if comBody(3) == "0"
                    im <= "000000000000" & comBody(3 downto 0);
                else
                    im <= "111111111111" & comBody(3 downto 0);
                end if;
            when "100" =>
            -- only need to use last 3 bits
                im <= "0000000000000" & comBody(4 downto 2);
            when others =>
                im <= "0000000000000000";
        end case;
    end process;
    -- get other parts which dont need any control signal
    -- func1, func2, pcOut
    process(comBody, pcIn opIn)
    begin
        func1 <= comBody(4 downto 0);
        func2 <= comBody(2 downto 0);
        pcOut <= pcIn;
        opOut <= opIn;
    end process;
end behavior;
