library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_tag_generator is
end tb_tag_generator;

architecture behavior of tb_tag_generator is
    constant C : natural := 2;
    constant D : natural := 2;
    constant R : natural := 15;
    constant T : natural := 4;
    constant S : natural := 16;

    signal record_in : std_logic_vector(R - 1 downto 0);
    signal secret    : std_logic_vector(S - 1 downto 0);
    signal tag_out   : std_logic_vector(T - 1 downto 0);

    component tag_generator
        generic (C : natural; D : natural; R : natural; T : natural; S : natural);
        port (
            record_in : in  std_logic_vector(R - 1 downto 0);
            secret    : in  std_logic_vector(S - 1 downto 0);
            tag_out   : out std_logic_vector(T - 1 downto 0)
        );
    end component;

begin
    uut: tag_generator
        generic map (C => C, D => D, R => R, T => T, S => S)
        port map (
            record_in => record_in,
            secret    => secret,
            tag_out   => tag_out
        );

    process
    begin
        wait for 10 ns;
        record_in <= "010000111001100"; -- from example
        secret    <= "1110100001011001"; -- bs=11 r=10 s=10 py=00 px=01 by=01 bx=10 bf=01
        wait for 20 ns;
    end process;

end behavior;
