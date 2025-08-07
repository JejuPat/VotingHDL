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

    constant BS_WIDTH : natural := ceil_log2(EXTENDED_SIZE / TAG_SIZE);
    constant R_WIDTH  : natural := ceil_log2(TAG_SIZE);
    constant NUM_SLICES : natural := EXTENDED_SIZE / TAG_SIZE;

    signal bs_index   : integer range 0 to NUM_SLICES-1 := 0;
    signal rot_amt    : integer range 0 to TAG_SIZE-1 := 0;
    signal reg_slice  : unsigned(TAG_SIZE-1 downto 0);
    signal reg_slice_rot : unsigned(TAG_SIZE-1 downto 0);
    signal temp_record: std_logic_vector(EXTENDED_SIZE-1 downto 0);

begin

    -- Safe slicing of key input
    bs_index <= to_integer(unsigned(i_key(KEY_SIZE - 1 downto KEY_SIZE - BS_WIDTH))) mod NUM_SLICES;
    rot_amt  <= to_integer(unsigned(i_key(KEY_SIZE - BS_WIDTH - 1 downto KEY_SIZE - BS_WIDTH - R_WIDTH))) mod TAG_SIZE;

    -- Extract and rotate the slice
    reg_slice <= unsigned(i_record(TAG_SIZE * (bs_index + 1) - 1 downto TAG_SIZE * bs_index));
    reg_slice_rot <= rotate_left(reg_slice, rot_amt);

    -- Overwrite the rotated slice into the output
    process(i_record, reg_slice_rot)
    begin
        temp_record <= i_record;
        temp_record(TAG_SIZE * (bs_index + 1) - 1 downto TAG_SIZE * bs_index) <= std_logic_vector(reg_slice_rot);
    end process;

    o_record <= temp_record;

end behavioural;
