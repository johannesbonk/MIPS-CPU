-- This package contains all the procedures needed for the testbenches
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

package tb_procedure_pkg is
  procedure checkBranchUnitOut(op_a : std_logic_vector; op_b : std_logic_vector; branch : std_logic_vector; branch_res : boolean; branch_expected : boolean);
  procedure checkALUOut(op_a : std_logic_vector; op_b : std_logic_vector; cntrl : std_logic_vector; res : std_logic_vector; res_expected : std_logic_vector);
end package tb_procedure_pkg;

package body tb_procedure_pkg is
  procedure checkBranchUnitOut(op_a : std_logic_vector; op_b : std_logic_vector; branch : std_logic_vector; branch_res : boolean; branch_expected : boolean) is
  begin
  assert (branch_res = branch_expected)
  report "Unexpected result at " & lf &
          "operand a (unsigned): " & integer'image(to_integer(unsigned(op_a))) & "; " & lf &
          "operand b (unsigned): " & integer'image(to_integer(unsigned(op_b))) & "; " & lf &
          "operand a (signed): " & integer'image(to_integer(signed(op_a))) & "; " & lf &
          "operand b (signed): " & integer'image(to_integer(signed(op_b))) & "; " & lf &
          "branch type: " & integer'image(to_integer(unsigned(branch))) & "; " & lf &
          "branch result: " & boolean'image(branch_res) & lf &
          "branch expected: " & boolean'image(branch_expected)
  severity error;
  end procedure checkBranchUnitOut;

  procedure checkALUOut(op_a : std_logic_vector; op_b : std_logic_vector; cntrl : std_logic_vector; res : std_logic_vector; res_expected : std_logic_vector) is
  begin
  assert res = res_expected
  report "Unexpected result at " & lf &
          "operand a (unsigned): " & integer'image(to_integer(unsigned(op_a))) & "; " & lf &
          "operand b (unsigned): " & integer'image(to_integer(unsigned(op_b))) & "; " & lf &
          "operand a (signed): " & integer'image(to_integer(signed(op_a))) & "; " & lf &
          "operand b (signed): " & integer'image(to_integer(signed(op_b))) & "; " & lf &
          "control signal: " & integer'image(to_integer(unsigned(cntrl))) & "; " & lf &
          "result expected (unsigned): " & integer'image(to_integer(unsigned(res_expected))) & lf &
          "result (unsigned): " & integer'image(to_integer(unsigned(res)))
  severity error;
end procedure checkALUOut;
end package body tb_procedure_pkg;
