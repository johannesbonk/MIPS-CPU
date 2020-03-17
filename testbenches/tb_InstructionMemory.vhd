-- This is the testbench of the provisional Instruction Memory of the RISC-V CPU
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

entity tb_InstructionMemory is
end;

architecture tb of tb_InstructionMemory is
  constant c_T_SET : time := 0.5 ns;

  signal w_fe_to_imem : fe_to_imem_t := (addr => (others => '0'));
  signal w_imem_to_fe : imem_to_fe_t;

  begin
  DUT : entity work.InstructionMemory(behavior)
        port map(in_fe_to_imem => w_fe_to_imem,
                 out_imem_to_fe => w_imem_to_fe);

  p_SIMULATION : process
    begin
      w_fe_to_imem.addr <= (others => '0');
      wait for c_T_SET;
      assert w_imem_to_fe.data = x"00000000" --set initial value to this in InstructionMemory architecture
      report "Unexpected result at " & lf &
              "Address: " & integer'image(to_integer(unsigned(w_fe_to_imem.addr(3 downto 0)))) & "; " & lf &
              "value expected: " & "00000000" & "; " & lf &
              "value read: " & integer'image(to_integer(signed(w_imem_to_fe.data)))
      severity error;

      w_fe_to_imem.addr <= x"0000000f";
      wait for c_T_SET;
      assert w_imem_to_fe.data = x"ffffffff"
      report "Unexpected result at " & lf &
              "Address: " & integer'image(to_integer(unsigned(w_fe_to_imem.addr(3 downto 0)))) & "; " & lf &
              "value expected: " & "ffffffff" & "; " & lf &
              "value read: " & integer'image(to_integer(signed(w_imem_to_fe.data)))
      severity error;

    assert false report "Reached end of test successfully!";
    wait; --make process wait for an infinite timespan
  end process;

  end tb;
