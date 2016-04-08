library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
library ims;
use ims.coprocessor.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

ENTITY Q16_8_FullXorMin is
PORT (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
END;

ARCHITECTURE rtl of Q16_8_FullXorMin IS
BEGIN

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) Q16_8_FullXorMin : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1, INPUT_2)
		VARIABLE OP1  : SIGNED(15 downto 0);
		VARIABLE MIN1 : SIGNED(15 downto 0);
		VARIABLE MIN2 : SIGNED(15 downto 0);
		VARIABLE SIGN : STD_LOGIC;
  	BEGIN
	
		--
		-- ON RECUPERE NOS OPERANDES
		--
		OP1  := SIGNED(      INPUT_1(15 downto  0));
		MIN1 := SIGNED('0' & INPUT_2(30 downto 16)); -- VALEUR ABSOLUE => PAS DE BIT DE SIGNE (TJS POSITIF)
		MIN2 := SIGNED('0' & INPUT_2(14 downto  0)); -- VALEUR ABSOLUE => PAS DE BIT DE SIGNE (TJS POSITIF)
		SIGN := INPUT_2(31);
		
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

		--
		-- ON S'OCCUPE DU BIT DE SIGNE DU RESULTAT
		--
		SIGN := SIGN XOR (NOT INPUT_1(15) );

		--
		-- ON REFORME LE RESULTAT AVANT DE LE RENVOYER
		--
		OUTPUT_1 <= SIGN & STD_LOGIC_VECTOR(MIN1(14 downto 0)) & '0' & STD_LOGIC_VECTOR(MIN2(14 downto 0)); 
	END PROCESS;
	-------------------------------------------------------------------------

END; 
