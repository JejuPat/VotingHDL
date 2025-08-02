----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 15:13:41
-- Design Name: 
-- Module Name: tag_generator - Behavioral
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

entity tag_generator is
    generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
              R : natural := 12;
              T : natural := 4; 
              S : natural := 16 );
    port ( record_in : in std_logic_vector(R - 1 downto 0);
           secret : in std_logic_vector(S - 1 downto 0);
           tag_out : out std_logic_vector(T - 1 downto 0) );
end tag_generator;

architecture Behavioral of tag_generator is


    constant B : natural := (R + T - 1) / T; -- B is number of blocks
    
    
    signal zero_ext_record : std_logic_vector((T * B) - 1 downto 0) := (others => '0');
    signal flip_record : std_logic_vector((T * B) - 1 downto 0) := (others => '0');
    signal swap_record : std_logic_vector((T * B) - 1 downto 0) := (others => '0');
    signal shift_record : std_logic_vector((T * B) - 1 downto 0) := (others => '0');
    -- the xor module output will go straight to tag_out
begin

    -- firstly, we will zero extend the record
    zero_ext_the_end : for i in 0 to R-1 generate
        zero_ext_record((T * B) - 1 - i) <= record_in((R - 1) - i);
    end generate;
    -- todo: implement tag generation algorithm, replace the output tag_out
    tag_out <= (others => '0');
end Behavioral;
