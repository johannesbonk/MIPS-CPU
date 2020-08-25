-- This is the fetch stage of the RISC-V CPU
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

entity FETCH is
  port(in_ext_to_all  : in ext_to_all_t;
       in_de_to_fe    : in de_to_fe_t;
       in_ex_to_fe    : in ex_to_fe_t; 
       in_imem_to_fe  : in imem_to_fe_t; 
       out_fe_to_de   : out fe_to_de_t;
       out_fe_to_imem : out fe_to_imem_t);
end entity;

architecture RTL of FETCH is
  --PC REGISTER
  signal r_pc : reglen_t;
  --INTERNAL WIREING
  signal w_pc4 : reglen_t;
  signal w_pcmux : reglen_t;
begin
  --STORE CURRENT PC VALUE IN REGISTER
  p_PROGRAM_COUNTER : process(in_ext_to_all.clk, in_ext_to_all.clr, in_de_to_fe.stall)
  begin
    if(in_de_to_fe.stall = c_STALL_NO) then 
      if(rising_edge(in_ext_to_all.clk)) then
        if(in_ext_to_all.clr = '1') then 
            r_pc <= (others => '0');
        else 
            r_pc <= w_pcmux;
        end if; 
      end if;
    end if; 
  end process;
  --INCREMENT PC VALUE
  w_pc4 <= std_logic_vector(unsigned(r_pc) + 4);
  
  --SELECT CURRENT PC VALUE
  p_MUX_PC: process(in_de_to_fe.muxpc, w_pc4, in_de_to_fe.jaladr, in_de_to_fe.jalradr, in_ex_to_fe.branchadr, in_ex_to_fe.branchadr)
  begin 
    if(in_de_to_fe.muxpc = c_MUXPC_PC4) then 
        w_pcmux <= w_pc4;
    else 
        if(in_de_to_fe.muxpc = c_MUXPC_JAL) then 
            w_pcmux <= in_de_to_fe.jaladr;
        elsif(in_de_to_fe.muxpc = c_MUXPC_JALR) then 
            w_pcmux <= in_de_to_fe.jalradr;
        else 
            w_pcmux <= in_ex_to_fe.branchadr;
        end if; 
    end if; 
  end process; 
  
  w_pcmux <= w_pc4 when in_de_to_fe.muxpc = c_MUXPC_PC4 else
             in_de_to_fe.jaladr when in_de_to_fe.muxpc = c_MUXPC_JAL else
             in_de_to_fe.jalradr when in_de_to_fe.muxpc = c_MUXPC_JALR else
             in_ex_to_fe.branchadr; -- when in_ex_to_fe.muxpc = c_MUXPC_BRANCH
  --OUTPUT CURRENT PC VALUE AND INCREMENTED PC VALUE
  out_fe_to_de.pc <= r_pc;
  out_fe_to_de.pc4 <= w_pc4;
  --FETCH NEXT INSTRUCTION FROM MEMORY OR OUTPUT NOP
  out_fe_to_de.instr <= in_imem_to_fe.data when in_de_to_fe.muxnop = '0' else
                        x"00000013"; -- when in_de_to_fe.muxnop = '1' -- NOP == addi x0, x0, 0                     
  ----------------------------------------------------
  --|           ASSIGN OUTPUTS (external)            |
  ----------------------------------------------------    
  out_fe_to_imem.addr <= r_pc; 
end RTL;
