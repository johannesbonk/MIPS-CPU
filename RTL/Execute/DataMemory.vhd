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
  type ram_t is array (0 to 255) of std_logic_vector(7 downto 0);
  signal r_data_ram : ram_t := (others => (others => '0'));
  begin
  p_WRITE_PROCESS: process (in_ext_to_all.clk, in_ext_to_all.clr)
  begin
    if (rising_edge(in_ext_to_all.clk)) then
      if (in_ex_to_dmem.memop = c_MEM_SB) then
        r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0)))) <= in_ex_to_dmem.data(7 downto 0);
      elsif (in_ex_to_dmem.memop = c_MEM_SH) then
        r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0)))) <= in_ex_to_dmem.data(7 downto 0);
        r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0))) + 1) <= in_ex_to_dmem.data(15 downto 8);
      elsif (in_ex_to_dmem.memop = c_MEM_SW) then
        r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0)))) <= in_ex_to_dmem.data(7 downto 0);
        r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0))) + 1) <= in_ex_to_dmem.data(15 downto 8);
        r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0))) + 2) <= in_ex_to_dmem.data(23 downto 16);
        r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0))) + 3) <= in_ex_to_dmem.data(31 downto 24);
      end if;
    elsif (falling_edge(in_ext_to_all.clr)) then
      r_data_ram <= (others => (others => '0'));
    end if;
   end process;

  --asynchronous read
  out_dmem_to_ex.data <= (31 downto 8 => '0') & r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0)))) when in_ex_to_dmem.memop = c_MEM_LB else 
                         (31 downto 16 => '0') & r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0))) + 1) & r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0)))) when in_ex_to_dmem.memop = c_MEM_LH else 
                         r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0))) + 3) & r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0))) + 2) & 
                                                                           r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0))) + 1) & r_data_ram(to_integer(unsigned(in_ex_to_dmem.addr(5 downto 0)))) when in_ex_to_dmem.memop = c_MEM_LW;
end behavior;
