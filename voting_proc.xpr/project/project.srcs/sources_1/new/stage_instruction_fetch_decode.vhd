----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 12:49:34
-- Design Name: 
-- Module Name: stage_instruction_fetch_decode - Behavioral
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

entity stage_instruction_fetch_decode is
    generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
              R : natural := 12;
              T : natural := 4 );
    port ( clk, reset : in std_logic;
           record_process_en_in : in std_logic;
           stall_pipeline : in std_logic;
           record_process_en_out : out std_logic;
           change_secret : out std_logic );
end stage_instruction_fetch_decode;

architecture Behavioral of stage_instruction_fetch_decode is
    -- define the components
    component pc_reg is
        port ( clk, reset : in std_logic;
               stall_pipeline : in std_logic;
               pc_next : in std_logic_vector(15 downto 0);
               pc_out : out std_logic_vector(15 downto 0) );
    end component;
    
    component next_pc_calc is
        port ( do_branch : in std_logic;
               pc_curr : in std_logic_vector(15 downto 0);
               sign_ext_imm : in std_logic_vector(15 downto 0);
               pc_next : out std_logic_vector(15 downto 0) );
    end component;
    
    component instruction_memory is
        port ( pc_in : in std_logic_vector(15 downto 0);
               instr_out : out std_logic_vector(15 downto 0) );
    end component;
    
    component control_unit is
        port ( record_process_en : in std_logic;
               opcode : in std_logic_vector(3 downto 0);
               do_branch : out std_logic;
               change_secret : out std_logic; 
               process_record : out std_logic );
    end component;
    
    component sign_extender_n_to_m is
        generic ( N : integer := 12;
                  M : integer := 16 );
        port ( input : in std_logic_vector(N - 1 downto 0);
               sign_ext_output : out std_logic_vector(M - 1 downto 0) := (others => '0') );
    end component;
    
    -- define the signals for program counter calc
    signal curr_pc, next_pc, sign_ext_imm : std_logic_vector(15 downto 0);
    signal do_branch : std_logic;
    signal curr_instr : std_logic_vector(15 downto 0);

begin

    -- define the pc register
    pc_reg_def : pc_reg
        port map ( clk => clk,
                   reset => reset,
                   stall_pipeline => stall_pipeline,
                   pc_next => next_pc,
                   pc_out => curr_pc );

    -- define the next pc calc
    pc_next_get : next_pc_calc
        port map ( do_branch => do_branch,
                   pc_curr => curr_pc,
                   sign_ext_imm => sign_ext_imm,
                   pc_next => next_pc );
   
    -- define the instruction memory
    IMEM : instruction_memory
        port map ( pc_in => curr_pc,
                   instr_out => curr_instr );
                   
    -- define control unit
    ctrl_unit : control_unit
        port map ( record_process_en => record_process_en_in,
                   opcode => curr_instr(15 downto 12),
                   do_branch => do_branch,
                   change_secret => change_secret,
                   process_record => record_process_en_out );
              
    -- define sign extender for branching
    sign_ext : sign_extender_n_to_m
        generic map ( N => 12,
                      M => 16 )
        port map ( input => curr_instr(11 downto 0),
                   sign_ext_output => sign_ext_imm );

end Behavioral;
