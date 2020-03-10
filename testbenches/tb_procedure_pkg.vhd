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
  procedure checkBranchUnitOut(op_a : std_logic_vector; op_b : std_logic_vector; eq_res : std_logic; lt_res : std_logic; ltu_res : std_logic; eq_expected : std_logic; lt_expected : std_logic; ltu_expected : std_logic);
end package tb_procedure_pkg;

package body tb_procedure_pkg is
  procedure checkBranchUnitOut(op_a : std_logic_vector; op_b : std_logic_vector; eq_res : std_logic; lt_res : std_logic; ltu_res : std_logic; eq_expected : std_logic; lt_expected : std_logic; ltu_expected : std_logic) is
  begin
  assert (eq_res = eq_expected) and (lt_res = lt_expected) and (ltu_res = ltu_expected)
  report "Unexpected result at " &
          "operand a (unsigned): " & integer'image(to_integer(unsigned(op_a))) & "; " &
          "operand b (unsigned): " & integer'image(to_integer(unsigned(op_b))) & "; " &
          "operand a (signed): " & integer'image(to_integer(signed(op_a))) & "; " &
          "operand b (signed): " & integer'image(to_integer(signed(op_b))) & "; " &
          "equal bit expected: " & std_logic'image(eq_expected) & "; " &
          "equal bit result: " & std_logic'image(eq_res) &
          "less than bit expected: " & std_logic'image(lt_expected) & "; " &
          "less than bit result: " & std_logic'image(lt_res) &
          "less than unsigned bit expected: " & std_logic'image(ltu_expected) & "; " &
          "less than unsigned bit result: " & std_logic'image(ltu_res)
  severity error;
  end procedure checkBranchUnitOut;
end package body tb_procedure_pkg;
