----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.07.2025 14:49:48
-- Design Name: 
-- Module Name: multi_cycle_core - Behavioral
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

entity multi_cycle_core is
    port ( clk, reset : in std_logic;
           sw : in std_logic_vector(15 downto 0);
           led : out std_logic_vector(15 downto 0) );
end multi_cycle_core;

architecture Behavioral of multi_cycle_core is
    
component instruction_fetch is
    port ( clk, reset : in std_logic;
           branch_pc : in std_logic_vector(3 downto 0);
           do_branch, pause_pipeline : in std_logic;
           ID_pc : out std_logic_vector(3 downto 0);
           ID_insn : out std_logic_vector(15 downto 0) );
end component;

component instruction_decode is
    port ( clk, reset : in std_logic;
           sw : in std_logic_vector(15 downto 0);
           clear_pipeline : in std_logic;
           next_pc : in std_logic_vector(3 downto 0);
           next_insn : in std_logic_vector(15 downto 0);
           ID_EX_opcode : in std_logic_vector(3 downto 0);
           ID_EX_write_reg : in std_logic_vector(3 downto 0);
           MEM_WB_write_en : in std_logic;
           MEM_WB_write_reg : in std_logic_vector(3 downto 0);
           MEM_WB_write_data : in std_logic_vector (15 downto 0); 
           pause_pipeline : out std_logic;
           src1_out, src2_out, imm_out : out std_logic_vector(15 downto 0);
           src1, src2, write_reg : out std_logic_vector(3 downto 0);
           pc_out : out std_logic_vector(3 downto 0);
           opcode_out : out std_logic_vector(3 downto 0);
           EX_ctrl : out std_logic_vector(1 downto 0);
           MEM_ctrl : out std_logic;
           WB_ctrl : out std_logic_vector(2 downto 0) );
end component;

component execute is 
    port ( clk, reset : in std_logic;
           src1_data_in, src2_data_in, imm_data_in : in std_logic_vector(15 downto 0);
           src1_in, src2_in, write_reg_in : in std_logic_vector(3 downto 0);
           pc_in : in std_logic_vector(3 downto 0);
           opcode_in : in std_logic_vector(3 downto 0);
           EX_ctrl_in : in std_logic_vector(1 downto 0);
           MEM_ctrl_in : in std_logic;
           WB_ctrl_in : in std_logic_vector(2 downto 0);
           EX_MEM_write, MEM_WB_write : in std_logic; 
           EX_MEM_dst, MEM_WB_dst : in std_logic_vector(3 downto 0);
           EX_MEM_data, MEM_WB_data : in std_logic_vector(15 downto 0);
           do_branch : out std_logic;
           pc_out : out std_logic_vector(3 downto 0);
           opcode_out : out std_logic_vector(3 downto 0);
           alu_out : out std_logic_vector(15 downto 0);
           src2_data_out : out std_logic_vector(15 downto 0);
           write_reg_out : out std_logic_vector(3 downto 0);
           MEM_ctrl_out : out std_logic;
           WB_ctrl_out : out std_logic_vector(2 downto 0) );
end component;

component memory_fetch is
    port ( clk, reset : in std_logic;
           alu_res_in : in std_logic_vector(15 downto 0);
           src2_data_in : in std_logic_vector(15 downto 0);
           write_reg_in : in std_logic_vector(3 downto 0);
           MEM_ctrl_in : in std_logic;
           WB_ctrl_in : in std_logic_vector(2 downto 0);
           MEM_write : out std_logic;
           write_reg_out : out std_logic_vector(3 downto 0);
           mem_data_fwd : out std_logic_vector(15 downto 0);
           mem_data_out, alu_data_out : out std_logic_vector(15 downto 0);
           WB_ctrl_out : out std_logic_vector(2 downto 0) );
end component;

component write_back is
    port ( clk, reset : in std_logic;
           write_reg_in : in std_logic_vector(3 downto 0);
           mem_data_in, alu_data_in : in std_logic_vector(15 downto 0);
           WB_ctrl_in : in std_logic_vector(2 downto 0);
           WB_write : out std_logic;
           WB_write_reg : out std_logic_vector(3 downto 0);
           WB_data_out : out std_logic_vector(15 downto 0);
           led : out std_logic_vector(15 downto 0) );
end component;

