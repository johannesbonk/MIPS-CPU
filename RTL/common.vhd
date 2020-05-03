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

  subtype memop_t is std_logic_vector(3 downto 0); --determines main memory operation
    constant c_MEM_LB  : memop_t := "0000";
    constant c_MEM_LH  : memop_t := "0001";
    constant c_MEM_LW  : memop_t := "0010"; 
    constant c_MEM_LBU : memop_t := "0100"; 
    constant c_MEM_LHU : memop_t := "0101"; 
    constant c_MEM_SB  : memop_t := "1000";
    constant c_MEM_SH  : memop_t := "1001";
    constant c_MEM_SW  : memop_t := "1010"; 
    constant c_MEM_WD  : memop_t := "1111"; 

  subtype alucntrl_t is std_logic_vector(3 downto 0); --determines alu operation
    constant c_ALU_ADD  : alucntrl_t := "0000";
    constant c_ALU_SUB  : alucntrl_t := "1000";
    constant c_ALU_AND  : alucntrl_t := "0111";
    constant c_ALU_OR   : alucntrl_t := "0110";
    constant c_ALU_XOR  : alucntrl_t := "0100";
    constant c_ALU_SLL  : alucntrl_t := "0001";
    constant c_ALU_SLT  : alucntrl_t := "0010";
    constant c_ALU_SLTU : alucntrl_t := "1011";
    constant c_ALU_SRL  : alucntrl_t := "0101";
    constant c_ALU_SRA  : alucntrl_t := "1101";

  subtype muxrs1_t is std_logic_vector(1 downto 0); --selects either register 1 or 0 value
    constant c_MUXRS1_REG   : muxrs1_t := "00";
    constant c_MUXRS1_ZERO  : muxrs1_t := "01";
    constant c_MUXRS1_PC    : muxrs1_t := "10"; 

  subtype muxrs2_t is std_logic; --selects either register or sign/zero extended value
    constant c_MUXRS2_REG   : muxrs2_t := '0'; --also used for shamt
    constant c_MUXRS2_IMM   : muxrs2_t := '1';

   subtype muxalu_t is std_logic_vector(1 downto 0); --selects either alu or memory or pc output
    constant c_MUXALU_ALU       : muxalu_t := "00";
    constant c_MUXALU_MEM       : muxalu_t := "01";
    constant c_MUXALU_PC        : muxalu_t := "10";
    constant c_MUXRALU_INVALID  : muxalu_t := "11";

   subtype muxpc_t is std_logic_vector(1 downto 0); --selects the input value of the program counter
    constant c_MUXPC_PC4    : muxpc_t  := "00";
    constant c_MUXPC_BRANCH : muxpc_t := "01";
    constant c_MUXPC_JAl    : muxpc_t := "10";
    constant c_MUXPC_JALR   : muxpc_t := "11";

   subtype muxnop_t is std_logic; --selects either the current operation or a NOP
    constant c_MUXNOP_OP  : muxnop_t := '0';
    constant c_MUXNOP_NOP : muxnop_t := '1';

   subtype muxfwdrs1_t is std_logic; --selects either the register value or the source to forward
    constant c_MUXFWDRS1_RS1 : muxfwdrs1_t := '0';
    constant c_MUXFWDRS1_EX  : muxfwdrs1_t := '1';

   subtype muxfwdrs2_t is std_logic; --selects either the register value or the source to forward
    constant c_MUXFWDRS2_RS2 : muxfwdrs2_t := '0';
    constant c_MUXFWDRS2_EX  : muxfwdrs2_t := '1';

    subtype branch_t is std_logic_vector(2 downto 0); -- equals all branch types
      constant c_BRANCH_NO   : branch_t := "010"; 
      constant c_BRANCH_BEQ  : branch_t := "000"; 
      constant c_BRANCH_BNE  : branch_t := "001"; 
      constant c_BRANCH_BLT  : branch_t := "100"; 
      constant c_BRANCH_BGE  : branch_t := "101"; 
      constant c_BRANCH_BLTU : branch_t := "110"; 
      constant c_BRANCH_BGEU : branch_t := "111"; 

    subtype stall_t is std_logic; 
      constant c_STALL_YES : stall_t := '1'; 
      constant c_STALL_No  : stall_t := '0'; 

  type ext_to_all_t is record
    clk : std_logic; --clock
    clr : std_logic; --clear
  end record ext_to_all_t;

  type fe_to_imem_t is record
    addr : reglen_t;
  end record fe_to_imem_t;

  type imem_to_fe_t is record
    data : reglen_t;
  end record;

  type fe_to_de_t is record
    pc    : reglen_t; --pc
    pc4   : reglen_t; --pc + 4
    instr : reglen_t; --current instruction
  end record fe_to_de_t;

  type de_to_fe_t is record
    pc4       : reglen_t; --pc + 4
    jaladr    : reglen_t; --new jump address
    jalradr   : reglen_t; --new jump and link address
    branchadr : reglen_t; --current(new or predicted) branch address
    muxpc     : muxpc_t; --multiplexes new pc value
    muxnop    : muxnop_t; --muxes either currrent op or a NOP
  end record de_to_fe_t;

  type de_to_regfile_t is record
    regop  : regop_t; --register operation
    rd     : regadr_t; --write address
    rs1adr : regadr_t; --address of register source 1
    rs2adr : regadr_t; --address of register source 2
    wrin   : reglen_t; --write data input
  end record de_to_regfile_t;

  type regfile_to_de_t is record
    rs1 : reglen_t; --register source output 1
    rs2 : reglen_t; --register source output 2
  end record regfile_to_de_t;

  type de_to_cu_t is record
    opcode   : opcode_t; --opcode of current instruction
    func3    : func3_t; --function 3 block of current instruction
    func7    : func7_t; --function 7 block of current instruction
    exbranch : boolean; --output of execution stage whether the branch is taken or not
  end record de_to_cu_t;

  type cu_to_de_t is record
    alucntrl  : alucntrl_t; --alu control
    regop     : regop_t; --register operation
    memop     : memop_t; --memory operation
    muxrs1    : muxrs1_t; --muxrs1 selection
    muxrs2    : muxrs2_t; --muxrs2 selection
    muxalu    : muxalu_t; --muxalu selection
    muxpc     : muxpc_t; --muxpc selection
    muxnop    : muxnop_t; --muxnop selection
    branch    : branch_t; --type of branch 
    stallfe   : stall_t; --outputs whether to stall the fetch stage or not 
  end record cu_to_de_t;

  type de_to_fwd_t is record
    exregop  : regop_t; 
    exregadr : regadr_t; 
    ders1adr : regadr_t; 
    ders2adr : regadr_t; 
  end record de_to_fwd_t;

  type fwd_to_de_t is record
    muxfwdrs1 : muxfwdrs1_t;
    muxfwdrs2 : muxfwdrs2_t; 
  end record fwd_to_de_t;  

  type de_to_ex_t is record
    -- BRANCH TARGET UNIT OPERANDS
    branch    : branch_t; 
    --ALU OPERANDS
    rs1       : reglen_t; --operand a of ALU
    rs2       : reglen_t; --operand b of ALU
    imm       : reglen_t; 
    --OPERAND MULTIPLEXER
    muxrs1     : muxrs1_t; --mux rs1 selection
    muxrs2     : muxrs2_t; --mux rs2 selection
    muxalu     : muxalu_t; --mux alu selection
    --UNIT CONTROL SIGNALS
    alucntrl  : alucntrl_t; --ALU control signals
    regop     : regop_t; --register operation
    memop     : memop_t; --write memory
    -- DECODER FEEDBACK
    rd        : regadr_t; 
  end record de_to_ex_t;

  type ex_to_de_t is record
    --OPERAND OUTPUT
    res       : reglen_t; 
    regop     : regop_t; --register operation
    rd        : regadr_t; 
    branch    : boolean; 
    branchadr : reglen_t; 
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
  end record ex_to_bu_t;

  type bu_to_ex_t is record
    eq  : std_logic;
    lt  : std_logic;
    ltu : std_logic;
  end record bu_to_ex_t;

  type ex_to_dmem_t is record
    memop : memop_t;
    addr  : reglen_t;
    data  : reglen_t;
  end record ex_to_dmem_t;

  type dmem_to_ex_t is record
    data  : reglen_t;
  end record dmem_to_ex_t;
end package common;
