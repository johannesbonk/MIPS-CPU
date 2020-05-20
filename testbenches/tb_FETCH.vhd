-- This is the testbench of the FETCH stage of the RISC-V CPU
-- Copyright (C) 2020  Johannes Bonk
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see http://www.gnu.org/licenses

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.common.ALL;

entity tb_FETCH is
end;

architecture tb of tb_FETCH is
  constant c_T_SET : time := 0.5 ns;
  constant c_T_CLK : time := 0.5 ns;

  signal w_ext_to_all : ext_to_all_t := (clk => '0',
                                         clr => '0');
  signal w_de_to_fe : de_to_fe_t := (pc4 => (others => '0'),
                                    jaladr => x"00000004",
                                    jalradr => x"00000007",
                                    branchadr => x"00000015",
                                    muxpc => c_MUXPC_PC4, 
                                    muxnop => c_MUXNOP_OP);
  signal w_fe_to_de : fe_to_de_t;

  begin
  DUT : entity work.FETCH(RTL)
        port map(in_ext_to_all => w_ext_to_all,
                 in_de_to_fe => w_de_to_fe,
                 out_fe_to_de => w_fe_to_de);

  p_SIMULATION : process
    begin
    wait for c_T_CLK; 
    w_ext_to_all.clk <= '1'; 
    wait for c_T_CLK; 
    w_ext_to_all.clk <= '0';
    assert (w_fe_to_de.pc = x"00000000" and w_fe_to_de.pc4 = x"00000004" and w_fe_to_de.instr = x"00828293")
    report "Unexpected result at " & lf &
           "PC: " & integer'image(to_integer(unsigned((w_fe_to_de.pc)))) & "; " & lf &
           "PC (expected): " & "0x00828293" & "; " & lf &
           "PC4: " & integer'image(to_integer(unsigned(w_fe_to_de.pc4))) & "; " & lf &
           "PC4 (expected): " & "0x00000004" & "; " & lf &
           "Instruction " & integer'image(to_integer(signed(w_fe_to_de.instr))) & "; " & lf &
           "Instruction (expected): " & "0x00828293" & "; " 
    severity error;

    w_de_to_fe.muxpc <= c_MUXPC_JAL;
    wait for c_T_CLK; 
    w_ext_to_all.clk <= '1'; 
    wait for c_T_CLK; 
    w_ext_to_all.clk <= '0';
    assert (w_fe_to_de.pc = x"00000004" and w_fe_to_de.pc4 = x"00000008" and w_fe_to_de.instr = x"0062d663")
    report "Unexpected result at " & lf &
           "PC: " & integer'image(to_integer(unsigned(w_fe_to_de.pc))) & "; " & lf &
           "PC (expected): " & "0x00000004" & "; " & lf &
           "PC4: " & integer'image(to_integer(unsigned(w_fe_to_de.pc4))) & "; " & lf &
           "PC4 (expected): " & "0x00000008" & "; " & lf &
           "Instruction " & integer'image(to_integer(signed(w_fe_to_de.instr))) & "; " & lf &
           "Instruction (expected): " & "0x0062d663" & "; " 
    severity error;

    w_de_to_fe.muxpc <= c_MUXPC_JALR;
    wait for c_T_CLK; 
    w_ext_to_all.clk <= '1'; 
    wait for c_T_CLK; 
    w_ext_to_all.clk <= '0';
    assert (w_fe_to_de.pc = x"00000007" and w_fe_to_de.pc4 = x"0000000b" and w_fe_to_de.instr = x"00c10113")
    report "Unexpected result at " & lf &
           "PC: " & integer'image(to_integer(unsigned(w_fe_to_de.pc))) & "; " & lf &
           "PC (expected): " & "0x00000007" & "; " & lf &
           "PC4: " & integer'image(to_integer(unsigned(w_fe_to_de.pc4))) & "; " & lf &
           "PC4 (expected): " & "0x0000000b" & "; " & lf &
           "Instruction " & integer'image(to_integer(signed(w_fe_to_de.instr))) & "; " & lf &
           "Instruction (expected): " & "0x00c10113" & "; " 
    severity error;

    w_de_to_fe.muxpc <= c_MUXPC_BRANCH;
    wait for c_T_CLK; 
    w_ext_to_all.clk <= '1'; 
    wait for c_T_CLK; 
    w_ext_to_all.clk <= '0';
    assert (w_fe_to_de.pc = x"00000015" and w_fe_to_de.pc4 = x"00000019" and w_fe_to_de.instr = x"00000063")
    report "Unexpected result at " & lf &
           "PC: " & integer'image(to_integer(unsigned(w_fe_to_de.pc))) & "; " & lf &
           "PC (expected): " & "0x00000015" & "; " & lf &
           "PC4: " & integer'image(to_integer(unsigned(w_fe_to_de.pc4))) & "; " & lf &
           "PC4 (expected): " & "0x00000019" & "; " & lf &
           "Instruction " & integer'image(to_integer(signed(w_fe_to_de.instr))) & "; " & lf &
           "Instruction (expected): " & "0x00000063" & "; " 
    severity error;

    w_de_to_fe.muxpc <= c_MUXPC_PC4; 
    w_de_to_fe.muxnop <= c_MUXNOP_NOP;
    wait for c_T_CLK; 
    w_ext_to_all.clk <= '1'; 
    wait for c_T_CLK; 
    w_ext_to_all.clk <= '0';
    assert (w_fe_to_de.pc = x"00000000" and w_fe_to_de.pc4 = x"00000004" and w_fe_to_de.instr = x"00000000")
    report "Unexpected result at " & lf &
           "PC: " & integer'image(to_integer(unsigned(w_fe_to_de.pc))) & "; " & lf &
           "PC (expected): " & "0x00000000" & "; " & lf &
           "PC4: " & integer'image(to_integer(unsigned(w_fe_to_de.pc4))) & "; " & lf &
           "PC4 (expected): " & "0x00000004" & "; " & lf &
           "Instruction " & integer'image(to_integer(signed(w_fe_to_de.instr))) & "; " & lf &
           "Instruction (expected): " & "0x00000000" & "; " 
    severity error;

    assert false report "Reached end of test successfully!";
    wait; --make process wait for an infinite timespan
  end process;

  end tb;
