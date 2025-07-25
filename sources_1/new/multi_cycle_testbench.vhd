library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity multi_cycle_testbench is
end multi_cycle_testbench;


architecture behave of multi_cycle_testbench is
 
  -- 1 GHz = 2 nanoseconds period
  constant c_CLOCK_PERIOD : time := 2 ns; 


 signal r_CLOCK     : std_logic := '0';
 signal r_reset    : std_logic := '0';
 signal r_led      : std_logic_vector(15 downto 0) := (OTHERS => '0');
 

-- Component declaration for the Unit Under Test (UUT)
component multi_cycle_core is
    port ( clk, reset : in std_logic;
           sw : in std_logic_vector(15 downto 0);
           led : out std_logic_vector(15 downto 0) );
      end component ;
      
      signal sw_val : std_logic_vector(15 downto 0) := X"0005";
      begin
       
        -- Instantiate the Unit Under Test (UUT)
        UUT : multi_cycle_core
          port map (
            reset    => r_reset,
            clk     => r_CLOCK,
            sw      => sw_val,
            led     => r_led    
            );
       
        p_CLK_GEN : process is
        begin
          wait for c_CLOCK_PERIOD/2;
          r_CLOCK <= not r_CLOCK;
        end process p_CLK_GEN; 
         
        process                               -- main testing
        begin
          r_reset <= '0';
       
             wait for 2*c_CLOCK_PERIOD ;
        r_reset <= '1';
           
           wait for 2*c_CLOCK_PERIOD ;
                r_reset <= '0';         
          
          wait for 2 sec;
           
        end process;
         
      end behave;
      
      
      
      
      
