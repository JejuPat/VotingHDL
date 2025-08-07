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

----------------------------------
----------------------------------
-- TB 1                         --
----------------------------------
----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity voting_proc_testbench_1 is
end voting_proc_testbench_1;

architecture Behavioral of voting_proc_testbench_1 is

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
    constant C : natural := 3;
    constant D : natural := 2;
    constant R : natural := 10;
    constant T : natural := 4;
    constant S : natural := 16;
    
    signal r_CLOCK : std_logic := '0';
    signal r_reset : std_logic := '0';
    
    signal r_process_tag_en : std_logic := '1';
    signal r_secret : std_logic_vector(S - 1 downto 0) := "1010010010000110";
    signal r_record_tag : std_logic_vector((R + T) - 1 downto 0) := (others => '0');
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
    
        -- wait for 50ns to avoid startup behaviour
        wait for 50 ns;
        
        r_reset <= '1';
        
        wait for 10 ns;
        r_reset <= '0';
        wait for 10 ns; -- instruction is load secret
        
        -- now load first key
        r_record_tag <= "01001111111000";
        -- NOTE, we wait 20 ns in between records since
        --  first 10 ns, record is waiting to be read by pipeline
        --  second 10 ns, record is in TAG
        --  third 10 ns, record is in MEM, branch is in TAG, stall == 1
        --  fourth 10 ns, record is in WB, branch is in TAG, stall == 0 <=> we send a new record NOW
        --  so wait 30 seconds for a correct tage
        wait for 30 ns;
        -- right now, first record is in the TAG stage, no need to worry about stall yet!
        r_record_tag <= "01010111001000";
        wait for 30 ns; 
        
        r_record_tag <= "01011111010100";
        wait for 30 ns; 
        
        r_record_tag <= "01100101010010";
        wait for 30 ns; 
        
        r_record_tag <= "10001111101111";
        wait for 30 ns; 
        
        r_record_tag <= "10010111001011";
        wait for 30 ns; 
        
        r_record_tag <= "10011101000001";
        wait for 30 ns; 
        
        r_record_tag <= "10100100000100";
        wait for 30 ns;
        
        r_record_tag <= "01010001001011";
        wait for 10 ns; 
        r_process_tag_en <= '0';    -- during this time, no tags should be processed
        
        wait for 2 sec;
    end process test;

end Behavioral;

----------------------------------
----------------------------------
-- TB 2                         --
----------------------------------
----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity voting_proc_testbench_2 is
end voting_proc_testbench_2;

architecture Behavioral of voting_proc_testbench_2 is

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
    constant C : natural := 4;
    constant D : natural := 3;
    constant R : natural := 13;
    constant T : natural := 4;
    constant S : natural := 16;
    
    signal r_CLOCK : std_logic := '0';
    signal r_reset : std_logic := '0';
    
    signal r_process_tag_en : std_logic := '1';
    signal r_secret : std_logic_vector(S - 1 downto 0) := "1110101001110001";
    signal r_record_tag : std_logic_vector((R + T) - 1 downto 0) := (others => '0');
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
    
        -- wait for 50ns to avoid startup behaviour
        wait for 50 ns;
        
        r_reset <= '1';
        
        wait for 10 ns;
        r_reset <= '0';
        wait for 10 ns; -- instruction is load secret
        
        -- now load first record
        -- records for district 4
        r_record_tag <= "10000010111000111";
        wait for 30 ns;
        -- right now, first record is in the TAG stage, no need to worry about stall yet!
        r_record_tag <= "10010000000110110";
        wait for 30 ns; 
        
        r_record_tag <= "10001110110101000";
        wait for 30 ns; 
        
        r_record_tag <= "10001100011000001";
        wait for 30 ns; 
        
        r_record_tag <= "10001011100010000";
        wait for 30 ns; 
        
        r_record_tag <= "10001001001000000";
        wait for 30 ns; 
        
        r_record_tag <= "10000110001010111";
        wait for 30 ns; 
        
        r_record_tag <= "10000100111100000";
        wait for 30 ns;
        
        -- records for district 2

        r_record_tag <= "01000010101011101";
        wait for 30 ns;
        
        r_record_tag <= "01010000001101010";
        wait for 30 ns;
        
        r_record_tag <= "01001110010111110";
        wait for 30 ns;
        
        r_record_tag <= "01001101110010100";
        wait for 30 ns;
        
        r_record_tag <= "01001011110001010";
        wait for 30 ns;
        
        r_record_tag <= "01001000011100010";
        wait for 30 ns;
        
        r_record_tag <= "01000110010110110";
        wait for 30 ns;
        
        r_record_tag <= "01000100010101100";
        wait for 30 ns;

        -- records for district 1
        
        r_record_tag <= "00100010100110100";
        wait for 30 ns;
        
        r_record_tag <= "00110000010111110";
        wait for 30 ns;
        
        r_record_tag <= "00101110110100100";
        wait for 30 ns;
        
        r_record_tag <= "00101101100000010";
        wait for 30 ns;
        
        r_record_tag <= "00101010010010001";
        wait for 30 ns;
        
        r_record_tag <= "00101001111100001";
        wait for 30 ns;
        
        r_record_tag <= "00100110110101100";
        wait for 30 ns;
        
        r_record_tag <= "00100100001111000";

        wait for 10 ns; 
        r_process_tag_en <= '0';    -- during this time, no tags should be processed
        
        wait for 2 sec;
    end process test;

