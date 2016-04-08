library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
library ims;
use ims.coprocessor.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

ENTITY Q16_8_CondSelect is
PORT (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
END;

ARCHITECTURE rtl of Q16_8_CondSelect IS
BEGIN

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) Q16_8_CondSelect : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1, INPUT_2)
		VARIABLE OP1  : SIGNED(15 downto 0);
		VARIABLE aOP1 : SIGNED(15 downto 0);
		VARIABLE MIN1 : SIGNED(15 downto 0);
		VARIABLE MIN2 : SIGNED(15 downto 0);
		VARIABLE CST1 : SIGNED(15 downto 0);
		VARIABLE CST2 : SIGNED(15 downto 0);
		VARIABLE RESU : SIGNED(15 downto 0);
  	BEGIN
		-- ON RECUPERE NOS OPERANDES
		OP1  := SIGNED(INPUT_1(15 downto  0));
		MIN1 := SIGNED(INPUT_2(31 downto 16));
		MIN2 := SIGNED(INPUT_2(15 downto  0));
		aOP1 := abs( OP1 );
		CST1 := MIN2 - TO_SIGNED(38, 16); -- BETA_FIX;
		CST2 := MIN1 - TO_SIGNED(38, 16); -- BETA_FIX; 
		IF CST1 < TO_SIGNED(0, 16) THEN CST1 := TO_SIGNED(0, 16); END IF;
		IF CST2 < TO_SIGNED(0, 16) THEN CST2 := TO_SIGNED(0, 16); END IF;

		if ( aOP1 = MIN1 ) THEN
			RESU := CST1;
		ELSE
			RESU := CST2;
		END IF;
		OUTPUT_1 <= "0000000000000000" & STD_LOGIC_VECTOR(RESU);
	END PROCESS;
	-------------------------------------------------------------------------

END; 
