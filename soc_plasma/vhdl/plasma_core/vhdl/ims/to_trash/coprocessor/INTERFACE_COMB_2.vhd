library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ims;
use ims.coprocessor.all;

ENTITY INTERFACE_COMB_2 IS
PORT (
		inp  : IN  custom32_in_type;
		outp : OUT custom32_out_type
	);
END;

ARCHITECTURE RTL OF INTERFACE_COMB_2 IS

	-------------------------------------------------------------------------
	-- PRAGMA BEGIN DECLARATION
	-- PRAGMA END DECLARATION
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN SIGNAL
	-- PRAGMA END SIGNAL
	-------------------------------------------------------------------------
	
BEGIN

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) INTERFACE_COMB_2 : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN INSTANCIATION
	-- PRAGMA END INSTANCIATION
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	-- PRAGMA BEGIN RESULT SELECTION
	outp.result <= inp.op1(31 downto 0) AND inp.op2(31 downto 0);
	-- PRAGMA END RESULT SELECTION
	-------------------------------------------------------------------------
	
end; 
