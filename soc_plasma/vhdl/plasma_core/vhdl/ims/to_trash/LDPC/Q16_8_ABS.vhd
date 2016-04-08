library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
library ims;
use ims.coprocessor.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

entity Q16_8_ABS is
port (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
end;

architecture rtl of Q16_8_ABS is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) Q16_8_ABS : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1)
		VARIABLE temp  : SIGNED(15 downto 0);
  	begin
		temp := abs( SIGNED( INPUT_1(15 downto 0) ) );
		OUTPUT_1 <= STD_LOGIC_VECTOR( RESIZE(temp, 32) );
	END PROCESS;
	-------------------------------------------------------------------------

end; 
