-- This module describes the forwarding unit of the RISC-V CPU
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

entity ForwardingUnit is
  port(in_de_to_fwd  : in de_to_fwd_t;
       out_fwd_to_de : out fwd_to_de_t);
end entity ForwardingUnit;

architecture logic of ForwardingUnit is
begin
  p_FORWARD_MUX1: process(in_de_to_fwd.exregop, in_de_to_fwd.exrd, in_de_to_fwd.ders1adr, in_de_to_fwd.ders2adr)
  begin
    -- output for muxfwdrs1
    if((in_de_to_fwd.exregop = c_REG_WE) and (to_integer(unsigned(in_de_to_fwd.exrd)) /= 0) and (in_de_to_fwd.exrd = in_de_to_fwd.ders1adr)) then 
        out_fwd_to_de.muxfwdrs1 <= c_MUXFWDRS1_EX; 
    else 
        out_fwd_to_de.muxfwdrs1 <= c_MUXFWDRS1_RS1; 
    end if; 
    -- output for muxfwdrs2
    if((in_de_to_fwd.exregop = c_REG_WE) and (to_integer(unsigned(in_de_to_fwd.exrd)) /= 0) and (in_de_to_fwd.exrd = in_de_to_fwd.ders2adr)) then 
        out_fwd_to_de.muxfwdrs2 <= c_MUXFWDRS2_EX;  
    else 
        out_fwd_to_de.muxfwdrs2 <= c_MUXFWDRS2_RS2; 
    end if;
  end process;  
end logic;
