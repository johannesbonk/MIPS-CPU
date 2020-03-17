-- This is the testbench of the provisional Data Memory of the RISC-V CPU
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

entity tb_DataMemory is
end;

architecture tb of tb_DataMemory is
  constant c_T_SET : time := 0.5 ns;
  constant c_T_CLK : time := 0.5 ns;

  signal w_ext_to_all : ext_to_all_t := (clk => '0',
                                         clr => '0');
  signal w_ex_to_dmem : ex_to_dmem_t := (memop => c_MEM_WD,
                                         addr => (others => '0'),
                                         data => (others => '0'));
  signal w_dmem_to_ex : dmem_to_ex_t;

  begin
  DUT : entity work.DataMemory(behavior)
        port map(in_ext_to_all => w_ext_to_all,
                 in_ex_to_dmem => w_ex_to_dmem,
                 out_dmem_to_ex => w_dmem_to_ex);

  p_SIMULATION : process
    begin
      wait for c_T_SET;
      w_ex_to_dmem.memop <= c_MEM_WE;
      w_ex_to_dmem.addr <= x"00000000";
      w_ex_to_dmem.data <= x"11111111";
      wait for c_T_SET;
      w_ext_to_all.clk <= '1';
      wait for c_T_CLK;
      w_ext_to_all.clk <= '0';
      wait for c_T_CLK;

      w_ex_to_dmem.memop <= c_MEM_WE;
      w_ex_to_dmem.addr <= x"0000003f";
      w_ex_to_dmem.data <= x"c3c3c3c3";
      wait for c_T_SET;
      w_ext_to_all.clk <= '1';
      wait for c_T_CLK;
      w_ext_to_all.clk <= '0';
      wait for c_T_CLK;

      w_ex_to_dmem.addr <= (others => '0');
      wait for c_T_SET;
      assert w_dmem_to_ex.data = x"11111111"
      report "Unexpected result at " & lf &
              "Address: " & integer'image(to_integer(unsigned(w_ex_to_dmem.addr(5 downto 0)))) & "; " & lf &
              "value expected: " & "11111111" & "; " & lf &
              "value read: " & integer'image(to_integer(signed(w_dmem_to_ex.data)))
      severity error;

      w_ex_to_dmem.addr <= x"0000003f";
      wait for c_T_SET;
      assert w_dmem_to_ex.data = x"c3c3c3c3"
      report "Unexpected result at " & lf &
              "Address: " & integer'image(to_integer(unsigned(w_ex_to_dmem.addr(5 downto 0)))) & "; " & lf &
              "value expected: " & "c3c3c3c3" & "; " & lf &
              "value read: " & integer'image(to_integer(signed(w_dmem_to_ex.data)))
      severity error;

    assert false report "Reached end of test successfully!";
    wait; --make process wait for an infinite timespan
  end process;

  end tb;
