----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2025 14:12:37
-- Design Name:  
-- Module Name: voting_proc - Behavioral
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

entity voting_proc is
    generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
              R : natural := 12;
              T : natural := 4; 
              S : natural := 16 );
    port ( clk, reset : in std_logic;    -- note: valid is a temporary signal for testing until TAG stage implemented
           process_tag_en : in std_logic;
           secret_in : in std_logic_vector(S - 1 downto 0);
           record_tag_in : in std_logic_vector((R + T) - 1 downto 0);
           curr_write_addr : out std_logic_vector((C * (D + 1)) - 1 downto 0);
           curr_write_data : out std_logic_vector((R + T) - 1 downto 0) );
end voting_proc;

architecture Behavioral of voting_proc is

    -- define the components (stages)
    component stage_instruction_fetch_decode is
        generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
                  R : natural := 12;
                  T : natural := 4 );
        port ( clk, reset : in std_logic;
               record_process_en_in : in std_logic;
               stall_pipeline : in std_logic;
               record_process_en_out : out std_logic;
               change_secret : out std_logic );
    end component;
    
    component stage_tag_gen is
        generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
                  R : natural := 12;
                  T : natural := 4; 
                  S : natural := 16 );
        port ( clk, reset : in std_logic;
               record_in : in std_logic_vector(R - 1 downto 0);
               tag_in : in std_logic_vector(T - 1 downto 0);
               secret_in : in std_logic_vector(S - 1 downto 0);
               change_secret_in : in std_logic;
               record_process_en_in : in std_logic;
               stall_in : in std_logic;
               record_out : out std_logic_vector(R - 1 downto 0);
               write_tally_en_out : out std_logic );
    end component;

    component stage_memory is
        generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
                  R : natural := 12;
                  T : natural := 4 );
        port ( clk, reset : in std_logic;
               record_in : in std_logic_vector(R - 1 downto 0);
               tag_valid_in : in std_logic; 
               write_en_in : in std_logic;
               write_addr_in : in std_logic_vector((C * (D + 1)) - 1 downto 0);
               write_data_in : in std_logic_vector((R + T) - 1 downto 0);
               stall_out : out std_logic;
               write_en_out : out std_logic;
               addr_out : out std_logic_vector((C * (D + 1)) - 1 downto 0);
               tally_out : out std_logic_vector((R + T) - 1 downto 0);
               data_out : out std_logic_vector((R + T) - 1 downto 0) );
    end component;
    
    component stage_write_back is
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
    end component;

    -- define signals for each stage
    -- IFD stage signals
    signal IFD_record_process_en : std_logic;
    signal IFD_change_secret : std_logic;
    
    -- TAG stage signals
    signal TAG_record : std_logic_vector(R - 1 downto 0);
    signal TAG_valid : std_logic;
    
    -- MEM stage signals
    signal MEM_stall : std_logic;
    signal MEM_write_en : std_logic;
    signal MEM_write_addr : std_logic_vector((C * (D + 1)) - 1 downto 0);
    signal MEM_data_out : std_logic_vector((R + T) - 1 downto 0);
    signal MEM_tally_out : std_logic_vector((R + T) - 1 downto 0);
    
    -- WB stage signals
    signal WB_write_en : std_logic;
    signal WB_write_addr : std_logic_vector((C * (D + 1)) - 1 downto 0);
    signal WB_write_data : std_logic_vector((R + T) - 1 downto 0);
   

begin

    IFD : stage_instruction_fetch_decode
        generic map ( C => C,
                      D => D,
                      R => R,
                      T => T )
        port map ( clk => clk,
                   reset => reset,
                   record_process_en_in => process_tag_en,
                   stall_pipeline => MEM_stall,
                   record_process_en_out => IFD_record_process_en,
                   change_secret => IFD_change_secret );

    TAG: stage_tag_gen
        generic map ( C => C,
                      D => D,
                      R => R,
                      T => T,
                      S => S ) 
        port map ( clk => clk,
                   reset => reset,
                   record_in => record_tag_in((R + T) - 1 downto T),
                   tag_in => record_tag_in(T - 1 downto 0),
                   secret_in => secret_in,
                   change_secret_in => IFD_change_secret,
                   record_process_en_in => IFD_record_process_en, 
                   stall_in => MEM_stall,
                   record_out => TAG_record,
                   write_tally_en_out => TAG_valid );
                   

    MEM : stage_memory 
        generic map ( C => C,
                      D => D,
                      R => R,
                      T => T )
        port map ( clk => clk, 
                   reset => reset,
                   record_in => TAG_record,
                   tag_valid_in => TAG_valid,
                   write_en_in => WB_write_en,
                   write_addr_in => WB_write_addr,
                   write_data_in => WB_write_data,
                   stall_out => MEM_stall,
                   write_en_out => MEM_write_en,
                   addr_out => MEM_write_addr,
                   tally_out => MEM_tally_out,
                   data_out => MEM_data_out );
                   
    WB : stage_write_back
        generic map ( C => C,
                      D => D,
                      R => R,
                      T => T )
        port map ( clk => clk,
                   reset => reset,
                   write_en_in => MEM_write_en,
                   addr_in => MEM_write_addr,
                   tally_in => MEM_tally_out,
                   data_in => MEM_data_out,
                   write_en_out => WB_write_en,
                   addr_out => WB_write_addr,
                   write_data_out => WB_write_data );

    -- todo: remove below signals which make the implementation not delete all my leaf cells
    curr_write_addr <= WB_write_addr;
    curr_write_data <= WB_write_data;
end Behavioral;
