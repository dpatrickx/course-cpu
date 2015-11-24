LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use my_data_types.ALL;

-- author : daptrickx
-- ID : read/write to registers

entity reg is
    port(
        regWrite    : in std_logic_vector(2 downto 0);
        regWriteAdd : in std_logic_vector(2 downto 0);
        data        : in std_logic_vector(15 downto 0);
        aluSrcA     : in std_logic;
        aluSrcB     : in std_logic_vector(2 downto 0);
        instruction : in std_logic_vector(15 downto 0);
        pc          : in std_logic_vector(15 downto 0);

        regT        : inout WORD;
        regIH       : inout WORD;
        regSP       : inout WORD;
        regiArr     : inout REGISTERARRAY;

        valueA      : out WORD;
        valueB      : out WORD;
        specValue   : out WORD);
end reg;

architecture behavior of reg is
signal rs : std_logic_vector(2 downto 0);
signal rt : std_logic_vector(2 downto 0);
begin
    -- valueA
    process(aluSrcA)
        begin
        case aluSrcA is
            when Srca_A =>
                rs <= instruction(10 downto 8);
                valueA <= regiArr(conv_integer(rs));
            when others =>
                valueA <= ZERO_16;
        end case;
    end process;
    -- valueB
    process(aluSrcB)
        begin
        case aluSrcB is
            when Srcb_B =>
                rt <= instruction(7 downto 5);
                valueB <= regiArr(conv_integer(rt));
            when others =>
                valueB <= ZERO_16;
        end case;
    end process;
    -- specReg
    specReg: process(aluSrcB)
    begin
        case aluSrcB is
            when Srcb_SP => specValue <= regSP;
            when Srcb_IH => specValue <= regIH;
            when Srcb_PC => specValue <= pc;
            when others  => specValue <= ZERO_16;
        end case;
    end process;

    -- write to register
    writeReg: process(regWrite, regWriteAdd, data)
    begin
        if regWrite = Regw_RD then
            -- write to register array
            regiArr(conv_integer(regWriteAdd)) <= data;
        elsif regWrite = Regw_T then
            -- write to register T
            regT <= data;
        elsif regWrite = Regw_IH then
            -- write to register IH
            regIH <= data;
        elsif regWrite = Regw_SP then
            -- write to register SP
            regSP <= data;
        else
            -- nothing
        end if;
    end process;
end behavior;