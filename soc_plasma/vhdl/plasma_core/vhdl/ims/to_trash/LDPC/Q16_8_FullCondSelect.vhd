library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
library ims;
use ims.coprocessor.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

ENTITY Q16_8_FullCondSelect is
PORT (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
END;

ARCHITECTURE rtl of Q16_8_FullCondSelect IS
BEGIN

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) Q16_8_FullCondSelect : ALLOCATION OK !");
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
		VARIABLE RESUp : SIGNED(15 downto 0);
		VARIABLE iSIGN : STD_LOGIC;
		VARIABLE sSIGN : STD_LOGIC;
  	BEGIN
		--
		-- ON RECUPERE NOS OPERANDES
		--
		OP1   := SIGNED(      INPUT_1(15 downto  0)); -- DONNEE SIGNEE SUR 16 bits
		MIN1  := SIGNED('0' & INPUT_2(30 downto 16)); -- DONNEE TJS POSITIVE SUR 16 BITS
		MIN2  := SIGNED('0' & INPUT_2(14 downto  0)); -- DONNEE TJS POSITIVE SUR 16 BITS
		iSIGN := INPUT_1(15); -- ON EXTRAIT LA VALEUR DU SIGNE DE LA SOMME
		sSIGN := INPUT_2(31); -- ON EXTRAIT LA VALEUR DU SIGNE DE LA SOMME
		
		--
		--
		--
		aOP1 := abs( OP1 );
		
		--
		--
		--
		CST1 := MIN2 - TO_SIGNED(38, 16); -- BETA_FIX;
		CST2 := MIN1 - TO_SIGNED(38, 16); -- BETA_FIX; 
		IF CST1 < TO_SIGNED(0, 16) THEN CST1 := TO_SIGNED(0, 16); END IF;
		IF CST2 < TO_SIGNED(0, 16) THEN CST2 := TO_SIGNED(0, 16); END IF;

		--
		--
		--
		if ( aOP1 = MIN1 ) THEN
			RESU := CST1;
		ELSE
			RESU := CST2;
		END IF;
		
		--
		--
		--
		RESUp := -RESU;
		iSIGN := iSIGN XOR sSIGN;
		
		--
		--
		--
		IF( iSIGN = '0' ) THEN 
			OUTPUT_1 <= STD_LOGIC_VECTOR( RESIZE(RESU, 32)  ); 
		ELSE
			OUTPUT_1 <= STD_LOGIC_VECTOR( RESIZE(RESUp, 32) ); 
		END IF;
		
		
	END PROCESS;
	-------------------------------------------------------------------------

END; 
