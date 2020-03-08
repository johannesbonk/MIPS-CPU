LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.common.ALL;

entity BranchTargetUnit is
  port(in_ext_to_all  : in ext_to_all _t;
       in_de_to_btu   : in de_to_btu_t;
       out_btu_to_de  : out btu_to_de_t);
end BranchTargetUnit;


architecture behavior of BranchTargetUnit is
  signal w_pcbranch : reglen_t;
  signal w_pcnobranch : reglen_t;
begin
  w_pcbranch <= std_logic_vector(unsigned(in_de_to_btu.pc) + unsigned(in_de_to_btu.displace)); 
  w_pcnobranch <= in_de_to_btu.pc4;
  p_SET_NOP: process(in_ext_to_all.clk) is
    if(in_de_to_btu.opcode = b"11000") then
      out_btu_to_de.muxnop <= c_MUXNOP_NOP;
    else
      out_btu_to_de.muxnop <= c_MUXNOP_OP;
    end if;
  end process;
  p_SET_PC: process(in_de_to_btu.eq, in_de_to_btu.lt, in_de_to_btu.ltu) is
    if((in_de_to_btu.eq or in_de_to_btu.lt or in_de_to_btu.ltu) = '1') then
      out_btu_to_de.pcnext <= w_pcbranch;
    else
      out_btu_to_de.pcnext <= w_pcnobranch;
    end if;
  end process;
end behavior;
