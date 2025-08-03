library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_flip is
end tb_flip;

architecture behavior of tb_flip is
    constant EXTENDED_SIZE : integer := 16;
    constant TAG_SIZE      : integer := 4;
    constant KEY_SIZE      : integer := 16;

    signal i_record : std_logic_vector(EXTENDED_SIZE-1 downto 0);
    signal i_key    : std_logic_vector(KEY_SIZE-1 downto 0);
    signal o_record : std_logic_vector(EXTENDED_SIZE-1 downto 0);

    component flip
        generic (
            EXTENDED_SIZE : natural;
            TAG_SIZE      : natural;
            KEY_SIZE      : natural
        );
        port (
            i_record : in std_logic_vector(EXTENDED_SIZE-1 downto 0);
            i_key    : in std_logic_vector(KEY_SIZE-1 downto 0);
            o_record : out std_logic_vector(EXTENDED_SIZE-1 downto 0)
        );
    end component;

begin
    uut: flip
        generic map (EXTENDED_SIZE => EXTENDED_SIZE, TAG_SIZE => TAG_SIZE, KEY_SIZE => KEY_SIZE)
        port map (i_record => i_record, i_key => i_key, o_record => o_record);

    process
    begin
        i_record <= "0100001110011000"; -- LSB aligned
        i_key    <= (others => '0');
        i_key(1 downto 0) <= "00"; -- bf = 01

        wait for 10 ns;
    end process;
end architecture;
