-- This module describes the execution stage of the RISC-V CPU
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

entity EXECUTE is
  generic(g_REGISTER_WIDTH : integer := 32;
          g_CONTROL_WIDTH : integer := 4;
          g_REGISTER_ADDRESS_WIDTH : integer := 5);
  port(in_ext_to_all  : in ext_to_all_t;
       in_de_to_ex    : in de_to_ex_t;
       out_ex_to_de   : out ex_to_de_t);
end entity;

architecture behavior of EXECUTE is
  --PIPELINE REGISTER FOR OUTPUT SIGNALS OF INSTRUCTION DECODE PHASE
  signal r_rs1      : reglen_t;
  signal r_shfta    : reglen_t;
  signal r_rs2      : reglen_t;
  signal r_sgnexti  : sgnexti_t;
  signal r_sgnextsb : sgnextsb_t;
  signal r_zeroextuj : zeroextuj_t;
  signal r_muxrs1   : muxrs1_t;
  signal r_muxrs2   : muxrs2_t;
  signal r_muxalu   : muxalu_t;
  signal r_muxzero  : muxzero_t;
  signal r_alucntrl : alucntrl_t;
  signal r_regop    : regop_t;
  signal r_memop    : memop_t;

  signal w_muxbout  : reglen_t;
  signal w_aluop_a  : reglen_t;
  signal w_aluop_b  : reglen_t;
  signal w_alures   : reglen_t;
  signal w_memout   : reglen_t;

  component BranchUnit is
    port(in_reg_a, in_reg_b : in std_logic;
         out_eq, out_lt, out_ltu : out std_logic);
  end component;

  component ALU is
    port(in_op_a, in_op_b, in_cntrl : in std_logic;
         out_res : out std_logic);
  end component;

begin
  --LOAD PIPELINE REGISTER
  p_PIPELINE_REGISTER: process(in_clk)
  begin
    if(rising_edge(in_clk)) then
      r_rs1 <= in_rs1;
      r_shfta <= in_shfta;
      r_rs2 <= in_rs2;
      r_sgnexti  <= in_sgnexti;
      r_sgnextsb <= in_sgnextsb;
      r_zeroextuj <= in_zeroextuj;
      r_muxrs1 <= in_muxrs1;
      r_muxrs2 <= in_muxrs2;
      r_muxalu <= in_muxalu;
      r_muxzero in_muxzero;
      r_alucntrl <= in_alucntrl;
      r_regop <= in_regop;
      r_memop <= in_memop;
    end if;
    if(falling_edge(in_clr)) then
      r_rs1 <= (others => '0');
      r_shfta <= (others => '0');
      r_rs2 <= (others => '0');
      r_sgnexti  <= (others => '0');
      r_sgnextsb <= (others => '0');
      r_zeroextuj <= (others => '0');
      r_muxrs1 <= '0';
      r_muxrs2 <= (others => '0');
      r_muxalu <= (others => '0');
      r_muxzero <= '0';
      r_alucntrl <= (others => '0');
      r_regop <= (others => '0');
      r_memop <= (others => '0');
    end if;
  end process;
  --MULTIPLEX ALU OPERAND A
   w_aluop_a <= r_rs1 when r_muxrs1 = '0' else
                r_shfta when r_muxrs1 = '1';
  --MULTIPLEX ALU OPERAND B
   w_muxbout <= r_rs2 when r_muxrs2 = "00" else
                r_sgnexti when r_muxrs2 = "01" else
                r_sgnextsb when r_muxrs2 = "10" else
                r_zeroextuj when r_muxrs2 = "11";
   w_aluop_b <= w_muxbout when  r_muxzero = '0' else
                (others => '0') when r_muxzero = '1';
  --ALU CONNECTION
  alu1: entity work.ALU(behavior) -- instance of ALU.vhd
  generic map(g_REGISTER_WIDTH => g_REGISTER_WIDTH,
              g_CONTROL_WIDTH => g_CONTROL_WIDTH)
  port map (in_op_a => w_aluop_a,
            in_op_b => w_aluop_b,
            in_cntrl => r_alucntrl,
            out_res => w_alures);
  --MULTIPLEX ALU OUTPUT
  out_alures <= w_alures;
  --SET DESTINATION REGISTER
  out_toreg <= w_alures when r_muxalu = "00" else
              w_memout when r_muxalu = "01" else
              r_pc4 when r_muxalu = "10";
end behavior;
