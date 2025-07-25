----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.07.2025 16:48:02
-- Design Name: 
-- Module Name: hazard_detection_unit - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hazard_detection_unit is
    port ( prev_opcode : in STD_LOGIC_VECTOR (3 downto 0);
           prev_write_reg : in STD_LOGIC_VECTOR (3 downto 0);
           curr_opcode : in STD_LOGIC_VECTOR (3 downto 0);
           curr_src1 : in STD_LOGIC_VECTOR (3 downto 0);
           curr_src2 : in STD_LOGIC_VECTOR (3 downto 0);
           do_bubble : out STD_LOGIC);
end hazard_detection_unit;

architecture Behavioral of hazard_detection_unit is

constant OP_LOAD  : std_logic_vector(3 downto 0) := "0001";
constant OP_STORE : std_logic_vector(3 downto 0) := "0011";
constant OP_ADD   : std_logic_vector(3 downto 0) := "1000";
constant OP_BEQ   : std_logic_vector(3 downto 0) := "0100";
constant OP_LED   : std_logic_vector(3 downto 0) := "0010";
constant OP_SW    : std_logic_vector(3 downto 0) := "1100";

begin

    calc_bubble : process ( prev_opcode, prev_write_reg, curr_opcode, curr_src1, curr_src2 )
    begin
        if ( prev_opcode = OP_LOAD ) then
            if ( curr_opcode = OP_LOAD ) then
                if ( curr_src1 = prev_write_reg ) then
                    do_bubble <= '1';
                else 
                    do_bubble <= '0';
                end if;
            elsif ( curr_opcode = OP_STORE ) then
                if ( curr_src1 = prev_write_reg or curr_src2 = prev_write_reg ) then
                    do_bubble <= '1';
                else 
                    do_bubble <= '0';
                end if;
            elsif ( curr_opcode = OP_ADD ) then
                if ( curr_src1 = prev_write_reg or curr_src2 = prev_write_reg ) then
                    do_bubble <= '1';
                else 
                    do_bubble <= '0';
                end if;
            elsif ( curr_opcode = OP_BEQ ) then
                if ( curr_src1 = prev_write_reg or curr_src2 = prev_write_reg ) then
                    do_bubble <= '1';
                else 
                    do_bubble <= '0';
                end if;
            elsif ( curr_opcode = OP_LED ) then
                if ( curr_src1 = prev_write_reg ) then
                    do_bubble <= '1';
                else 
                    do_bubble <= '0';
                end if;
            else
                -- we never have to do bubble for SW
                do_bubble <= '0';
            end if;
        else 
            do_bubble <= '0';
        end if;
    end process;

end Behavioral;
