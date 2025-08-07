library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity voting_proc_tb is
end voting_proc_tb;

architecture Behavioral of voting_proc_tb is

    -- Clock period definition
    constant clk_period : time := 10 ns;

    -- DUT Signals
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal btn1     : std_logic := '0';
    signal btn2     : std_logic := '0';
    signal btn3     : std_logic := '0';
    signal btn4     : std_logic := '0';
    signal btn5     : std_logic := '0';
    signal led      : std_logic_vector(15 downto 0);

    -- DUT component
    component voting_proc
        generic ( C : natural := 2;
                  D : natural := 2;
                  R : natural := 12;
                  T : natural := 4;
                  S : natural := 20 );
        port ( clk, reset     : in std_logic;
               btn1           : in std_logic;
               btn2           : in std_logic;
               btn3           : in std_logic;
               btn4           : in std_logic;
               btn5           : in std_logic;
               led            : out std_logic_vector(15 downto 0) );
    end component;

begin

    -- Instantiate DUT
    uut: voting_proc
        port map (
            clk     => clk,
            reset   => reset,
            btn1    => btn1,
            btn2    => btn2,
            btn3    => btn3,
            btn4    => btn4,
            btn5    => btn5,
            led     => led
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
        stim_proc : process
        begin
            -- Initial reset
            reset <= '1';
            wait for 20 ns;
            reset <= '0';
            wait for 20 ns;
        
            report "Reset complete, starting stimuli";
        
            -- Simulate loading a new record
            btn2 <= '1';  -- Load record
            wait for 100 ns;
            btn2 <= '0';
        
            -- Simulate loading a new secret
            btn3 <= '1';  -- Load secret
            wait for 100 ns;
            btn3 <= '0';
        
            -- Step to next instruction
            btn1 <= '1';
            wait for 100 ns;
            btn1 <= '0';
        
            -- Perform the instruction
            btn4 <= '1';
            wait for 100 ns;
            btn4 <= '0';
        
            -- Switch LED view
            btn5 <= '1';
            wait for 100 ns;
            btn5 <= '0';
        
            -- Finish simulation
            wait for 500 ns;
            report "Simulation complete";
            wait;
        end process;


end Behavioral;
