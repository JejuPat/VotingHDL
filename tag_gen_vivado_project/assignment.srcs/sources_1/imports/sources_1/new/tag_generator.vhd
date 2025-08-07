----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2025 15:13:41
-- Design Name: 
-- Module Name: tag_generator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tag_generator is
    generic ( C, D : natural := 2;  -- C, D = #of bits for candidate and district respectively, R = #bits per record, T = #tag bits
              R : natural := 12;
              T : natural := 4; 
              S : natural := 16 );
    port ( record_in : in std_logic_vector(R - 1 downto 0);
           secret : in std_logic_vector(S - 1 downto 0);
           tag_out : out std_logic_vector(T - 1 downto 0) );
end tag_generator;

architecture Behavioral of tag_generator is


    constant B : natural := (R + T - 1) / T; -- B is number of blocks
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
        generic (
            TAG_SIZE        : integer;
            RECORD_SIZE     : integer;
            SECRET_KEY_SIZE : integer
        );
        port (
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
        generic (
            TAG_SIZE : natural;
            PADDED_RECORD_SIZE : natural
        );
        port (
            shifted_record : in  std_logic_vector(PADDED_RECORD_SIZE - 1 downto 0);
            xor_result     : out std_logic_vector(TAG_SIZE - 1 downto 0)
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
        generic map (
            TAG_SIZE            => T,
            PADDED_RECORD_SIZE  => EXTENDED_SIZE
        )
        port map (
            shifted_record => shift_record,
            xor_result     => tag_out
        );
end Behavioral;
