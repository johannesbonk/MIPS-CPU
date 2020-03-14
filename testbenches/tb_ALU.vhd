-- This is the testbench of the ALU of the RISC-V CPU
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
USE work.tb_procedure_pkg.ALL;

entity tb_ALU is
end;

architecture tb of tb_ALU is
  constant c_DELTA_TIME : time := 1 ns;

  signal w_ex_to_alu : ex_to_alu_t := (op_a => (others => '0'),
                                       op_b => (others => '0'),
                                       cntrl => (others => '0'));
  signal w_alu_to_ex : alu_to_ex_t;

  begin
  DUT : entity work.ALU(behavior)
        port map(in_ex_to_alu => w_ex_to_alu,
                 out_alu_to_ex => w_alu_to_ex);

  p_SIMULATION : process
    begin
      wait for c_DELTA_TIME;
      --********ADDITION TEST********
      w_ex_to_alu.op_a <= x"00000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_ADD;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"0abcd000";
      w_ex_to_alu.op_b <= x"000abcd0";
      w_ex_to_alu.cntrl <= c_ALU_ADD;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"0ac78cd0");

      w_ex_to_alu.op_a <= x"ffff0000";
      w_ex_to_alu.op_b <= x"00123456";
      w_ex_to_alu.cntrl <= c_ALU_ADD;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00113456");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_ADD;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"fffffffe");

      --********SUBTRACTION TEST********
      w_ex_to_alu.op_a <= x"00000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_SUB;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"00000000";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_SUB;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      w_ex_to_alu.op_a <= x"00000000";
      w_ex_to_alu.op_b <= x"7fffffff";
      w_ex_to_alu.cntrl <= c_ALU_SUB;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"80000001");

      w_ex_to_alu.op_a <= x"80000000";
      w_ex_to_alu.op_b <= x"00000001";
      w_ex_to_alu.cntrl <= c_ALU_SUB;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"7fffffff");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_SUB;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      --********ANDing TEST********
      w_ex_to_alu.op_a <= x"00000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_AND;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_AND;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"ffffffff");

      w_ex_to_alu.op_a <= x"10101010";
      w_ex_to_alu.op_b <= x"01010101";
      w_ex_to_alu.cntrl <= c_ALU_AND;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"10101010";
      w_ex_to_alu.op_b <= x"10101010";
      w_ex_to_alu.cntrl <= c_ALU_AND;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"10101010");

      --********ORing TEST********
      w_ex_to_alu.op_a <= x"00000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_OR;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_OR;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"ffffffff");

      w_ex_to_alu.op_a <= x"10101010";
      w_ex_to_alu.op_b <= x"01010101";
      w_ex_to_alu.cntrl <= c_ALU_OR;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"11111111");

      w_ex_to_alu.op_a <= x"10101010";
      w_ex_to_alu.op_b <= x"10101010";
      w_ex_to_alu.cntrl <= c_ALU_OR;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"10101010");

      --********XORing TEST********
      w_ex_to_alu.op_a <= x"00000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_XOR;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_XOR;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"10101010";
      w_ex_to_alu.op_b <= x"01010101";
      w_ex_to_alu.cntrl <= c_ALU_XOR;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"11111111");

      w_ex_to_alu.op_a <= x"10101010";
      w_ex_to_alu.op_b <= x"10101010";
      w_ex_to_alu.cntrl <= c_ALU_XOR;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"c3c3c3c3";
      w_ex_to_alu.op_b <= x"3c3c3c3c";
      w_ex_to_alu.cntrl <= c_ALU_XOR;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"ffffffff");

      --********SLL TEST********
      w_ex_to_alu.op_a <= x"00000001";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_SLL;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      w_ex_to_alu.op_a <= x"00000001";
      w_ex_to_alu.op_b <= x"0000001f";
      w_ex_to_alu.cntrl <= c_ALU_SLL;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"80000000");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"00000020";
      w_ex_to_alu.cntrl <= c_ALU_SLL;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      --********SLT TEST********
      w_ex_to_alu.op_a <= x"00000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_SLT;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_SLT;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"fffffffe";
      w_ex_to_alu.cntrl <= c_ALU_SLT;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"fffffffe";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_SLT;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      w_ex_to_alu.op_a <= x"7ffffffe";
      w_ex_to_alu.op_b <= x"7fffffff";
      w_ex_to_alu.cntrl <= c_ALU_SLT;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      w_ex_to_alu.op_a <= x"80000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_SLT;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      w_ex_to_alu.op_a <= x"7fffffff";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_SLT;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"7fffffff";
      w_ex_to_alu.cntrl <= c_ALU_SLT;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      --********SLTU TEST********
      w_ex_to_alu.op_a <= x"00000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_SLTU;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_SLTU;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"fffffffe";
      w_ex_to_alu.cntrl <= c_ALU_SLTU;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"fffffffe";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_SLTU;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      w_ex_to_alu.op_a <= x"7ffffffe";
      w_ex_to_alu.op_b <= x"7fffffff";
      w_ex_to_alu.cntrl <= c_ALU_SLTU;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      w_ex_to_alu.op_a <= x"80000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_SLTU;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      w_ex_to_alu.op_a <= x"7fffffff";
      w_ex_to_alu.op_b <= x"ffffffff";
      w_ex_to_alu.cntrl <= c_ALU_SLTU;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"7fffffff";
      w_ex_to_alu.cntrl <= c_ALU_SLTU;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      --********SRL TEST********
      w_ex_to_alu.op_a <= x"80000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_SRL;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"80000000");

      w_ex_to_alu.op_a <= x"80000000";
      w_ex_to_alu.op_b <= x"0000001f";
      w_ex_to_alu.cntrl <= c_ALU_SRL;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"00000020";
      w_ex_to_alu.cntrl <= c_ALU_SRL;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000000");

      --********SRA TEST********
      w_ex_to_alu.op_a <= x"80000000";
      w_ex_to_alu.op_b <= x"00000000";
      w_ex_to_alu.cntrl <= c_ALU_SRA;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"80000000");

      w_ex_to_alu.op_a <= x"80000000";
      w_ex_to_alu.op_b <= x"0000001f";
      w_ex_to_alu.cntrl <= c_ALU_SRA;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"ffffffff");

      w_ex_to_alu.op_a <= x"4fffffff";
      w_ex_to_alu.op_b <= x"0000001e";
      w_ex_to_alu.cntrl <= c_ALU_SRA;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"00000001");

      w_ex_to_alu.op_a <= x"ffffffff";
      w_ex_to_alu.op_b <= x"0000001f";
      w_ex_to_alu.cntrl <= c_ALU_SRA;
      wait for c_DELTA_TIME;
      checkALUOut(w_ex_to_alu.op_a, w_ex_to_alu.op_b, w_ex_to_alu.cntrl, w_alu_to_ex.res, x"ffffffff");

      wait for c_DELTA_TIME;
    assert false report "Reached end of test successfully!";
    wait; --make process wait for an infinite timespan
  end process;

  end tb;
