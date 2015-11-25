LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_data_types.ALL;

-- author: dpatrickx
-- ID : get control signals according to instructions
-- ID : expand immidiate to 16 bits

entity control is
    port(
        pcIn        : in std_logic_vector(15 downto 0);
        opIn        : in std_logic_vector(4 downto 0);
        comBody     : in std_logic_vector(10 downto 0);
        rdPcWrite   : in std_logic;

        -- im
        immEx       : out std_logic;
        immSrc      : out std_logic_vector(2 downto 0);
        -- alu
        aluSrcA     : out std_logic;
        aluSrcB     : out std_logic_vector(2 downto 0);
        aluOp       : out std_logic_vector(3 downto 0);
        -- mem
        memToReg    : out std_logic;
        memRead     : out std_logic;
        memWrite    : out std_logic;
        memData     : out std_logic;
        -- reg
        regDst      : out std_logic_vector(1 downto 0);
        regWrite    : out std_logic_vector(2 downto 0);
        -- pc, linked to IF
        pcWriteOut     : out std_logic;
        rdPcWriteOut : out std_logic);
end control;

architecture behavior of control is
begin
    -- decide control signals according to instructions
    getConSig: process(opIn, comBody, rdPcWrite)
    begin


        case opIn is
            -- NOP
            when "00001" =>
                -- nothing
                immEx   <= '1';      immSrc   <= Imms_00;
                aluSrcA <= Srca_IM;  aluSrcB  <= Srcb_IM;
                memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
                if rdPcWrite = '0' then
                    rdPcWriteOut <= YES; pcWriteOut <= NO;
                else
                    rdPcWriteOut <= YES; pcWriteOut <= YES;
                end if;
            when "11100" =>
                -- ADDU SUBU
                immEx   <= '1';      immSrc   <= Imms_00;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_B;
                memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                regDst  <= Regd_RZ;  regWrite <= Regw_RD;
                rdPcWriteOut <= YES;  pcWriteOut <= YES;
                case comBody(1 downto 0) is
                    when "01" => aluOp <= ADDU_a;
                    when "11" => aluOp <= SUBU_a;
                    when others => aluOp <= PASSA_a;
                end case;
            when "11101" =>
                -- AND OR NEG NOT CMP
                immEx   <= '1';      immSrc   <= Imms_00;
                aluSrcA <= Srca_A;
                memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                regWrite <= Regw_RD;
                rdPcWriteOut <= YES;  pcWriteOut <= YES;
                case comBody(4 downto 0) is
                    when "01100" => aluOp <= AND_a;    aluSrcB  <= Srcb_B;  regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    when "01101" => aluOp <= OR_a;     aluSrcB  <= Srcb_B;  regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    when "01011" => aluOp <= NEG_a;    aluSrcB  <= Srcb_B;  regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    when "01111" => aluOp <= NOT_a;    aluSrcB  <= Srcb_B;  regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    when "01010" => aluOp <= CMP_a;    aluSrcB  <= Srcb_B;  regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    when others  => aluOp <= PASSA_a;  aluSrcB  <= Srcb_B;  regDst  <= Regd_RX;  regWrite <= Regw_RD;
                end case;
                case comBody(7 downto 0) is
                    when "01000000" =>
                    -- MFPC
                        regDst  <= Regd_RX;     regWrite <= Regw_RD;
                        aluOp   <= PASSB_a;     aluSrcB  <= Srcb_PC;
                    when "00000000" =>
                    -- JR
                        aluSrcB  <= Srcb_B;   aluOp     <= PASSA_a;
                        regDst  <= Regd_SP;   regWrite <= Regw_NO;
                    when others => --nothing
                end case;
            when "01111" =>
                -- MOVE
                immEx   <= '1';      immSrc   <= Imms_00;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_B;   aluOp <= PASSB_a;
                memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                regDst  <= Regd_RX;  regWrite <= Regw_RD;
                rdPcWriteOut <= YES;  pcWriteOut <= YES;
            when "11110" =>
                case comBody(0) is
                when '0' =>
                    -- MFIH
                    immEx   <= '1';      immSrc   <= Imms_00;
                    aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IH;   aluOp <= PASSB_a;
                    memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                    regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    rdPcWriteOut <= YES;  pcWriteOut <= YES;
                when '1' =>
                    -- MTIH
                    immEx   <= '1';      immSrc   <= Imms_00;
                    aluSrcA <= Srca_A;   aluSrcB  <= Srcb_B;   aluOp <= PASSA_a;
                    memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                    regDst  <= Regd_SP;  regWrite <= Regw_IH;
                    rdPcWriteOut <= YES; pcWriteOut <= YES;
                when others => --nothing
                end case;
            when "01100" =>
                if comBody(10 downto 8) = "100" then
                    -- MTSP
                    immEx   <= '1';      immSrc   <= Imms_00;
                    aluSrcA <= Srca_A;   aluSrcB  <= Srcb_B;   aluOp <= PASSA_a;
                    memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                    regDst  <= Regd_SP;  regWrite <= Regw_SP;
                    rdPcWriteOut <= YES; pcWriteOut <= YES;
                elsif comBody(10 downto 8) = "011" then
                    -- ADDSP
                    immEx   <= '1';      immSrc   <= Imms_70;
                    aluSrcA <= Srca_IM;   aluSrcB  <= Srcb_SP;   aluOp <= ADDU_a;
                    memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                    regDst  <= Regd_SP;  regWrite <= Regw_SP;
                    rdPcWriteOut <= YES; pcWriteOut <= YES;
                elsif comBody(10 downto 8) = "000" then
                    -- BTEQZ
                    immEx   <= '1';      immSrc   <= Imms_70;
                    aluSrcA <= Srca_A;   aluSrcB  <= Srcb_B;   aluOp <= PASSA_a;
                    memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                    regDst  <= Regd_SP;  regWrite <= Regw_NO;
                    rdPcWriteOut <= YES; pcWriteOut <= YES;
                else  --nothing
                end if;
            when "01000" =>
                -- ADDIU3
                immEx   <= '1';      immSrc   <= Imms_30;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IM;   aluOp <= ADDU_a;
                memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                regDst  <= Regd_RY;  regWrite <= Regw_RD;
                rdPcWriteOut <= YES; pcWriteOut <= YES;
            when "10011" =>
                -- LW
                immEx   <= '1';      immSrc   <= Imms_40;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IM;  aluOp    <= ADDU_a;
                memRead <= '1';      memToReg <= '1';      memWrite <= '0';     memData <= Memd_B;
                regDst  <= Regd_RY;  regWrite <= Regw_RD;
                rdPcWriteOut <= YES;  pcWriteOut <= NO;
            when "11011" =>
                -- SW
                immEx   <= '1';      immSrc   <= Imms_40;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IM;  aluOp    <= ADDU_a;
                memRead <= '0';      memToReg <= '0';      memWrite <= '1';     memData <= Memd_B;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
                rdPcWriteOut <= NO;  pcWriteOut <= NO;
            when "00110" =>
                if comBody(1 downto 0) = "11" then
                    -- SRA
                    immEx   <= '0';      immSrc   <= Imms_42;
                    aluSrcA <= Srca_IM;   aluSrcB  <= Srcb_B;   aluOp <= SRA_a;
                    memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                    regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    rdPcWriteOut <= YES; pcWriteOut <= YES;
                elsif comBody(1 downto 0) = "10" then
                    -- SRL
                    immEx   <= '0';      immSrc   <= Imms_42;
                    aluSrcA <= Srca_IM;   aluSrcB  <= Srcb_B;   aluOp <= SRL_a;
                    memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                    regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    rdPcWriteOut <= YES; pcWriteOut <= YES;
                elsif comBody(1 downto 0) = "00" then
                    -- SLL
                    immEx   <= '0';      immSrc   <= Imms_42;
                    aluSrcA <= Srca_IM;   aluSrcB  <= Srcb_B;   aluOp <= SLL_a;
                    memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_B;
                    regDst  <= Regd_RX;  regWrite <= Regw_RD;
                    rdPcWriteOut <= YES; pcWriteOut <= YES;
                else
                    -- nothing
                end if;
            when "01001" =>
                -- ADDIU
                immEx   <= '1';      immSrc   <= Imms_70;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IM;  aluOp    <= ADDU_a;
                memRead <= '0';      memToReg <= '0';      memWrite <= '1';     memData <= Memd_B;
                regDst  <= Regd_RX;  regWrite <= Regw_RD;
                rdPcWriteOut <= YES;  pcWriteOut <= YES;
            when "01110" =>
                -- CMPI
                immEx   <= '1';      immSrc   <= Imms_70;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IM;  aluOp    <= CMP_a;
                memRead <= '0';      memToReg <= '0';      memWrite <= '1';     memData <= Memd_B;
                regDst  <= Regd_SP;  regWrite <= Regw_T;
                rdPcWriteOut <= YES;  pcWriteOut <= YES;
            when "01101" =>
                -- LI
                immEx   <= '0';      immSrc   <= Imms_70;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_IM;  aluOp    <= PASSB_a;
                memRead <= '0';      memToReg <= '0';      memWrite <= '1';     memData <= Memd_B;
                regDst  <= Regd_RX;  regWrite <= Regw_RD;
                rdPcWriteOut <= YES;  pcWriteOut <= YES;
            when "10010" =>
                -- LW_SP
                immEx   <= '1';      immSrc   <= Imms_70;
                aluSrcA <= Srca_IM;   aluSrcB  <= Srcb_SP;  aluOp    <= ADDU_a;
                memRead <= '1';      memToReg <= '1';      memWrite <= '1';     memData <= Memd_B;
                regDst  <= Regd_RX;  regWrite <= Regw_RD;
                rdPcWriteOut <= YES;  pcWriteOut <= NO;
            when "11010" =>
                -- SW_SP
                immEx   <= '1';      immSrc   <= Imms_70;
                aluSrcA <= Srca_IM;   aluSrcB  <= Srcb_SP;  aluOp    <= ADDU_a;
                memRead <= '0';      memToReg <= '0';      memWrite <= '1';     memData <= Memd_A;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
                rdPcWriteOut <= NO;  pcWriteOut <= NO;
            when "00010" =>
                -- B
                immEx   <= '1';      immSrc   <= Imms_10;
                aluSrcA <= Srca_A;  aluSrcB   <= Srcb_B;   aluOp    <= PASSA_a;
                memRead <= '0';      memToReg <= '0';      memWrite <= '0';     memData <= Memd_A;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
                rdPcWriteOut <= YES;  pcWriteOut <= YES;
            when "00100" =>
                -- BEQZ
                immEx   <= '1';      immSrc   <= Imms_70;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_B;   aluOp     <= PASSA_a;
                memRead <= '0';      memToReg <= '0';      memWrite  <= '0';     memData <= Memd_A;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
                rdPcWriteOut <= YES;  pcWriteOut <= YES;
            when "00101" =>
                -- BNEZ
                immEx   <= '1';      immSrc   <= Imms_70;
                aluSrcA <= Srca_A;   aluSrcB  <= Srcb_B;   aluOp     <= PASSA_a;
                memRead <= '0';      memToReg <= '0';      memWrite  <= '0';     memData <= Memd_A;
                regDst  <= Regd_SP;  regWrite <= Regw_NO;
                rdPcWriteOut <= YES;  pcWriteOut <= YES;
            when others =>
                -- nothing
        end case;
    end process;

end behavior;
