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

architecture RTL of InstructionMemory is
  type ram_t is array (0 to 31) of std_logic_vector(reglen_t'length - 1 downto 0);
  -- Fibonacci code
  signal r_data_ram : ram_t :=
  (x"00828293", -- addi x5, x5, 8
   x"00230313", -- addi x6, x6, 2
   x"008000ef", -- jal x1, fib
   x"04000463", -- beq x0, x0, end
   -- fib: 
   x"0062d663", -- bge x5, x6, rec 
   x"00028393", -- addi x7, x5, 0
   x"00008067", -- jalr x0, x1, 0
   -- rec:
   x"00c10113", -- addi sp, sp, 12
   x"00112023", -- sw x1, 0(sp)
   x"00512223", -- sw x5, 4(sp)
   x"fff28293", -- addi x5, x5, -1
   x"fe5ff0ef", -- jal x1, FIB
   x"00712423", -- sw x7, 8(sp)
   x"00412283", -- lw x5, 4(sp)
   x"ffe28293", -- addi x5, x5, -2
   x"fd5ff0ef", -- jal x1, FIB 
   x"00812683", -- lw x13, 8(sp)
   x"007683b3", -- add x7, x13, x7
   x"00012083", -- lw x1, 0(sp)
   x"ff410113", -- addi sp, sp, -12
   x"00008067", -- jalr x0, x1, 0
   -- end: 
   x"00000063", -- beq x0, x0, end
   x"ffffffff",
   x"ffffffff",
   x"ffffffff",
   x"ffffffff",
   x"ffffffff",
   x"ffffffff",
   x"ffffffff",
   x"ffffffff",
   x"ffffffff",
   x"ffffffff");
  begin

  out_imem_to_fe.data <= r_data_ram(to_integer(unsigned(in_fe_to_imem.addr(4 downto 0)))); --asynchronous read
end RTL;
