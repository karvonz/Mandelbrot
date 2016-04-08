library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
--library ims;
--use ims.coprocessor.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

ENTITY Q16_8_RAM_288s is
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

architecture aQ16_8_RAM_288s of Q16_8_RAM_288s is
	type ram_type is array (0 to 288-1) of STD_LOGIC_VECTOR (15 downto 0);                 
	signal RAM : ram_type;

	SIGNAL READ_C  : UNSIGNED(8 downto 0);
	SIGNAL WRITE_C : UNSIGNED(8 downto 0);

BEGIN

	--
	--
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(8 downto 0);
	begin
		if reset = '0' then
			WRITE_C <= TO_UNSIGNED(0, 9);
		elsif clock'event and clock = '1' then
			if write_en = '1' then
				TEMP := WRITE_C + TO_UNSIGNED(1, 9);
				IF TEMP = 288 THEN
					TEMP := TO_UNSIGNED(0, 9);
				END IF;
				WRITE_C <= TEMP;
			else
				WRITE_C <= WRITE_C;
			end if;
		end if;
	end process;


	--
	--
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(8 downto 0);
	begin
		if reset = '0' then
			READ_C <= TO_UNSIGNED(0, 9);
		elsif clock'event and clock = '1' then
			if read_en = '1' then
				TEMP := READ_C + TO_UNSIGNED(1, 9);
				IF TEMP = 288 THEN
					TEMP := TO_UNSIGNED(0, 9);
				END IF;
				READ_C <= TEMP;
			else
				READ_C <= READ_C;
			end if;
		end if;
	end process;


	--
	--
	--
	process(clock)
		VARIABLE AR  : INTEGER RANGE 0 to 287;
		VARIABLE AW  : INTEGER RANGE 0 to 287;
	begin
		if clock'event and clock = '1' then
			AR := to_integer( READ_C  );
			AW := to_integer( WRITE_C );
			if WRITE_EN = '1' then
				RAM( AW ) <= INPUT_1(15 downto 0);
			end if;
			OUTPUT_1(15 downto 0) <= RAM( AR );
		end if;
	end process;

	OUTPUT_1(31 downto 16) <= "0000000000000000";

END aQ16_8_RAM_288s;
