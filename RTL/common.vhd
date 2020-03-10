-- This module describes the common module
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

package common is
  subtype reglen_t is std_logic_vector(31 downto 0); --defines cpu bus width
  subtype regadr_t is std_logic_vector(4 downto 0); --defines address with of register file
  subtype opcode_t is std_logic_vector(6 downto 0); --opcode width
  subtype func3_t is std_logic_vector(2 downto 0); --funtion3 block width
  subtype func7_t is std_logic_vector(6 downto 0); --function7 block width

  subtype regop_t is std_logic; --determines register operation
    constant c_REG_WD : regop_t := '0';
    constant c_REG_WE : regop_t := '1';

  subtype memop_t is std_logic; --determines main memory operation
    constant c_MEM_WD : memop_t := '0';
    constant c_MEM_WE : memop_t := '1';

  subtype alucntrl_t is std_logic_vector(3 downto 0); --determines alu operation
    constant c_ALU_ADD  : alucntrl_t := "0000";
    constant c_ALU_SUB  : alucntrl_t := "1000";
    constant c_ALU_AND  : alucntrl_t := "0111";
    constant c_ALU_OR   : alucntrl_t := "0110";
    constant c_ALU_XOR  : alucntrl_t := "0100";
    constant c_ALU_LUI  : alucntrl_t := "1100";
    constant c_ALU_SLL  : alucntrl_t := "0001";
    constant c_ALU_SLT  : alucntrl_t := "0010";
    constant c_ALU_SLTU : alucntrl_t := "1011";
    constant c_ALU_SRL  : alucntrl_t := "0101";
    constant c_ALU_SRA  : alucntrl_t := "1101";

  subtype muxshamt_t is std_logic; --selects either register source 2 or shift amount
    constant c_MUXSHAMT_RS2   : muxshamt_t := '0';
    constant c_MUXSHAMT_SHAMT : muxshamt_t := '1';

  subtype muxrs1_t is std_logic; --selects either register 1 or 0 value
    constant c_MUXRS1_REG   : muxrs1_t := '0';
    constant c_MUXRS1_ZERO  : muxrs1_t := '1';

  subtype muxrs2_t is std_logic_vector(1 downto 0); --selects either register or sign/zero extended value
    constant c_MUXRS2_REG   : muxrs2_t := "00"; --also used for shamt
    constant c_MUXRS2_EXI   : muxrs2_t := "01";
    constant c_MUXRS2_EXSB  : muxrs2_t := "10";
    constant c_MUXRS2_ZEXUI : muxrs2_t := "11";

   subtype muxalu_t is std_logic_vector(1 downto 0); --selects either alu or memory or pc output
    constant c_MUXALU_ALU       : muxalu_t := "00";
    constant c_MUXALU_MEM       : muxalu_t := "01";
    constant c_MUXALU_PC        : muxalu_t := "10";
    constant c_MUXRALU_INVALID  : muxalu_t := "11";

   subtype muxpc_t is std_logic_vector(1 downto 0); --selects the input value of the program counter
    constant c_MUXPC_PC4    : muxpc_t  := "00";
    constant c_MUXPC_BRANCH : muxpc_t := "01";
    constant c_MUXPC_JMP    : muxpc_t := "10";
    constant c_MUXPC_JALR   : muxpc_t := "11";

   subtype muxnop_t is std_logic; --selects either the current operation or a NOP
    constant c_MUXNOP_OP  : muxnop_t := '0';
    constant c_MUXNOP_NOP : muxnop_t := '1';

   --subtype muxfwdrs1_t is std_logic_vector(); --selects either the register value or the source to forward
    --constant c_MUXFWDRS1_RS1 : muxfwdrs1_t := '0';
    --constant c_MUXFWDRS1_ALU : muxfwdrs1_t := '1';

   --subtype muxfwdrs2_t is std_logic_vector(); --selects either the register value or the source to forward
    --constant c_MUXFWDRS2_RS2 : muxfwdrs2_t := '0';
    --constant c_MUXFWDRS2_ALU : muxfwdrs2_t := '1';

  type ext_to_all_t is record
    clk : std_logic; --clock
    clr : std_logic; --clear
  end record ext_to_all_t;

  type fe_to_de_t is record
    pc    : reglen_t; --pc
    pc4   : reglen_t; --pc + 4
    instr : reglen_t; --current instruction
  end record fe_to_de_t;

  type de_to_fe_t is record
    pc4    : reglen_t; --pc + 4
    jump   : reglen_t; --new jump address
    jalr   : reglen_t; --new jump and link address
    branch : reglen_t; --current(new or predicted) branch address
    muxpc  : muxpc_t; --multiplexes new pc value
    muxnop : muxnop_t; --muxes either currrent op or a NOP
  end record de_to_fe_t;

  type de_to_regfile_t is record
    regop  : regop_t; --register operation
    wradr  : regadr_t; --write address
    rs1adr : regadr_t; --address of register source 1
    rs2adr : regadr_t; --address of register source 2
    wrin   : reglen_t; --write data input
  end record de_to_regfile_t;

  type regfile_to_de_t is record
    rs1 : reglen_t; --register source output 1
    rs2 : reglen_t; --register source output 2
  end record regfile_to_de_t;

  type de_to_cu_t is record
    opcode  : opcode_t; --opcode of current instruction
    func3   : func3_t; --function 3 block of current instruction
    func7   : func7_t; --function 7 block of current instruction
  end record de_to_cu_t;

  type cu_to_de_t is record
    alucntrl : alucntrl_t; --alu control
    regop    : regop_t; --register operation
    memop    : memop_t; --memory operation
    muxshamt : muxshamt_t; --multiplexes shift amount
    muxrs1   : muxrs1_t; --muxrs1 selection
    muxrs2   : muxrs2_t; --muxrs2 selection
    muxalu   : muxalu_t; --muxalu selection
    muxpc    : muxpc_t; --muxpc selection
    muxnop   : muxnop_t; --muxnop selection
  end record cu_to_de_t;

  type de_to_btu_t is record
    pc       : reglen_t;
    pc4      : reglen_t;
    eq       : std_logic;
    lt       : std_logic;
    ltu      : std_logic;
    opcode   : opcode_t;
    displace : reglen_t;
  end record de_to_btu_t;

  type btu_to_de_t is record
    pcnext : reglen_t;
    muxnop : muxnop_t;
  end record btu_to_de_t;

  type de_to_ex_t is record
    --ALU OPERANDS
    rs1       : reglen_t; --operand a of ALU
    rs2       : reglen_t; --operand b of ALU
    sgnexti   : reglen_t; --sign extend of i instruction format
    sgnextsb  : reglen_t; --sign extend of s/b instruction format
    zeroextuj : reglen_t; --zero extend of u/j instruction format
    --OPERAND MULTIPLEXER
    muxrs1     : muxrs1_t; --mux rs1 selection
    muxrs2     : muxrs2_t; --mux rs2 selection
    muxalu     : muxalu_t; --mux alu selection
    --UNIT CONTROL SIGNALS
    alucntrl  : alucntrl_t; --ALU control signals
    regop     : regop_t; --register operation
    memop     : memop_t; --write memory
  end record de_to_ex_t;

  type ex_to_de_t is record
    --OPERAND OUTPUT
    regop    : regop_t; --register operation
    alures   : reglen_t; --ALU result, pc result or memory read (used for forwarding)
    eq       : std_logic;
    lt       : std_logic;
    ltu      : std_logic;
  end record ex_to_de_t;

  type ex_to_alu_t is record
    op_a  : reglen_t; --alu operand a (rs1)
    op_b  : reglen_t; --alu operand b (rs2)
    cntrl : alucntrl_t; --alu control
  end record ex_to_alu_t;

  type alu_to_ex_t is record
    res : reglen_t; --gives current alu result value
  end record alu_to_ex_t;

  type ex_to_bu_t is record
    op_a : reglen_t;
    op_b : reglen_t;
  end record;

  type bu_to_ex_t is record
    eq  : std_logic;
    lt  : std_logic;
    ltu : std_logic;
  end record;
end package common;
