----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.07.2025 14:51:10
-- Design Name: 
-- Module Name: execute - Behavioral
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

entity instruction_fetch is
    port ( clk, reset : in std_logic;
           branch_pc : in std_logic_vector(3 downto 0);
           do_branch, pause_pipeline : in std_logic;
           ID_pc : out std_logic_vector(3 downto 0);
           ID_insn : out std_logic_vector(15 downto 0) );
end instruction_fetch;

architecture Behavioral of instruction_fetch is

component program_counter is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(3 downto 0);
           addr_out : out std_logic_vector(3 downto 0) );
end component;

component instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(3 downto 0);
           insn_out : out std_logic_vector(15 downto 0) );
end component;

component adder_4b is
    port ( src_a     : in  std_logic_vector(3 downto 0);
           src_b     : in  std_logic_vector(3 downto 0);
           sum       : out std_logic_vector(3 downto 0) );
end component;

component mux_4to1_4b is
    port ( src_00, src_01, src_10, src_11 : in STD_LOGIC_VECTOR (3 downto 0);
           sel : in STD_LOGIC_VECTOR (1 downto 0);
           output : out STD_LOGIC_VECTOR (3 downto 0) );
end component;

component mux_2to1_16b is
    port ( src_0 : in STD_LOGIC_VECTOR (15 downto 0);
           src_1 : in STD_LOGIC_VECTOR (15 downto 0);
           sel : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (15 downto 0) );
end component;

    signal curr_pc, next_pc, pc_in, branch_pc_plus1 : std_logic_vector(3 downto 0);
    signal curr_insn : std_logic_vector(15 downto 0);
    
    signal one_4b : std_logic_vector(3 downto 0);
    signal zero_16b : std_logic_vector(15 downto 0);
    signal mux_sel : std_logic_vector(1 downto 0);

begin

    zero_16b <= (others => '0');
    one_4b <= "0001";
    mux_sel <= pause_pipeline & do_branch;
    
    ID_pc <= curr_pc;

    -- program counter is just a 4 bit register
    pc : program_counter
    port map ( reset => reset,
               clk => clk,
               addr_in => pc_in,
               addr_out => curr_pc );       

    -- instruction memory just returns the instruction at pc's array index
    IMEM : instruction_memory 
    port map ( reset => reset,
               clk => clk,
               addr_in => curr_pc,
               insn_out => curr_insn );
    
    -- calculate the next_pc
    pc_add : adder_4b 
    port map ( src_a => curr_pc,
               src_b => one_4b,
               sum => next_pc );
    
    branch_add : adder_4b
    port map ( src_a => branch_pc,
               src_b => one_4b,
               sum => branch_pc_plus1 );
    
    -- this processor has static prediction for no branch
    -- if pause_pipeline is true, pc_in is set to curr_pc
    -- if do_branch is true, pc_in is set to branch_pc
    -- otherwise, pc_in is set to pc_next
    pc_next : mux_4to1_4b
    port map ( src_00 => next_pc,
               src_01 => branch_pc_plus1,
               src_10 => curr_pc,
               src_11 => curr_pc,
               sel => mux_sel,
               output => pc_in );
           
    -- if do_branch is true, then the next instruction is a no-op
    -- else the next instruction is curr_insn    
    insn_next : mux_2to1_16b 
    port map ( src_0 => curr_insn,
               src_1 => zero_16b,
               sel => do_branch,
               output => ID_insn );
end Behavioral;
