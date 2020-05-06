-- This is the testbench of the ControlUnit of the RISC-V CPU 
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

entity tb_ControlUnit is
end;

architecture tb of tb_ControlUnit is
  constant c_DELTA_TIME : time := 1 ns;
  signal w_de_to_cu : de_to_cu_t; 
  signal w_cu_to_de : cu_to_de_t; 
  begin
  DUT : entity work.ControlUnit(logic)
        port map(in_de_to_cu => w_de_to_cu,
                 out_cu_to_de => w_cu_to_de);

  p_SIMULATION : process
    begin
         ----------------------------------------------------
         --|              REG-REG INSTRUCTIONS              |
         ---------------------------------------------------- 
        -- ADD
        w_de_to_cu.opcode <= b"0110011"; 
        w_de_to_cu.func3 <= b"000"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SUB
        w_de_to_cu.opcode <= b"0110011"; 
        w_de_to_cu.func3 <= b"000"; 
        w_de_to_cu.func7 <= b"0100000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SLL
        w_de_to_cu.opcode <= b"0110011"; 
        w_de_to_cu.func3 <= b"001"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SLT
        w_de_to_cu.opcode <= b"0110011"; 
        w_de_to_cu.func3 <= b"010"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SLTU
        w_de_to_cu.opcode <= b"0110011"; 
        w_de_to_cu.func3 <= b"011"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- XOR
        w_de_to_cu.opcode <= b"0110011"; 
        w_de_to_cu.func3 <= b"100"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SRL
        w_de_to_cu.opcode <= b"0110011"; 
        w_de_to_cu.func3 <= b"101"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SRA
        w_de_to_cu.opcode <= b"0110011"; 
        w_de_to_cu.func3 <= b"101"; 
        w_de_to_cu.func7 <= b"0100000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- OR
        w_de_to_cu.opcode <= b"0110011"; 
        w_de_to_cu.func3 <= b"110"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- AND
        w_de_to_cu.opcode <= b"0110011"; 
        w_de_to_cu.func3 <= b"111"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        ----------------------------------------------------
        --|             IMMEDIATE INSTRUCTIONS             |
        ---------------------------------------------------- 
        -- ADDI
        w_de_to_cu.opcode <= b"0010011"; 
        w_de_to_cu.func3 <= b"000"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SLTI
        w_de_to_cu.opcode <= b"0010011"; 
        w_de_to_cu.func3 <= b"010"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SLTIU
        w_de_to_cu.opcode <= b"0010011"; 
        w_de_to_cu.func3 <= b"011"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- XORI
        w_de_to_cu.opcode <= b"0010011"; 
        w_de_to_cu.func3 <= b"100"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- ORI
        w_de_to_cu.opcode <= b"0010011"; 
        w_de_to_cu.func3 <= b"110"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- ADDI
        w_de_to_cu.opcode <= b"0010011"; 
        w_de_to_cu.func3 <= b"111"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SHIFTS 

        -- SLLI
        w_de_to_cu.opcode <= b"0010011"; 
        w_de_to_cu.func3 <= b"001"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SRLI
        w_de_to_cu.opcode <= b"0010011"; 
        w_de_to_cu.func3 <= b"101"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SRAI
        w_de_to_cu.opcode <= b"0010011"; 
        w_de_to_cu.func3 <= b"101"; 
        w_de_to_cu.func7 <= b"0100000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        ----------------------------------------------------
        --|               LOAD INSTRUCTIONS                |
        ---------------------------------------------------- 
        -- LB 
        w_de_to_cu.opcode <= b"0000011"; 
        w_de_to_cu.func3 <= b"000"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- LH
        w_de_to_cu.opcode <= b"0000011"; 
        w_de_to_cu.func3 <= b"001"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- LW
        w_de_to_cu.opcode <= b"0000011"; 
        w_de_to_cu.func3 <= b"010"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- LBU
        w_de_to_cu.opcode <= b"0000011"; 
        w_de_to_cu.func3 <= b"100"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- LHU
        w_de_to_cu.opcode <= b"0000011"; 
        w_de_to_cu.func3 <= b"101"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;
        ----------------------------------------------------
        --|               STORE INSTRUCTIONS               |
        ---------------------------------------------------- 
        -- SB
        w_de_to_cu.opcode <= b"0100011"; 
        w_de_to_cu.func3 <= b"000"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SH 
        w_de_to_cu.opcode <= b"0100011"; 
        w_de_to_cu.func3 <= b"001"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- SW 
        w_de_to_cu.opcode <= b"0100011"; 
        w_de_to_cu.func3 <= b"010"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;
        ----------------------------------------------------
        --|               BRANCH INSTRUCTIONS              |
        ---------------------------------------------------- 
        -- BEQ
        w_de_to_cu.opcode <= b"1100011"; 
        w_de_to_cu.func3 <= b"000"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- BNE
        w_de_to_cu.opcode <= b"1100011"; 
        w_de_to_cu.func3 <= b"001"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- BLT
        w_de_to_cu.opcode <= b"1100011"; 
        w_de_to_cu.func3 <= b"100"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- BGE
        w_de_to_cu.opcode <= b"1100011"; 
        w_de_to_cu.func3 <= b"101"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- BLTU
        w_de_to_cu.opcode <= b"1100011"; 
        w_de_to_cu.func3 <= b"110"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- BGEU
        w_de_to_cu.opcode <= b"1100011"; 
        w_de_to_cu.func3 <= b"111"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        ----------------------------------------------------
        --|                JUMP INSTRUCTIONS               |
        ---------------------------------------------------- 
        -- JAL
        w_de_to_cu.opcode <= b"1101111"; 
        w_de_to_cu.func3 <= b"000"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;

        -- JALR
        w_de_to_cu.opcode <= b"1101111"; 
        w_de_to_cu.func3 <= b"000"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;
        ----------------------------------------------------
        --|                 LUI INSTRUCTION                |
        ---------------------------------------------------- 
        -- LUI
        w_de_to_cu.opcode <= b"0110111"; 
        w_de_to_cu.func3 <= b"000"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait for c_DELTA_TIME;
        ----------------------------------------------------
        --|                AUIPC INSTRUCTION               |
        ---------------------------------------------------- 
        -- LUI
        w_de_to_cu.opcode <= b"0010111"; 
        w_de_to_cu.func3 <= b"000"; 
        w_de_to_cu.func7 <= b"0000000"; 
        w_de_to_cu.exbranch <= false; 
        wait;
    end process;

  end tb;
