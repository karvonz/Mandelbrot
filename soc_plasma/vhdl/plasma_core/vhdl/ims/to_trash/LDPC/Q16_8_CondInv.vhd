library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
library ims;
use ims.coprocessor.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

ENTITY Q16_8_CondInv is
PORT (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
END;

ARCHITECTURE rtl of Q16_8_CondInv IS
BEGIN

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) Q16_8_CondInv : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1, INPUT_2)
		VARIABLE OP1 : SIGNED(15 downto 0);
		VARIABLE OP2 : SIGNED(15 downto 0);
  	BEGIN
		OP1 := SIGNED(INPUT_2(15 downto 0));
		OP2 := -OP1;
		
		IF( INPUT_1(0) = '0' ) THEN 
			OUTPUT_1 <= STD_LOGIC_VECTOR( RESIZE(OP2,32) ); 
		ELSE
			OUTPUT_1 <= STD_LOGIC_VECTOR( RESIZE(OP1,32) ); 
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------

END; 
