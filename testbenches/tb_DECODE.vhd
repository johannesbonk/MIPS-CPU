-- This is the testbench of the Decode stage of the RISC-V CPU 
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

entity tb_DECODE is
end;

architecture tb of tb_DECODE is
  constant c_DELTA_TIME : time := 1 ns;

  signal w_ext_to_all : ext_to_all_t := (clk => '0', 
                                         clr => '0'); 
  signal w_fe_to_de : fe_to_de_t := (pc => x"00_00_00_00",
                                     pc4 => x"00_00_00_04", 
                                     instr => b"00000000_00000000_00000000_00010011"); -- ADDI x0, x0, 0
  signal w_ex_to_de : ex_to_de_t := (res => x"00_00_00_00",
                                   regop => c_REG_WD, 
                                   rd => b"00000",
                                   branch => false, 
                                   branchadr => x"00_00_00_00");

  signal w_de_to_fe : de_to_fe_t;
  signal w_de_to_ex : de_to_ex_t; 

  begin
  DUT : entity work.DECODE(RTL)
        port map(in_ext_to_all => w_ext_to_all,
                 in_fe_to_de => w_fe_to_de, 
                 in_ex_to_de => w_ex_to_de, 
                 out_de_to_fe => w_de_to_fe, 
                 out_de_to_ex => w_de_to_ex);

  p_SIMULATION : process
    begin
        wait for c_DELTA_TIME; 
        w_ext_to_all.clk <= '1'; 
        wait for c_DELTA_TIME; 
        w_ext_to_all.clk <= '0'; 

        ----------------------------------------------------
         --|           ARITHMETIC INSTRUCTIONS             |
        ---------------------------------------------------- 
        -- TEST ADD x2, x1, x2 INSTRUCTION 
        w_fe_to_de.pc <= x"00_00_00_04"; 
        w_fe_to_de.pc4 <= x"00_00_00_08"; 
        w_fe_to_de.instr <= b"00000000_00100000_10000001_00110011"; 
        w_ex_to_de.res <= x"ff_ff_ff_ff"; 
        w_ex_to_de.regop <= c_REG_WE; 
        w_ex_to_de.rd <= b"00001"; 
        w_ex_to_de.branch <= false; 
        w_ex_to_de.branchadr <= x"00_00_00_00"; 

        wait for c_DELTA_TIME; 
        w_ext_to_all.clk <= '1'; 
        wait for c_DELTA_TIME; 
        w_ext_to_all.clk <= '0'; 

        -- TEST SUB x2, x1, x2 INSTRUCTION 
        w_fe_to_de.pc <= x"00_00_00_08"; 
        w_fe_to_de.pc4 <= x"00_00_00_0c"; 
        w_fe_to_de.instr <= b"01000000_00100000_10000001_00110011"; 
        w_ex_to_de.res <= x"ff_ff_ff_ff"; 
        w_ex_to_de.regop <= c_REG_WE; 
        w_ex_to_de.rd <= b"00010"; 
        w_ex_to_de.branch <= false; 
        w_ex_to_de.branchadr <= x"00_00_00_00"; 
        
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '1'; 
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '0'; 

        -- -- TEST SLL x1, x2, x2 INSTRUCTION 
        -- w_fe_to_de.pc <= ; 
        -- w_fe_to_de.pc4 <= ; 
        -- w_fe_to_de.instr <= ; 
        -- w_ex_to_de.res <= ; 
        -- w_ex_to_de.regop <= ; 
        -- w_ex_to_de.rd <= ; 
        -- w_ex_to_de.branch <= ; 
        -- w_ex_to_de.branchadr <= ; 
        
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '1'; 
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '0'; 

        -- -- TEST SLT x1, x2, x2 INSTRUCTION 
        -- w_fe_to_de.pc <= ; 
        -- w_fe_to_de.pc4 <= ; 
        -- w_fe_to_de.instr <= ; 
        -- w_ex_to_de.res <= ; 
        -- w_ex_to_de.regop <= ; 
        -- w_ex_to_de.rd <= ; 
        -- w_ex_to_de.branch <= ; 
        -- w_ex_to_de.branchadr <= ; 
        
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '1'; 
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '0'; 

        -- -- TEST SLTU x1, x2, x2 INSTRUCTION 
        -- w_fe_to_de.pc <= ; 
        -- w_fe_to_de.pc4 <= ; 
        -- w_fe_to_de.instr <= ; 
        -- w_ex_to_de.res <= ; 
        -- w_ex_to_de.regop <= ; 
        -- w_ex_to_de.rd <= ; 
        -- w_ex_to_de.branch <= ; 
        -- w_ex_to_de.branchadr <= ; 
        
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '1'; 
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '0'; 

        -- -- TEST XOR x1, x2, x2 INSTRUCTION 
        -- w_fe_to_de.pc <= ; 
        -- w_fe_to_de.pc4 <= ; 
        -- w_fe_to_de.instr <= ; 
        -- w_ex_to_de.res <= ; 
        -- w_ex_to_de.regop <= ; 
        -- w_ex_to_de.rd <= ; 
        -- w_ex_to_de.branch <= ; 
        -- w_ex_to_de.branchadr <= ; 
        
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '1'; 
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '0'; 

        -- -- TEST SRL x1, x2, x2 INSTRUCTION 
        -- w_fe_to_de.pc <= ; 
        -- w_fe_to_de.pc4 <= ; 
        -- w_fe_to_de.instr <= ; 
        -- w_ex_to_de.res <= ; 
        -- w_ex_to_de.regop <= ; 
        -- w_ex_to_de.rd <= ; 
        -- w_ex_to_de.branch <= ; 
        -- w_ex_to_de.branchadr <= ; 
        
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '1'; 
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '0'; 

        -- -- TEST SRA x1, x2, x2 INSTRUCTION 
        -- w_fe_to_de.pc <= ; 
        -- w_fe_to_de.pc4 <= ; 
        -- w_fe_to_de.instr <= ; 
        -- w_ex_to_de.res <= ; 
        -- w_ex_to_de.regop <= ; 
        -- w_ex_to_de.rd <= ; 
        -- w_ex_to_de.branch <= ; 
        -- w_ex_to_de.branchadr <= ; 
        
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '1'; 
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '0'; 

        -- -- TEST OR x1, x2, x2 INSTRUCTION 
        -- w_fe_to_de.pc <= ; 
        -- w_fe_to_de.pc4 <= ; 
        -- w_fe_to_de.instr <= ; 
        -- w_ex_to_de.res <= ; 
        -- w_ex_to_de.regop <= ; 
        -- w_ex_to_de.rd <= ; 
        -- w_ex_to_de.branch <= ; 
        -- w_ex_to_de.branchadr <= ; 
        
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '1'; 
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '0'; 

        -- -- TEST AND x1, x2, x2 INSTRUCTION 
        -- w_fe_to_de.pc <= ; 
        -- w_fe_to_de.pc4 <= ; 
        -- w_fe_to_de.instr <= ; 
        -- w_ex_to_de.res <= ; 
        -- w_ex_to_de.regop <= ; 
        -- w_ex_to_de.rd <= ; 
        -- w_ex_to_de.branch <= ; 
        -- w_ex_to_de.branchadr <= ; 
        
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '1'; 
        -- wait for c_DELTA_TIME; 
        -- w_ext_to_all.clk <= '0'; 
    wait; --make process wait for an infinite timespan
  end process;

  end tb;
