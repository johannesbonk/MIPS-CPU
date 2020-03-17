-- This is the provisionally Data Memory of the RISC-V CPU, used for testing the logic
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

entity DataMemory is
  port (in_ext_to_all  : in ext_to_all_t;
        in_ex_to_dmem  : in ex_to_dmem_t;
        out_dmem_to_ex : out dmem_to_ex_t);
end DataMemory;

architecture behavior of DataMemory is
  type ram_t is array (0 to 63) of std_logic_vector(reglen_t'length - 1 downto 0);
  signal r_data_ram : ram_t := (others => (others => '0'));
  begin
  p_WRITE_PROCESS: process (in_ext_to_all.clk, in_ext_to_all.clr)
  begin
    if (rising_edge(in_ext_to_all.clk)) then
      if (in_ex_to_dmem.memop = c_MEM_WE) then
        r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0)))) <= in_ex_to_dmem.data;
      end if;
    elsif (falling_edge(in_ext_to_all.clr)) then
      r_data_ram <= (others => (others => '0'));
    end if;
   end process;

  out_dmem_to_ex.data <= r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0)))); --asynchronous read
end behavior;
