----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 13:56:36
-- Design Name: 
-- Module Name: sign_extender_n_to_m - Behavioral
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

entity sign_extender_n_to_m is
    generic ( N : integer := 12;
              M : integer := 16 );
    port ( input : in std_logic_vector(N - 1 downto 0);
           sign_ext_output : out std_logic_vector(M - 1 downto 0) := (others => '0') );
end sign_extender_n_to_m;

architecture Behavioral of sign_extender_n_to_m is

begin

    process ( input )
    begin
        if (input(N - 1) = '1') then
            sign_ext_output(M - 1 downto N) <= (others => '1');
        else 
            sign_ext_output(M - 1 downto N) <= (others => '0');
        end if;
        sign_ext_output(N - 1 downto 0) <= input; 
    end process;

end Behavioral;
