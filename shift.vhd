library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift is
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
end entity;

architecture behavioural of shift is

    function ceil_log2 (Arg : positive) return natural is
        variable RetVal: natural := 0;
        variable Temp  : natural := Arg;
    begin
        Temp := Temp - 1;
        while Temp > 0 loop
            Temp    := Temp / 2;
            RetVal  := RetVal + 1;
        end loop;
        return RetVal;
    end function;

    constant BS_WIDTH   : natural := ceil_log2(TAG_SIZE);
    constant R_WIDTH    : natural := ceil_log2(TAG_SIZE);
    signal shifted_data : std_logic_vector(TAG_SIZE-1 downto 0);

begin

process(i_key, i_record)
    variable bs_index   : integer;
    variable rot_amt    : integer;
    variable reg_slice  : unsigned(TAG_SIZE-1 downto 0);
    variable temp_record: std_logic_vector(EXTENDED_SIZE-1 downto 0);
begin
    bs_index := to_integer(unsigned(i_key(KEY_SIZE - 1 downto KEY_SIZE - ceil_log2(TAG_SIZE))));
    rot_amt  := to_integer(unsigned(i_key(KEY_SIZE - ceil_log2(TAG_SIZE) - 1 downto KEY_SIZE - 2*ceil_log2(TAG_SIZE))));

    reg_slice   := unsigned(i_record(TAG_SIZE * (bs_index + 1) - 1 downto TAG_SIZE * bs_index));
    temp_record := i_record;

    temp_record(TAG_SIZE * (bs_index + 1) - 1 downto TAG_SIZE * bs_index) := std_logic_vector(rotate_left(reg_slice, rot_amt));

    o_record <= temp_record;
end process;


end behavioural;