end Behavioral;

----------------------------------
----------------------------------
-- TB 3                         --
----------------------------------
----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity voting_proc_testbench_3 is
end voting_proc_testbench_3;

architecture Behavioral of voting_proc_testbench_3 is

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
    constant C : natural := 3;
    constant D : natural := 2;
    constant R : natural := 10;
    constant T : natural := 3;
    constant S : natural := 16;
    
    signal r_CLOCK : std_logic := '0';
    signal r_reset : std_logic := '0';
    
    signal r_process_tag_en : std_logic := '1';
    signal r_secret : std_logic_vector(S - 1 downto 0) := "1010100010000110";
    signal r_record_tag : std_logic_vector((R + T) - 1 downto 0) := (others => '0');
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
    
        -- wait for 50ns to avoid startup behaviour
        r_reset <= '1';
        wait for 50 ns;
        
        wait for 10 ns;
        r_reset <= '0';
        wait for 10 ns; -- instruction is load secret
        
        -- now load first key
        r_record_tag <= "0100111111101";
        wait for 30 ns;
        -- right now, first record is in the TAG stage, no need to worry about stall yet!
        r_record_tag <= "0101011100000";
        wait for 30 ns; 
        
        r_record_tag <= "0101111101101";
        wait for 30 ns; 
        
        r_record_tag <= "0110010101110";
        wait for 30 ns; 
        
        r_record_tag <= "1000111110111";
        wait for 30 ns; 
        
        r_record_tag <= "1001011101010";
        wait for 30 ns; 
        
        r_record_tag <= "1001110100110";
        wait for 30 ns; 
        
        r_record_tag <= "1010010000110";
        wait for 30 ns;
        
        r_record_tag <= "0101100100100";
        wait for 10 ns; 
        r_process_tag_en <= '0';    -- during this time, no tags should be processed
        
        wait for 2 sec;
    end process test;

end Behavioral;

----------------------------------
----------------------------------
-- TB 4                         --
----------------------------------
----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity voting_proc_testbench_4 is
end voting_proc_testbench_4;

architecture Behavioral of voting_proc_testbench_4 is

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
    constant C : natural := 5;
    constant D : natural := 3;
    constant R : natural := 15;
    constant T : natural := 5;
    constant S : natural := 20;
    
    signal r_CLOCK : std_logic := '0';
    signal r_reset : std_logic := '0';
    
    signal r_process_tag_en : std_logic := '1';
    signal r_secret : std_logic_vector(S - 1 downto 0) := "10010010000010000110";
    signal r_record_tag : std_logic_vector((R + T) - 1 downto 0) := (others => '0');
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
    
        -- wait for 50ns to avoid startup behaviour
        wait for 50 ns;
        
        r_reset <= '1';
        
        wait for 10 ns;
        r_reset <= '0';
        wait for 10 ns; -- instruction is load secret
       
        -- now load first key
        r_record_tag <= "00100001001111111110";
        wait for 30 ns;
        -- right now, first record is in the TAG stage, no need to worry about stall yet!
        r_record_tag <= "00100010001110010001";
        wait for 30 ns; 
        
        r_record_tag <= "00100011001110110100";
        wait for 30 ns; 
        
        r_record_tag <= "00100100001010101111";
        wait for 30 ns; 
        
        r_record_tag <= "01000001001111001011";
        wait for 30 ns; 
        
        r_record_tag <= "01000010001110100100";
        wait for 30 ns; 
        
        r_record_tag <= "01000011001010001001";
        wait for 30 ns; 
        
        r_record_tag <= "01000100001000011110";
        wait for 30 ns;
        
        r_record_tag <= "00100011100010001010";

        wait for 10 ns; 
        r_process_tag_en <= '0';    -- during this time, no tags should be processed
        
        wait for 2 sec;
    end process test;

