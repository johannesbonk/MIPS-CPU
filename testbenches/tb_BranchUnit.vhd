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

  signal w_ex_to_bu : ex_to_bu_t := (op_a => (others => '1'),
                                     op_b => (others => '0'));
  signal w_bu_to_ex : bu_to_ex_t;

  begin
  DUT : entity work.BranchUnit(behavior)
        port map(in_ex_to_bu => w_ex_to_bu,
                 out_bu_to_ex => w_bu_to_ex);

  p_SIMULATION : process
    begin
      wait for c_DELTA_TIME;
      w_ex_to_bu.op_a <= x"00000000";
      w_ex_to_bu.op_b <= x"00000000";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_bu_to_ex.eq, w_bu_to_ex.lt, w_bu_to_ex.ltu, '1', '0', '0');

      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"ffffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_bu_to_ex.eq, w_bu_to_ex.lt, w_bu_to_ex.ltu, '1', '0', '0');

      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"fffffffe";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_bu_to_ex.eq, w_bu_to_ex.lt, w_bu_to_ex.ltu, '0', '0', '0');

      w_ex_to_bu.op_a <= x"fffffffe";
      w_ex_to_bu.op_b <= x"ffffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_bu_to_ex.eq, w_bu_to_ex.lt, w_bu_to_ex.ltu, '0', '1', '1');

      w_ex_to_bu.op_a <= x"7ffffffe";
      w_ex_to_bu.op_b <= x"7fffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_bu_to_ex.eq, w_bu_to_ex.lt, w_bu_to_ex.ltu, '0', '1', '1');

      w_ex_to_bu.op_a <= x"80000000";
      w_ex_to_bu.op_b <= x"00000000";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_bu_to_ex.eq, w_bu_to_ex.lt, w_bu_to_ex.ltu, '0', '1', '0');

      w_ex_to_bu.op_a <= x"7fffffff";
      w_ex_to_bu.op_b <= x"ffffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_bu_to_ex.eq, w_bu_to_ex.lt, w_bu_to_ex.ltu, '0', '0', '1');

      w_ex_to_bu.op_a <= x"ffffffff";
      w_ex_to_bu.op_b <= x"7fffffff";
      wait for c_DELTA_TIME;
      checkBranchUnitOut(w_ex_to_bu.op_a, w_ex_to_bu.op_b, w_bu_to_ex.eq, w_bu_to_ex.lt, w_bu_to_ex.ltu, '0', '1', '0');

      wait for c_DELTA_TIME;
    assert false report "Reached end of test successfully!";
    wait; --make process wait for an infinite timespan
  end process;

  end tb;
