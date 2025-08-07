----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2025 17:01:11
-- Design Name: 
-- Module Name: saturation_adder - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nbit_saturation_adder is
    generic ( N : natural := 16 ); 
    port ( src_0 : in std_logic_vector(N - 1 downto 0);
           src_1 : in std_logic_vector(N - 1 downto 0);
           res : out std_logic_vector(N - 1 downto 0) );
end nbit_saturation_adder;

architecture Behavioral of nbit_saturation_adder is

    signal src_0_ext, src_1_ext, res_ext : std_logic_vector(N downto 0) := (others => '0');

begin
    src_0_ext(N - 1 downto 0) <= src_0;
    src_1_ext(N - 1 downto 0) <= src_1;
    
    res_ext <= src_0_ext + src_1_ext;

    with (res_ext(N)) select
        res <= res_ext(N - 1 downto 0) when '0',
               (others => '1') when others;

end Behavioral;
