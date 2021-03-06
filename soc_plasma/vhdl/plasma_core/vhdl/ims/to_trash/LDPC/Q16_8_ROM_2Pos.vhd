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

ENTITY Q16_8_ROM_2Pos is
	PORT (
		RESET    : in  STD_LOGIC;
		CLOCK    : in  STD_LOGIC;
		HOLDN    : in  std_ulogic;
		READ_EN  : in  STD_LOGIC;
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
END;

architecture cRAM of Q16_8_ROM_2Pos is

	type rom_type is array (0 to 288-1) of UNSIGNED(2 downto 0);
	constant rom_2Pos : rom_type := (
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), TO_UNSIGNED(6, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), 
		TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3), TO_UNSIGNED(7, 3)
	);

	SIGNAL READ_C  : UNSIGNED(11 downto 0);
	--SIGNAL WRITE_C : UNSIGNED(11 downto 0);
	--SIGNAL ROM_ADR : UNSIGNED(11 downto 0);

   --signal IN_BIS : STD_LOGIC_VECTOR (15 downto 0);
   --signal WE_BIS : STD_LOGIC;
   --signal HD_BIS : STD_LOGIC;
	
BEGIN

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	--PROCESS
  	--BEGIN
    	--WAIT FOR 1 ns;
		--printmsg("(IMS) Q16_8_IndexLUT : ALLOCATION OK !");
    	--WAIT;
  	--END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	--
	--
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(11 downto 0);
		VARIABLE ADR  : INTEGER RANGE 0 to 288;
	begin
		if reset = '0' then
			READ_C <= TO_UNSIGNED(0, 12);
			OUTPUT_1(2 downto 0) <= "000";
		elsif clock'event and clock = '1' then
			TEMP := READ_C;
			if read_en = '1' AND holdn = '1' then
				TEMP := TEMP + TO_UNSIGNED(1, 12);
				IF TEMP = 288 THEN
					TEMP := TO_UNSIGNED(0, 12);
				END IF;
			end if;
			READ_C   <= TEMP;
			ADR      := to_integer( TEMP );
			OUTPUT_1(2 downto 0) <= STD_LOGIC_VECTOR( rom_2Pos( ADR ) );
		end if;
	end process;

	OUTPUT_1(31 downto 3) <= "00000000000000000000000000000";
	
END cRAM;