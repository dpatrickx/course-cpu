LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_data_types.ALL;

-- author : dpatrickx
-- ID : compute pc of jump instructions

entity branchPc is
    port(
        pcIn    : in std_logic_vector(15 downto 0);
        imm     : in std_logic_vector(15 downto 0);
        op      : in std_logic_vector(4 downto 0);
        rs      : in std_logic_vector(2 downto 0);
        valueA  : in std_logic_vector(15 downto 0);
        regT    : in std_logic_vector(15 downto 0);

        exForwardA  : in WORD;
        meForwardA  : in WORD;
        exmeRegW    : in std_logic_vector(2 downto 0);
        exmeRd      : in std_logic_vector(2 downto 0);
        mewbRegW    : in std_logic_vector(2 downto 0);
        mewbRd      : in std_logic_vector(2 downto 0);

        pcOut   : out std_logic_vector(15 downto 0);
        pcSrc   : out std_logic);
end branchPc;

architecture behavior of branchPc is
constant Pcs_NR   : std_logic  := '0';
constant Pcs_ID   : std_logic  := '1';
signal useForT : std_logic := '0';
signal useForA : std_logic_vector(1 downto 0) := "00";
signal valueRa : WORD := ZERO_16;
signal valueT  : WORD := ZERO_16;
begin
    -- judge forward
    process (op, exmeRegW, exmeRd, mewbRegW, mewbRd)
    begin
        case op is
            -- judge rx forward
            when "00100"|"00101"|"11101" =>
                if exmeRegW=Regw_RD and exmeRd=rs then
                    valueRa <= exForwardA;
                elsif mewbRegW=Regw_RD and exmeRegW/=Regw_RD and mewbRd=rs then
                    valueRa <= meForwardA;
                else
                    valueRa <= valueA;
                end if;
            -- judge t forward
            when "01100" =>
                if exmeRegW=Regw_T then
                    valueT <= exForwardA;
                else
                    valueT <= regT;
                end if;
            when others =>
                -- nothing
        end case;
    end process;
    -- get new pc according to different jump command
    process (op, pcIn, imm, valueA)
    begin
        case op is
            when "00010" => pcOut <= (pcIn + imm);
            when "00100" => pcOut <= (pcIn + imm);
            when "00101" => pcOut <= (pcIn + imm);
            when "01100" => pcOut <= (pcIn + imm);
            when "11101" => pcOut <= valueA;
				when others => --nothing
        end case;
    end process;
    -- pcSrc
    process (op, pcIn, imm, valueA, regT)
    variable temp : std_logic;
    begin
        case op is
            when "00100" =>
                temp := '0';
                for i in 0 to 16 loop
                    temp := temp or valueA(i);
                end loop;
                if temp = '0' then pcSrc <= Pcs_ID;
                else               pcSrc <= Pcs_NR;
                end if;
            when "00101" =>
                temp := '0';
                for i in 0 to 16 loop
                    temp := temp or valueA(i);
                end loop;
                if temp = '1' then pcSrc <= Pcs_ID;
                else               pcSrc <= Pcs_NR;
                end if;
            when "01100" =>
                case pcIn(10 downto 8) is
                when "000" =>
                    temp := '0';
                    for i in 0 to 16 loop
                        temp := temp or valueT(i);
                    end loop;
                    if temp = '0' then pcSrc <= Pcs_ID;
                    else               pcSrc <= Pcs_NR;
                    end if;
                when others =>
                    pcSrc <= Pcs_NR;
                end case;
            when "11101" => pcSrc <= Pcs_ID;
            when "00010" => pcSrc <= Pcs_ID;
				when others => --nothing
        end case;
    end process;
end behavior;