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
  port(in_clk        : in std_logic; --clock
       in_clr        : in std_logic; --clear
       in_instr      : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       in_pc         : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       in_pc4        : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       in_eq         : in std_logic;
       in_lt         : in std_logic;
       in_ltu        : in std_logic;
       in_fwdalu     : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       in_fwdmem     : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       out_alucntrl  : out alucntrl_t;
       out_muxrs1    : out muxrs1_t;
       out_muxrs2    : out muxrs2_t;
       out_muxalu    : out muxalu_t;
       out_regop     : out regop_t;
       out_memop     : out memop_t;
       out_rs1       : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       out_rs2       : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       out_sgnexti   : out sgnexti_t;
       out_sgnextsb  : out sgnextsb_t;
       out_zeroextuj : out zeroextuj_t;
       out_pc        : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       out_pc4       : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       out_jal       : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       out_branch    : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0)
       );
end entity;

architecture behavior of DECODE is
  --PIPELINE REGISTERS
  signal r_instr     : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal r_pc        : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal r_pc4       : std_logic_vector(g_REGISTER_WIDTH	- 1 downto 0);
  --INTERNAL WIREING
  signal w_opcode    : opcode_t;
  signal w_func3     : func3_t;
  signal w_func7     : func7_t;
  signal w_rs1       : std_logic_vector(g_REGISTER_WIDTH	- 1 downto 0);
  signal w_rs2       : std_logic_vector(g_REGISTER_WIDTH	- 1 downto 0);
  signal w_rd        : std_logic_vector(g_REGISTER_ADDRESS_WIDTH - 1 downto 0);
  signal w_immi      : immi_t;
  signal w_immsb     : immsb_t;
  signal w_immuj     : immuj_t;
  signal w_sgnexti   : sgnexti_t;
  signal w_sgnextsb  : sgnextsb_t;
  signal w_zeroextuj : zeroextuj_t;
  signal w_muxfwdrs1 : std_logic_vector();
  signal w_muxfwdrs2 : std_logic_vector();

  component ControlUnit is
    port(in_opcode  : in opcode_t;
         in_func3   : in func3_t;
         in_func7   : in func7_t;
         out_alucntrl : out alucntrl_t;
         out_muxrs1   : out muxrs1_t;
         out_muxrs2   : out muxrs2_t;
         out_muxalu   : out muxalu_t;
         out_regop    : out regop_t;
         out_memop    : out memop_t);
  end component;

begin
  --PIPELINE REGISTERS FOR OUTPUT SIGNALS OF THE FETCH STAGE
  p_PIPELINE_REGISTER : process(in_clk, in_clr)
  begin
    if(rising_edge(in_clk)) then
      r_instr <= in_instr;
      r_pc <= in_pc;
      r_pc4 <= in_pc4;
    end if;
    if(falling_edge(in_clr)) then
      r_instr <= (others => '0');
      r_pc <= (others => '0');
      r_pc4 <= (others => '0');
  end if;
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
  --REGISTER CONNECTION
  --MULTIPLEXING RS1/RS2 OUT AND FORWARDING
  out_rs1 <=
  --SET CONTROL SIGNALS
  controlunit: entity work.ControlUnit(behavior) -- instance of ControlUnit.vhd
  port map (in_opcode => w_opcode,
            in_func3 => w_func3,
            in_func7 => w_func7,
            out_alucntrl => out_alucntrl,
            out_muxrs1 => out_muxrs1,
            out_muxrs2 => out_muxrs2,
            out_muxalu => out_muxalu,
            out_regop => out_regop,
            out_memop => out_memop);
  --JUMP TARGET DECISION
  out_jal <=
  --BRANCH TARGET DECISION
end behavior;