signal sig_branch_pc : std_logic_vector(3 downto 0);
signal sig_branch_do : std_logic; 
signal sig_pause_pipeline : std_logic;
signal sig_ID_pc_in : std_logic_vector(3 downto 0);
signal sig_ID_insn : std_logic_vector(15 downto 0);
signal sig_WB_write : std_logic;
signal sig_WB_dst_reg : std_logic_vector(3 downto 0);
signal sig_WB_data : std_logic_vector(15 downto 0);
signal sig_ID_src1_data : std_logic_vector(15 downto 0);
signal sig_ID_src2_data : std_logic_vector(15 downto 0);
signal sig_ID_imm_data : std_logic_vector(15 downto 0);
signal sig_ID_src1_reg : std_logic_vector(3 downto 0);
signal sig_ID_src2_reg : std_logic_vector(3 downto 0);
signal sig_ID_dst_reg : std_logic_vector(3 downto 0);
signal sig_ID_pc_out : std_logic_vector(3 downto 0);
signal sig_ID_opcode_out : std_logic_vector(3 downto 0);
signal sig_ID_EX_ctrl : std_logic_vector(1 downto 0);
signal sig_ID_MEM_ctrl : std_logic;
signal sig_ID_WB_ctrl : std_logic_vector(2 downto 0);
signal sig_MEM_write : std_logic;
signal sig_MEM_dst_reg : std_logic_vector(3 downto 0);
signal sig_MEM_data : std_logic_vector(15 downto 0);
signal sig_MEM_fwd : std_logic_vector(15 downto 0);
signal sig_EX_alu_out : std_logic_vector(15 downto 0);
signal sig_EX_src2_out : std_logic_vector(15 downto 0);
signal sig_EX_opcode : std_logic_vector(3 downto 0);
signal sig_EX_dst_reg : std_logic_vector(3 downto 0);
signal sig_EX_MEM_ctrl : std_logic;
signal sig_EX_WB_ctrl : std_logic_vector(2 downto 0);
signal sig_MEM_alu_out : std_logic_vector(15 downto 0);
signal sig_MEM_WB_ctrl : std_logic_vector(2 downto 0);

begin

        I_F : instruction_fetch 
        port map ( clk => clk,
                   reset => reset,
                   branch_pc => sig_branch_pc,
                   do_branch => sig_branch_do,
                   pause_pipeline => sig_pause_pipeline,
                   ID_pc => sig_ID_pc_in,
                   ID_insn => sig_ID_insn );

        ID : instruction_decode
        port map ( clk => clk,
                   reset => reset,
                   sw => sw,
                   clear_pipeline => sig_branch_do,
                   next_pc => sig_ID_pc_in,
                   next_insn => sig_ID_insn,
                   ID_EX_opcode => sig_EX_opcode,
                   ID_EX_write_reg => sig_EX_dst_reg, 
                   MEM_WB_write_en => sig_WB_write,
                   MEM_WB_write_reg => sig_WB_dst_reg,
                   MEM_WB_write_data => sig_WB_data,
                   pause_pipeline => sig_pause_pipeline,
                   src1_out => sig_ID_src1_data,
                   src2_out => sig_ID_src2_data,
                   imm_out => sig_ID_imm_data,
                   src1 => sig_ID_src1_reg,
                   src2 => sig_ID_src2_reg,
                   write_reg => sig_ID_dst_reg,
                   pc_out => sig_ID_pc_out,
                   opcode_out => sig_ID_opcode_out,
                   EX_ctrl => sig_ID_EX_ctrl,
                   MEM_ctrl => sig_ID_MEM_ctrl,
                   WB_Ctrl => sig_ID_WB_ctrl );
        
        EX : execute
        port map ( clk => clk,
                   reset => reset,
                   src1_data_in => sig_ID_src1_data,
                   src2_data_in => sig_ID_src2_data,
                   imm_data_in => sig_ID_imm_data,
                   src1_in => sig_ID_src1_reg,
                   src2_in => sig_ID_src2_reg,
                   write_reg_in => sig_ID_dst_reg,
                   pc_in => sig_ID_pc_out,
                   opcode_in => sig_ID_opcode_out,
                   EX_ctrl_in => sig_ID_EX_ctrl,
                   MEM_ctrl_in => sig_ID_MEM_ctrl,
                   WB_ctrl_in => sig_ID_WB_ctrl,
                   EX_MEM_write => sig_MEM_write,
                   MEM_WB_write => sig_WB_write,
                   EX_MEM_dst => sig_MEM_dst_reg,
                   MEM_WB_dst => sig_WB_dst_reg,
                   EX_MEM_data => sig_MEM_fwd,
                   MEM_WB_data => sig_WB_data,
                   do_branch => sig_branch_do,
                   pc_out => sig_branch_pc,
                   opcode_out => sig_EX_opcode,
                   alu_out => sig_EX_alu_out,
                   src2_data_out => sig_EX_src2_out,
                   write_reg_out => sig_EX_dst_reg,
                   MEM_ctrl_out => sig_EX_MEM_ctrl,
                   WB_ctrl_out => sig_EX_WB_ctrl );
        
        MEM : memory_fetch 
        port map ( clk => clk,
                   reset => reset,
                   alu_res_in => sig_EX_alu_out,
                   src2_data_in => sig_EX_src2_out,
                   write_reg_in => sig_EX_dst_reg,
                   MEM_ctrl_in => sig_EX_MEM_ctrl,
                   WB_ctrl_in => sig_EX_WB_ctrl,
                   MEM_write => sig_MEM_write,
                   write_reg_out => sig_MEM_dst_reg,
                   mem_data_fwd => sig_MEM_fwd,
                   mem_data_out => sig_MEM_data,
                   alu_data_out => sig_MEM_alu_out,
                   WB_ctrl_out => sig_MEM_WB_ctrl );
        
        WB : write_back
        port map ( clk => clk,
                   reset => reset,
                   write_reg_in => sig_MEM_dst_reg,
                   mem_data_in => sig_MEM_data,
                   alu_data_in => sig_MEM_alu_out,
                   WB_ctrl_in => sig_MEM_WB_ctrl,
                   WB_write => sig_WB_write,
                   WB_write_reg => sig_WB_dst_reg,
                   WB_data_out => sig_WB_data,
                   led =>led );

end Behavioral;
