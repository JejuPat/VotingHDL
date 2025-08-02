----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2025 17:43:23
-- Design Name: 
-- Module Name: voting_proc_testbench - Behavioral
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

entity voting_proc_testbench is
end voting_proc_testbench;

architecture Behavioral of voting_proc_testbench is

    component voting_proc is
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
    end component;
    
    -- 1 GHz = 2 nanoseconds period
    constant c_CLOCK_PERIOD : time := 10 ns; 
    constant C : natural := 2;
    constant D : natural := 2;
    constant R : natural := 12;
    constant T : natural := 4;
    constant S : natural := 16;
    
    signal r_CLOCK : std_logic := '0';
    signal r_reset : std_logic := '0';
    
    signal r_process_tag_en : std_logic := '1';
    signal r_secret : std_logic_vector(S - 1 downto 0) := X"8001";
    signal r_record_tag : std_logic_vector((R + T) - 1 downto 0) := X"0010";
    signal r_write_addr : std_logic_vector((C * (D + 1)) - 1 downto 0);
    signal r_write_data : std_logic_vector((R + T) - 1 downto 0);

begin

    -- instantiate the unit under test (UUT)
    UUT : voting_proc
        generic map ( C => C,
                      D => D,
                      R => R,
                      T => T,
                      S => S )
        port map ( clk => r_CLOCK,
                   reset => r_reset,
                   process_tag_en => r_process_tag_en,
                   secret_in => r_secret,
                   record_tag_in => r_record_tag,
                   curr_write_addr => r_write_addr,
                   curr_write_data => r_write_data );

    -- clk gen for the testbench
    p_CLK_GEN : process is
    begin
      wait for c_CLOCK_PERIOD/2;
      r_CLOCK <= not r_CLOCK;
    end process p_CLK_GEN; 
    
    -- begin testing procedure
    test : process is
    begin 
    
        -- wait for 100ns to avoid startup behaviour
        wait for 50 ns;
        
        r_reset <= '1';
        
        wait for 10 ns;
        r_reset <= '0';
        
        wait for 50 ns;
        r_process_tag_en <= '0';    -- during this time, no tags should be processed
        
        wait for 50 ns;
        r_process_tag_en <= '1';
        
        wait for 50 ns;
        r_record_tag <= X"0011";    -- so far, tag gen is hardcoded to 0, so we should not add any more records at this point
        
        wait for 2 sec;
    end process test;

end Behavioral;
