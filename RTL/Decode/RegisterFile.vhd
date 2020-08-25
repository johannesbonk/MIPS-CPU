LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.common.ALL;

entity RegisterFile is
  port(in_ext_to_all     : in ext_to_all_t;
       in_de_to_regfile  : in de_to_regfile_t;
       out_regfile_to_de : out regfile_to_de_t);
end RegisterFile;


architecture RTL of RegisterFile is
  type reg_t is array(0 to 2**(regadr_t'length)) of reglen_t;
  signal r_reg_file : reg_t := (others => (others => '0'));
begin
  p_REG_FILE : process (in_ext_to_all.clk) is
  begin
    if rising_edge(in_ext_to_all.clk) then
      r_reg_file <= r_reg_file;
      if(in_ext_to_all.clr = '1') then 
        r_reg_file <= (others => (others => '0'));
      elsif((in_de_to_regfile.regop = c_REG_WE) and (in_de_to_regfile.rd /= b"00000")) then
        r_reg_file(to_integer(unsigned(in_de_to_regfile.rd))) <= in_de_to_regfile.wrin;
      end if; 
    end if;
  end process p_REG_FILE;

  out_regfile_to_de.rs1 <= r_reg_file(to_integer(unsigned(in_de_to_regfile.rs1adr)));
  out_regfile_to_de.rs2 <= r_reg_file(to_integer(unsigned(in_de_to_regfile.rs2adr)));
end RTL;
