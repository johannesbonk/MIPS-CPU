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
  generic(g_REGISTER_WIDTH : integer);
  port(in_clk    : in std_logic;
       in_rst    : in std_logic;
       in_jump    : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       in_jalr   : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       in_branch : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       in_muxpc  : in muxpc_t;
       in_muxnop : in muxnop_t;

       out_pc    : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       out_pc4   : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       out_instr : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0));
end entity;

architecture behavior of ALU is
  --PC REGISTER
  signal r_pc : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  --INTERNAL WIREING
  signal w_pc4 : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_pcmux : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_memout : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
begin
  --STORE CURRENT PC VALUE IN REGISTER
  p_PROGRAM_COUNTER : process(in_clk, in_rst)
  begin
    if(rising_edge(in_clk)) then
      r_pc <= w_pcmux;
    end if;
    if(falling_edge(in_rst)) then
        r_pc <= (others => '0');
    end if;
  end process;
  --INCREMENT PC VALUE
  w_pc4 <= std_logic_vector(unsigned(r_pc) + 4);
  --SELECT CURRENT PC VALUE
  w_pcmux <= in_pc4 when in_muxpc = "00" else
             in_jump when in_muxpc = "01" else
             in_jalr when in_muxpc = "10" else
             in_branch when in_muxpc = "11";
  --OUTPUT CURRENT PC VALUE AND INCREMENTED PC VALUE
  out_pc <= r_pc;
  out_pc4 <= w_pc4;
  --FETCH NEXT INSTRUCTION FROM MEMORY OR STALL WITH NOP
  out_instr <= w_memout when in_muxnop = '0' else
               (others => '0') when in_muxnop = '1';
end behavior;
