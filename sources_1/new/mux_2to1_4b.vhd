----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.07.2025 16:37:33
-- Design Name: 
-- Module Name: mux_2to1_4b - Behavioral
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

entity mux_2to1_4b is
    Port ( src_0 : in STD_LOGIC_VECTOR (3 downto 0);
           src_1 : in STD_LOGIC_VECTOR (3 downto 0);
           sel : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (3 downto 0));
end mux_2to1_4b;

architecture Behavioral of mux_2to1_4b is
    
begin

    output <= src_0 when sel = '0' else
              src_1 when sel = '1' else 
              (others => 'X');

end Behavioral;
