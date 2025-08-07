----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 12:49:34
-- Design Name: 
-- Module Name: control_unit - Behavioral
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

entity control_unit is
    port ( record_process_en : in std_logic;
           opcode : in std_logic_vector(3 downto 0);
           do_branch : out std_logic;
           change_secret : out std_logic; 
           process_record : out std_logic );
end control_unit;

architecture Behavioral of control_unit is

    constant OP_RECORD : std_logic_vector(3 downto 0) := "0001";
    constant OP_SECRET : std_logic_vector(3 downto 0) := "0010";
    constant OP_BRANCH_UNCOND : std_logic_vector(3 downto 0) := "0100";
begin
    
    do_branch <= '1' when (opcode = OP_BRANCH_UNCOND) else
                 '0';
                 
    change_secret <= '1' when (opcode = OP_SECRET) else
                     '0';
           
    process_record <= '1' when (opcode = OP_RECORD and record_process_en = '1') else
                      '0';          

end Behavioral;
