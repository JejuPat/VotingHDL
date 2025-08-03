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
    Generic (
        TAG_SIZE : natural := 4;
        PADDED_RECORD_SIZE : natural := 16
        );   
        
    Port ( shifted_record : in STD_LOGIC_VECTOR (PADDED_RECORD_SIZE - 1 downto 0);
           xor_result : out STD_LOGIC_VECTOR (TAG_SIZE - 1 downto 0));
end XOR_stage;

architecture Behavioral of XOR_stage is
    type my_array is array(PADDED_RECORD_SIZE / TAG_SIZE DOWNTO 0) OF STD_LOGIC_VECTOR(TAG_SIZE DOWNTO 0);
    signal running_xor : my_array := (others => (others => '0'));

begin

--    xor_result <= in_a xor in_b xor in_c xor in_d;

    
    gen_xor: for I in 0 to PADDED_RECORD_SIZE / TAG_SIZE - 1 generate
        xor_stage: running_xor(I+1) <= running_xor(I) xor shifted_record(TAG_SIZE + TAG_SIZE * I downto TAG_SIZE * I);
    end generate gen_xor;
    
    xor_result <= running_xor(PADDED_RECORD_SIZE / TAG_SIZE);
    
end Behavioral;
