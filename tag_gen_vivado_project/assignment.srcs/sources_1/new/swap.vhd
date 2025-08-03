library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity swap is
    generic (
        TAG_SIZE        : integer := 4;
        RECORD_SIZE     : integer := 16;
        SECRET_KEY_SIZE : integer := 16
    );
    port (
        i_record   : in  std_logic_vector(RECORD_SIZE - 1 downto 0);
        secret_key : in  std_logic_vector(SECRET_KEY_SIZE - 1 downto 0);
        o_record   : out std_logic_vector(RECORD_SIZE - 1 downto 0)
    );
end swap;

architecture Behavioral of swap is
    function ceil_log2(x : integer) return integer is
        variable res : integer := 0;
        variable val : integer := x - 1;
    begin
        while val > 0 loop
            val := val / 2;
            res := res + 1;
        end loop;
        return res;
    end function;

    constant CEIL2_BLOCK : integer := ceil_log2(RECORD_SIZE / TAG_SIZE);
    constant CEIL2_TAG   : integer := ceil_log2(TAG_SIZE);

    signal modified_record : std_logic_vector(RECORD_SIZE - 1 downto 0);

begin

    process(i_record, secret_key)
        variable bx, by     : integer range 0 to (RECORD_SIZE / TAG_SIZE) - 1;
        variable px, py, s  : integer range 0 to TAG_SIZE - 1;
        variable block1, block2, new_block1, new_block2 : std_logic_vector(TAG_SIZE - 1 downto 0);
        variable seg1, seg2 : std_logic_vector(TAG_SIZE - 1 downto 0);
        variable temp_record : std_logic_vector(RECORD_SIZE - 1 downto 0);
    begin
        -- Extract swap parameters from secret_key
        bx := to_integer(unsigned(secret_key(CEIL2_BLOCK * 2 - 1 downto CEIL2_BLOCK)));
        by := to_integer(unsigned(secret_key(CEIL2_BLOCK * 3 - 1 downto CEIL2_BLOCK * 2)));
        px := to_integer(unsigned(secret_key(CEIL2_BLOCK * 3 + CEIL2_TAG - 1 downto CEIL2_BLOCK * 3)));
        py := to_integer(unsigned(secret_key(CEIL2_BLOCK * 3 + CEIL2_TAG * 2 - 1 downto CEIL2_BLOCK * 3 + CEIL2_TAG)));
        s  := to_integer(unsigned(secret_key(CEIL2_BLOCK * 3 + CEIL2_TAG * 3 - 1 downto CEIL2_BLOCK * 3 + CEIL2_TAG * 2)));

        -- Extract the two blocks to be swapped
        block1 := i_record(TAG_SIZE * (bx + 1) - 1 downto TAG_SIZE * bx);
        block2 := i_record(TAG_SIZE * (by + 1) - 1 downto TAG_SIZE * by);

        new_block1 := block1;
        new_block2 := block2;

        -- Extract segments and swap them
        for i in 0 to s - 1 loop
            seg1(i) := block1((px + i) mod TAG_SIZE);
            seg2(i) := block2((py + i) mod TAG_SIZE);
        end loop;

        for i in 0 to s - 1 loop
            new_block1((px + i) mod TAG_SIZE) := seg2(i);
            new_block2((py + i) mod TAG_SIZE) := seg1(i);
        end loop;

        -- Assign modified record
        temp_record := i_record;
        temp_record(TAG_SIZE * (bx + 1) - 1 downto TAG_SIZE * bx) := new_block1;
        temp_record(TAG_SIZE * (by + 1) - 1 downto TAG_SIZE * by) := new_block2;

        o_record <= temp_record;
    end process;

end Behavioral;
