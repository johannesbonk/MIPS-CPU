-- This module determines the next program counter if a branch occurs, dependent on the result of the BranchUnit
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

entity BranchTargetUnit is
  port(in_ext_to_all  : in ext_to_all _t;
       in_de_to_btu   : in de_to_btu_t;
       out_btu_to_de  : out btu_to_de_t);
end BranchTargetUnit;


architecture behavior of BranchTargetUnit is
  signal w_wq : std_logic; 
  signal w_lt : std_logic; 
  signal w_ltu : std_logic; 
  signal w_pcbranch : reglen_t;
  signal w_pcnobranch : reglen_t;
begin
  -- compute branch outcome
  w_eq <= '1' when in_de_to_btu.rs1 = in_de_to_btu.rs2 else
          '0';
  w_lt <= '1' when signed(in_de_to_btu.rs1) < signed(in_de_to_btu.rs2) else
          '0';
  w_ltu <= '1' when unsigned(in_de_to_btu.rs1) < unsigned(in_de_to_btu.rs2) else
           '0';
  -- compute branch address
  w_pcbranch <= std_logic_vector(unsigned(in_de_to_btu.pc) + unsigned(in_de_to_btu.displace));
  w_pcnobranch <= in_de_to_btu.pc4;

  p_SET_NOP: process(in_ext_to_all.clk) is
    if(in_de_to_btu.opcode = b"11000") then
      out_btu_to_de.muxnop <= c_MUXNOP_NOP;
    else
      out_btu_to_de.muxnop <= c_MUXNOP_OP;
    end if;
  end process;
  p_SET_PC: process(in_de_to_btu.eq, in_de_to_btu.lt, in_de_to_btu.ltu) is
    if((in_de_to_btu.eq or in_de_to_btu.lt or in_de_to_btu.ltu) = '1') then
      out_btu_to_de.pcnext <= w_pcbranch;
    else
      out_btu_to_de.pcnext <= w_pcnobranch;
    end if;
  end process;
end behavior;
