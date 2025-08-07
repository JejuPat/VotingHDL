library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- For arithmetic on std_logic_vector

entity pc_reg is
    port (
        clk, reset           : in std_logic;
        stall_pipeline       : in std_logic;
        debounced_button     : in std_logic;  
        pc_out               : out std_logic_vector(15 downto 0)
    );
end pc_reg;

architecture Behavioral of pc_reg is
    signal pc_curr : std_logic_vector(15 downto 0);
begin
    process (clk, reset)
    begin
        if (reset = '1') then
            pc_curr <= (others => '0');
        elsif rising_edge(clk) then
            if (stall_pipeline = '0' and debounced_button = '1') then
                pc_curr <= std_logic_vector(unsigned(pc_curr) + 1);  -- Increment by 1
            end if;
        end if;
    end process;

    pc_out <= pc_curr;

end Behavioral;
