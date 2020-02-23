-- This is the ALU of the MIPS CPU capable of addition/subtraction/ANDing/ORing/XORing/shifting operands
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

entity ALU is
  generic(g_REGISTER_WIDTH : integer;
          g_CONTROL_WIDTH : integer);
  port(in_op_a   : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --input operand a
       in_op_b   : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --input operand b
       in_cntrl  : in std_logic_vector(g_CONTROL_WIDTH downto 0); --control inputs

       out_zflag : out std_logic; --zero flag output
       out_res   : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0)); --result output
end;

architecture behavior of ALU is
  signal w_arith_out : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --result of addition/subtraction of operands
  signal w_ano_out : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --result of and/or operation on operands
  signal w_xui_out : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --result of xor/lui operation on operands
  signal w_shft_out : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --result of shift operation on operands
  signal w_res : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0); --result wire

begin
  w_arith_out <= std_logic_vector(unsigned(in_op_a) + unsigned(in_op_b)) when in_cntrl(2) = '0' else
                 std_logic_vector(unsigned(in_op_a) - unsigned(in_op_b)) when in_cntrl(2) = '1';
  w_ano_out <=   in_op_a and in_op_b when in_cntrl(2) = '0' else
                 in_op_a or in_op_b when in_cntrl(2) = '1';
  w_xui_out <=   in_op_a xor in_op_b when in_cntrl(2) = '0' else
                 std_logic_vector(shift_left(unsigned(in_op_a), 16)) when in_cntrl(2) = '1';
  w_shft_out <=  std_logic_vector(shift_left(unsigned(in_op_b), to_integer(unsigned(in_op_a)))) when in_cntrl(2) = '0' else
                 std_logic_vector(shift_right(unsigned(in_op_b), to_integer(unsigned(in_op_a)))) when in_cntrl(2) = '1' and in_cntrl(3) = '0' else
                 std_logic_vector(shift_right(signed(in_op_b), to_integer(unsigned(in_op_a)))) when in_cntrl(2) = '1' and in_cntrl(3) = '1';

  --multiplex required operation reult based on lower 2 control bits
  w_res <= w_arith_out when in_cntrl(1 downto 0) = "00" else
           w_ano_out when in_cntrl(1 downto 0) = "01" else
           w_xui_out when in_cntrl(1 downto 0) = "10" else
           w_shft_out when in_cntrl(1 downto 0) = "11";

  out_zflag <= w_res(w_res'high); --zero flag == most significant bit of arithmetic operation result
  out_res <= w_res; --set output
end behavior;
