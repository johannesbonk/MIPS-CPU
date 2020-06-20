-- This module describes the core of the RISC-V CPU
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

entity core is
  port(in_clk : in std_logic; 
       in_clr : in std_logic);
end entity core;

architecture RTL of core is
    signal w_ext_to_all : ext_to_all_t; 
    signal w_fe_to_de : fe_to_de_t; 
    signal w_de_to_fe : de_to_fe_t; 
    signal w_de_to_ex : de_to_ex_t; 
    signal w_ex_to_de : ex_to_de_t; 
    signal w_ex_to_fe : ex_to_fe_t; 
begin
    w_ext_to_all.clk <= in_clk; 
    w_ext_to_all.clr <= in_clr; 
    
    fetch_stage: entity work.FETCH(RTL) -- instance of FETCH.vhd
    port map (in_ext_to_all => w_ext_to_all,
              in_de_to_fe => w_de_to_fe, 
              in_ex_to_fe => w_ex_to_fe,
              out_fe_to_de => w_fe_to_de); 

    decode_stage: entity work.DECODE(RTL) -- instance of DECODE.vhd
    port map (in_ext_to_all => w_ext_to_all,
              in_fe_to_de => w_fe_to_de,
              in_ex_to_de => w_ex_to_de,
              out_de_to_fe => w_de_to_fe,
              out_de_to_ex => w_de_to_ex); 

    execute_stage: entity work.EXECUTE(RTL) -- instance of EXECUTE.vhd
    port map (in_ext_to_all => w_ext_to_all,
              in_de_to_ex => w_de_to_ex,
              out_ex_to_de => w_ex_to_de
              out_ex_to_fe => w_ex_to_fe); 
end RTL;
