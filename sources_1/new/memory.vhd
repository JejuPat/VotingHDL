----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.07.2025 14:51:10
-- Design Name: 
-- Module Name: memory - Behavioral
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

entity memory_fetch is
    port ( clk, reset : in std_logic;
           alu_res_in : in std_logic_vector(15 downto 0);
           src2_data_in : in std_logic_vector(15 downto 0);
           write_reg_in : in std_logic_vector(3 downto 0);
           MEM_ctrl_in : in std_logic;
           WB_ctrl_in : in std_logic_vector(2 downto 0);
           MEM_write : out std_logic;
           write_reg_out : out std_logic_vector(3 downto 0);
           mem_data_fwd : out std_logic_vector(15 downto 0);
           mem_data_out, alu_data_out : out std_logic_vector(15 downto 0);
           WB_ctrl_out : out std_logic_vector(2 downto 0) );
end memory_fetch;

architecture Behavioral of memory_fetch is

component data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           addr_in      : in  std_logic_vector(3 downto 0);
           data_out     : out std_logic_vector(15 downto 0) );
end component;

    signal alu_res, src2_data : std_logic_vector(15 downto 0);
    signal write_reg : std_logic_vector(3 downto 0);
    signal MEM_ctrl : std_logic;
    signal WB_ctrl : std_logic_vector(2 downto 0);

begin

    -- pipeline register
    REG_EX_MEM : process ( reset, clk )
    begin
        if reset = '1' then
            alu_res <= (others => '0');
            src2_data <= (others => '0');
            write_reg <= (others => '0');
            MEM_ctrl <= '0';
            WB_ctrl <= "000";
        elsif clk'event and clk = '1' then
            alu_res <= alu_res_in;
            src2_data <= src2_data_in;
            write_reg <= write_reg_in;
            MEM_ctrl <= MEM_ctrl_in;
            WB_ctrl <= WB_ctrl_in;
        end if;     
    end process;

    -- data memory
    DMEM : data_memory
    port map ( reset => reset,
               clk => clk,
               write_enable => MEM_ctrl,
               write_data => src2_data,
               addr_in => alu_res(3 downto 0),
               data_out => mem_data_out );
               
    -- handle other outputs
    MEM_write <= WB_ctrl(0);
    write_reg_out <= write_reg;
    alu_data_out <= alu_res;
    WB_ctrl_out <= WB_ctrl;
    mem_data_fwd <= alu_res;
end Behavioral;
