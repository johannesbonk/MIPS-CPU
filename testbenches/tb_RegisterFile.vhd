-- This is the testbench of the Register File of the RISC-V CPU 
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

entity tb_RegisterFile is
end;

architecture tb of tb_RegisterFile is
  constant c_DELTA_TIME : time := 1 ns;

  signal w_ext_to_all    : ext_to_all_t := (clk => '0', 
                                            clr => '0'); 
  signal w_de_to_regfile : de_to_regfile_t := (regop => c_REG_WE,
                                               rd => b"00000",
                                               rs1adr => b"00000",
                                               rs2adr => b"00001", 
                                               wrin => x"ff_ff_ff_ff");
  signal w_regfile_to_de : regfile_to_de_t;

  begin
  DUT : entity work.RegisterFile(RTL)
        port map(in_ext_to_all => w_ext_to_all,
                 in_de_to_regfile => w_de_to_regfile,
                 out_regfile_to_de => w_regfile_to_de);

  p_SIMULATION : process
    begin
      wait for c_DELTA_TIME; 
        -- TEST WRITE TO HARDWIRED ZERO REGISTER 
        w_de_to_regfile.regop <= c_REG_WE; 
        w_de_to_regfile.rd <= b"00000"; 
        w_de_to_regfile.rs1adr <= b"00000"; 
        w_de_to_regfile.rs2adr <= b"00001"; 
        w_de_to_regfile.wrin <= x"ff_ff_ff_ff"; 
        wait for c_DELTA_TIME; 

        w_ext_to_all.clk <= '1'; 
        wait for c_DELTA_TIME; 
        w_ext_to_all.clk <= '0'; 

        -- TEST WRITE TO REGISTER 
        w_de_to_regfile.regop <= c_REG_WE; 
        w_de_to_regfile.rd <= b"11111"; 
        w_de_to_regfile.rs1adr <= b"11111"; 
        w_de_to_regfile.rs2adr <= b"00000"; 
        w_de_to_regfile.wrin <=  x"ff_ff_ff_ff"; 
        wait for c_DELTA_TIME; 

        w_ext_to_all.clk <= '1'; 
        wait for c_DELTA_TIME; 
        w_ext_to_all.clk <= '0'; 

        -- TEST WRITE DISABLED
        w_de_to_regfile.regop <= c_REG_WD; 
        w_de_to_regfile.rd <= b"11111"; 
        w_de_to_regfile.rs1adr <= b"11111"; 
        w_de_to_regfile.rs2adr <= b"00000"; 
        w_de_to_regfile.wrin <= x"00_ff_ff_ee"; 
        wait for c_DELTA_TIME; 

        w_ext_to_all.clk <= '1'; 
        wait for c_DELTA_TIME; 
        w_ext_to_all.clk <= '0'; 

        -- TEST CLEAR (triggered on falling edge)
        w_ext_to_all.clr <= '1'; 
        w_de_to_regfile.rs1adr <= b"11111"; 
        wait for c_DELTA_TIME; 
        w_ext_to_all.clr <= '0'; 
        wait for c_DELTA_TIME; 

    wait; --make process wait for an infinite timespan
  end process;

  end tb;
