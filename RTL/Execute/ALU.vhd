-- This is the ALU of the RISC-V CPU capable of addition/subtraction/ANDing/ORing/XORing/shifting/slt/lui operands
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

entity ALU is
  port(in_ex_to_alu : in ex_to_alu_t;
       out_alu_to_ex : out alu_to_ex_t);
end entity;

architecture logic of ALU is
  signal w_slt : reglen_t;
  signal w_sltu : reglen_t;
begin

  p_SLT : process(in_ex_to_alu.op_a, in_ex_to_alu.op_b) is
  begin
    if(signed(in_ex_to_alu.op_a) < signed(in_ex_to_alu.op_b)) then
      w_slt <= std_logic_vector(to_unsigned(1, w_slt'length));
    else
      w_slt <= std_logic_vector(to_unsigned(0, w_slt'length));
    end if;
  end process;

  p_SLTU : process(in_ex_to_alu.op_a, in_ex_to_alu.op_b) is
  begin
    if(unsigned(in_ex_to_alu.op_a) < unsigned(in_ex_to_alu.op_b)) then
      w_sltu <= std_logic_vector(to_unsigned(1, w_sltu'length));
    else
      w_sltu <= std_logic_vector(to_unsigned(0, w_sltu'length));
    end if;
  end process;

  --multiplex required operation
  with in_ex_to_alu.cntrl select 
  out_alu_to_ex.res <= std_logic_vector(unsigned(in_ex_to_alu.op_a) + unsigned(in_ex_to_alu.op_b)) when c_ALU_ADD, --addition
                       std_logic_vector(unsigned(in_ex_to_alu.op_a) - unsigned(in_ex_to_alu.op_b)) when c_ALU_SUB, --subtraction
                       in_ex_to_alu.op_a and in_ex_to_alu.op_b when c_ALU_AND, --ANDing
                       in_ex_to_alu.op_a or in_ex_to_alu.op_b when c_ALU_OR, --ORing
                       in_ex_to_alu.op_a xor in_ex_to_alu.op_b when c_ALU_XOR, --XORing
                       std_logic_vector(shift_left(unsigned(in_ex_to_alu.op_a), to_integer(unsigned(in_ex_to_alu.op_b)))) when c_ALU_SLL, --shift left logically
                       std_logic_vector(shift_right(unsigned(in_ex_to_alu.op_a), to_integer(unsigned(in_ex_to_alu.op_b)))) when c_ALU_SRL, --shift right logically
                       std_logic_vector(shift_right(signed(in_ex_to_alu.op_a), to_integer(unsigned(in_ex_to_alu.op_b)))) when c_ALU_SRA, --shift right arithmetically
                       w_slt when c_ALU_SLT, --set less than
                       w_sltu when others; --set less than unsigned
end logic;
