----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2025 14:21:55
-- Design Name: 
-- Module Name: data_memory - Behavioral
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

entity data_memory is
    generic ( C, D : natural := 2;
              R : natural := 12;
              T : natural := 4 );
    port ( clk, reset : in std_logic;
           write_en : in std_logic;
           read_addr, write_addr : in std_logic_vector((C * (D + 1)) - 1 downto 0);
           write_data : in std_logic_vector((R + T) - 1 downto 0);
           data_out : out std_logic_vector((R + T) - 1 downto 0) );
end data_memory;

architecture Behavioral of data_memory is
    type table_t is array(0 to (((2 ** C) * ((2 ** D) + 1)) - 1)) of std_logic_vector((R + T) - 1 downto 0);
    signal vote_table : table_t := (others => (others => '0'));
begin
    write_to_mem: process(clk, reset, write_en, write_addr, write_data) 
    begin
        if (reset = '1') then
            vote_table <= (others => (others => '0'));
        elsif (clk = '1' and clk'event) then
            if (write_en = '1') then
                vote_table(to_integer(unsigned(write_addr))) <= write_data;
            end if;
        end if;
    end process;
    
    data_out <= vote_table(to_integer(unsigned(read_addr)));

end Behavioral;
