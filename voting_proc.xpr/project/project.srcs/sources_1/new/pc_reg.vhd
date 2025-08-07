----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 12:53:17
-- Design Name: 
-- Module Name: pc_reg - Behavioral
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

entity pc_reg is
    port ( clk, reset : in std_logic;
           stall_pipeline : in std_logic;
           pc_next : in std_logic_vector(15 downto 0);
           pc_out : out std_logic_vector(15 downto 0) );
end pc_reg;

architecture Behavioral of pc_reg is
    -- pc reg signal
    signal pc_curr : std_logic_vector(15 downto 0);
begin
    process ( clk, reset )
    begin
        if (reset = '1') then
            pc_curr <= (others => '0');
        elsif (clk = '1' and clk'event) then
            if (stall_pipeline = '0') then
                pc_curr <= pc_next;
            end if;      
        end if;
    end process;


    pc_out <= pc_curr;
    
end Behavioral;
