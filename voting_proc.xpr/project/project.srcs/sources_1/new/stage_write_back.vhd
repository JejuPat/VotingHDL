----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2025 14:19:59
-- Design Name: 
-- Module Name: stage_write_back - Behavioral
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

entity stage_write_back is
    generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
              R : natural := 12;
              T : natural := 4 );
    port ( clk, reset : in std_logic;
           write_en_in : in std_logic;
           addr_in : in std_logic_vector((C * (D + 1)) - 1 downto 0);
           tally_in : in std_logic_vector((R + T) - 1 downto 0);
           data_in : in std_logic_vector((R + T) - 1 downto 0); 
           write_en_out : out std_logic;
           addr_out : out std_logic_vector((C * (D + 1)) - 1 downto 0);
           write_data_out : out std_logic_vector((R + T) - 1 downto 0) );
end stage_write_back;

architecture Behavioral of stage_write_back is

    -- components
    component nbit_saturation_adder is
        generic ( N : natural := 16 ); 
        port ( src_0 : in std_logic_vector(N - 1 downto 0);
               src_1 : in std_logic_vector(N - 1 downto 0);
               res : out std_logic_vector(N - 1 downto 0) );
    end component;

    -- signals for the pipeline register
    signal write_en_curr : std_logic;
    signal addr_curr : std_logic_vector((C * (D + 1)) - 1 downto 0);
    signal tally_curr, data_curr : std_logic_vector((R + T) - 1 downto 0);
begin

    -- pipeline register for EX/MEM
    MEM_EX_reg: process ( clk, reset )
    begin
        if (reset = '1') then
            write_en_curr <= '0';
            addr_curr <= (others => '0');
            tally_curr <= (others => '0');
            data_curr <= (others => '0');
        elsif (clk = '1' and clk'event) then
            write_en_curr <= write_en_in;
            addr_curr <= addr_in;
            tally_curr <= tally_in;
            data_curr <= data_in;
        end if;
    end process; 
    
    -- saturation adder for new overall tally
    sat_adder: nbit_saturation_adder
        generic map ( N => R + T )
        port map ( src_0 => tally_curr,
                   src_1 => data_curr,
                   res => write_data_out );

    -- handle the other outputs
    write_en_out <= write_en_curr;
    addr_out <= addr_curr;
end Behavioral;
