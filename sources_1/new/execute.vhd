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

entity execute is
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
end execute;

architecture Behavioral of execute is

component s_adder_4b is
    port ( src_a     : in  std_logic_vector(3 downto 0);
           src_b     : in  std_logic_vector(3 downto 0);
           sum       : out std_logic_vector(3 downto 0) );
end component;

component mux_2to1_16b is
    port ( src_0 : in STD_LOGIC_VECTOR (15 downto 0);
           src_1 : in STD_LOGIC_VECTOR (15 downto 0);
           sel : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (15 downto 0) );
end component;

component adder_16b is
    port ( src_a     : in  std_logic_vector(15 downto 0);
           src_b     : in  std_logic_vector(15 downto 0);
           sum       : out std_logic_vector(15 downto 0) );
end component;

component forwarding_unit is
    port ( src1_data : in STD_LOGIC_VECTOR (15 downto 0);
           src2_data : in STD_LOGIC_VECTOR (15 downto 0);
           src1_reg : in STD_LOGIC_VECTOR (3 downto 0);
           src2_reg : in STD_LOGIC_VECTOR (3 downto 0);
           MEM_data : in STD_LOGIC_VECTOR (15 downto 0);
           MEM_dst : in STD_LOGIC_VECTOR (3 downto 0);
           MEM_write : in STD_LOGIC;
           WB_data : in STD_LOGIC_VECTOR (15 downto 0);
           WB_dst : in STD_LOGIC_VECTOR (3 downto 0);
           WB_write : in STD_LOGIC; 
           src1_fwd : out STD_LOGIC_VECTOR (15 downto 0); 
           src2_fwd : out STD_LOGIC_VECTOR(15 downto 0) );
end component;

    signal src1, src2, write_reg, pc : std_logic_vector(3 downto 0);
    signal src1_data, src2_data, imm_data : std_logic_vector(15 downto 0);
    signal EX_ctrl : std_logic_vector(1 downto 0);
    signal MEM_ctrl : std_logic;
    signal WB_ctrl : std_logic_vector(2 downto 0);
    signal curr_opcode : std_logic_vector(3 downto 0);

    signal src1_fwd, src2_fwd : std_logic_vector(15 downto 0);
    signal alu_src2 : std_logic_vector(15 downto 0);
    signal sig_do_branch : std_logic;

begin

    -- ID/EX pipeline register
    REG_ID_EX : process ( reset, clk )
    begin
        if (reset = '1') then
            src1 <= (others => '0');
            src2 <= (others => '0');
            write_reg <= (others => '0');
            pc <= (others => '0');
            curr_opcode <= (others => '0');
            
            src1_data <= (others => '0');
            src2_data <= (others => '0');
            imm_data <= (others => '0');
            
            EX_ctrl <= "00";
            MEM_ctrl <= '0';
            WB_ctrl <= "000";
            
        elsif clk'event and clk = '1' then
            if (sig_do_branch = '1') then
                src1 <= (others => '0');
                src2 <= (others => '0');
                write_reg <= (others => '0');
                pc <= (others => '0');
                curr_opcode <= (others => '0');
                
                src1_data <= (others => '0');
                src2_data <= (others => '0');
                imm_data <= (others => '0');
                
                EX_ctrl <= "00";
                MEM_ctrl <= '0';
                WB_ctrl <= "000";
            else 
                src1 <= src1_in;
                src2 <= src2_in;
                write_reg <= write_reg_in;
                pc <= pc_in;
                curr_opcode <= opcode_in;
                
                src1_data <= src1_data_in;
                src2_data <= src2_data_in;
                imm_data <= imm_data_in;
                
                EX_ctrl <= EX_ctrl_in;
                MEM_ctrl <= MEM_ctrl_in;
                WB_ctrl <= WB_ctrl_in;
            end if;
        end if;
    end process;

    -- create the forwarding unit
    FU : forwarding_unit 
    port map ( src1_data => src1_data,
               src2_data => src2_data,
               src1_reg => src1,
               src2_reg => src2,
               MEM_data => EX_MEM_data,
               MEM_dst => EX_MEM_dst,
               MEM_write => EX_MEM_write,
               WB_data => MEM_WB_data,
               WB_dst => MEM_WB_dst,
               WB_write => MEM_WB_write,
               src1_fwd => src1_fwd,
               src2_fwd => src2_fwd );
               
    -- pc adder
    next_pc : s_adder_4b
    port map ( src_a => pc,
               src_b => imm_data(3 downto 0),
               sum => pc_out );
  
  
    -- mux for alu src2 select
    mux_alu_src_sel : mux_2to1_16b
    port map ( src_0 => src2_fwd,
               src_1 => imm_data,
               sel => EX_ctrl(0),
               output => alu_src2 );
            
    -- adder
    alu : adder_16b 
    port map ( src_a => src1_fwd,
               src_b => alu_src2,
               sum => alu_out );   

    -- handle other outputs
    sig_do_branch <= '1' when (src1_fwd = src2_fwd and EX_ctrl(1) = '1') else
                 '0';
                 
    do_branch <= sig_do_branch;
    src2_data_out <= src2_fwd;
    write_reg_out <= write_reg;
    MEM_ctrl_out <= MEM_ctrl;
    WB_ctrl_out <= WB_ctrl;
    opcode_out <= curr_opcode;
    
end Behavioral;
