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
          g_ADDRESS_WIDTH : integer := 32;
          g_REGISTER_ADDRESS_WIDTH : integer := 5);
  port(in_clk       : in std_logic; --clock
       in_clr       : in std_logic; --clear
       --ALU OPERANDS
       in_rega      : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --operand a of ALU
       in_shfta     : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --shift operand for ALU input a
       in_regb      : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --operand b of ALU
       in_immb      : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --immediate input for ALU input b
       in_alucntrl  : in std_logic_vector(g_CONTROL_WIDTH - 1 downto 0); --ALU control signals
       --ALU INPUT MULTIPLEXER CONTROL
       in_alushft   : in std_logic; --selects shift count as ALU operand
       in_aluimm    : in std_logic; --selects immediate value as ALU operand
       --PROGRAM COUNTER INCREMENTATION
       in_pc        : in std_logic_vector(g_ADDRESS_WIDTH - 1 downto 0);
       --SELECTS EITHER ALU RESULT OR BRANCH DESTINATION
       in_jal       : in std_logic;
       --TEMPORARY DEST REGISTER
       in_dreg      : in std_logic_vector(g_REGISTER_ADDRESS_WIDTH - 1 downto 0);
       --CONTROL SIGNALS FOR MEMORY ADDRESS AND WRITE BACK STAGE
       in_wrmem     : in std_logic; --write memory
       in_wrreg     : in std_logic; --write register
       in_ldreg     : in std_logic; --load register

       --OUTPUT OF CONTROL SIGNALS FOR MEMORY ADDRESS AND WRITE BACK STAGE
       out_wrmem    : out std_logic; --write memory
       out_wrreg    : out std_logic; --write register
       out_ldreg    : out std_logic; --load register
       --OPERAND OUTPUT
       out_memb     : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --ALU operand b
       out_dreg     : out std_logic_vector(g_REGISTER_ADDRESS_WIDTH - 1 downto 0); --destination register
       out_alures   : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0)); --ALU result (also used for forwarding)
end entity;

architecture behavior of EXECUTE is
  --PIPELINE REGISTER FOR OUTPUT SIGNALS OF INSTRUCTION DECODE PHASE
  signal r_rega     : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal r_shfta    : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal r_regb     : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal r_immb     : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal r_alucntrl : std_logic_vector(g_CONTROL_WIDTH - 1 downto 0);
  signal r_alushft  : std_logic;
  signal r_aluimm   : std_logic;
  signal r_pc       : std_logic_vector(g_ADDRESS_WIDTH - 1 downto 0);
  signal r_jal      : std_logic;
  signal r_dreg     : std_logic_vector(g_REGISTER_ADDRESS_WIDTH - 1 downto 0);
  signal r_wrmem    : std_logic;
  signal r_wrreg    : std_logic;
  signal r_ldreg    : std_logic;

  signal w_aluop_a  : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_aluop_b  : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_alures   : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_pcres    : std_logic_vector(g_ADDRESS_WIDTH - 1 downto 0);

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
      r_rega <= in_rega;
      r_shfta <= in_shfta;
      r_regb <= in_regb;
      r_immb <= in_immb;
      r_alucntrl <= in_alucntrl;
      r_alushft <= in_alushft;
      r_aluimm <= in_aluimm;
      r_pc <= in_pc;
      r_jal <= in_jal;
      r_dreg <= in_dreg;
      r_wrmem <= in_wrmem;
      r_wrreg <= in_wrreg;
      r_ldreg <= in_ldreg;
    end if;
    if(falling_edge(in_clr)) then
      r_rega <= (others => '0');
      r_shfta <= (others => '0');
      r_regb <= (others => '0');
      r_immb <= (others => '0');
      r_alucntrl <= (others => '0');
      r_alushft <= '0';
      r_aluimm <= '0';
      r_pc <= (others => '0');
      r_jal <= '0';
      r_dreg <= (others => '0');
      r_wrmem <= '0';
      r_wrreg <= '0';
      r_ldreg <= '0';
    end if;
  end process;
  --MULTIPLEX ALU OPERAND A
  w_aluop_a <= r_rega when r_alushft = '0' else
               r_shfta when r_alushft = '1';
  --MULTIPLEX ALU OPERAND B
  w_aluop_b <= r_regb when r_aluimm = '0' else
               r_immb when r_aluimm = '1';
  --ALU CONNECTION
  alu1: entity work.ALU(behavior) -- instance of ALU.vhd
  generic map(g_REGISTER_WIDTH => g_REGISTER_WIDTH,
              g_CONTROL_WIDTH => g_CONTROL_WIDTH)
  port map (in_op_a => w_aluop_a,
            in_op_b => w_aluop_b,
            in_cntrl => r_alucntrl,
            out_res => w_alures);
  --GENERATE NEW PROGRAM COUNTER
  w_pcres <= std_logic_vector(unsigned(r_pc) + 4);
  --MULTIPLEX ALU OUTPUT
  out_alures <= w_alures when r_jal = '0' else
                w_pcres when r_jal = '1';
  --SET DESTINATION REGISTER
  out_dreg <= r_dreg when r_jal = '0' else
              (others => '1') when r_jal = '1';
end behavior;
