-- This is the BranchUnit of the RISC-V CPU which determines the equal and less than (unsigned) conditions
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

entity BranchUnit is
  port(in_ex_to_bu  : in ex_to_bu_t;
       out_bu_to_ex : out bu_to_ex_t);
end entity;

architecture logic of BranchUnit is
  signal w_beq  : std_logic; 
  signal w_bne  : std_logic; 
  signal w_blt  : std_logic; 
  signal w_bge  : std_logic; 
  signal w_bltu : std_logic; 
  signal w_bgeu : std_logic; 
begin

  w_beq <= '1' when in_ex_to_bu.op_a = in_ex_to_bu.op_b else
           '0';
  w_bne <= '1' when in_ex_to_bu.op_a /= in_ex_to_bu.op_b else 
            '0'; 
  w_blt <= '1' when signed(in_ex_to_bu.op_a) < signed(in_ex_to_bu.op_b) else
           '0';
  w_bge <= '1' when ((signed(in_ex_to_bu.op_a) > signed(in_ex_to_bu.op_b)) or (in_ex_to_bu.op_a = in_ex_to_bu.op_b)) else 
           '0'; 
  w_bltu <= '1' when unsigned(in_ex_to_bu.op_a) < unsigned(in_ex_to_bu.op_b) else
            '0';
  w_bgeu <= '1' when ((unsigned(in_ex_to_bu.op_a) > unsigned(in_ex_to_bu.op_b)) or (in_ex_to_bu.op_a = in_ex_to_bu.op_b)) else 
            '0';
            
  out_bu_to_ex.branch <= true when ((in_ex_to_bu.branch = c_BRANCH_BEQ) and w_beq = '1') else 
                         true when ((in_ex_to_bu.branch = c_BRANCH_BNE) and w_bne = '1') else 
                         true when ((in_ex_to_bu.branch = c_BRANCH_BLT) and w_blt = '1') else 
                         true when ((in_ex_to_bu.branch = c_BRANCH_BGE) and w_bge = '1') else 
                         true when ((in_ex_to_bu.branch = c_BRANCH_BLTU) and w_bltu = '1') else 
                         true when ((in_ex_to_bu.branch = c_BRANCH_BGEU) and w_bgeu = '1') else
                         false;  
end logic;
