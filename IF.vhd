library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

---------- Clock ----------
signal clk : std_logic := '1';
---------- IF ----------
-- variable
shared variable if_cnt : int8 := 0;
-- general signal
signal if_pc_src   : std_logic := '0';
signal if_pc_write : std_logic := '0';
signal if_pc       : std_logic_vector(15 downto 0) := zero16;

begin
-------------------- CLOCK --------------------
process(clk_50m)
begin
    clk <= clk_50m;
end process;

-------------------- IF --------------------
process(clk)
begin
    if clk'event and clk = '1' then
        case if_cnt is
        when 0 =>
        when 1 =>
        when 2 =>
        when 3 =>
            if if_pc_write = '1' then
                case if_pc_src is
                    when '0' =>
                        if_pc <= id_pc_add_imm;
                    when '1' =>
                        if_pc <= id_jump_output;
                    when others =>
                        -- do nothing
                end case;
            end if;
        when 4 =>
            -- instruction
            -- TODO : caln if_id_ins

            -- ADD : pc + 1
            if_id_pc <= if_pc + '1';
        when others =>
    end case;

    if if_cnt = 4 then
        if_cnt := 0;
    else
        if_cnt := if_cnt + 1;
    end if;
end if;
end process;