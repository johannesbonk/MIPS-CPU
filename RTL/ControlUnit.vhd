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

entity ControlUnit is
  port(in_de_to_cu  : in de_to_cu_t;
       out_cu_to_de : out cu_to_de_t);
end entity;

architecture behavior of ControlUnit is

begin
  case in_opcode(6 downto 2) is
    when b"00000" => --load opcode
      case in_func3 =>
        when b"000" => --lb
        when b"001" => --lh
        when b"010" => --lw
        when b"100" => --lbu
        when b"101" => --lhu
    when b"01000" => --store opcode
      case in_func3 =>
        when b"000" => --sb
        when b"001" => --sh
        when b"010" => --sw
    when b"00011" => --FENCE opcode
      case in_func3 =>
        when b"000" => --FENCE
        when b"001" => --FENCE.I
    when b"00100" => --immediate opcode
      case in_func3 =>
        when b"000" => --addi
        when b"001" => --slli
        when b"010" => --slti
        when b"011" => --sltiu
        when b"100" => --xori
        when b"101" => --srli/srai decided by func7
        when b"110" => --ori
        when b"111" => --andi
    when b"00101" => --add upper immediate (aui) opcode
    when b"01100" => --reg-reg(arithmetic) opcode
        when b"000" => --b"000" add/sub decided by func7
          out_muxshamt <= c_MUXSHAMT_RS2;
        when b"001" => --b"001" sll
          out_muxshamt <= c_MUXSHAMT_SHAMT;
        when b"010" => --b"010" slt
          out_muxshamt <= c_MUXSHAMT_RS2;
        when b"011" => --b"011" sltu
          out_muxshamt <= c_MUXSHAMT_RS2;
        when b"100" => --b"100" xor
          out_muxshamt <= c_MUXSHAMT_RS2;
        when b"101" => --b"101" srl/sra decided by func7
          out_muxshamt <= c_MUXSHAMT_SHAMT;
        when b"110" => --b"110" or
          out_muxshamt <= c_MUXSHAMT_RS2;
        when b"111" => --b"111" -and
          out_muxshamt <= c_MUXSHAMT_RS2;
        out_alucntrl <= in_func7(in_func7'high - 1) & in_func3;
        out_muxrs1 <= c_MUXRS1_REG;
        out_muxrs2 <= c_MUXRS2_REG;
        out_muxalu <= c_MUXALU_ALU;
        out_regop <= c_REG_WE;
        out_wmem <= c_MEM_WE;
        out_muxpc <= c_MUXPC_PC4;
        out_muxnop <= c_MUXNOP_OP;
    when b"01101" => --load upper immediate (lui) opcode
        out_alucntrl <= c_ALU_LUI
    when b"11000" => --branch opcode
      case in_func3 =>
        when b"000" => --beq
        when b"001" => --bne
        when b"100" => --blt
        when b"101" => --bge
        when b"110" => --bltu
        when b"111" => --bgeu
    when b"11001" => --jump and link register (jalr) opcode
    when b"11011" => --jump and link (jal) opcode
    when b"11100" => --CSR opcode
      case in_func3 is
        when b"000" => --ECALL/EBREAK decided by func7
        when b"001" => --CSRRW
        when b"010" => --CSRRS
        when b"011" => --CSRRC
        when b"101" => --CSRRWI
        when b"110" => --CSRRSI
        when b"111" => --CSRRCI
end behavior;
