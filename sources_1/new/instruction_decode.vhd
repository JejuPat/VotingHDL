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

entity instruction_decode is
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
end instruction_decode;

architecture Behavioral of instruction_decode is

component register_file is
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           read_register_a : in  std_logic_vector(3 downto 0);
           read_register_b : in  std_logic_vector(3 downto 0);
           write_enable    : in  std_logic;
           write_register  : in  std_logic_vector(3 downto 0);
           write_data      : in  std_logic_vector(15 downto 0);
           read_data_a     : out std_logic_vector(15 downto 0);
           read_data_b     : out std_logic_vector(15 downto 0) );
end component;

component control_unit is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
           mem_write  : out std_logic;
           mem_to_reg : out std_logic;
           do_branch  : out std_logic;
           led_reg_en : out std_logic;
           sw_read    : out std_logic );
end component;

component hazard_detection_unit is
    port ( prev_opcode : in STD_LOGIC_VECTOR (3 downto 0);
           prev_write_reg : in STD_LOGIC_VECTOR (3 downto 0);
           curr_opcode : in STD_LOGIC_VECTOR (3 downto 0);
           curr_src1 : in STD_LOGIC_VECTOR (3 downto 0);
           curr_src2 : in STD_LOGIC_VECTOR (3 downto 0);
           do_bubble : out STD_LOGIC);
end component;

component sign_extend_4to16 is
    port ( data_in  : in  std_logic_vector(3 downto 0);
           data_out : out std_logic_vector(15 downto 0) );
end component;

component s_adder_4b is
    port ( src_a     : in  std_logic_vector(3 downto 0);
           src_b     : in  std_logic_vector(3 downto 0);
           sum       : out std_logic_vector(3 downto 0) );
end component;

component mux_2to1_4b is
    port ( src_0 : in std_logic_vector(3 downto 0);
           src_1 : in std_logic_vector(3 downto 0);
           sel : in std_logic;
           output : out std_logic_vector(3 downto 0) );
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
    
    signal curr_pc : std_logic_vector(3 downto 0);
    signal curr_insn : std_logic_vector(15 downto 0);
    signal opcode, reg_src1, reg_src2, reg_write, imm_data : std_logic_vector(3 downto 0);
    signal imm_sign_ext : std_logic_vector(15 downto 0);
    signal src1_data, src2_data, src1_data_fwd, src2_data_fwd : std_logic_vector(15 downto 0);
    
    signal dst_sel : std_logic;
    signal do_bubble : std_logic;
    
    signal curr_EX_ctrl : std_logic_vector(1 downto 0);
    signal curr_MEM_ctrl : std_logic;
    signal curr_WB_ctrl : std_logic_vector(2 downto 0);
    signal do_sw : std_logic;
    signal curr_sw_val : std_logic_vector(15 downto 0);

begin

    -- IF/ID Pipeline Register
    REG_IF_ID : process ( reset, clk, do_bubble, clear_pipeline )
    begin
        if (reset = '1') then
            curr_pc <= (others => '0');
            curr_insn <= (others => '0');
            curr_sw_val <= (others => '0');
        elsif clk'event and clk = '1' then
            if (clear_pipeline = '1') then
                curr_pc <= (others => '0');
                curr_insn <= (others => '0');
                curr_sw_val <= (others => '0');
            elsif do_bubble = '0' then
                curr_pc <= next_pc;
                curr_insn <= next_insn;
                curr_sw_val <= sw;
            end if;
        end if;
    end process;

    opcode <= curr_insn(15 downto 12);
    reg_src1 <= curr_insn(11 downto 8);
    reg_src2 <= curr_insn(7 downto 4);
    imm_data <= curr_insn(3 downto 0);
    
    -- select which register is the dst reg
    reg_dst_mux : mux_2to1_4b
    port map ( src_0 => curr_insn(7 downto 4),
               src_1 => curr_insn(3 downto 0),
               sel => dst_sel,
               output => reg_write );
               
    -- sign extend the immediate data
    sign_extend : sign_extend_4to16 
    port map ( data_in  => imm_data,
               data_out => imm_sign_ext );

    -- Register File
    RF : register_file 
    port map ( reset => reset,
               clk => clk,
               read_register_a => reg_src1,
               read_register_b => reg_src2,
               write_enable => MEM_WB_write_en,
               write_register => MEM_WB_write_reg,
               write_data => MEM_WB_write_data,
               read_data_a => src1_data,
               read_data_b => src2_data );

    -- Hazard Detection Unit (see if we need to insert a bubble and pause pipeline
    HDU : hazard_detection_unit
    port map ( prev_opcode => ID_EX_opcode,
               prev_write_reg => ID_EX_write_reg,
               curr_opcode => opcode,
               curr_src1 => reg_src1,
               curr_src2 => reg_src2,
               do_bubble => do_bubble );
    
    ctrl : control_unit 
    port map ( opcode => opcode,
               reg_dst => dst_sel,
               reg_write => curr_WB_ctrl(0),
               alu_src => curr_EX_ctrl(0),
               mem_write => curr_MEM_ctrl,
               mem_to_reg => curr_WB_ctrl(1),
               do_branch => curr_EX_ctrl(1),
               led_reg_en => curr_WB_ctrl(2),
               sw_read => do_sw );
               
--    -- create the forwarding unit
--    FU : forwarding_unit 
--    port map ( src1_data => src1_data,
--               src2_data => src2_data,
--               src1_reg => reg_src1,
--               src2_reg => reg_src2,
--               WB_data => MEM_WB_write_data,
--               WB_dst => MEM_WB_write_reg,
--               WB_write => MEM_WB_write_en,
--               src1_fwd => src1_data_fwd,
--               src2_fwd => src2_data_fwd );
            
    -- handle output logic based on if we do a bubble
    pause_pipeline <= do_bubble;
    src1_out <= curr_sw_val when do_sw = '1' else
                src1_data;
    src2_out <= (others => '0') when do_sw = '1' else 
                src2_data;
    src1 <= (others => '0') when do_sw = '1' else
            reg_src1;
    src2 <= (others => '0') when do_sw = '1' else
            reg_src2;
    imm_out <= imm_sign_ext;
    write_reg <= reg_write;
    pc_out <= curr_pc;
    opcode_out <= opcode;
    EX_ctrl <= (others => '0') when do_bubble = '1' else
               curr_EX_ctrl;
    MEM_ctrl <= '0' when do_bubble = '1' else
                curr_MEM_ctrl;
    WB_ctrl <= (others => '0') when do_bubble = '1' else
                curr_WB_ctrl;
       
end Behavioral;
