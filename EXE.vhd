-------------------- EXE --------------------
u_forwarding_unit : ForwardingUnit port map ( -- when exe_cnt = 0
    Rx             => id_exe_rx,
    Ry             => id_exe_ry,
    ExeMemRegWrite => exe_mem_reg_write,
    ExeMemRd       => exe_mem_write_reg,
    MemWbRegWrite  => exe_mem_reg_write,
    MemWbRd        => exe_mem_write_reg,
    Forward1       => exe_forward_1,
    Forward2       => exe_forward_2);

    u_alu : ALU port map( -- when exe_cnt = 2
    op      => id_exe_alu_op,
    input_A => exe_alu_input_A,
    input_B => exe_alu_input_B,
    output  => exe_mem_alu_output);

process(clk)
    begin
        if clk'event and clk = '1' then
        case exe_cnt is
            when 0 =>
        -- control signal pass EXE
                exe_mem_mem_write <= id_exe_mem_write;
                exe_mem_mem_read <= id_exe_mem_read;
                exe_mem_reg_write <= id_exe_reg_write;
                exe_mem_reg_data <= id_exe_reg_data;

-- MUX : ALUSrc1
                case id_exe_alu_src_1 is
                when "00" =>
                    exe_alu_pre_1 <= id_exe_A;
                when "01" =>
                    exe_alu_pre_1 <= id_exe_C;
                when "10" =>
                    exe_alu_pre_1 <= id_exe_imm;
                when "11" =>
                    exe_alu_pre_1 <= id_exe_pc;
                when others =>
                    exe_alu_pre_1 <= zero16;
                end case;

-- MUX : ALUSrc2
case id_exe_alu_src_2 is
when '0' =>
exe_alu_pre_2 <= id_exe_B;
when '1' =>
exe_alu_pre_2 <= id_exe_imm;
when others =>
exe_alu_pre_2 <= zero16;
end case;

-- MUX : RegDst
case id_exe_reg_dst is
when "00" =>
exe_mem_write_reg <= id_exe_rx;
when "01" =>
exe_mem_write_reg <= id_exe_ry;
when "10" =>
exe_mem_write_reg <= id_exe_rz;
when others =>
exe_mem_write_reg <= "000";
end case;

-- MUX : MemData
case id_exe_mem_data is
when '0' =>
exe_mem_mem_d <= id_exe_A;
when '1' =>
exe_mem_mem_d <= id_exe_B;
when others =>
exe_mem_mem_d <= zero16;
end case;
when 1 =>
-- MUX : Forward1
case exe_forward_1 is
when "00" =>
exe_alu_input_A <= exe_alu_pre_1;
when "01" =>
exe_alu_input_A <= exe_mem_alu_output;
when "10" =>
exe_alu_input_A <= wb_write_data;
when others =>
exe_alu_input_A <= zero16;
end case;

-- MUX : Forward2
case exe_forward_2 is
when "00" =>
exe_alu_input_B <= exe_alu_pre_2;
when "01" =>
exe_alu_input_B <= exe_mem_alu_output;
when "10" =>
exe_alu_input_B <= wb_write_data;
when others =>
exe_alu_input_B <= zero16;
end case;
when 2 =>
when 3 =>
when 4 =>
when others =>
end case;

if exe_cnt = 4 then
exe_cnt := 0;
else
exe_cnt := exe_cnt + 1;
end if;
end if;
end process;