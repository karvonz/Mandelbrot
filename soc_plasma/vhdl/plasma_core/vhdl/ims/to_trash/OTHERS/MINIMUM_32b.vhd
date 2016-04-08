library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library ims;
--use ims.coprocessor.all;

entity MINIMUM_32b is
port (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
end;

architecture rtl of MINIMUM_32b is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		ASSERT false REPORT "(IMS) MINIMUM_32b : ALLOCATION OK !";
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
  	process (INPUT_1, INPUT_2)
  	begin
		if( SIGNED(INPUT_1) < SIGNED(INPUT_2) ) then
			OUTPUT_1 <= INPUT_1;
		else
			OUTPUT_1 <= INPUT_2;
		end if;
	end process;
	-------------------------------------------------------------------------

end; 

