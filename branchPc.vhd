LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- author : dpatrickx
-- ID : compute pc of jump instructions

entity branchPc is
    port(
        pcIn    : in std_logic_vector(15 downto 0);
        imm     : in std_logic_vector(15 downto 0);
        op      : in std_logic_vector(4 downto 0);
        valueA  : in std_logic_vector(15 downto 0);
        regT    : in std_logic_vector(15 downto 0);

        pcOut   : out std_logic_vector(15 downto 0));
        pcSrc   : out std_logic;
end branchPc;

architecture behavior of branchPc is
constant Pcs_NR   : std_logic  := "0";
constant Pcs_ID   : std_logic  := "1";
begin
    -- get new pc according to different jump command
    process (op, pcIn, imm, valueA)
    begin
        case op is
            when "00010" => pcOut <= (pcIn + imm);
            when "00100" => pcOut <= (pcIn + imm);
            when "00101" => pcOut <= (pcIn + imm);
            when "01100" => pcOut <= (pcIn + imm);
            when "11101" => pcOut <= valueA;
        end case;
    end process;

    process (op, pcIn, imm, valueA, regT)
    variable temp : std_logic;
    begin
        case op is
            when "00100" =>
                temp := "0";
                for i in 0 to 16 loop
                    temp := temp or valueA[i];
                end loop;
                if temp = "0" then pcSrc <= Pcs_ID;
                else               pcSrc <= Pcs_NR;
                end if;
            when "00101" =>
                temp := "0";
                for i in 0 to 16 loop
                    temp := temp or valueA[i];
                end loop;
                if temp = "1" then pcSrc <= Pcs_ID;
                else               pcSrc <= Pcs_NR;
                end if;
            when "01100" =>
                case pcIn(10 downto 8) is
                when "000" =>
                    temp := "0";
                    for i in 0 to 16 loop
                        temp := temp or regT[i];
                    end loop;
                    if temp = "0" then pcSrc <= Pcs_ID;
                    else               pcSrc <= Pcs_NR;
                    end if;
                when others =>
                    pcSrc <= Pcs_NR;
                end case;
            when "11101" => pcSrc <= Pcs_ID;
            when "00010" => pcSrc <= Pcs_ID;
        end case;
    end process;
end behavior