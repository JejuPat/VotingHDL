----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 12:49:34
-- Design Name: 
-- Module Name: next_pc_calc - Behavioral
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
use IEEE.STD_LOGIC_SIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity next_pc_calc is
    port ( do_branch : in std_logic;
           pc_curr : in std_logic_vector(15 downto 0);
           sign_ext_imm : in std_logic_vector(15 downto 0);
           pc_next : out std_logic_vector(15 downto 0) );
end next_pc_calc;

architecture Behavioral of next_pc_calc is

    component mux_2to1_nbit is
        generic ( N : natural := 8 );
        port ( src_0, src_1 : in std_logic_vector(N - 1 downto 0);
               sel : in std_logic;
               data_out : out std_logic_vector(N - 1 downto 0) );
    end component;


    signal pc_plus_one : std_logic_vector(15 downto 0);
    signal pc_branch : std_logic_vector(15 downto 0);
    constant one_16b : std_logic_vector(15 downto 0) := X"0001";
begin


    -- calculate next pcs
    pc_plus_one <= pc_curr + one_16b;
    pc_branch <= pc_plus_one + sign_ext_imm;
    
    -- mux to choose the pc after that
    branch_mux : mux_2to1_nbit 
        generic map ( N => 16 )
        port map ( src_0 => pc_plus_one,
                   src_1 => pc_branch,
                   sel => do_branch,
                   data_out => pc_next );

end Behavioral;
