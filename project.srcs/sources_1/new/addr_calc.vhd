----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2025 15:56:11
-- Design Name: 
-- Module Name: addr_calc - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity addr_calc is
    generic ( C, D : natural := 2;
              R : natural := 12 );
    port ( district, candidate : in std_logic_vector(R - 1 downto 0);
           addr : out std_logic_vector((C * (D + 1)) - 1 downto 0) );
end addr_calc;

architecture Behavioral of addr_calc is
    signal district_int, candidate_int, addr_int: natural;
begin
    -- addr = district * (2 ^ C) + candidate 
    district_int <= to_integer(unsigned(district));
    candidate_int <= to_integer(unsigned(candidate));
    addr_int <= district_int * (2 ** C) + candidate_int;
    
    addr <= std_logic_vector(to_unsigned(addr_int, addr'length));

end Behavioral;
