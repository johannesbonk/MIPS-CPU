-- This module describes the decode stage of the RISC-V CPU
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

entity DECODE is
  generic(g_REGISTER_WIDTH : integer := 32;
          g_ADDRESS_WIDTH : integer := 32;
          g_REGISTER_ADDRESS_WIDTH : integer := 5);
  port(in_clk       : in std_logic; --clock
       in_clr       : in std_logic; --clear
       in_instr     : in std_logic_vector();
       in_pc        : in std_logic_vector();
       in_pc4       : in std_logic_vector()
       out_alucntrl : out alucntrl_t;
       out_muxrs1   : out muxrs1_t;
       out_muxrs2   : out muxrs2_t;
       out_muxalu   : out muxalu_t;
       out_regop    : out regop_t;
       out_memop    : out memop_t
       );
end entity;

architecture behavior of DECODE is
  signal w_opcode    : std_logic_vector( downto 0);
  signal w_func3     : std_logic_vector( downto 0);
  signal w_func7     : std_logic_vector( downto 0);
  signal w_rs1       : std_logic_vector( downto 0);
  signal w_rs2       : std_logic_vector( downto 0);
  signal w_rd        : std_logic_vector( downto 0);
  signal w_immi      : std_logic_vector( downto 0);
  signal w_immsb     : std_logic_vector( downto 0);
  signal w_immuj     : std_logic_vector( downto 0);
  signal w_sgnexti   : std_logic_vector();
  signal w_sgnextsb  : std_logic_vector();
  signal w_zeroextuj : std_logic_vector();

begin
  --EVALUATE OPCODE
  w_opcode <= in_instr(6 downto 0);
  --EVALUUATE FUNCTION
  w_func3 <= in_instr(14 downto 12);
  w_func7 <= in_instr(31 downto 25);
  --EVALUATE SOURCE REGISTERS
  w_rs1 <= in_instr(19 downto 15);
  w_rs2 <= in_instr(24 downto 20);
  --EVALUATE DESTINATION REGISTER / SHIFT AMOUNT
  w_rd <= in_instr(11 downto 7);
  --EVALUATE IMMEDIATES
  w_immi <= in_instr(31 downto 20);
  w_immsb <= in_instr(31 downto 25);
  w_immuj <= in_instr(31 downto 12);

  --SIGN EXTEND I FORMAT
  w_sgnexti <= std_logic_vector(resize(signed(w_immi), g_REGISTER_WIDTH));
  --SIGN EXTEND S FORMAT
  w_sgnextsb <= std_logic_vector(resize(signed(w_imms), g_REGISTER_WIDTH));
  --ZERO EXTEND
  w_zeroextuj <= w_immuj & (others => '0');
end behavior;
