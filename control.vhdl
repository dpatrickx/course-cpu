LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use my_data_types.ALL;

-- author: dpatrickx
-- ID : get control signals according to instructions
-- ID : expand immidiate to 16 bits

entity control is
    port(
        pcIn        : in std_logic_vector(15 downto 0);
        opIn        : in std_logic_vector(4 downto 0);
        comBody     : in std_logic_vector(10 downto 0);

        regDst      : out std_logic_vector(1 downto 0);
        regWrite    : out std_logic_vector(2 downto 0);
        memToReg    : out std_logic;
        memRead     : out std_logic;
        memWrite    : out std_logic;
        memData     : out std_logic;
        aluSrcA     : out std_logic_vector(2 downto 0);
        aluSrcB     : out std_logic_vector(2 downto 0);
        aluOp       : out std_logic_vector(4 downto 0);
        pcWrite     : out std_logic;
        pcSrc       : out std_logic_vector(1 downto 0);
        immEx       : out std_logic;
        immSrc      : out std_logic_vector(2 downto 0);

        pcOut       : out std_logic_vector(15 downto 0);
        opOut       : out std_logic_vector(4 downto 0);
        rd          : out std_logic_vector(2 downto 0);
        rs          : out std_logic_vector(2 downto 0);
        rt          : out std_logic_vector(2 downto 0);
        im          : out std_logic_vector(15 downto 0);
        spVal       : out std_logic_vector(15 downto 0);
        A           : out std_logic_vector(15 downto 0);
        B           : out std_logic_vector(15 downto 0);
end control;

architecture behavior of control is
constant Srcb_PC : std_logic_vector(2 downto 0)  := "010";
constant Srcb_IH : std_logic_vector(2 downto 0)  := "100";
constant Srcb_SP : std_logic_vector(2 downto 0)  := "111";
constant Srcb_B  : std_logic_vector(2 downto 0)  := "000";
constant Srcb_IM : std_logic_vector(2 downto 0)  := "111";

constant Srca_A  : std_logic_vector(2 downto 0)  := "0";
constant Srca_IM : std_logic_vector(2 downto 0)  := "1";

constant Regw_NO : std_logic_vector(2 downto 0)  := "000";
constant Regw_RD : std_logic_vector(2 downto 0)  := "001";
constant Regw_T  : std_logic_vector(2 downto 0)  := "011";
constant Regw_IH : std_logic_vector(2 downto 0)  := "101";
constant Regw_SP : std_logic_vector(2 downto 0)  := "010";

constant Regd_RX  : std_logic_vector(1 downto 0)  := "00";
constant Regd_RY  : std_logic_vector(1 downto 0)  := "01";
constant Regd_RZ  : std_logic_vector(1 downto 0)  := "10";
constant Regd_SP  : std_logic_vector(1 downto 0)  := "11";

constant Imms_10  : std_logic_vector(2 downto 0)  := "000";
constant Imms_70  : std_logic_vector(2 downto 0)  := "001";
constant Imms_40  : std_logic_vector(2 downto 0)  := "010";
constant Imms_30  : std_logic_vector(2 downto 0)  := "011";
constant Imms_42  : std_logic_vector(2 downto 0)  := "100";
constant Imms_00  : std_logic_vector(2 downto 0)  := "111";

constant Pcs_NR   : std_logic_vector(1 downto 0)  := "00";
constant Pcs_ID   : std_logic_vector(1 downto 0)  := "00";
constant Pcs_RX   : std_logic_vector(1 downto 0)  := "00";

constant Memd_A   : std_logic := "0";
constant Memd_B   : std_logic := "1";

constant NO    : std_logic := "0";
constant YES   : std_logic := "1";
begin
    -- get rd due to regDst
    getRd: process(regDst, comBody)
    begin
        case regDst is
            when Regd_RX =>
                rd <= comBody(10 downto 8);
            when Regd_RY =>
                rd <= comBody(7 downto 5);
            when Regd_RZ =>
                rd <= comBody(4 downto 2);
            when Regd_SP =>
                rd <= ZERO_16;
        end case;
    end process;
    -- get im due to immSrc
    getIm: process(immSrc, comBody)
    begin
        case immSrc is
            when Imms_10 =>
                case comBody(10) is
                    when "0" => im <= "00000" & comBody;
                    when "1" => im <= "11111" & comBody;
                end case;
            when Imms_70 =>
                case comBody(7) is
                    when "0" => im <= ZERO_8 & comBody(7 downto 0);
                    when "1" => im <= ONE_8  & comBody(7 downto 0);
                end case;
            when Imms_40 =>
                case comBody(4) is
                    when "0" => im <= ZERO_11 & comBody(4 downto 0);
                    when "1" => im <= ONE_11  & comBody(4 downto 0);
                end case;
            when Imms_30 =>
                case comBody(3) is
                    when "0" => im <= ZERO_12 & comBody(3 downto 0);
                    when "1" => im <= ONE_12  & comBody(3 downto 0);
                end case;
            when Imms_42 =>
            -- only need to use last 3 bits
                im <= ZERO_13 & comBody(4 downto 2);
            when others =>
                im <= ZERO_16;
        end case;
    end process;
    -- decide control signals according to instructions
    getConSig: process(opIn, comBody)
    begin
        immEx   <= "0";         immSrc <= Imms_00;
        memRead <= "0";         memToReg <= "0";
        regWrite <= Regw_NO;
        case opIn is
            -- NOP
            when "00001" =>
                -- nothing
            when "11100" =>
                -- ADDU SUBU
                regDst  <= Regd_RZ;     regWrite <= Regw_RD;
                aluSrcA <= Srca_A;      aluSrcB  <= Srcb_B;
                case comBody(1 downto 0) is
                    when "01" => aluOp <= ADDU_;
                    when "11" => aluOp <= SUBU_;
                    when others => aluOp <= "0000";
                end case;
            when "11101" =>
                -- AND OR NEG NOT CMP
                regDst  <= Regd_RX;     regWrite <= Regw_RD;
                aluSrcA <= Srca_A;      aluSrcB  <= Srcb_B;
                case comBody(4 downto 0) is
                    when "01100" => aluOp <= AND_;
                    when "01101" => aluOp <= OR_;
                    when "01011" => aluOp <= NEG_;
                    when "01111" => aluOp <= NOT_;
                    when "01010" => aluOp <= CMP_;
                    when others  => aluOp <= "0000";
                end case;
            when "01111" =>
                -- MOVE
                regDst  <= Regd_RX;     regWrite <= Regw_RD;
                aluSrcA <= Srca_A;      aluSrcB  <= Srcb_B;
                aluOp <= PASSB_;
            when "11101" =>
                -- MFPC
                regDst  <= Regd_RX;     regWrite <= Regw_RD;
                aluSrcA <= Srca_A;      aluSrcB  <= Srcb_PC;
                aluOp   <= PASSB_;
            when "11110" =>
                case comBody(0) is
                when "0" =>
                    -- MFIH
                    regDst  <= Regd_RX;     regWrite <= Regw_RD;
                    aluSrcA <= Srca_A;      aluSrcB  <= Srcb_IH;
                    aluOp   <= PASSB_;
                when "1" =>
                    -- MTIH
                    regDst  <= Regd_SP;     regWrite <= Regw_IH;
                    aluSrcA <= Srca_A;      aluSrcB  <= Srcb_B;
                    aluOp   <= PASSA_;
                end case;
            when "01100" =>
                if comBody(10 downto 8) == "100" then
                    -- MTSP
                    regDst  <= Regd_SP;     regWrite <= Regw_SP;
                    aluSrcA <= Srca_A;      aluSrcB  <= Srcb_B;
                    aluOp   <= PASSA_;
                elsif comBody(10 downto 8) == "011" then
                    -- ADDSP
                    immEx   <= "1";      immSrc   <= Imms_70;
                    aluSrcA <= Srca_IM;  aluSrcB  <= Srcb_SP;  aluOp    <= ADD_;
                    memRead <= "0";      memToReg <= "0";      memWrite <= "0";     memData <= Memd_A;
                    regDst  <= Regd_SP;  regWrite <= Regw_SP;
                elsif comBody(10 downto 8) == "000" then
                    -- BTEQZ
                    immEx   <= "1";      immSrc   <= Imms_70;
                    aluSrcA <= Srca_A;   aluSrcB  <= Srca_B;   aluOp     <= PASSA_;
                    memRead <= "0";      memToReg <= "0";      memWrite  <= "0";     memData <= Memd_A;
                    regDst  <= Regd_SP;  regWrite <= Regw_NO;
                    pcSrc   <= Pcs_ID;
                end if;
            when "01000" =>
                -- ADDIU3
                regDst <= Regd_RY;  regWrite <= Regw_RD;
                aluSrcA <= Srca_A;  aluSrcB <= Srcb_IM;
                immEx <= "1";       immSrc <= Imms_30;
                aluOp <= ADDU_;
            when "10011" =>
                -- LW
                regDst <= Regd_RY;  regWrite <= Regw_RD;
                immEx <= "1";       immSrc <= Imms_40;
                aluOp <= ADDU_;
                memRead <= "1";     memToReg <= "1";
            when "11011" =>
                -- SW
                immEx   <= "1";      immSrc   <= Imms_40;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IM;  aluOp    <= ADD_;
                memRead <= "0";      memToReg <= "0";      memWrite <= "1";     memData <= Memd_B;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
            when "00110" =>
                -- SLL
                regDst  <= Regd_RX;  regWrite <= Regw_RD;
                aluSrcA <= Srca_IM;  aluSrcB  <= Srcb_B;
                immEx <= "0";        immSrc   <= Imms_42;
                aluOp <= SLL_;
            when "00110" =>
                if comBody(1 downto 0) = "11" then
                    -- SRA
                    regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    aluSrcA <= Srca_IM;  aluSrcB  <= Srcb_B;
                    immEx <= "0";        immSrc   <= Imms_42;
                    aluOp <= SRA_;
                elsif comBody(1 downto 0) = "10" then
                    -- SRL
                    regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    aluSrcA <= Srca_IM;  aluSrcB  <= Srcb_B;
                    immEx <= "0";        immSrc   <= Imms_42;
                    aluOp <= SRL_;
                else
                    -- nothing
                end if;
            when "01001" =>
                -- ADDIU
                regDst  <= Regd_RX;  regWrite <= Regw_RD;
                immEx   <= "1";      immSrc   <= Imms_70;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IM;
                aluOp   <= ADDU_;
            when "01110" =>
                -- CMPI
                regDst  <= Regd_SP;  regWrite <= Regw_T;
                immEx   <= "1";      immSrc   <= Imms_70;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IM;
                aluOp   <= CMP_;
            when "01101" =>
                -- LI
                regDst  <= Regd_RX;  regWrite <= Regw_RD;
                immEx   <= "0";      immSrc   <= Imms_70;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IM;
                aluOp   <= PASSB_;
            when "10010" =>
                -- LW_SP
                immEx   <= "1";      immSrc   <= Imms_70;
                aluSrcA <= Srca_IM;  aluSrcB  <= Srcb_SP;  aluOp    <= ADD_;
                memRead <= "1";      memToReg <= "1";      memWrite <= "0";
                regDst  <= Regd_RX;  regWrite <= Regw_RD;
            when "11010" =>
                -- SW_SP
                immEx   <= "1";      immSrc   <= Imms_70;
                aluSrcA <= Srca_IM;  aluSrcB  <= Srcb_SP;  aluOp    <= ADD_;
                memRead <= "0";      memToReg <= "0";      memWrite <= "1";     memData <= Memd_A;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
            when "00010" =>
                -- B
                immEx   <= "1";      immSrc   <= Imms_10;
                aluSrcA <= Srca_A;  aluSrcB   <= Srca_B;   aluOp    <= PASSA_;
                memRead <= "0";      memToReg <= "0";      memWrite <= "0";     memData <= Memd_A;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
                pcSrc   <= Pcs_ID;
            when "00100" =>
                -- BEQZ
                immEx   <= "1";      immSrc   <= Imms_70;
                aluSrcA <= Srca_A;   aluSrcB  <= Srca_B;   aluOp     <= PASSA_;
                memRead <= "0";      memToReg <= "0";      memWrite  <= "0";     memData <= Memd_A;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
                pcSrc   <= Pcs_ID;
            when "00101" =>
                -- BNEZ
                immEx   <= "1";      immSrc   <= Imms_70;
                aluSrcA <= Srca_A;   aluSrcB  <= Srca_B;   aluOp     <= PASSA_;
                memRead <= "0";      memToReg <= "0";      memWrite  <= "0";     memData <= Memd_A;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
                pcSrc   <= Pcs_ID;
            when "11101" =>
                -- JR
                immEx   <= "1";      immSrc   <= Imms_00;
                aluSrcA <= Srca_A;   aluSrcB  <= Srca_B;   aluOp     <= PASSA_;
                memRead <= "0";      memToReg <= "0";      memWrite  <= "0";     memData <= Memd_A;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
                pcSrc   <= Pcs_RX;
            when others =>
                -- nothing
        end case;
    end process;

end behavior;
