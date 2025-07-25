----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.07.2025 18:11:26
-- Design Name: 
-- Module Name: forwarding_unit - Behavioral
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

entity forwarding_unit is
    port ( src1_data : in STD_LOGIC_VECTOR (15 downto 0);
           src2_data : in STD_LOGIC_VECTOR (15 downto 0);
           src1_reg : in STD_LOGIC_VECTOR (3 downto 0);
           src2_reg : in STD_LOGIC_VECTOR (3 downto 0);
           MEM_data : in STD_LOGIC_VECTOR (15 downto 0);
           MEM_dst : in STD_LOGIC_VECTOR (3 downto 0);
           MEM_write : in STD_LOGIC;
           WB_data : in STD_LOGIC_VECTOR (15 downto 0);
           WB_dst : in STD_LOGIC_VECTOR (3 downto 0);
           WB_write : in STD_LOGIC; 
           src1_fwd : out STD_LOGIC_VECTOR (15 downto 0); 
           src2_fwd : out STD_LOGIC_VECTOR(15 downto 0) );
end forwarding_unit;

architecture Behavioral of forwarding_unit is

begin

    process ( src1_data, src2_data, src1_reg, src2_reg, MEM_data, MEM_dst, MEM_write, WB_data, WB_dst, WB_write )
    begin
        if ( MEM_write = '1' ) then
            if src1_reg = MEM_dst and not (MEM_dst = "0000") then 
                src1_fwd <= MEM_data;
            else
                src1_fwd <= src1_data;
            end if;
            
            if src2_reg = MEM_dst and not (MEM_dst = "0000") then 
                src2_fwd <= MEM_data;
            else
                src2_fwd <= src2_data;
            end if;
        elsif ( WB_write = '1' ) then
            if src1_reg = WB_dst and not (WB_dst = "0000") then 
                src1_fwd <= WB_data;
            else
                src1_fwd <= src1_data;
            end if;
            
            if src2_reg = WB_dst and not (WB_dst = "0000") then 
                src2_fwd <= WB_data;
            else
                src2_fwd <= src2_data;
            end if;
        else 
            src1_fwd <= src1_data;
            src2_fwd <= src2_data;
        end if;
        
        
    end process;

end Behavioral;
