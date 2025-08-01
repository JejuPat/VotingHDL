----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 12:22:49
-- Design Name: 
-- Module Name: check_tags_equal - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity check_tags_equal is
    Generic (
        TAG_SIZE : integer := 4;
        ); 
    Port ( tag_a : in STD_LOGIC_VECTOR (TAG_SIZE - 1 downto 0);
           tag_b : in STD_LOGIC_VECTOR (TAG_SIZE - 1 downto 0);
           equal : out STD_LOGIC);
end check_tags_equal;

architecture Behavioral of check_tags_equal is

begin

    equal <= '1' when tag_a = tag_b else '0';

end Behavioral;
