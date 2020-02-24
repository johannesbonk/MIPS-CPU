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
  generic(g_REGISTER_WIDTH : integer;
          g_CONTROL_WIDTH : integer);
  port(in_rs1   : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --input register 1
       in_rs2   : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --input register 2
       in_cntrl  : in alucntrl_t; --control inputs

       out_res   : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0)); --result output
end entity;

architecture behavior of ALU is
  signal w_slt : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_sltu : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
begin

  p_SLT : process(in_rs1, in_rs2) is
  begin
    if(signed(in_rs1) < signed(in_rs2)) then
      w_slt <= std_logic_vector(to_unsigned(1, w_slt'length));
    else
      w_slt <= std_logic_vector(to_unsigned(0, w_slt'length));
    end if;
  end process;

  p_SLTU : process(in_rs1, in_rs2) is
  begin
    if(unsigned(in_rs1) < unsigned(in_rs2)) then
      w_sltu <= std_logic_vector(to_unsigned(1, w_sltu'length));
    else
      w_sltu <= std_logic_vector(to_unsigned(0, w_sltu'length));
    end if;
  end process;

  --multiplex required operation
  out_res <= std_logic_vector(unsigned(in_rs1) + unsigned(in_rs2)) when in_cntrl = c_ALU_ADD else --addition
             std_logic_vector(unsigned(in_rs1) - unsigned(in_rs2))  when in_cntrl = c_ALU_SUB else --subtraction
             in_rs1 and in_rs2 when in_cntrl = c_ALU_AND else --ANDing
             in_rs1 or in_rs2 when in_cntrl = c_ALU_OR else --ORing
             in_rs1 xor in_rs2 when in_cntrl = c_ALU_XOR else --XORing
             std_logic_vector(shift_left(unsigned(in_rs2), to_integer(unsigned(in_rs1)))) when in_cntrl = c_ALU_SLL else --shift left logically
             std_logic_vector(shift_right(unsigned(in_rs2), to_integer(unsigned(in_rs1)))) when in_cntrl = c_ALU_SRL else --shift right logically
             std_logic_vector(shift_right(signed(in_rs2), to_integer(unsigned(in_rs1)))) when in_cntrl = c_ALU_SRA else --shift right arithmetically
             w_slt when in_cntrl = c_ALU_SLT else --set less than
             w_sltu when in_cntrl = c_ALU_SLTU else --set less than unsigned
             std_logic_vector(shift_left(unsigned(in_rs1), 16)) when in_cntrl = c_ALU_LUI; --load upper immediate
end behavior;
