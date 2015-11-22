LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity control is
    port(
        pcIn: in std_logic_vector(15 downto 0);
        opIn: in std_logic_vector(4 downto 0);
        comBody: in std_logic_vector(10 downto 0);

        regDst : out std_logic_vector(1 downto 0)           := "00";
        regWrite : out std_logic_vector(2 downto 0)         := "000";
        memToReg : out std_logic                            := "0";
        aluSrcA : out std_logic_vector(2 downto 0)          := "000";     -- not decided
        aluSrcB : out std_logic_vector(2 downto 0)          := "000";
        aluOp : out std_logic_vector(4 downto 0);           := "00000"-- not decided
        memRead : out std_logic                             := "0";
        memWrite : out std_logic                            := "0";
        pcWrite : out std_logic                             := "0";
        pcSrc : out std_logic_vector(2 downto 0)            := "000";       -- not decided
        pcWriteCond : out std_logic_vector(2 downto 0)      := "000"; -- not decided
        immEx : out std_logic                               := "0";
        immSrc : out std_logic_vector(2 downto 0)           := "000";

        pcOut: out std_logic_vector(15 downto 0)            := "0000000000000000";
        opOut : out std_logic_vector(4 downto 0)            := "00000";
        rd : out std_logic_vector(2 downto 0)               := "000";
        rs : out std_logic_vector(2 downto 0)               := "000";
        rt : out std_logic_vector(2 downto 0)               := "000";
        im : out std_logic_vector(15 downto 0)              := "0000000000000000";
        spVal : out std_logic_vector(15 downto 0)           := "0000000000000000";
        A : out std_logic_vector(15 downto 0)               := "0000000000000000";
        B : out std_logic_vector(15 downto 0)               := "0000000000000000";
        func1 : out std_logic_vector(4 downto 0)            := "00000";
        func2 : out std_logic_vector(1 downto 0)            := "00");
end control;

architecture behavior of control is
constant ZERO_16 : std_logic_vector(15 downto 0) := "0000000000000000";
constant ZERO_3 : std_logic_vector(15 downto 0) := "000";
begin
    -- get rd due to regDst
    process(opIn, comBody)
    begin
        case opIn is
            -- NOP
            when "00001" =>
                -- nothing
            when "11100" =>
                if comBody(1 downto 0) = "01" then
                    -- ADDU
                    func2 <= "01";
                    regDst <= "10";     regWrite <= "001";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "000";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                elsif comBody(1 downto 0) = "11" then
                    -- SUBU
                    func1 <= "00000";   func2 <= "11";
                    regDst <= "10";     regWrite <= "001";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "000";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                end if;
            when "11101" =>
                if comBody(4 downto 0) = "01100" then
                    -- AND
                    func1 <= "01100";   func2 <= "00";
                    regDst <= "00";     regWrite <= "001";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "000";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                elsif comBody(4 downto 0) = "01101" then
                    -- OR
                    func1 <= "01101";   func2 <= "00";
                    regDst <= "00";     regWrite <= "001";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "000";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                elsif comBody(4 downto 0) = "01011" then
                    -- NEG
                    func1 <= "01011";   func2 <= "00";
                    regDst <= "00";     regWrite <= "001";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "000";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                elsif comBody(4 downto 0) = "01111" then
                    -- NOT
                    func1 <= "01111";   func2 <= "00";
                    regDst <= "00";     regWrite <= "001";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "000";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                elsif comBody(4 downto 0) = "01010" then
                    -- CMP
                    func1 <= "01010";   func2 <= "00";
                    regDst <= "11";     regWrite <= "011";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "000";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                end if;
            when "01111" =>
                -- MOVE
                func1 <= "00000";   func2 <= "00";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "000";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "000";
            when "11101" =>
                -- MFPC
                func1 <= "00000";   func2 <= "00";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "010";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "000";
            when "11110" =>
                if comBody(0) = "0" then
                    -- MFIH
                    func1 <= "00000";   func2 <= "00";
                    regDst <= "00";     regWrite <= "001";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "100";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                elsif comBody(0) = "1" then
                    -- MTIH
                    func1 <= "00000";   func2 <= "00";
                    regDst <= "11";     regWrite <= "101";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "101";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                end if;
            when "01100" =>
                if comBody(10 downto 8) == "100" then
                    -- MTSP
                    func1 <= "00000";   func2 <= "00";
                    regDst <= "11";     regWrite <= "010";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "000";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                elsif comBody(10 downto 8) == "011" then
                    -- ADDSP
                    func1 <= "00000";   func2 <= "00";
                    regDst <= "11";     regWrite <= "010";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "000";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                elsif comBody(10 downto 8) == "000" then
                    -- BTEQZ
                    func1 <= "00000";   func2 <= "00";
                    regDst <= "11";     regWrite <= "010";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "000";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "000";
                end if;
            when "01000" =>
                -- ADDIU3
                func1 <= "00000";   func2 <= "00";
                regDst <= "01";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "1";       immSrc <= "011";
            when "10011" =>
                -- LW
                func1 <= "00000";   func2 <= "00";
                regDst <= "01";     regWrite <= "001";
                memToReg <= "0";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "1";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "1";       immSrc <= "010";
            when "11011" =>
                -- SW
                func1 <= "00000";   func2 <= "00";
                regDst <= "00";     regWrite <= "000";
                memToReg <= "0";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "1";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "1";       immSrc <= "010";
            when "00110" =>
                -- SLL
                func1 <= "00000";   func2 <= "00";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "100";
            when "00110" =>
                if comBody(1 downto 0) = "11" then
                    -- SRA
                    func1 <= "00000";   func2 <= "11";
                    regDst <= "00";     regWrite <= "001";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "001";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "100";
                elsif comBody(1 downto 0) = "10" then
                    -- SRL
                    func1 <= "00000";   func2 <= "11";
                    regDst <= "00";     regWrite <= "001";
                    memToReg <= "1";    aluSrcA <= "000";
                    aluSrcB <= "001";   aluOp <= "000";
                    memRead <= "0";     memWrite <= "0";
                    pcWrite <= "0";     pcSrc <= "0";
                    immEx <= "0";       immSrc <= "100";
                end if;
            when "01001" =>
                -- ADDIU
                func1 <= "00000";   func2 <= "11";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "100";
            when "01110" =>
                -- CMPI
                func1 <= "00000";   func2 <= "11";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "100";
            when "01101" =>
                -- LI
                func1 <= "00000";   func2 <= "11";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "100";
            when "10010" =>
                -- LW_SP
                func1 <= "00000";   func2 <= "11";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "100";
            when "11010" =>
                -- SW_SP
                func1 <= "00000";   func2 <= "11";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "100";
            when "00010" =>
                -- B
                func1 <= "00000";   func2 <= "11";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "100";
            when "00100" =>
                -- BEQZ
                func1 <= "00000";   func2 <= "11";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "100";
            when "00101" =>
                -- BNEZ
                func1 <= "00000";   func2 <= "11";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "100";
            when "11101" =>
                -- JR
                func1 <= "00000";   func2 <= "11";
                regDst <= "00";     regWrite <= "001";
                memToReg <= "1";    aluSrcA <= "000";
                aluSrcB <= "001";   aluOp <= "000";
                memRead <= "0";     memWrite <= "0";
                pcWrite <= "0";     pcSrc <= "0";
                immEx <= "0";       immSrc <= "100";
        end case;
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
