library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
--library ims;
--use ims.coprocessor.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

ENTITY TB_Q16_8_NodeRAM is
PORT (
	RESET    : in  STD_LOGIC;
	CLOCK    : in  STD_LOGIC;
	WRITE_EN : in  STD_LOGIC;
	READ_EN  : in  STD_LOGIC;
	INPUT_1  : in  STD_LOGIC_VECTOR(15 downto 0);
	OUTPUT_1 : out STD_LOGIC_VECTOR(15 downto 0)
);
END;

architecture cRAM of TB_Q16_8_NodeRAM is
   type ram_type is array (0 to 1824-1) of STD_LOGIC_VECTOR (15 downto 0);                 
   signal RAM : ram_type;

	SIGNAL READ_C  : UNSIGNED(11 downto 0);
	SIGNAL WRITE_C : UNSIGNED(11 downto 0);

BEGIN

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		--printmsg("(IMS) Q16_8_IndexLUT : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	--
	--
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(11 downto 0);
	begin
		if reset = '0' then
			WRITE_C <= TO_UNSIGNED(0, 12);
		elsif clock'event and clock = '1' then
			if write_en = '1' then
				TEMP := WRITE_C + TO_UNSIGNED(1, 12);
				IF TEMP = 1824 THEN
					TEMP := TO_UNSIGNED(0, 12);
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
		VARIABLE TEMP : UNSIGNED(11 downto 0);
	begin
		if reset = '0' then
			READ_C <= TO_UNSIGNED(0, 12);
		elsif clock'event and clock = '1' then
			if read_en = '1' then
				TEMP := READ_C + TO_UNSIGNED(1, 12);
				IF TEMP = 1824 THEN
					TEMP := TO_UNSIGNED(0, 12);
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
	begin
		if clock'event and clock = '1' then
			if WRITE_EN = '1' then
				RAM( to_integer( WRITE_C ) ) <= INPUT_1;
			end if;
			OUTPUT_1 <= RAM( to_integer(READ_C) );
		end if;
	end process;

END cRAM;
