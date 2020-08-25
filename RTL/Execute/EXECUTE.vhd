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

USE work.common.ALL; 

entity EXECUTE is
  port(in_ext_to_all  : in ext_to_all_t;
       in_de_to_ex    : in de_to_ex_t;
       in_dmem_to_ex  : in dmem_to_ex_t; 
       out_ex_to_dmem : out ex_to_dmem_t;
       out_ex_to_de   : out ex_to_de_t;
       out_ex_to_fe   : out ex_to_fe_t);
end entity;

architecture RTL of EXECUTE is
  --PIPELINE REGISTER FOR OUTPUT SIGNALS OF INSTRUCTION DECODE PHASE
  signal r_rs1       : reglen_t; 
  signal r_rs2       : reglen_t; 
  signal r_imm       : reglen_t; 
  signal r_rd        : regadr_t; 
  signal r_muxrs1    : muxrs1_t; 
  signal r_muxrs2    : muxrs2_t; 
  signal r_muxalu    : muxalu_t; 
  signal r_alucntrl  : alucntrl_t; 
  signal r_regop     : regop_t; 
  signal r_memop     : memop_t;  
  signal r_branch    : branch_t; 
  signal r_pc        : reglen_t; 
  signal r_pc4       : reglen_t; 
  signal r_branchadr : reglen_t; 

  signal w_muxbout  : reglen_t;
  signal w_aluop_a  : reglen_t;
  signal w_aluop_b  : reglen_t;
  signal w_alures   : reglen_t;
  signal w_branch   : boolean; 

  component ALU is
    port(in_ex_to_alu  : in ex_to_alu_t;
         out_alu_to_ex : out alu_to_ex_t);
  end component ALU;

  component BranchUnit is
    port(in_ex_to_bu  : in ex_to_bu_t;
         out_bu_to_ex : out bu_to_ex_t);
  end component BranchUnit;

begin
  --LOAD PIPELINE REGISTER
  p_PIPELINE_REGISTER: process(in_ext_to_all.clk)
  begin
    if(rising_edge(in_ext_to_all.clk)) then
      if(in_ext_to_all.clr = '1') then 
          r_rs1 <= (others => '0');
          r_rs2 <= (others => '0');
          r_imm <= (others => '0'); 
          r_muxrs1 <= (others => '0');
          r_muxrs2 <= '0';
          r_muxalu <= (others => '0');
          r_alucntrl <= (others => '0');
          r_regop <= c_REG_WD;
          r_memop <= c_MEM_WD;
          r_rd <= (others => '0'); 
          r_branch <= c_BRANCH_NO; 
          r_branchadr <= (others => '0'); 
          r_pc <= (others => '0'); 
          r_pc4 <= (others => '0'); 
      else
          r_rs1 <= in_de_to_ex.rs1;
          r_rs2 <= in_de_to_ex.rs2;
          r_imm  <= in_de_to_ex.imm;
          r_muxrs1 <= in_de_to_ex.muxrs1;
          r_muxrs2 <= in_de_to_ex.muxrs2;
          r_muxalu <= in_de_to_ex.muxalu;
          r_alucntrl <= in_de_to_ex.alucntrl;
          r_regop <= in_de_to_ex.regop;
          r_memop <= in_de_to_ex.memop;
          r_rd <= in_de_to_ex.rd; 
          r_branch <= in_de_to_ex.branch; 
          r_branchadr <= in_de_to_ex.branchadr; 
          r_pc <= in_de_to_ex.pc; 
          r_pc4 <= in_de_to_ex.pc4; 
      end if; 
    end if;
  end process;
  
  --MULTIPLEX ALU OPERAND A
  p_MUX_OP_A: process(r_muxrs1, r_rs1, r_pc) 
  begin 
    if(r_muxrs1 = c_MUXRS1_REG) then 
        w_aluop_a <= r_rs1; 
    else 
        if(r_muxrs1 = c_MUXRS1_ZERO) then
            w_aluop_a <= (others => '0');
        else
            w_aluop_a <= r_pc; 
        end if; 
    end if; 
  end process;
   
  --MULTIPLEX ALU OPERAND B
  p_MUX_OP_B: process(r_muxrs2, r_rs2, r_imm) 
  begin 
    if(r_muxrs2 = c_MUXRS2_REG) then
        w_aluop_b <= r_rs2;  
    else 
        w_aluop_b <= r_imm; 
    end if; 
  end process; 
  
  --ALU CONNECTION
  alu1: entity work.ALU(logic) -- instance of ALU.vhd
  port map (in_ex_to_alu.op_a => w_aluop_a,
            in_ex_to_alu.op_b => w_aluop_b,
            in_ex_to_alu.cntrl => r_alucntrl,
            out_alu_to_ex.res => w_alures);
  --Branch Unit CONNECTION
  bu1: entity work.BranchUnit(logic) -- instance of BranchUnit.vhd
  port map (in_ex_to_bu.op_a => r_rs1,
            in_ex_to_bu.op_b => r_rs2,
            in_ex_to_bu.branch => r_branch,
            out_bu_to_ex.branch => w_branch); 
  --************EXECUTION PHASE OUT TO FETCH PHASE******************
  -- BRANCH  ADDRESS PASS THROUGH
  out_ex_to_fe.branchadr <= r_branchadr; 
  --************EXECUTION PHASE OUT TO DECODE PHASE******************
  --REGOP PASS THROUGH
  out_ex_to_de.regop <= r_regop;
  --REGISTER DESTINATION PASS THROUGH
  out_ex_to_de.rd <= r_rd; 
  
  --MULTIPLEX ALU/MEMORY OUTPUT
  p_MUX_RES: process(r_muxalu, w_alures, in_dmem_to_ex.data, r_pc4)
  begin 
    if(r_muxalu = c_MUXALU_ALU) then
        out_ex_to_de.res <= w_alures; 
    else 
        if(r_muxalu = c_MUXALU_MEM) then 
            out_ex_to_de.res <= in_dmem_to_ex.data; 
        else -- when r_muxalu = c_MUXALU_PC
            out_ex_to_de.res <= r_pc4; 
        end if; 
    end if; 
  end process; 
  
  --BRANCH TRUE/FALSE
  out_ex_to_de.branch <= w_branch; 
  --DATA MEMORY INTECONNECT
  out_ex_to_dmem.data <= r_rs2;
  out_ex_to_dmem.addr <= w_alures;
  out_ex_to_dmem.memop <= r_memop;
end RTL;
