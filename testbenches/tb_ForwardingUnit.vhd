-- This is the testbench of the Forwaring Unit of the RISC-V CPU 
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

entity tb_ForwardingUnit is
end;

architecture tb of tb_ForwardingUnit is
  constant c_DELTA_TIME : time := 1 ns;

  signal w_de_to_fwd : de_to_fwd_t := (exregop => c_REG_WE,
                                       exrd => b"00000",
                                       ders1adr => b"00000",
                                       ders2adr => b"00000");
  signal w_fwd_to_de : fwd_to_de_t;

  begin
  DUT : entity work.ForwardingUnit(logic)
        port map(in_de_to_fwd => w_de_to_fwd,
                 out_fwd_to_de => w_fwd_to_de);

  p_SIMULATION : process
    begin
      -- EXPECTED: NO FORWARDING, SINCE EXECUTION STAGE REGISTER DESTINATION IS HARDWIRED ZERO REGISTER 
      wait for c_DELTA_TIME; 

    -- TEST FORWARD RS1
      -- EXPECTED: NO FORWARDING, SINCE REGOP IS WRITE DISABLED 
      w_de_to_fwd.exregop <= c_REG_WD; 
      w_de_to_fwd.exrd <= b"00001"; 
      w_de_to_fwd.ders1adr <= b"00001"; 
      w_de_to_fwd.ders2adr <= b"10000"; 
      wait for c_DELTA_TIME; 
      -- EXPECTED: NO FORWARDING, SINCE EXECUTION STAGE DESTINATION IS NOT READ ADRESS
      w_de_to_fwd.exregop <= c_REG_WE; 
      w_de_to_fwd.exrd <= b"00001"; 
      w_de_to_fwd.ders1adr <= b"00010"; 
      w_de_to_fwd.ders2adr <= b"10000"; 
      wait for c_DELTA_TIME; 
      -- EXPECTED: FORWARDING, IF NONE OF THE CONDITIONS MENTIONED ABOVE APPLY
      w_de_to_fwd.exregop <= c_REG_WE; 
      w_de_to_fwd.exrd <= b"00001"; 
      w_de_to_fwd.ders1adr <= b"00001"; 
      w_de_to_fwd.ders2adr <= b"10000"; 
      wait for c_DELTA_TIME; 
   
    -- TEST FORWARD RS2
      -- EXPECTED: NO FORWARDING, SINCE REGOP IS WRITE DISABLED 
      w_de_to_fwd.exregop <= c_REG_WD; 
      w_de_to_fwd.exrd <= b"00001"; 
      w_de_to_fwd.ders1adr <= b"10000"; 
      w_de_to_fwd.ders2adr <= b"00001"; 
      wait for c_DELTA_TIME; 
      -- EXPECTED: NO FORWARDING, SINCE EXECUTION STAGE DESTINATION IS NOT READ ADRESS
      w_de_to_fwd.exregop <= c_REG_WE; 
      w_de_to_fwd.exrd <= b"00001"; 
      w_de_to_fwd.ders1adr <= b"10000"; 
      w_de_to_fwd.ders2adr <= b"00010"; 
      wait for c_DELTA_TIME; 
      -- EXPECTED: FORWARDING, IF NONE OF THE CONDITIONS MENTIONED ABOVE APPLY
      w_de_to_fwd.exregop <= c_REG_WE; 
      w_de_to_fwd.exrd <= b"00001"; 
      w_de_to_fwd.ders1adr <= b"10000"; 
      w_de_to_fwd.ders2adr <= b"00001"; 
      wait for c_DELTA_TIME; 
    wait; --make process wait for an infinite timespan
  end process;

  end tb;
