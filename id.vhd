LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use my_data_types.ALL;

-- author : dpatrickx
-- ID : pass im, rd, rs, rt, spcial value according to control signals

entity id is
    port(
        pcIn        : in std_logic_vector(15 downto 0);
        opIn        : in std_logic_vector(4 downto 0);
        instBody    : in std_logic_vector(10 downto 0);

        regDst      : in std_logic_vector(1 downto 0);
        regWrite    : in std_logic_vector(2 downto 0);
        memToReg    : in std_logic;
        memRead     : in std_logic;
        memWrite    : in std_logic;
        memData     : in std_logic;
        aluSrcA     : in std_logic_vector(2 downto 0);
        aluSrcB     : in std_logic_vector(2 downto 0);
        aluOp       : in std_logic_vector(4 downto 0);
        pcWrite     : in std_logic;
        pcSrc       : in std_logic;
        immEx       : in std_logic;
        immSrc      : in std_logic_vector(2 downto 0);

        pcOut       : out std_logic_vector(15 downto 0);
        opOut       : out std_logic_vector(4 downto 0);
        rd          : out std_logic_vector(2 downto 0);
        rs          : out std_logic_vector(2 downto 0);
        rt          : out std_logic_vector(2 downto 0);
        im          : out std_logic_vector(15 downto 0));
end id;

architecture behavior of id is
    pcOut <= pcIn;
    opOut <= opIn;
    rs <= instBody(10 downto 8);
    rt <= instBody(7 downto 5);
    getRd: process(regDst, instBody)
    -- rd
    begin
        case regDst is
            when Regd_RX =>
                rd <= instBody(10 downto 8);
            when Regd_RY =>
                rd <= instBody(7 downto 5);
            when Regd_RZ =>
                rd <= instBody(4 downto 2);
            when Regd_SP =>
                rd <= ZERO_16;
        end case;
    end process;
    -- im
    getIm: process(immSrc, instBody)
    begin
        case immSrc is
            when Imms_10 =>
                case instBody(10) is
                    when "0" => im <= "00000" & instBody;
                    when "1" => im <= "11111" & instBody;
                end case;
            when Imms_70 =>
                case instBody(7) is
                    when "0" => im <= ZERO_8 & instBody(7 downto 0);
                    when "1" => im <= ONE_8  & instBody(7 downto 0);
                end case;
            when Imms_40 =>
                case instBody(4) is
                    when "0" => im <= ZERO_11 & instBody(4 downto 0);
                    when "1" => im <= ONE_11  & instBody(4 downto 0);
                end case;
            when Imms_30 =>
                case instBody(3) is
                    when "0" => im <= ZERO_12 & instBody(3 downto 0);
                    when "1" => im <= ONE_12  & instBody(3 downto 0);
                end case;
            when Imms_42 =>
            -- only need to use last 3 bits
                im <= ZERO_13 & instBody(4 downto 2);
            when others =>
                im <= ZERO_16;
        end case;
    end process;
begin