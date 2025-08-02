----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2025 14:19:59
-- Design Name: 
-- Module Name: stage_memory - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity stage_memory is
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
end stage_memory;

architecture Behavioral of stage_memory is

    -- components definition
    component mux_2to1_nbit is
        generic ( N : INTEGER := 8 );
        port ( src_0, src_1 : in std_logic_vector(N - 1 downto 0);
               sel : in std_logic;
               data_out : out std_logic_vector(N - 1 downto 0) );
    end component;
    
    component addr_calc is
        generic ( C, D : integer := 2;
                  R : integer := 12 );
        port ( district, candidate : in std_logic_vector(R - 1 downto 0);
               addr : out std_logic_vector((C * (D + 1)) - 1 downto 0) );
    end component;
    
    component data_memory is
        generic ( C, D : natural := 2;
                  R : natural := 12;
                  T : natural := 4 );
        port ( clk, reset : in std_logic;
               write_en : in std_logic;
               read_addr, write_addr : in std_logic_vector((C * (D + 1)) - 1 downto 0);
               write_data : in std_logic_vector((R + T) - 1 downto 0);
               data_out : out std_logic_vector((R + T) - 1 downto 0) );
    end component;

    -- signals for the TAG/MEM pipeline reg
    signal record_curr : std_logic_vector(R - 1 downto 0);
    signal tag_valid_curr : std_logic;
    signal add_total_curr : std_logic;
    
    -- intermediate signals
    signal district_curr : std_logic_vector(R - 1 downto 0) := (others => '0');
    signal candidate_curr : std_logic_vector(R - 1 downto 0) := (others => '0');
    signal tally_curr : std_logic_vector((R + T - 1) downto 0) := (others => '0');
    
    signal addr_calc_district : std_logic_vector(R - 1 downto 0); 
    
    signal addr_curr : std_logic_vector((C * (D + 1)) - 1 downto 0);
    
    -- constant signals
    signal totals_mem_addr : std_logic_vector(R - 1 downto 0);

begin
    -- handle constant signals
    totals_mem_addr <= std_logic_vector(to_unsigned(2 ** D, totals_mem_addr'length));

    -- handle the pipeline register transition
    TAG_MEM_reg: process (clk, reset, tag_valid_curr)
    begin
        if (reset = '1') then
            record_curr <= (others => '0');
            tag_valid_curr <= '0';
            add_total_curr <= '0';
        elsif (clk = '1' and clk'event) then
            if (tag_valid_curr = '1') then
                -- then we are currently writing to the district/candidate address, next cycle
                --  we stall and write to total + candidate address
                tag_valid_curr <= '0';
                add_total_curr <= '1';
            else 
                record_curr <= record_in;
                tag_valid_curr <= tag_valid_in;
                add_total_curr <= '0';
            end if;
        end if;
    end process;
    
    -- based on pipeline registers, definee the intermediate signals
    district_curr((D - 1) downto 0) <= record_curr(R - 1 downto (R - D));
    candidate_curr((C - 1) downto 0) <= record_curr((R - D - 1) downto (R - D - C));
    tally_curr((R - C - D - 1) downto 0) <= record_curr((R - D - C - 1) downto 0);
    
    -- depending on add_total_curr the district input to the address calc will differ
    addr_calc_dist_mux : mux_2to1_nbit
        generic map ( N => R )
        port map ( src_0 => district_curr,
                   src_1 => totals_mem_addr,
                   sel => add_total_curr,
                   data_out => addr_calc_district);
                   
    -- calculate memory address for the record
    addr_calc_unit : addr_calc
        generic map ( C => C,
                      D => D,
                      R => R )
        port map ( district => addr_calc_district,
                   candidate => candidate_curr,
                   addr => addr_curr );
                   
    -- data memory access using addr curr to get data out, also support writing on the negative clock edge   
    DMEM: data_memory
        generic map ( C => C, 
                      D => D,
                      R => R,
                      T => T )
        port map ( clk => clk,
                   reset => reset,
                   write_en => write_en_in,
                   read_addr => addr_curr,
                   write_addr => write_addr_in,
                   write_data => write_data_in,
                   data_out => data_out );

    -- handle outputs (other than data_out which is directly out of memory
    stall_out <= tag_valid_curr;
    write_en_out <= tag_valid_curr or add_total_curr;
    addr_out <= addr_curr;
    tally_out <= tally_curr;
end Behavioral;