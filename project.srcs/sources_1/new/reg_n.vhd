----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 15:06:07
-- Design Name: 
-- Module Name: reg_n - Behavioral
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

entity reg_n is
    generic ( N : natural := 8 );
    port ( clk, reset : in std_logic;
           input : in std_logic_vector(N - 1 downto 0);
           enable : in std_logic;
           output : out std_logic_vector(N - 1 downto 0) );
end reg_n;

architecture Behavioral of reg_n is

begin

    process( clk, reset, enable )
    begin
        if (reset = '1') then
            output <= (others => '0');
        elsif (clk = '1' and clk'event) then
            if (enable = '1') then
                output <= input;
            end if;
        end if;
    end process;

end Behavioral;
