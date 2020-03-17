-- This is the provisionally Instruction Memory of the RISC-V CPU, used for testing the logic
-- after finishing the main aspects of the CPU it will be extended to a proper Load/Store Unit with Cache/TLB ...
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

entity InstructionMemory is
  port (in_fe_to_imem  : in fe_to_imem_t;
        out_imem_to_fe : out imem_to_fe_t);
end InstructionMemory;

architecture behavior of InstructionMemory is
  type ram_t is array (0 to 15) of std_logic_vector(reglen_t'length - 1 downto 0);
  signal r_data_ram : ram_t :=
  (x"00000000",
   x"ffffffff",
   x"00000000",
   x"ffffffff",
   x"00000000",
   x"ffffffff",
   x"00000000",
   x"ffffffff",
   x"00000000",
   x"ffffffff",
   x"00000000",
   x"ffffffff",
   x"00000000",
   x"ffffffff",
   x"00000000",
   x"ffffffff");
  begin

  out_imem_to_fe.data <= r_data_ram(to_integer(unsigned(in_fe_to_imem.addr(3 downto 0)))); --asynchronous read
end behavior;
