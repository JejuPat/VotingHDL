library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity secret_memory_auto is
  Port (
    clk : in std_logic;
    reset : in std_logic;
    read_in : in std_logic;
    data_out : out std_logic_vector(19 downto 0)  -- S = 20
  );
end secret_memory_auto;

architecture Behavioral of secret_memory_auto is
  type mem_type is array(0 to 255) of std_logic_vector(19 downto 0);
  signal mem : mem_type := (
    0 => x"ABCDE",
    1 => x"12345",
    2 => x"0F0F0",
    others => (others => '0')
  );

  signal addr : unsigned(7 downto 0) := (others => '0');
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        addr <= (others => '0');
      elsif read_in = '1' then
        addr <= addr + 1;
      end if;
    end if;
  end process;

  data_out <= mem(to_integer(addr));
end Behavioral;
