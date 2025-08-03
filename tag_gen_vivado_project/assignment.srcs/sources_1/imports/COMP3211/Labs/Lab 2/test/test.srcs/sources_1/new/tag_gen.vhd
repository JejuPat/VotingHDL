library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tag_generator is
    generic (
        C : natural := 2;  -- candidate bits
        D : natural := 2;  -- district bits
        R : natural := 15; -- record size (excluding padding)
        T : natural := 4;  -- tag size
        S : natural := 16  -- secret key size
    );
    port (
        record_in : in  std_logic_vector(R - 1 downto 0);
        secret    : in  std_logic_vector(S - 1 downto 0);
        tag_out   : out std_logic_vector(T - 1 downto 0)
    );
end tag_generator;

architecture Behavioral of tag_generator is

    constant B : natural := (R + T - 1) / T;  -- number of blocks
    constant EXTENDED_SIZE : natural := T * B;

    signal zero_ext_record : std_logic_vector(EXTENDED_SIZE - 1 downto 0);
    signal flip_record     : std_logic_vector(EXTENDED_SIZE - 1 downto 0);
    signal swap_record     : std_logic_vector(EXTENDED_SIZE - 1 downto 0);
    signal shift_record    : std_logic_vector(EXTENDED_SIZE - 1 downto 0);
    signal xor_tag         : std_logic_vector(T - 1 downto 0);

    component flip
        generic (EXTENDED_SIZE : natural; TAG_SIZE : natural; KEY_SIZE : natural);
        port (
            i_record : in  std_logic_vector(EXTENDED_SIZE - 1 downto 0);
            i_key    : in  std_logic_vector(KEY_SIZE - 1 downto 0);
            o_record : out std_logic_vector(EXTENDED_SIZE - 1 downto 0)
        );
    end component;

    component swap
        generic (TAG_SIZE : integer; RECORD_SIZE : integer; SECRET_KEY_SIZE : integer);
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            i_record   : in  std_logic_vector(RECORD_SIZE - 1 downto 0);
            secret_key : in  std_logic_vector(SECRET_KEY_SIZE - 1 downto 0);
            o_record   : out std_logic_vector(RECORD_SIZE - 1 downto 0)
        );
    end component;

    component shift
        generic (EXTENDED_SIZE : natural; TAG_SIZE : natural; KEY_SIZE : natural);
        port (
            i_record : in  std_logic_vector(EXTENDED_SIZE - 1 downto 0);
            i_key    : in  std_logic_vector(KEY_SIZE - 1 downto 0);
            o_record : out std_logic_vector(EXTENDED_SIZE - 1 downto 0)
        );
    end component;

    component XOR_stage
        generic (TAG_SIZE : integer);
        port (
            in_a, in_b, in_c, in_d : in  std_logic_vector(TAG_SIZE - 1 downto 0);
            xor_result             : out std_logic_vector(TAG_SIZE - 1 downto 0)
        );
    end component;

begin
    process(record_in)
    begin
        zero_ext_record <= (others => '0');
        for i in 0 to R - 1 loop
            zero_ext_record(EXTENDED_SIZE - 1 - i) <= record_in(R - 1 - i);
        end loop;
    end process;

    flip_inst: flip
        generic map (EXTENDED_SIZE => EXTENDED_SIZE, TAG_SIZE => T, KEY_SIZE => S)
        port map (
            i_record => zero_ext_record,
            i_key    => secret,
            o_record => flip_record
        );

    swap_inst: swap
        generic map (TAG_SIZE => T, RECORD_SIZE => EXTENDED_SIZE, SECRET_KEY_SIZE => S)
        port map (
            clk        => '0',
            reset      => '0',
            i_record   => flip_record,
            secret_key => secret,
            o_record   => swap_record
        );

    shift_inst: shift
        generic map (EXTENDED_SIZE => EXTENDED_SIZE, TAG_SIZE => T, KEY_SIZE => S)
        port map (
            i_record => swap_record,
            i_key    => secret,
            o_record => shift_record
        );

    xor_inst: XOR_stage
        generic map (TAG_SIZE => T)
        port map (
            in_a => shift_record(T * 4 - 1 downto T * 3),
            in_b => shift_record(T * 3 - 1 downto T * 2),
            in_c => shift_record(T * 2 - 1 downto T * 1),
            in_d => shift_record(T * 1 - 1 downto T * 0),
            xor_result => tag_out
        );

end Behavioral;
