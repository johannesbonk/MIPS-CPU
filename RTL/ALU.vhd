LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity alu is
  generic(g_REGISTER_WIDTH : integer := 32;
          g_CONTROL_WIDTH : integer := 4);
  port(in_op_a   : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       in_op_b   : in std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
       in_cntrl  : in std_logic_vector(g_CONTROL_WIDTH downto 0);

       out_zflag : out std_logic;
       out_res   : out std_logic_vector(g_REGISTER_WIDTH - 1 downto 0));
end;

architecture behavior of alu is
  signal w_arith_out : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_ano_out : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_xui_out : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_shft_out : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);
  signal w_res : std_logic_vector(g_REGISTER_WIDTH - 1 downto 0);

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

  w_res <= w_arith_out when in_cntrl(1 downto 0) = "00" else
           w_ano_out when in_cntrl(1 downto 0) = "01" else
           w_xui_out when in_cntrl(1 downto 0) = "10" else
           w_shft_out when in_cntrl(1 downto 0) = "11";

  out_zflag <= w_res(w_res'high);
  out_res <= w_res;
end behavior;
