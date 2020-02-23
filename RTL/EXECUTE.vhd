-- This module describes the execution stage of the MIPS CPU
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
  port(--ALU OPERANDS
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
       out_alures   : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0)); --ALU result (also used for formwarding)
end;

architecture behavior of EXECUTE is
  signal w_aluop_a : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_aluop_b : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_alures  : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_zflag   : std_logic;
  signal w_pcres   : std_logic_vector(g_ADDRESS_WIDTH - 1 downto 0);

  component ALU is
    port(in_op_a, in_op_b, in_cntrl : in std_logic;
         out_zflag, out_res : out std_logic);
  end component;

begin
  --MULTIPLEX ALU OPERAND A
  w_aluop_a <= in_rega when in_alushft = '0' else
               in_shfta when in_alushft = '1';
  --MULTIPLEX ALU OPERAND B
  w_aluop_b <= in_regb when in_aluimm = '0' else
               in_immb when in_aluimm = '1';
  --ALU CONNECTION
  alu1: entity work.ALU(behavior) -- instance of ALU.vhd
  generic map(g_REGISTER_WIDTH => g_REGISTER_WIDTH,
              g_CONTROL_WIDTH => g_CONTROL_WIDTH)
  port map (in_op_a => w_aluop_a,
            in_op_b => w_aluop_b,
            in_cntrl => in_alucntrl,
            out_zflag => w_zflag,
            out_res => w_alures);
  --GENERATE NEW PROGRAM COUNTER
  w_pcres <= std_logic_vector(unsigned(in_pc) + 4);
  --MULTIPLEX ALU OUTPUT
  out_alures <= w_alures when in_jal = '0' else
                w_pcres when in_jal = '1';
  --SET DESTINATION REGISTER
  out_dreg <= in_dreg when in_jal = '0' else
              (others => '1') when in_jal = '1';
  --CONTROL SIGNAL PASS THROUGH
  out_wrmem <= in_wrmem;
  out_wrreg <= in_wrreg;
  out_ldreg <= in_ldreg;
  --VALUE PASS THROUGH
  out_memb <= in_regb;
end behavior;
