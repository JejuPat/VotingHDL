library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_shift is
end entity;

architecture sim of tb_shift is
    constant EXTENDED_SIZE : natural := 16;
    constant TAG_SIZE      : natural := 4;
    constant KEY_SIZE      : natural := 16;

    signal i_record  : std_logic_vector(EXTENDED_SIZE - 1 downto 0);
    signal i_key     : std_logic_vector(KEY_SIZE - 1 downto 0);
    signal o_record  : std_logic_vector(EXTENDED_SIZE - 1 downto 0);

    component shift
        generic(
            EXTENDED_SIZE   : natural := 16;
            TAG_SIZE        : natural := 4;
            KEY_SIZE        : natural := 16
        );
        port(
            i_record    : in std_logic_vector(EXTENDED_SIZE-1 downto 0);
            i_key       : in std_logic_vector(KEY_SIZE-1 downto 0);
            o_record    : out std_logic_vector(EXTENDED_SIZE-1 downto 0)
        );
    end component;

begin

    uut: shift
        generic map(
            EXTENDED_SIZE => EXTENDED_SIZE,
            TAG_SIZE      => TAG_SIZE,
            KEY_SIZE      => KEY_SIZE
        )
        port map(
            i_record => i_record,
            i_key    => i_key,
            o_record => o_record
        );

    
    stim_proc: process
        variable bs_index : integer;
        variable rot_amt  : integer;
        variable line     : std_logic_vector(TAG_SIZE-1 downto 0);
        variable expected : std_logic_vector(TAG_SIZE-1 downto 0);
        variable rec      : std_logic_vector(EXTENDED_SIZE-1 downto 0);
    begin
        
        i_record <= x"4558"; 

        wait for 10 ns;

        bs_index := 0;
        rot_amt  := 1;

        
        i_key <= (others => '0');
        i_key(KEY_SIZE-1 downto KEY_SIZE-2) <= std_logic_vector(to_unsigned(bs_index, 2));
        i_key(KEY_SIZE-3 downto KEY_SIZE-4) <= std_logic_vector(to_unsigned(rot_amt, 2));

        wait;
    end process;

end architecture;
