-- Shift component that takes in 4 different lines
-- and rotates left a selected line by a defined number
-- of bits
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift is
    port(
        i_a, i_b, i_c, i_d  : in std_logic_vector(3 downto 0);
        i_bs                : in std_logic_vector(1 downto 0);
        i_r                 : in std_logic_vector(1 downto 0);
        o_shift             : out std_logic_vector(3 downto 0)
    );
end entity;

architecture behavioural of shift is
    signal sig_reg : std_logic_vector(3 downto 0);
begin
    with i_bs select 
        sig_reg <= i_a when "00",
                   i_b when "01",
                   i_c when "10",
                   i_d when "11",
                   i_a when others;
    
    o_shift <= std_logic_vector(rotate_left(unsigned(sig_reg), to_integer(unsigned(i_r))));

end behavioural;