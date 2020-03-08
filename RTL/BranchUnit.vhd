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

architecture behavior of BranchUnit is
  function or_reduce(vec_in : std_logic_vector) return std_logic is
    variable v_res : std_logic := '0';
    begin
    for i in vec_in'range loop
        v_res := v_res or vec_in(i);
    end loop;
    return v_res;
    end function or_reduce;
begin
  out_bu_to_ex.eq <= '1' when or_reduce(std_logic_vector(unsigned(in_ex_to_bu.rs1) - unsigned(in_ex_to_bu.rs2))) = '0' else
                     '0';
  out_bu_to_ex.lt <= '1' when signed(in_ex_to_bu.rs1) < signed(in_ex_to_bu.rs2) else
                     '0';
  out_bu_to_ex.ltu <= '1' when unsigned(in_ex_to_bu.rs1) < unsigned(in_ex_to_bu.rs2) else
                      '0';
end behavior;
