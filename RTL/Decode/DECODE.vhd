-- This module describes the decode stage of the RISC-V CPU
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

LIBRARY work; 
USE work.common.ALL;  

entity DECODE is
  port(in_ext_to_all  : in ext_to_all_t;
       in_fe_to_de    : in fe_to_de_t;
       in_ex_to_de    : in ex_to_de_t;
       out_de_to_fe   : out de_to_fe_t;
       out_de_to_ex   : out de_to_ex_t);
end entity DECODE;

architecture RTL of DECODE is
  --PIPELINE REGISTERS
  signal r_instr     : reglen_t;
  signal r_pc        : reglen_t;
  signal r_pc4       : reglen_t;
  --COMPONENT INTERFACES (internal)
  signal w_de_to_cu      : de_to_cu_t; 
  signal w_cu_to_de      : cu_to_de_t; 
  signal w_de_to_fwd     : de_to_fwd_t; 
  signal w_fwd_to_de     : fwd_to_de_t; 
  signal w_de_to_regfile : de_to_regfile_t; 
  signal w_regfile_to_de : regfile_to_de_t; 
  --COMPONENT INTERFACES (external)
  signal w_fe_to_de : fe_to_de_t; 
  signal w_de_to_fe : de_to_fe_t; 
  signal w_de_to_ex : de_to_ex_t; 
  signal w_ex_to_de : ex_to_de_t; 
  --INTERNAL WIREING
  signal w_opcode  : opcode_t;
  signal w_func3   : func3_t;
  signal w_func7   : func7_t;
  signal w_rs1     : reglen_t;
  signal w_rs2     : reglen_t;
  signal w_rs1adr  : regadr_t;
  signal w_rs2adr  : regadr_t;
  signal w_rd      : regadr_t;
  signal w_imm     : reglen_t;
  signal w_fwdrs1  : reglen_t; 
  signal w_fwdrs2  : reglen_t; 
  signal w_jaladr  : reglen_t; 
  signal w_jalradr : reglen_t; 
  signal w_branchadr : reglen_t; 

  -- INPUT WIREING
  -- FROM EXECUTE STAGE
  signal w_exres       : reglen_t; 
  signal w_exregop     : regop_t; 
  signal w_exrd        : regadr_t; 
  signal w_exbranch    : boolean; 
  signal w_exbranchadr : reglen_t; 
  -- FROM CONTROL UNIT
  signal w_cumuxrs1 : muxrs1_t; 
  signal w_cumuxrs2 : muxrs2_t; 
  signal w_cualucntrl : alucntrl_t; 
  signal w_cumuxalu : muxalu_t; 
  signal w_curegop : regop_t; 
  signal w_cumemop : memop_t; 
  signal w_cumuxpc : muxpc_t; 
  signal w_cumuxnop : muxnop_t; 
  signal w_cubranch : branch_t; 
  signal w_custallfe : stall_t; 
  -- FORWARDING UNIT
  signal w_fwdmuxfwdrs1 : muxfwdrs1_t; 
  signal w_fwdmuxfwdrs2 : muxfwdrs2_t;  
  component ControlUnit is
    port(in_de_to_cu  : de_to_cu_t;
         out_cu_to_de : cu_to_de_t);
  end component;

  component ForwardingUnit is 
    port(in_de_to_fwd  : de_to_fwd_t;
         out_fwd_to_de : fwd_to_de_t); 
  end component; 

