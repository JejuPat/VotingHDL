----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 11:42:21
-- Design Name: 
-- Module Name: XOR_stage - Behavioral
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

entity XOR_stage is
    generic (
        TAG_SIZE : integer := 4
        );   
    Port ( in_a : in STD_LOGIC_VECTOR (TAG_SIZE - 1 downto 0);
           in_b : in STD_LOGIC_VECTOR (TAG_SIZE - 1 downto 0);
           in_c : in STD_LOGIC_VECTOR (TAG_SIZE - 1 downto 0);
           in_d : in STD_LOGIC_VECTOR (TAG_SIZE - 1 downto 0);
           xor_result : out STD_LOGIC_VECTOR (TAG_SIZE - 1 downto 0));
end XOR_stage;

architecture Behavioral of XOR_stage is

begin

    xor_result <= in_a xor in_b xor in_c xor in_d;
    
end Behavioral;
