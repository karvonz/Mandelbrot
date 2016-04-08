library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
library ims;
use ims.coprocessor.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

ENTITY Q16_8_DoubleMini is
PORT (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
END;

ARCHITECTURE rtl of Q16_8_DoubleMini IS
BEGIN

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) Q16_8_DoubleMini : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1, INPUT_2)
		VARIABLE OP1  : SIGNED(15 downto 0);
		VARIABLE MIN1 : SIGNED(15 downto 0);
		VARIABLE MIN2 : SIGNED(15 downto 0);
  	BEGIN
	
		--
		-- ON RECUPERE NOS OPERANDES
		--
		OP1  := SIGNED(INPUT_1(15 downto  0));
		MIN1 := SIGNED(INPUT_2(31 downto 16));
		MIN2 := SIGNED(INPUT_2(15 downto  0));
		
		--
		-- ON CALCULE LA VALEUR ABSOLUE DE L'ENTREE
		--
		OP1 := abs( OP1 );

		--
		-- ON CALCULE LE MIN QUI VA BIEN
		--
		IF OP1 < MIN1 THEN
			MIN2 := MIN1;
			MIN1 := OP1;
		ELSIF OP1 < MIN2 THEN
			MIN2 := OP1;
		END IF;
		
		OUTPUT_1 <= STD_LOGIC_VECTOR(MIN1) & STD_LOGIC_VECTOR(MIN2); 
	END PROCESS;
	-------------------------------------------------------------------------

END; 
