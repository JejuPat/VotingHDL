---------------------------------------------------------------------------
-- instruction_memory.vhd - Implementation of A Single-Port, 16 x 16-bit
--                          Instruction Memory.
-- 
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(3 downto 0);
           insn_out : out std_logic_vector(15 downto 0) );
end instruction_memory;

architecture behavioral of instruction_memory is

type mem_array is array(0 to 15) of std_logic_vector(15 downto 0);
signal sig_insn_mem : mem_array;

begin
    mem_process: process ( clk,
                           addr_in ) is
  
    variable var_insn_mem : mem_array;
    variable var_addr     : integer;
  
    begin
        if (reset = '1') then
            -- initial values of the instruction memory :
            --  insn_0 : load  $1, $0, 0   - load data 0($0) into $1 "1010"
            --  insn_1 : load  $2, $0, 1   - load data 1($0) into $2 "1021"
            --  insn_2 : add   $3, $0, $1  - $3 <- $0 + $1           "8013"
            --  insn_3 : add   $4, $1, $2  - $4 <- $1 + $2           "8124"
            --  insn_4 : store $3, $0, 2   - store data $3 into 2($0) "3032"
            --  insn_5 : store $4, $0, 3   - store data $4 into 3($0) "3043
            --  insn_6 - insn_15 : noop    - end of program          "0000"

--            var_insn_mem(0)  := X"1010";
--            var_insn_mem(1)  := X"1021";
--            var_insn_mem(2)  := X"8013";
--            var_insn_mem(3)  := X"8124";
--            var_insn_mem(4)  := X"3032";
--            var_insn_mem(5)  := X"3043";
--            var_insn_mem(6)  := X"4440";
--            var_insn_mem(7)  := X"0000";
--            var_insn_mem(8)  := X"0000";
--            var_insn_mem(9)  := X"0000";
--            var_insn_mem(10) := X"0000";
--            var_insn_mem(11) := X"0000";
--            var_insn_mem(12) := X"0000";
--            var_insn_mem(13) := X"0000";
--            var_insn_mem(14) := X"0000";
--            var_insn_mem(15) := X"4002";
            
            
            
            -- insn_0 : sw    $1              - load data sw into $1 "C001" -- where sw = "001D"
            -- insn_1 : load    $2, $0, 7     - load data 7($0) into $2 "1027" -- where 7($0) == 0001
            -- insn_2 : add     $3, $0, $0    - $3 <- $0 + $0 = 0 "8003"
            
            -- here we are setting up a for loop (for (int i = 0; i < X"001D"; i++)
            
            -- insn_3 : beq     $1, $3, 4      - branch _ instructions ahead if we reach $3 == 001D "4134"
            -- insn_4 : store   $3, $0, 2      - store data 3 into 2($0)  "3032"
            -- insn_5 : led     $0, 2          - send data from 2($0) to led "20X2"
            -- insn_6 : add     $3, $3, $2     - $3 = $3 + $2 ($3+1)   "8323"
            -- insn_7 : beq     $0, $0, -5     - branch back to loop cond  "400B" (1011 == B == -5 since 5 = 0101)
            
            -- here we are at the end of the loop so no-op from here on out until
            
            -- ...
            -- insn_15 : beq    $0, $0, -1     - continually branch back "1" to get stuck here "400F"

            var_insn_mem(0)  := X"C001";
            var_insn_mem(1)  := X"1027";
            var_insn_mem(2)  := X"8003";
            var_insn_mem(3)  := X"4134";
            var_insn_mem(4)  := X"3032";
            var_insn_mem(5)  := X"2012";
            var_insn_mem(6)  := X"8323";
            var_insn_mem(7)  := X"400B";
            var_insn_mem(8)  := X"8626";
            var_insn_mem(9)  := X"1077";
            var_insn_mem(10) := X"8679";
            var_insn_mem(11) := X"309a";
            var_insn_mem(12) := X"202a";
            var_insn_mem(13) := X"0000";
            var_insn_mem(14) := X"0000";
            var_insn_mem(15) := X"400F";
        
        else
            -- read instructions on the rising clock edge
            var_addr := conv_integer(addr_in);
            insn_out <= var_insn_mem(var_addr);
        end if;

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;

    end process;
  
end behavioral;