end Behavioral;

----------------------------------
----------------------------------
-- TB 5                         --
----------------------------------
----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity voting_proc_testbench_5 is
end voting_proc_testbench_5;

architecture Behavioral of voting_proc_testbench_5 is

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
    constant C : natural := 3;
    constant D : natural := 2;
    constant R : natural := 10;
    constant T : natural := 8;
    constant S : natural := 20;
    
    signal r_CLOCK : std_logic := '0';
    signal r_reset : std_logic := '0';
    
    signal r_process_tag_en : std_logic := '1';
    signal r_secret : std_logic_vector(S - 1 downto 0) := "10010010000010000110";
    signal r_record_tag : std_logic_vector((R + T) - 1 downto 0) := (others => '0');
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
    
        -- wait for 50ns to avoid startup behaviour
        wait for 50 ns;
        
        r_reset <= '1';
        
        wait for 10 ns;
        r_reset <= '0';
        wait for 10 ns; -- instruction is load secret
        
        -- we will enter every possible tag combination for candidate 00 in district 0
        r_record_tag <= "000000000100000000";
        wait for 30 ns;
        
        r_record_tag <= "000000000100000001";
        wait for 30 ns;
        
        r_record_tag <= "000000000100000010";
        wait for 30 ns;
        
        r_record_tag <= "000000000100000011";
        wait for 30 ns;
        
        r_record_tag <= "000000000100000100";
        wait for 30 ns;
        
        r_record_tag <= "000000000100000101";
        wait for 30 ns;
        
        r_record_tag <= "000000000100000110";
        wait for 30 ns;
        
        r_record_tag <= "000000000100000111";
        wait for 30 ns;
        
        r_record_tag <= "000000000100001000";
        wait for 30 ns;
        
        r_record_tag <= "000000000100001001";
        wait for 30 ns;
        
        r_record_tag <= "000000000100001010";
        wait for 30 ns;
        
        r_record_tag <= "000000000100001011";
        wait for 30 ns;
        
        r_record_tag <= "000000000100001100";
        wait for 30 ns;
        
        r_record_tag <= "000000000100001101";
        wait for 30 ns;
        
        r_record_tag <= "000000000100001110";
        wait for 30 ns;
        
        r_record_tag <= "000000000100001111";
        wait for 30 ns;
        
        r_record_tag <= "000000000100010000";
        wait for 30 ns;
        
        r_record_tag <= "000000000100010001";
        wait for 30 ns;
        
        r_record_tag <= "000000000100010010";
        wait for 30 ns;
        
        r_record_tag <= "000000000100010011";
        wait for 30 ns;
        
        r_record_tag <= "000000000100010100";
        wait for 30 ns;
        
        r_record_tag <= "000000000100010101";
        wait for 30 ns;
        
        r_record_tag <= "000000000100010110";
        wait for 30 ns;
        
        r_record_tag <= "000000000100010111";
        wait for 30 ns;
        
        r_record_tag <= "000000000100011000";
        wait for 30 ns;
        
        r_record_tag <= "000000000100011001";
        wait for 30 ns;
        
        r_record_tag <= "000000000100011010";
        wait for 30 ns;
        
        r_record_tag <= "000000000100011011";
        wait for 30 ns;
        
        r_record_tag <= "000000000100011100";
        wait for 30 ns;
        
        r_record_tag <= "000000000100011101";
        wait for 30 ns;
        
        r_record_tag <= "000000000100011110";
        wait for 30 ns;
        
        r_record_tag <= "000000000100011111";
        wait for 30 ns;
        
        r_record_tag <= "000000000100100000";
        wait for 30 ns;
        
        r_record_tag <= "000000000100100001";
        wait for 30 ns;
        
        r_record_tag <= "000000000100100010";
        wait for 30 ns;
        
        r_record_tag <= "000000000100100011";
        wait for 30 ns;
        
        r_record_tag <= "000000000100100100";
        wait for 30 ns;
        
        r_record_tag <= "000000000100100101";
        wait for 30 ns;
        
        r_record_tag <= "000000000100100110";
        wait for 30 ns;
        
        r_record_tag <= "000000000100100111";
        wait for 30 ns;
        
        r_record_tag <= "000000000100101000";
        wait for 30 ns;
        
        r_record_tag <= "000000000100101001";
        wait for 30 ns;
        
        r_record_tag <= "000000000100101010";
        wait for 30 ns;
        
        r_record_tag <= "000000000100101011";
        wait for 30 ns;
        
        r_record_tag <= "000000000100101100";
        wait for 30 ns;
        
        r_record_tag <= "000000000100101101";
        wait for 30 ns;
        
        r_record_tag <= "000000000100101110";
        wait for 30 ns;
        
        r_record_tag <= "000000000100101111";
        wait for 30 ns;
        
        r_record_tag <= "000000000100110000";
        wait for 30 ns;
        
        r_record_tag <= "000000000100110001";
        wait for 30 ns;
        
        r_record_tag <= "000000000100110010";
        wait for 30 ns;
        
        r_record_tag <= "000000000100110011";
        wait for 30 ns;
        
        r_record_tag <= "000000000100110100";
        wait for 30 ns;
        
        r_record_tag <= "000000000100110101";
        wait for 30 ns;
        
        r_record_tag <= "000000000100110110";
        wait for 30 ns;
        
        r_record_tag <= "000000000100110111";
        wait for 30 ns;
        
        r_record_tag <= "000000000100111000";
        wait for 30 ns;
        
        r_record_tag <= "000000000100111001";
        wait for 30 ns;
        
        r_record_tag <= "000000000100111010";
        wait for 30 ns;
        
        r_record_tag <= "000000000100111011";
        wait for 30 ns;
        
        r_record_tag <= "000000000100111100";
        wait for 30 ns;
        
        r_record_tag <= "000000000100111101";
        wait for 30 ns;
        
        r_record_tag <= "000000000100111110";
        wait for 30 ns;
        
        r_record_tag <= "000000000100111111";
        wait for 30 ns;
        
        r_record_tag <= "000000000101000000";
        wait for 30 ns;
        
        r_record_tag <= "000000000101000001";
        wait for 30 ns;
        
        r_record_tag <= "000000000101000010";
        wait for 30 ns;
        
        r_record_tag <= "000000000101000011";
        wait for 30 ns;
        
        r_record_tag <= "000000000101000100";
        wait for 30 ns;
        
        r_record_tag <= "000000000101000101";
        wait for 30 ns;
        
        r_record_tag <= "000000000101000110";
        wait for 30 ns;
        
        r_record_tag <= "000000000101000111";
        wait for 30 ns;
        
        r_record_tag <= "000000000101001000";
        wait for 30 ns;
        
        r_record_tag <= "000000000101001001";
        wait for 30 ns;
        
        r_record_tag <= "000000000101001010";
        wait for 30 ns;
        
        r_record_tag <= "000000000101001011";
        wait for 30 ns;
        
        r_record_tag <= "000000000101001100";
        wait for 30 ns;
        
        r_record_tag <= "000000000101001101";
        wait for 30 ns;
        
        r_record_tag <= "000000000101001110";
        wait for 30 ns;
        
        r_record_tag <= "000000000101001111";
        wait for 30 ns;
        
        r_record_tag <= "000000000101010000";
        wait for 30 ns;
        
        r_record_tag <= "000000000101010001";
        wait for 30 ns;
        
        r_record_tag <= "000000000101010010";
        wait for 30 ns;
        
        r_record_tag <= "000000000101010011";
        wait for 30 ns;
        
        r_record_tag <= "000000000101010100";
        wait for 30 ns;
        
        r_record_tag <= "000000000101010101";
        wait for 30 ns;
        
        r_record_tag <= "000000000101010110";
        wait for 30 ns;
        
        r_record_tag <= "000000000101010111";
        wait for 30 ns;
        
        r_record_tag <= "000000000101011000";
        wait for 30 ns;
        
        r_record_tag <= "000000000101011001";
        wait for 30 ns;
        
        r_record_tag <= "000000000101011010";
        wait for 30 ns;
        
        r_record_tag <= "000000000101011011";
        wait for 30 ns;
        
        r_record_tag <= "000000000101011100";
        wait for 30 ns;
        
        r_record_tag <= "000000000101011101";
        wait for 30 ns;
        
        r_record_tag <= "000000000101011110";
        wait for 30 ns;
        
        r_record_tag <= "000000000101011111";
        wait for 30 ns;
        
        r_record_tag <= "000000000101100000";
        wait for 30 ns;
        
        r_record_tag <= "000000000101100001";
        wait for 30 ns;
        
        r_record_tag <= "000000000101100010";
        wait for 30 ns;
        
        r_record_tag <= "000000000101100011";
        wait for 30 ns;
        
        r_record_tag <= "000000000101100100";
        wait for 30 ns;
        
        r_record_tag <= "000000000101100101";
        wait for 30 ns;
        
        r_record_tag <= "000000000101100110";
        wait for 30 ns;
        
        r_record_tag <= "000000000101100111";
        wait for 30 ns;
        
        r_record_tag <= "000000000101101000";
        wait for 30 ns;
        
        r_record_tag <= "000000000101101001";
        wait for 30 ns;
        
        r_record_tag <= "000000000101101010";
        wait for 30 ns;
        
        r_record_tag <= "000000000101101011";
        wait for 30 ns;
        
        r_record_tag <= "000000000101101100";
        wait for 30 ns;
        
        r_record_tag <= "000000000101101101";
        wait for 30 ns;
        
        r_record_tag <= "000000000101101110";
        wait for 30 ns;
        
        r_record_tag <= "000000000101101111";
        wait for 30 ns;
        
        r_record_tag <= "000000000101110000";
        wait for 30 ns;
        
        r_record_tag <= "000000000101110001";
        wait for 30 ns;
        
        r_record_tag <= "000000000101110010";
        wait for 30 ns;
        
        r_record_tag <= "000000000101110011";
        wait for 30 ns;
        
        r_record_tag <= "000000000101110100";
        wait for 30 ns;
        
        r_record_tag <= "000000000101110101";
        wait for 30 ns;
        
        r_record_tag <= "000000000101110110";
        wait for 30 ns;
        
        r_record_tag <= "000000000101110111";
        wait for 30 ns;
        
        r_record_tag <= "000000000101111000";
        wait for 30 ns;
        
        r_record_tag <= "000000000101111001";
        wait for 30 ns;
        
        r_record_tag <= "000000000101111010";
        wait for 30 ns;
        
        r_record_tag <= "000000000101111011";
        wait for 30 ns;
        
        r_record_tag <= "000000000101111100";
        wait for 30 ns;
        
        r_record_tag <= "000000000101111101";
        wait for 30 ns;
        
        r_record_tag <= "000000000101111110";
        wait for 30 ns;
       
        r_record_tag <= "000000000101111111";
        wait for 30 ns;
        
        r_record_tag <= "000000000110000000";
        wait for 30 ns;
        
        r_record_tag <= "000000000110000001";
        wait for 30 ns;
        
        r_record_tag <= "000000000110000010";
        wait for 30 ns;
        
        r_record_tag <= "000000000110000011";
        wait for 30 ns;
        
        r_record_tag <= "000000000110000100";
        wait for 30 ns;
        
        r_record_tag <= "000000000110000101";
        wait for 30 ns;
        
        r_record_tag <= "000000000110000110";
        wait for 30 ns;
        
        r_record_tag <= "000000000110000111";
        wait for 30 ns;
        
        r_record_tag <= "000000000110001000";
        wait for 30 ns;
        
        r_record_tag <= "000000000110001001";
        wait for 30 ns;
        
        r_record_tag <= "000000000110001010";
        wait for 30 ns;
        
        r_record_tag <= "000000000110001011";
        wait for 30 ns;
        
        r_record_tag <= "000000000110001100";
        wait for 30 ns;
        
        r_record_tag <= "000000000110001101";
        wait for 30 ns;
        
        r_record_tag <= "000000000110001110";
        wait for 30 ns;
        
        r_record_tag <= "000000000110001111";
        wait for 30 ns;
        
        r_record_tag <= "000000000110010000";
        wait for 30 ns;
        
        r_record_tag <= "000000000110010001";
        wait for 30 ns;
        
        r_record_tag <= "000000000110010010";
        wait for 30 ns;
        
        r_record_tag <= "000000000110010011";
        wait for 30 ns;
        
        r_record_tag <= "000000000110010100";
        wait for 30 ns;
        
        r_record_tag <= "000000000110010101";
        wait for 30 ns;
        
        r_record_tag <= "000000000110010110";
        wait for 30 ns;
        
        r_record_tag <= "000000000110010111";
        wait for 30 ns;
        
        r_record_tag <= "000000000110011000";
        wait for 30 ns;
        
        r_record_tag <= "000000000110011001";
        wait for 30 ns;
        
        r_record_tag <= "000000000110011010";
        wait for 30 ns;
        
        r_record_tag <= "000000000110011011";
        wait for 30 ns;
        
        r_record_tag <= "000000000110011100";
        wait for 30 ns;
        
        r_record_tag <= "000000000110011101";
        wait for 30 ns;
        
        r_record_tag <= "000000000110011110";
        wait for 30 ns;
        
        r_record_tag <= "000000000110011111";
        wait for 30 ns;
        
        r_record_tag <= "000000000110100000";
        wait for 30 ns;
        
        r_record_tag <= "000000000110100001";
        wait for 30 ns;
        
        r_record_tag <= "000000000110100010";
        wait for 30 ns;
        
        r_record_tag <= "000000000110100011";
        wait for 30 ns;
        
        r_record_tag <= "000000000110100100";
        wait for 30 ns;
        
        r_record_tag <= "000000000110100101";
        wait for 30 ns;
        
        r_record_tag <= "000000000110100110";
        wait for 30 ns;
        
        r_record_tag <= "000000000110100111";
        wait for 30 ns;
        
        r_record_tag <= "000000000110101000";
        wait for 30 ns;
        
        r_record_tag <= "000000000110101001";
        wait for 30 ns;
        
        r_record_tag <= "000000000110101010";
        wait for 30 ns;
        
        r_record_tag <= "000000000110101011";
        wait for 30 ns;
        
        r_record_tag <= "000000000110101100";
        wait for 30 ns;
        
        r_record_tag <= "000000000110101101";
        wait for 30 ns;
        
        r_record_tag <= "000000000110101110";
        wait for 30 ns;
        
        r_record_tag <= "000000000110101111";
        wait for 30 ns;
        
        r_record_tag <= "000000000110110000";
        wait for 30 ns;
        
        r_record_tag <= "000000000110110001";
        wait for 30 ns;
        
        r_record_tag <= "000000000110110010";
        wait for 30 ns;
        
        r_record_tag <= "000000000110110011";
        wait for 30 ns;
        
        r_record_tag <= "000000000110110100";
        wait for 30 ns;
        
        r_record_tag <= "000000000110110101";
        wait for 30 ns;
        
        r_record_tag <= "000000000110110110";
        wait for 30 ns;
        
        r_record_tag <= "000000000110110111";
        wait for 30 ns;
        
        r_record_tag <= "000000000110111000";
        wait for 30 ns;
        
        r_record_tag <= "000000000110111001";
        wait for 30 ns;
        
        r_record_tag <= "000000000110111010";
        wait for 30 ns;
        
        r_record_tag <= "000000000110111011";
        wait for 30 ns;
        
        r_record_tag <= "000000000110111100";
        wait for 30 ns;
        
        r_record_tag <= "000000000110111101";
        wait for 30 ns;
        
        r_record_tag <= "000000000110111110";
        wait for 30 ns;
        
        r_record_tag <= "000000000110111111";
        wait for 30 ns;
        
        r_record_tag <= "000000000111000000";
        wait for 30 ns;
        
        r_record_tag <= "000000000111000001";
        wait for 30 ns;
        
        r_record_tag <= "000000000111000010";
        wait for 30 ns;
        
        r_record_tag <= "000000000111000011";
        wait for 30 ns;
        
        r_record_tag <= "000000000111000100";
        wait for 30 ns;
        
        r_record_tag <= "000000000111000101";
        wait for 30 ns;
        
        r_record_tag <= "000000000111000110";
        wait for 30 ns;
        
        r_record_tag <= "000000000111000111";
        wait for 30 ns;
        
        r_record_tag <= "000000000111001000";
        wait for 30 ns;
        
        r_record_tag <= "000000000111001001";
        wait for 30 ns;
        
        r_record_tag <= "000000000111001010";
        wait for 30 ns;
        
        r_record_tag <= "000000000111001011";
        wait for 30 ns;
        
        r_record_tag <= "000000000111001100";
        wait for 30 ns;
        
        r_record_tag <= "000000000111001101";
        wait for 30 ns;
        
        r_record_tag <= "000000000111001110";
        wait for 30 ns;
        
        r_record_tag <= "000000000111001111";
        wait for 30 ns;
        
        r_record_tag <= "000000000111010000";
        wait for 30 ns;
        
        r_record_tag <= "000000000111010001";
        wait for 30 ns;
        
        r_record_tag <= "000000000111010010";
        wait for 30 ns;
        
        r_record_tag <= "000000000111010011";
        wait for 30 ns;
        
        r_record_tag <= "000000000111010100";
        wait for 30 ns;
        
        r_record_tag <= "000000000111010101";
        wait for 30 ns;
        
        r_record_tag <= "000000000111010110";
        wait for 30 ns;
        
        r_record_tag <= "000000000111010111";
        wait for 30 ns;
        
        r_record_tag <= "000000000111011000";
        wait for 30 ns;
        
        r_record_tag <= "000000000111011001";
        wait for 30 ns;
        
        r_record_tag <= "000000000111011010";
        wait for 30 ns;
        
        r_record_tag <= "000000000111011011";
        wait for 30 ns;
        
        r_record_tag <= "000000000111011100";
        wait for 30 ns;
        
        r_record_tag <= "000000000111011101";
        wait for 30 ns;
        
        r_record_tag <= "000000000111011110";
        wait for 30 ns;
        
        r_record_tag <= "000000000111011111";
        wait for 30 ns;
        
        r_record_tag <= "000000000111100000";
        wait for 30 ns;
        
        r_record_tag <= "000000000111100001";
        wait for 30 ns;
        
        r_record_tag <= "000000000111100010";
        wait for 30 ns;
        
        r_record_tag <= "000000000111100011";
        wait for 30 ns;
        
        r_record_tag <= "000000000111100100";
        wait for 30 ns;
        
        r_record_tag <= "000000000111100101";
        wait for 30 ns;
        
        r_record_tag <= "000000000111100110";
        wait for 30 ns;
        
        r_record_tag <= "000000000111100111";
        wait for 30 ns;
        
        r_record_tag <= "000000000111101000";
        wait for 30 ns;
        
        r_record_tag <= "000000000111101001";
        wait for 30 ns;
        
        r_record_tag <= "000000000111101010";
        wait for 30 ns;
        
        r_record_tag <= "000000000111101011";
        wait for 30 ns;
        
        r_record_tag <= "000000000111101100";
        wait for 30 ns;
        
        r_record_tag <= "000000000111101101";
        wait for 30 ns;
        
        r_record_tag <= "000000000111101110";
        wait for 30 ns;
        
        r_record_tag <= "000000000111101111";
        wait for 30 ns;
        
        r_record_tag <= "000000000111110000";
        wait for 30 ns;
        
        r_record_tag <= "000000000111110001";
        wait for 30 ns;
        
        r_record_tag <= "000000000111110010";
        wait for 30 ns;
        
        r_record_tag <= "000000000111110011";
        wait for 30 ns;
        
        r_record_tag <= "000000000111110100";
        wait for 30 ns;
        
        r_record_tag <= "000000000111110101";
        wait for 30 ns;
        
        r_record_tag <= "000000000111110110";
        wait for 30 ns;
        
        r_record_tag <= "000000000111110111";
        wait for 30 ns;
        
        r_record_tag <= "000000000111111000";
        wait for 30 ns;
        
        r_record_tag <= "000000000111111001";
        wait for 30 ns;
        
        r_record_tag <= "000000000111111010";
        wait for 30 ns;
        
        r_record_tag <= "000000000111111011";
        wait for 30 ns;
        
        r_record_tag <= "000000000111111100";
        wait for 30 ns;
        
        r_record_tag <= "000000000111111101";
        wait for 30 ns;
        
        r_record_tag <= "000000000111111110";
        wait for 30 ns;
       
        r_record_tag <= "000000000111111111";
        
        wait for 10 ns; 
        r_process_tag_en <= '0';    -- during this time, no tags should be processed
        
        wait for 4 sec;
    end process test;

end Behavioral;

