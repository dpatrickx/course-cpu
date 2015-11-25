LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.control.ALL;
use work.my_data_types.ALL;

entity IF is
    port(
        PCSrc : in std_logic_vector(1 downto 0);
        pc_B  : in std_logic_vector(15 downto 0);
        pc_JR : in std_logic_vector(15 downto 0);
        pc_BE : in std_logic_vector(15 downto 0);
        pc_normal : in std_logic_vector(15 downto 0);
        PC_out : out std_logic_vector(15 downto 0));
        PC_added_out : out std_logic_vector(15 downto 0));
end IF;

architecture behavior of IF is
    if_pc : std_logic_vector(15 downto 0);
begin
    process(PCSrc, pc_B, pc_JR, pc_BE)
        if if_pc_write = '1' then
            case pcSource is
                when "00" =>
                    if_pc <= pc_B;
                when "01" =>
                    if_pc <= pc_JR;
                when "10" =>
                    if_pc <= pc_BE;
                when others =>
                    if_pc <= pc_normal;
            end case;
        end if;

        PC_out <= if_pc;
        PC_added_out <= if_pc + 1;

    end process;
end behavior;

