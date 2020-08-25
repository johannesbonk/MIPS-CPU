-- This module describes the control unit of the RISC-V CPU
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

entity ControlUnit is
  port(in_de_to_cu  : in de_to_cu_t;
       out_cu_to_de : out cu_to_de_t);
end entity ControlUnit;

architecture logic of ControlUnit is
  signal w_branch : boolean; 
  signal w_jal    : boolean; 
  signal w_jalr   : boolean; 
  -- output capsule signals 
  signal w_alucntrl : alucntrl_t; 
  signal w_regop    : regop_t; 
  signal w_memop    : memop_t; 
  signal w_muxrs1   : muxrs1_t; 
  signal w_muxrs2   : muxrs2_t; 
  signal w_muxalu   : muxalu_t; 
  signal w_muxpc    : muxpc_t; 
  signal w_muxnop   : muxnop_t; 
  signal w_branch_out : branch_t; 
  signal w_stallfe  : stall_t;
begin
  p_DECODE: process(in_de_to_cu.opcode) 
  begin
    -- decoded outputs
    case in_de_to_cu.opcode(6 downto 2) is
      when b"00000" => --load opcode
        w_alucntrl <= c_ALU_ADD;
        w_muxrs1 <= c_MUXRS1_REG;
        w_muxrs2 <= c_MUXRS2_IMM;
        w_muxalu <= c_MUXALU_ALU;
        w_regop <= c_REG_WE;
        w_memop <= '0' & in_de_to_cu.func3; -- preceding 0 stands for load
        w_branch <= false; 
        w_jal <= false; 
        w_jalr <= false; 
      when b"01000" => --store opcode
        w_alucntrl <= c_ALU_ADD;
        w_muxrs1 <= c_MUXRS1_REG;
        w_muxrs2 <= c_MUXRS2_IMM;
        w_muxalu <= c_MUXALU_ALU;
        w_regop <= c_REG_WD;
        w_memop <= '1' & in_de_to_cu.func3; -- preceding 1 stands for store
        w_branch <= false; 
        w_jal <= false; 
        w_jalr <= false; 
      -- when b"00011" => --FENCE opcode
      --   case in_func3 =>
      --     when b"000" => --FENCE
      --     when b"001" => --FENCE.I
      when b"00100" => --immediate opcode
        w_alucntrl <= '0' & in_de_to_cu.func3;
        w_muxrs1 <= c_MUXRS1_REG;
        w_muxrs2 <= c_MUXRS2_IMM;
        w_muxalu <= c_MUXALU_ALU;
        w_regop <= c_REG_WE;
        w_memop <= c_MEM_WD;
        w_branch <= false; 
        w_jal <= false; 
        w_jalr <= false; 
      when b"00101" => --add upper immediate (aui) opcode
        w_alucntrl <= c_ALU_ADD;
        w_muxrs1 <= c_MUXRS1_PC;
        w_muxrs2 <= c_MUXRS2_IMM;
        w_muxalu <= c_MUXALU_ALU;
        w_regop <= c_REG_WE;
        w_memop <= c_MEM_WD;
        w_branch <= false; 
        w_jal <= false; 
        w_jalr <= false; 
      when b"01100" => --reg-reg(arithmetic) opcode
        w_alucntrl <= in_de_to_cu.func7(in_de_to_cu.func7'high - 1) & in_de_to_cu.func3;
        w_muxrs1 <= c_MUXRS1_REG;
        w_muxrs2 <= c_MUXRS2_REG;
        w_muxalu <= c_MUXALU_ALU;
        w_regop <= c_REG_WE;
        w_memop <= c_MEM_WD;
        w_branch <= false; 
        w_jal <= false; 
        w_jalr <= false; 
      when b"01101" => --load upper immediate (lui) opcode
        w_alucntrl <= c_ALU_ADD;
        w_muxrs1 <= c_MUXRS1_ZERO;
        w_muxrs2 <= c_MUXRS2_IMM;
        w_muxalu <= c_MUXALU_ALU;
        w_regop <= c_REG_WE;
        w_memop <= c_MEM_WD;
        w_branch <= false; 
        w_jal <= false; 
        w_jalr <= false; 
      when b"11000" => --branch opcode
        w_alucntrl <= c_ALU_ADD;
        w_muxrs1 <= c_MUXRS1_REG;
        w_muxrs2 <= c_MUXRS2_REG;
        w_muxalu <= c_MUXALU_ALU;
        w_regop <= c_REG_WD;
        w_memop <= c_MEM_WD;
        w_branch <= true; 
        w_jal <= false; 
        w_jalr <= false; 
      when b"11001" => --jump and link register (jalr) opcode
        w_alucntrl <= c_ALU_ADD;
        w_muxrs1 <= c_MUXRS1_ZERO;
        w_muxrs2 <= c_MUXRS2_IMM;
        w_muxalu <= c_MUXALU_PC;
        w_regop <= c_REG_WE;
        w_memop <= c_MEM_WD;
        w_branch <= false; 
        w_jal <= false; 
        w_jalr <= true; 
      when b"11011" => --jump and link (jal) opcode
        w_alucntrl <= c_ALU_ADD;
        w_muxrs1 <= c_MUXRS1_ZERO;
        w_muxrs2 <= c_MUXRS2_IMM;
        w_muxalu <= c_MUXALU_PC;
        w_regop <= c_REG_WE;
        w_memop <= c_MEM_WD;
        w_branch <= false; 
        w_jal <= true; 
        w_jalr <= false; 
      -- when b"11100" => --CSR opcode
      --   case in_func3 is
      --     when b"000" => --ECALL/EBREAK decided by func7
      --     when b"001" => --CSRRW
      --     when b"010" => --CSRRS
      --     when b"011" => --CSRRC
      --     when b"101" => --CSRRWI
      --     when b"110" => --CSRRSI
      --     when b"111" => --CSRRCI
      when others => --non existant opcode (perform arithmetic operation without storing the result)
         w_alucntrl <= in_de_to_cu.func7(in_de_to_cu.func7'high - 1) & in_de_to_cu.func3;
        w_muxrs1 <= c_MUXRS1_REG;
        w_muxrs2 <= c_MUXRS2_REG;
        w_muxalu <= c_MUXALU_ALU;
        w_regop <= c_REG_WD;
        w_memop <= c_MEM_WD;
        w_branch <= false; 
        w_jal <= false; 
        w_jalr <= false; 
      end case; 
  end process p_DECODE; 

    -- HAZARD DETECTION / STALL FETCH STAGE AND INSERT BUBBLE (MUXNOP)
    p_DETECT_HAZARD: process(w_branch, in_de_to_cu.func3)
    begin
      case w_branch is 
        when true => 
          w_branch_out <= in_de_to_cu.func3; 
          w_muxnop <= c_MUXNOP_NOP; 
          w_stallfe <= c_STALL_YES; 
        when others => 
          w_branch_out <= c_BRANCH_NO; 
          w_muxnop <= c_MUXNOP_OP; 
          w_stallfe <= c_STALL_NO; 
      end case; 
    end process p_DETECT_HAZARD; 

    -- EVALUATE NEXT PC 
    p_NEXT_PC : process(in_de_to_cu.exbranch, w_jal, w_jalr)
    begin 
      if(in_de_to_cu.exbranch = true) and (w_jal = false) and (w_jalr = false) then 
        w_muxpc <= c_MUXPC_BRANCH; 
      elsif(in_de_to_cu.exbranch = false) and (w_jal = true) and (w_jalr = false) then 
        w_muxpc <= c_MUXPC_JAL; 
      elsif(in_de_to_cu.exbranch = false) and (w_jal = false) and (w_jalr = true) then 
        w_muxpc <= c_MUXPC_JALR; 
      else 
        w_muxpc <= c_MUXPC_PC4; 
      end if; 
    end process p_NEXT_PC; 

    -- ASSIGN OUTPUTS 
    out_cu_to_de.alucntrl <= w_alucntrl;
    out_cu_to_de.muxrs1 <= w_muxrs1;
    out_cu_to_de.muxrs2 <= w_muxrs2;
    out_cu_to_de.muxalu <= w_muxalu;
    out_cu_to_de.regop <= w_regop;
    out_cu_to_de.memop <= w_memop;
    out_cu_to_de.muxnop <= w_muxnop; 
    out_cu_to_de.branch <= w_branch_out; 
    out_cu_to_de.stallfe <= w_stallfe; 
    out_cu_to_de.muxpc <= w_muxpc; 
end logic;


