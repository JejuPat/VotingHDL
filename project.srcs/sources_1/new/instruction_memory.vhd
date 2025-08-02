----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 12:49:34
-- Design Name: 
-- Module Name: instruction_memory - Behavioral
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

entity instruction_memory is
    port ( pc_in : in std_logic_vector(15 downto 0);
           instr_out : out std_logic_vector(15 downto 0) );
end instruction_memory;

architecture Behavioral of instruction_memory is
    type instr_mem_format is array(0 to 2 ** 16 - 1) of std_logic_vector(15 downto 0);
    signal instr_mem : instr_mem_format := (others => (others => '0'));
    
    constant OP_RECORD : std_logic_vector(3 downto 0) := "0001";
    constant OP_SECRET : std_logic_vector(3 downto 0) := "0010";
    constant OP_BRANCH_UNCOND : std_logic_vector(3 downto 0) := "0100";
begin
    -- handle instruction output
    instr_out <= instr_mem(to_integer(unsigned(pc_in)));

    -- define a sequency of instructions;
    instr_mem(0) <= X"2000";    -- set secret X"2XXX"
    instr_mem(1) <= X"1000";    -- handle record X"1XXX"
    instr_mem(2) <= X"4FFE";    -- unconditional branch -2 (back to instruction 1) X"4FFE"
end Behavioral;
