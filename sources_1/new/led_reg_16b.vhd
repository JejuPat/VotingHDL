----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.06.2025 12:39:13
-- Design Name: 
-- Module Name: led_reg_16b - Behavioral
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

entity led_reg_16b is
    Port ( led_reg_in : in STD_LOGIC_VECTOR (15 downto 0);
           led_reg_en : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           led_reg_Q : out STD_LOGIC_VECTOR (15 downto 0));
end led_reg_16b;

architecture Behavioral of led_reg_16b is

begin
    led_reg_process : process ( clk, reset, led_reg_in, led_reg_en )
    begin
    
        if (reset = '1') then
            led_reg_Q <= (OTHERS => '0');
        elsif clk = '1' and clk'EVENT then
            if led_reg_en = '1' then
                led_reg_Q <= led_reg_in;
            end if;
        end if; 
    end process;

end Behavioral;
