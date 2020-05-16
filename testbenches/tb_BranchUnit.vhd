-- This is the testbench of the BranchUnit of the RISC-V CPU 
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
USE work.tb_procedure_pkg.ALL;

entity tb_BranchUnit is
end;

architecture tb of tb_BranchUnit is
  constant c_DELTA_TIME : time := 1 ns;

  signal w_ex_to_bu : ex_to_bu_t := (op_a => (others => '0'),
                                     op_b => (others => '0'),
                                     branch => c_BRANCH_BEQ);
  signal w_bu_to_ex : bu_to_ex_t;

  begin
  DUT : entity work.BranchUnit(behavior)
        port map(in_ex_to_bu => w_ex_to_bu,
                 out_bu_to_ex => w_bu_to_ex);

  p_SIMULATION : process
    begin
      --TEST BEQ 
        --VECTORS ARE EQUAL (true OUTPUT EXPECTED)
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, true);
        --VECTORS ARE NOT EQUAL (false OUTPUT EXPECTED)
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"fffffff0";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, false);

      --TEST BNE
      w_ex_to_bu.branch <= c_BRANCH_BNE; 
        --VECTORS ARE NOT EQUAL (true OUTPUT EXPECTED) 
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"fffffff0";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, true);
        --VECTORS ARE EQUAL (false OUTPUT EXPECTED)
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"ffffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, false);

      --TEST BLT
      w_ex_to_bu.branch <= c_BRANCH_BLT; 
        --VECTOR A IS LESS THAN VECTOR B (true OUTPUT EXPECTED) 
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"7fffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, true);
        --VECTOR A EQUAL TO VECTOR B (false OUTPUT EXPECTED)
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"ffffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, false);

      --TEST BGE
      w_ex_to_bu.branch <= c_BRANCH_BGE; 
        --VECTOR A IS GREATER THAN VECTOR B (true OUTPUT EXPECTED) 
      w_ex_to_bu.op_a <= x"7fffffff";
      w_ex_to_bu.op_b <= x"00000000";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, true);
        --VECTOR A EQUAL TO VECTOR B (true OUTPUT EXPECTED)
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"ffffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, true);
        --VECTOR A IS LESS THAN VECTOR B (false OUTPUT EXPECTED)
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"7fffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, false);

      --TEST BLTU
      w_ex_to_bu.branch <= c_BRANCH_BLTU; 
        --VECTOR A IS LESS THAN VECTOR B (true OUTPUT EXPECTED) 
      w_ex_to_bu.op_a <= x"7fffffff";
      w_ex_to_bu.op_b <= x"ffffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, true);
        --VECTOR A EQUAL TO VECTOR B (false OUTPUT EXPECTED)
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"ffffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, false);
        --VECTOR A IS GREATER THAN VECTOR B (false OUTPUT EXPECTED) 
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"7fffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, false);

      --TEST BGEU
      w_ex_to_bu.branch <= c_BRANCH_BGEU; 
      --VECTOR A IS GREATER THAN VECTOR B (true OUTPUT EXPECTED) 
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"7fffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, true);
        --VECTOR A EQUAL TO VECTOR B (true OUTPUT EXPECTED)
      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"ffffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, true);
        --VECTOR A IS LESS THAN VECTOR B (false OUTPUT EXPECTED) 
      w_ex_to_bu.op_a <= x"7fffffff";
      w_ex_to_bu.op_b <= x"ffffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_ex_to_bu.branch, w_bu_to_ex.branch, false);

      wait for c_DELTA_TIME;
    assert false report "Reached end of test successfully!";
    wait; --make process wait for an infinite timespan
  end process;

  end tb;
