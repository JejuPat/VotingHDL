----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 14:36:18
-- Design Name: 
-- Module Name: stage_tag_gen - Behavioral
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

entity stage_tag_gen is
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
end stage_tag_gen;

architecture Behavioral of stage_tag_gen is

    component reg_n is
        generic ( N : natural := 8 );
        port ( clk, reset : in std_logic;
               input : in std_logic_vector(N - 1 downto 0);
               enable : in std_logic;
               output : out std_logic_vector(N - 1 downto 0) );
    end component;
    
    component tag_generator is
        generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
                  R : natural := 12;
                  T : natural := 4; 
                  S : natural := 16 );
        port ( record_in : in std_logic_vector(R - 1 downto 0);
               secret : in std_logic_vector(S - 1 downto 0);
               tag_out : out std_logic_vector(T - 1 downto 0) );
    end component;

    -- pipeline reg signals
    signal record_curr : std_logic_vector(R - 1 downto 0);
    signal tag_curr : std_logic_vector(T - 1 downto 0);
    signal secret_in_curr : std_logic_vector(S - 1 downto 0);
    signal change_secret_curr : std_logic;
    signal record_process_en_curr : std_logic;
    
    -- secret reg
    signal secret_curr : std_logic_vector(S - 1 downto 0);
    
    -- tag gen
    signal generated_tag : std_logic_vector(T - 1 downto 0);
begin


    -- IFD/TAG pipeline register
    IFD_TAG_reg : process ( clk, reset, stall_in )
    begin
        if (reset = '1') then
            record_curr <= (others => '0');
            tag_curr <= (others => '0');
            secret_in_curr <= (others => '0');
            change_secret_curr <= '0';
            record_process_en_curr <= '0';
        elsif (clk = '1' and clk'event) then
            if (stall_in = '0') then
                record_curr <= record_in;
                tag_curr <= tag_in;
                secret_in_curr <= secret_in;
                change_secret_curr <= change_secret_in;
                record_process_en_curr <= record_process_en_in;
            end if;
        end if;
    end process;
    
    -- secret register
    secret_reg : reg_n
        generic map ( N => S )
        port map ( clk => clk,
                   reset => reset,
                   input => secret_in_curr,
                   enable => change_secret_curr,
                   output => secret_curr );
        
    -- use the tag generator to get tag for the current record
    tag_gen : tag_generator 
        generic map ( C => C,
                      D => D,
                      R => R,
                      T => T,
                      S => S )
        port map ( record_in => record_curr,
                   secret => secret_curr,
                   tag_out => generated_tag );
                   
  
    -- output signals handler
    record_out <= record_curr;
    
    write_tally_en_out <= '1' when (generated_tag = tag_curr) and record_process_en_curr = '1' else
                 '0';
end Behavioral;
