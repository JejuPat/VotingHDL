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

entity write_back is
    port ( clk, reset : in std_logic;
           write_reg_in : in std_logic_vector(3 downto 0);
           mem_data_in, alu_data_in : in std_logic_vector(15 downto 0);
           WB_ctrl_in : in std_logic_vector(2 downto 0);
           WB_write : out std_logic;
           WB_write_reg : out std_logic_vector(3 downto 0);
           WB_data_out : out std_logic_vector(15 downto 0);
           led : out std_logic_vector(15 downto 0) );
end write_back;

architecture Behavioral of write_back is

component led_reg_16b is
    Port ( led_reg_in : in STD_LOGIC_VECTOR (15 downto 0);
           led_reg_en : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           led_reg_Q : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component mux_2to1_16b is
    port ( src_0 : in STD_LOGIC_VECTOR (15 downto 0);
           src_1 : in STD_LOGIC_VECTOR (15 downto 0);
           sel : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (15 downto 0) );
end component;

    signal write_reg : std_logic_vector(3 downto 0);
    signal mem_data, alu_data : std_logic_vector(15 downto 0);
    signal WB_ctrl : std_logic_vector(2 downto 0);
    
    signal next_write : std_logic_vector(15 downto 0);
begin

    -- pipeline register for MEM/WB
    REG_MEM_WB : process ( reset, clk )
    begin
        if reset = '1' then
            write_reg <= "0000";
            mem_data <= (others => '0');
            alu_data <= (others => '0');
            WB_ctrl <= "000";
        elsif clk'event and clk = '1' then
            write_reg <= write_reg_in;
            mem_data <= mem_data_in;
            alu_data <= alu_data_in;
            WB_ctrl <= WB_ctrl_in;
        end if;
    end process;
    
    -- handle the led reg
    led_reg : led_reg_16b 
    port map ( led_reg_in => mem_data,
               led_reg_en => WB_ctrl(2),
               clk => clk,
               reset => reset,
               led_reg_Q => led );
               
   -- handle choosing between mem and alu
   mux_mem_to_write : mux_2to1_16b
   port map ( src_0 => alu_data,
              src_1 => mem_data,
              sel => WB_ctrl(1),
              output => WB_data_out );
       
    -- handle other outputs
    WB_write <= WB_ctrl(0);
    WB_write_reg <= write_reg;       
end Behavioral;
