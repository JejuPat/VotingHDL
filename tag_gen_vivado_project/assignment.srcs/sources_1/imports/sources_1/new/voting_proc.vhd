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
              S : natural := 20 );
    port ( clk, reset : in std_logic;    -- note: valid is a temporary signal for testing until TAG stage implemented
           btn1   : in std_logic;        -- goes to next instruction (right)
           btn2   : in std_logic;        -- goes to next record (up)
           btn3   : in std_logic;        -- goes to next secret (down)
           btn4       : in std_logic;    -- performs the instruction (center)
           btn5      : in std_logic;    -- to switch led output (left)
           led        : out std_logic_vector(15 downto 0) ); -- 15
end voting_proc;

architecture Behavioral of voting_proc is
    
    component secret_memory_auto is
      port (
        clk      : in std_logic;
        reset    : in std_logic;
        read_in  : in std_logic;
        data_out : out std_logic_vector(19 downto 0)  -- assuming S = 20
      );
    end component;

    
    component record_memory_auto is
      port (
        clk      : in std_logic;
        reset    : in std_logic;
        read_in  : in std_logic;
        data_out : out std_logic_vector(15 downto 0)
      );
    end component;

    
    -- define the components (stages)
    component stage_instruction_fetch_decode is
        generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
                  R : natural := 12;
                  T : natural := 4 );
        port ( clk, reset : in std_logic;
               record_process_en_in : in std_logic;
               stall_pipeline : in std_logic;
               debounced_button    : in std_logic;
               record_process_en_out : out std_logic;
               change_secret : out std_logic );
    end component;
    
    component stage_tag_gen is
        generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
                  R : natural := 12;
                  T : natural := 4; 
                  S : natural := 20 );
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
    signal record_data : std_logic_vector(15 downto 0);
    signal secret_data : std_logic_vector(19 downto 0);

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
   
       -- Debounce signal
    signal button_sync_0, button_sync_1 : std_logic := '0';
    signal button_stable                : std_logic := '0';
    signal debounce_counter             : integer range 0 to 50000 := 0;
    signal debounced_button             : std_logic := '0';  
    
    signal button_sync2_0, button_sync2_1 : std_logic := '0';
    signal button_stable2                : std_logic := '0';
    signal debounce_counter2             : integer range 0 to 50000 := 0;
    signal debounced_button2             : std_logic := '0'; 
    
    signal button_sync3_0, button_sync3_1 : std_logic := '0';
    signal button_stable3                : std_logic := '0';
    signal debounce_counter3             : integer range 0 to 50000 := 0;
    signal debounced_button3             : std_logic := '0';  

    signal button_sync4_0, button_sync4_1 : std_logic := '0';
    signal debounce_counter4              : integer range 0 to 50000 := 0;
    signal debounced_button4              : std_logic := '0';  -- used as process_tag_en
    
    signal button_sync5_0, button_sync5_1 : std_logic := '0';
    signal debounce_counter5              : integer range 0 to 50000 := 0;
    signal debounced_button5              : std_logic := '0';
    
    signal led_output  : std_logic_vector(21 downto 0);
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            button_sync5_0 <= btn5;
            button_sync5_1 <= button_sync5_0;
    
            if button_sync5_1 = '1' then
                if debounce_counter5 < 50000 then
                    debounce_counter5 <= debounce_counter5 + 1;
                else
                    debounced_button5 <= '1';
                end if;
            else
                debounce_counter5 <= 0;
                debounced_button5 <= '0';
            end if;
        end if;
    end process;
        -- Simple debounce using 2-stage synchronizer and counter
    process(clk)
    begin
        if rising_edge(clk) then
            button_sync4_0 <= btn4;
            button_sync4_1 <= button_sync4_0;
    
            if button_sync4_1 = '1' then
                if debounce_counter4 < 50000 then
                    debounce_counter4 <= debounce_counter4 + 1;
                else
                    debounced_button4 <= '1';
                end if;
            else
                debounce_counter4 <= 0;
                debounced_button4 <= '0';
            end if;
        end if;
    end process;

        
    process(clk)
    begin
        if rising_edge(clk) then
            -- 2-stage sync to avoid metastability
            button_sync3_0 <= btn3;
            button_sync3_1 <= button_sync3_0;

            -- Detect stable high signal
            if button_sync3_1 = '1' then
                if debounce_counter3 < 50000 then
                    debounce_counter3 <= debounce_counter3 + 1;
                else
                    debounced_button3 <= '1';
                end if;
            else
                debounce_counter3 <= 0;
                debounced_button3 <= '0';
            end if;
        end if;
    end process;
    
        -- Simple debounce using 2-stage synchronizer and counter
    process(clk)
    begin
        if rising_edge(clk) then
            -- 2-stage sync to avoid metastability
            button_sync2_0 <= btn2;
            button_sync2_1 <= button_sync2_0;

            -- Detect stable high signal
            if button_sync2_1 = '1' then
                if debounce_counter2 < 50000 then
                    debounce_counter2 <= debounce_counter2 + 1;
                else
                    debounced_button2 <= '1';
                end if;
            else
                debounce_counter2 <= 0;
                debounced_button2 <= '0';
            end if;
        end if;
    end process;
    
        -- Simple debounce using 2-stage synchronizer and counter
    process(clk)
    begin
        if rising_edge(clk) then
            -- 2-stage sync to avoid metastability
            button_sync_0 <= btn1;
            button_sync_1 <= button_sync_0;

            -- Detect stable high signal
            if button_sync_1 = '1' then
                if debounce_counter < 50000 then
                    debounce_counter <= debounce_counter + 1;
                else
                    debounced_button <= '1';
                end if;
            else
                debounce_counter <= 0;
                debounced_button <= '0';
            end if;
        end if;
    end process;
    
    RECORD_MEM : record_memory_auto
    port map (
        clk      => clk,
        reset    => reset,
        read_in  => debounced_button2,  
        data_out => record_data
    );

    SECRET_MEM : secret_memory_auto
    port map (
        clk      => clk,
        reset    => reset,
        read_in  => debounced_button3,  
        data_out => secret_data
    );

    
    IFD : stage_instruction_fetch_decode
        generic map ( C => C,
                      D => D,
                      R => R,
                      T => T )
        port map ( clk => clk,
                   reset => reset,
                   record_process_en_in => debounced_button4,
                   stall_pipeline => MEM_stall,
                   debounced_button => debounced_button,
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
                   record_in => record_data((R + T) - 1 downto T),
                   tag_in    => record_data(T - 1 downto 0),
                   secret_in => secret_data,
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

    
    led_output <= WB_write_addr & WB_write_data;
    -- Output assignment to LEDs (show upper or lower 16 bits of led_output)
    led <= led_output(21 downto 6) when debounced_button5 = '1'
        else led_output(15 downto 0);

end Behavioral;
