library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
library ims;
use ims.coprocessor.all;
use ims.conversion.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

ENTITY Q16_8_RAM_576s is
	PORT (
		RESET    : in  STD_LOGIC;
		CLOCK    : in  STD_LOGIC;
		HOLDN    : in  std_ulogic;
		WRITE_EN : in  STD_LOGIC;
		READ_EN  : in  STD_LOGIC;
		INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
END;

architecture aQ16_8_RAM_576s of Q16_8_RAM_576s is
	type ram_type is array (0 to 576-1) of STD_LOGIC_VECTOR (15 downto 0);                 
	signal RAM     : ram_type;
	SIGNAL READ_C  : UNSIGNED(9 downto 0);
	SIGNAL WRITE_C : UNSIGNED(9 downto 0);
BEGIN

	--
	--
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(9 downto 0);
	begin
		if reset = '0' then
			WRITE_C <= TO_UNSIGNED(0, 10);
		elsif clock'event and clock = '1' then
			if write_en = '1' AND holdn = '1' then
				TEMP := WRITE_C + TO_UNSIGNED(1, 10);
				IF TEMP = 576 THEN
					TEMP := TO_UNSIGNED(0, 10);
				END IF;
				WRITE_C <= TEMP;
			else
				WRITE_C <= WRITE_C;
			end if;
		end if;
	end process;


	--
	-- COMPTEUR EN CHARGE DE LA GENERATION DE L'ADRESSE DES DONNEES
	-- A LIRE DANS LA MEMOIRE (ACCES LINAIRE DE 0 => 575)
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(9 downto 0);
	begin
		if reset = '0' then
			READ_C <= TO_UNSIGNED(0, 10);
		elsif clock'event and clock = '1' then
			TEMP := READ_C;
			if read_en = '1' AND holdn = '1' then
				-- synthesis translate_off 
				-- printmsg("(Q16_8_RAM_576s) ===> READING (" & to_int_str( STD_LOGIC_VECTOR( RAM( to_integer(TEMP) ) ), 6) & ") AT POSITION : " & to_int_str( STD_LOGIC_VECTOR(TEMP),6) );
				-- synthesis translate_on 
				TEMP := TEMP + TO_UNSIGNED(1, 10);
				IF TEMP = 576 THEN
					TEMP := TO_UNSIGNED(0, 10);
				END IF;
			end if;
			READ_C   <= TEMP;
			OUTPUT_1 <= STD_LOGIC_VECTOR(RESIZE( SIGNED(RAM( to_integer(TEMP) )), 32));
		end if;
	end process;


	--
	--
	--
	process(clock)
		VARIABLE AR  : INTEGER RANGE 0 to 575;
		VARIABLE AW  : INTEGER RANGE 0 to 575;
	begin
		if clock'event and clock = '1' then
			--AR := to_integer( READ_C  );
			if WRITE_EN = '1' AND holdn = '1' then
				AW := to_integer( WRITE_C );
				RAM( AW ) <= INPUT_1(15 downto 0);
				-- synthesis translate_off 
				-- printmsg("(Q16_8_RAM_576s) ===> WRITING (" & to_int_str( STD_LOGIC_VECTOR(INPUT_1(15 downto 0)),6) & ") AT POSITION : " & to_int_str( STD_LOGIC_VECTOR(WRITE_C),6) );
				-- synthesis translate_on 
			end if;
		end if;
	end process;

END aQ16_8_RAM_576s;