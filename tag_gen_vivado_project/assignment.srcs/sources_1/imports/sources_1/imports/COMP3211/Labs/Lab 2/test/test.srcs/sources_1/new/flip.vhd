library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flip is
    generic (
        EXTENDED_SIZE : natural := 16;
        TAG_SIZE      : natural := 4;
        KEY_SIZE      : natural := 16
    );
    port (
        i_record : in  std_logic_vector(EXTENDED_SIZE-1 downto 0);
        i_key    : in  std_logic_vector(KEY_SIZE-1 downto 0);
        o_record : out std_logic_vector(EXTENDED_SIZE-1 downto 0)
    );
end entity;

architecture Behavioral of flip is
    function ceil_log2 (x: integer) return integer is
        variable res: integer := 0;
        variable val: integer := x - 1;
    begin
        while val > 0 loop
            val := val / 2;
            res := res + 1;
        end loop;
        return res;
    end function;

    constant BS_WIDTH : integer := ceil_log2(EXTENDED_SIZE / TAG_SIZE);

begin

    process(i_key, i_record)
        variable idx          : integer;
        variable temp_record  : std_logic_vector(EXTENDED_SIZE-1 downto 0);
    begin
        idx := to_integer(unsigned(i_key(BS_WIDTH - 1 downto 0)));

        temp_record := i_record;
        for j in 0 to TAG_SIZE - 1 loop
            temp_record(TAG_SIZE * idx + j) := not i_record(TAG_SIZE * idx + j);
        end loop;

        o_record <= temp_record;
    end process;

end architecture;

