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

        -- im
        immEx       : out std_logic;
        immSrc      : out std_logic_vector(2 downto 0);
        -- alu
        aluSrcA     : out std_logic_vector(2 downto 0);
        aluSrcB     : out std_logic_vector(2 downto 0);
        aluOp       : out std_logic_vector(4 downto 0);
        -- mem
        memToReg    : out std_logic;
        memRead     : out std_logic;
        memWrite    : out std_logic;
        memData     : out std_logic;
        -- reg
        regDst      : out std_logic_vector(1 downto 0);
        regWrite    : out std_logic_vector(2 downto 0));
end control;

architecture behavior of control is
begin
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
                pcSrc   <= Pcs_NR;
            when others =>
                -- nothing
        end case;
    end process;

end behavior;
