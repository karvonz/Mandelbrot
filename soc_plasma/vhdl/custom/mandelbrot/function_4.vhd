
---------------------------------------------------------------------
-- TITLE: Arithmetic Logic Unit
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 2/8/01
-- FILENAME: alu.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the ALU.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.mlite_pack.all;
use work.constants.all;

entity function_4 is
   port(
		INPUT_1  : in  std_logic_vector(31 downto 0);
		INPUT_2  : in  std_logic_vector(31 downto 0);
		OUTPUT_1 : out std_logic_vector(31 downto 0)
	);
end; --comb_alu_1

architecture logic of function_4 is
begin
	
	-------------------------------------------------------------------------
	computation : process (INPUT_1, INPUT_2)
		variable rTemp1  : SIGNED(63 downto 0);
		variable rTemp2  : SIGNED(31 downto 0);
		variable rTemp3  : SIGNED(31 downto 0);
	begin
		rTemp1 := (signed(signed(INPUT_1) srl 2) * signed(INPUT_2));  --* signed(INPUT_2));
		OUTPUT_1 <= std_logic_vector((rTemp1(32+(FIXED-1) downto FIXED)) sll 8);  --x1*y1
	end process;
	
	-------------------------------------------------------------------------

end; --architecture logic
