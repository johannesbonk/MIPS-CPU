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
  subtype opcode_t is std_logic_vector(6 downto 0);
  subtype func3_t is std_logic_vector(2 downto 0);
  subtype func7_t is std_logic_vector(6 downto 0);

  subtype regop_t is std_logic;
    constant c_REG_WE : regop_t := '0';
    constant c_REG_WD : regop_t := '1';

  subtype memop_t is std_logic;
    constant c_MEM_WE : memop_t := '0';
    constant c_MEM_WD : memop_t := '1';

  subtype alucntrl_t is std_logic_vector(3 downto 0);
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

  subtype muxrs1_t is std_logic;
    constant c_MUXRS1_REG   : muxrs1_t := '0';
    constant c_MUXRS1_ZERO  : muxrs1_t := '1';

  subtype muxrs2_t is std_logic_vector(1 downto 0);
    constant c_MUXRS2_REG   : muxrs2_t := "00";
    constant c_MUXRS2_EXI   : muxrs2_t := "01";
    constant c_MUXRS2_EXSB  : muxrs2_t := "10";
    constant c_MUXRS2_ZEXUI : muxrs2_t := "11";

   subtype muxshamt_t is std_logic;
    constant c_MUXSHAMT_RS2   : muxshamt_t := '0';
    constant c_MUXSHAMT_SHAMT : muxshamt_t := '1';

   subtype muxalu_t is std_logic_vector(1 downto 0);
    constant c_MUXALU_ALU       : muxalu_t := "00";
    constant c_MUXALU_MEM       : muxalu_t := "01";
    constant c_MUXALU_PC        : muxalu_t := "10";
    constant c_MUXRALU_INVALID  : muxalu_t := "11";

   subtype muxpc_t is std_logic_vector(1 downto 0);
    constant c_MUXPC_PC4    : muxpc_t  := "00";
    constant c_MUXPC_BRANCH : muxpc_t := "01";
    constant c_MUXPC_JMP    : muxpc_t := "10";
    constant c_MUXPC_JALR   : muxpc_t := "11";

   subtype muxnop_t is std_logic;
    constant c_MUXNOP_OP  : muxnop_t := '0';
    constant c_MUXNOP_NOP : muxnop_t := '1';

   subtype muxfwdrs1_t is std_logic_vector();
    constant c_MUXFWDRS1_RS1 : muxfwdrs1_t := "00";
    constant c_MUXFWDRS1_ALU : muxfwdrs1_t := "01";
    constant c_MUXFWDRS1_MEM : muxfwdrs1_t := "10";
    constant c_MUXFWDRS1_INV : muxfwdrs1_t := "11";

   subtype muxfwdrs2_t is std_logic_vector();
    constant c_MUXFWDRS2_RS1 : muxfwdrs2_t := "00";
    constant c_MUXFWDRS2_ALU : muxfwdrs2_t := "01";
    constant c_MUXFWDRS2_MEM : muxfwdrs2_t := "10";
    constant c_MUXFWDRS2_INV : muxfwdrs2_t := "11";
end package common;