begin
 ----------------------------------------------------
 --|             INITIALIZE COMPONENTS              |
 ---------------------------------------------------- 
 control_unit: entity work.ControlUnit(logic) -- instance of ControlUnit.vhd
 port map (in_de_to_cu => w_de_to_cu,
           out_cu_to_de => w_cu_to_de);

  forwarding_unit: entity work.ForwardingUnit(logic) -- instance of ForwardingUnit.vhd
  port map(in_de_to_fwd => w_de_to_fwd,
           out_fwd_to_de => w_fwd_to_de); 
  
  register_file: entity work.RegisterFile(RTL) -- instance of RegisterFile.vhd
  port map(in_ext_to_all => in_ext_to_all,
           in_de_to_regfile => w_de_to_regfile,
           out_regfile_to_de => w_regfile_to_de); 
 ----------------------------------------------------
 --|            ASSIGN INPUTS (external)            |
 ---------------------------------------------------- 
  -- FETCH STAGE
  -- SEE PIPELINE REGISTERS
  -- EXECUTE STAGE
  w_exres <= in_ex_to_de.res; 
  w_exregop <= in_ex_to_de.regop;
  w_exrd <= in_ex_to_de.rd;  
  w_exbranch <= in_ex_to_de.branch; 
 ----------------------------------------------------
 --|            ASSIGN INPUTS (internal)            |
 ---------------------------------------------------- 
  -- CONTROL UNIT
  w_cumuxrs1 <= w_cu_to_de.muxrs1; 
  w_cumuxrs2 <= w_cu_to_de.muxrs2; 
  w_cualucntrl <= w_cu_to_de.alucntrl; 
  w_cumuxalu <= w_cu_to_de.muxalu; 
  w_curegop <= w_cu_to_de.regop; 
  w_cumemop <= w_cu_to_de.memop; 
  w_cumuxpc <= w_cu_to_de.muxpc; 
  w_cumuxnop <= w_cu_to_de.muxnop;
  w_cubranch <= w_cu_to_de.branch;  
  w_custallfe <= w_cu_to_de.stallfe; 
  -- FORWARDING UNIT
  w_fwdmuxfwdrs1 <= w_fwd_to_de.muxfwdrs1; 
  w_fwdmuxfwdrs2 <= w_fwd_to_de.muxfwdrs2; 
  -- REGFILE 
  w_rs1 <= w_regfile_to_de.rs1; 
  w_rs2 <= w_regfile_to_de.rs2; 
  ----------------------------------------------------
  --|              PIPELINE REGISTERS                |
  ---------------------------------------------------- 
  --SAVE THE OUTPUT SIGNALS OF THE FETCH STAGE
  p_PIPELINE_REGISTER : process(in_ext_to_all.clk, in_ext_to_all.clr)
  begin
    if(rising_edge(in_ext_to_all.clk)) then
      if(in_ext_to_all.clr = '1') then -- clear pipeline register on reset
          r_instr <= x"00000013";
          r_pc <= (others => '0');
          r_pc4 <= (others => '0');
      else 
          r_instr <= in_fe_to_de.instr;
          r_pc <= in_fe_to_de.pc;
          r_pc4 <= in_fe_to_de.pc4;
      end if; 
    end if;
  end process p_PIPELINE_REGISTER; 
  ----------------------------------------------------
  --|             EVALUATE INSTRUCTION               |
  ----------------------------------------------------     
  --EVALUATE OPCODE
  w_opcode <= r_instr(6 downto 0);
  --EVALUUATE FUNCTION
  w_func3 <= r_instr(14 downto 12);
  w_func7 <= r_instr(31 downto 25);
  --EVALUATE SOURCE REGISTER ADRESS
  w_rs1adr <= r_instr(19 downto 15);
  w_rs2adr <= in_fe_to_de.instr(24 downto 20);
  --EVALUATE DESTINATION REGISTER / SHIFT AMOUNT
  w_rd <= r_instr(11 downto 7);
  ----------------------------------------------------
  --|              EVALUATE IMMEDIATE                |
  ----------------------------------------------------                    
           -- U TYPE
  w_imm <= in_fe_to_de.instr(31 downto 12) & (11 downto 0 => '0') when w_opcode(6 downto 2) = (b"01101" or b"00101") else 
           -- J TYPE
           (31 downto 20 => in_fe_to_de.instr(31)) & in_fe_to_de.instr(19 downto 12) & in_fe_to_de.instr(20) & in_fe_to_de.instr(30 downto 21) & '0' when w_opcode(6 downto 2) = b"11011" else 
           -- I TYPE 
           (31 downto 11 => in_fe_to_de.instr(31)) & in_fe_to_de.instr(30 downto 20) when w_opcode(6 downto 2) = (b"11001" or b"00000" or b"00100"  or b"11100") else 
           -- S TYPE
           (31 downto 11 => in_fe_to_de.instr(31)) & in_fe_to_de.instr(30 downto 25) & in_fe_to_de.instr(11 downto 7) when w_opcode = b"01000" else 
           -- B TYPE
           (31 downto 12 => in_fe_to_de.instr(31)) & in_fe_to_de.instr(7) & in_fe_to_de.instr(30 downto 25) & in_fe_to_de.instr(11 downto 8) & '0' when w_opcode = b"11000" else 
           (others => '0'); 
  --REGISTER CONNECTION
  ----------------------------------------------------
  --|          FORWARDING REGISTER OUTPUTS           |
  ----------------------------------------------------     
  w_fwdrs1 <= w_rs1 when w_fwdmuxfwdrs1 = c_MUXFWDRS1_RS1 else
              w_exres; 
  w_fwdrs2 <= w_rs2 when w_fwdmuxfwdrs2 = c_MUXFWDRS2_RS2 else 
              w_exres; 
 ----------------------------------------------------
 --|          EVALUATE BRANCH/JUMP TARGET           |
 ----------------------------------------------------    
  --JUMP TARGET 
  w_jaladr <= w_imm; 
  --JUMP AND LINK REGISTER TARGET
  w_jalradr <= (std_logic_vector(unsigned(w_fwdrs1) + unsigned(w_imm))) and x"ff_ff_ff_fe";
  --BRANCH TARGET 
  w_branchadr <= std_logic_vector(to_unsigned(to_integer(unsigned(r_pc)) + to_integer(signed(w_imm)), w_branchadr'length));
 ----------------------------------------------------
 --|           ASSIGN OUTPUTS (internal)            |
 ----------------------------------------------------   
 -- CONTROL UNIT
 w_de_to_cu.opcode <= w_opcode; 
 w_de_to_cu.func3 <= w_func3; 
 w_de_to_cu.func7 <= w_func7; 
 w_de_to_cu.exbranch <= w_exbranch; 

 -- FORWARDING UNIT
 w_de_to_fwd.ders1adr <= w_rs1adr;  
 w_de_to_fwd.ders2adr <= w_rs2adr; 
 w_de_to_fwd.exregop <= w_exregop; 
 w_de_to_fwd.exrd <= w_exrd; 

 -- REGFILE
 w_de_to_regfile.regop <= w_exregop; 
 w_de_to_regfile.rd <= w_exrd; 
 w_de_to_regfile.rs1adr <= w_rs1adr; 
 w_de_to_regfile.rs2adr <= w_rs2adr; 
 w_de_to_regfile.wrin <= w_exres; 
 ----------------------------------------------------
 --|           ASSIGN OUTPUTS (external)            |
 ----------------------------------------------------    
 out_de_to_ex.rs1 <= w_fwdrs1; 
 out_de_to_ex.rs2 <= w_fwdrs2; 
 out_de_to_ex.rd <= w_rd; 
 out_de_to_ex.imm <= w_imm; 
 out_de_to_ex.muxrs1 <= w_cumuxrs1; 
 out_de_to_ex.muxrs2 <= w_cumuxrs2; 
 out_de_to_ex.alucntrl <= w_cualucntrl; 
 out_de_to_ex.muxalu <= w_cumuxalu; 
 out_de_to_ex.regop <= w_curegop; 
 out_de_to_ex.memop <= w_cumemop; 
 out_de_to_ex.branch <= w_cubranch; 
 out_de_to_ex.pc <= r_pc; 
 out_de_to_ex.pc4 <= r_pc4; 
 out_de_to_ex.branchadr <= w_branchadr; 

 out_de_to_fe.jaladr <= w_jaladr; 
 out_de_to_fe.jalradr <= w_jalradr; 
 out_de_to_fe.muxpc <= w_cumuxpc; 
 out_de_to_fe.muxnop <= w_cumuxnop; 
 out_de_to_fe.stall <= w_custallfe; 
end RTL;
