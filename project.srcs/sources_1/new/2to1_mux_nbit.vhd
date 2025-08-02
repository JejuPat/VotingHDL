----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2025 14:21:55
-- Design Name: 
-- Module Name: 2to1_mux_nbit - Behavioral
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

entity mux_2to1_nbit is
    generic ( N : natural := 8 );
    port ( src_0, src_1 : in std_logic_vector(N - 1 downto 0);
           sel : in std_logic;
           data_out : out std_logic_vector(N - 1 downto 0) );
end mux_2to1_nbit;

architecture Behavioral of mux_2to1_nbit is
   
begin

    with sel select
        data_out <= src_0 when '0',
                    src_1 when others;

end Behavioral;
