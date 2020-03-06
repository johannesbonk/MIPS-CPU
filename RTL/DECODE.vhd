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
          g_REGISTER_ADDRESS_WIDTH : integer := 5);
  port(in_ext_to_all  : in ext_to_all_t;
       in_fe_to_de    : in fe_to_de_t;
       in_ex_to_de    : in ex_to_de_t;
       out_de_to_fe   : out de_to_fe_t;
       out_de_to_ex   : out de_to_ex_t);
end entity;

architecture behavior of DECODE is
  --PIPELINE REGISTERS
  signal r_instr     : reglen_t;
  signal r_pc        : reglen_t;
  signal r_pc4       : reglen_t;
  --INTERNAL WIREING
  signal w_opcode    : opcode_t;
  signal w_func3     : func3_t;
  signal w_func7     : func7_t;
  signal w_rs1       : reglen_t;
  signal w_rs2       : reglen_t;
  signal w_rd        : regadr_t;
  signal w_immi      : immi_t;
  signal w_immsb     : immsb_t;
  signal w_immuj     : immuj_t;
  signal w_sgnexti   : sgnexti_t;
  signal w_sgnextsb  : sgnextsb_t;
  signal w_zeroextuj : zeroextuj_t;
  signal w_muxfwdrs1 : std_logic_vector();
  signal w_muxfwdrs2 : std_logic_vector();

  component ControlUnit is
    port();
  end component;

begin
  --PIPELINE REGISTERS FOR OUTPUT SIGNALS OF THE FETCH STAGE
  p_PIPELINE_REGISTER : process(in_ext_to_all.clk, in_ext_to_all.rst)
  begin
    if(rising_edge(in_ext_to_all.clk)) then
      r_instr <= in_fe_to_de.instr;
      r_pc <= in_fe_to_de.pc;
      r_pc4 <= in_fe_to_de.pc4;
    end if;
    if(falling_edge(in_ext_to_all.rst)) then
      r_instr <= (others => '0');
      r_pc <= (others => '0');
      r_pc4 <= (others => '0');
  end if;
  --EVALUATE OPCODE
  w_opcode <= in_fe_to_de.instr(6 downto 0);
  --EVALUUATE FUNCTION
  w_func3 <= in_fe_to_de.instr(14 downto 12);
  w_func7 <= in_fe_to_de.instr(31 downto 25);
  --EVALUATE SOURCE REGISTERS
  w_rs1 <= in_fe_to_de.instr(19 downto 15);
  w_rs2 <= in_fe_to_de.instr(24 downto 20);
  --EVALUATE DESTINATION REGISTER / SHIFT AMOUNT
  w_rd <= in_fe_to_de.instr(11 downto 7);
  --EVALUATE IMMEDIATES
  w_immi <= in_fe_to_de.instr(31 downto 20);
  w_immsb <= in_fe_to_de.instr(31 downto 25);
  w_immuj <= in_fe_to_de.instr(31 downto 12);
  --SIGN EXTEND I FORMAT
  w_sgnexti <= std_logic_vector(resize(signed(w_immi), g_REGISTER_WIDTH));
  --SIGN EXTEND S FORMAT
  w_sgnextsb <= std_logic_vector(resize(signed(w_imms), g_REGISTER_WIDTH));
  --ZERO EXTEND
  w_zeroextuj <= w_immuj & (others => '0');
  --REGISTER CONNECTION
  --MULTIPLEXING RS1/RS2 OUT AND FORWARDING
  out_de_to_ex.rs1 <=
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
