library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
library ims;
use ims.coprocessor.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

entity Q16_8_DECISION is
port (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
end;

architecture rtl of Q16_8_DECISION is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) Q16_8_DECISION : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1)
		VARIABLE temp  : SIGNED(15 downto 0);
  	begin
		temp := SIGNED( INPUT_1(15 downto 0) );
		IF temp < TO_SIGNED(0, 16) THEN
			OUTPUT_1 <= STD_LOGIC_VECTOR( TO_UNSIGNED(0, 32) );
		ELSE
			OUTPUT_1 <= STD_LOGIC_VECTOR( TO_UNSIGNED(1, 32) );
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------

END; 