library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ims;
use ims.coprocessor.all;
use ims.conversion.all;

library grlib;
use grlib.stdlib.all;
use grlib.sparc.all;
use std.textio.all;

ENTITY INTERFACE_COMB_4 IS
PORT (
		rst    : IN  std_ulogic;
		clk    : IN  std_ulogic;
		holdn  : IN  std_ulogic;
		cancel : IN  std_ulogic;
		inp    : IN  custom32_in_type;
		outp   : OUT custom32_out_type
	);
END;

ARCHITECTURE RTL OF INTERFACE_COMB_4 IS

	-------------------------------------------------------------------------
	-- PRAGMA BEGIN DECLARATION
	COMPONENT Q16_8_V_to_C_RAM
		PORT (
			RESET    : in  STD_LOGIC;
			CLOCK    : in  STD_LOGIC;
			HOLDN    : in  std_ulogic;
			WRITE_EN : in  STD_LOGIC;
			READ_EN  : in  STD_LOGIC;
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT Q16_8_C_to_V_RAM
		PORT (
			RESET    : in  STD_LOGIC;
			CLOCK    : in  STD_LOGIC;
			HOLDN    : in  std_ulogic;
			WRITE_EN : in  STD_LOGIC;
			READ_EN  : in  STD_LOGIC;
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;

	COMPONENT Q16_8_ROM_iPos is
		PORT (
			RESET    : in  STD_LOGIC;
			CLOCK    : in  STD_LOGIC;
			HOLDN    : in  std_ulogic;
			READ_EN  : in  STD_LOGIC;
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;

	COMPONENT Q16_8_ROM_2Pos is
		PORT (
			RESET    : in  STD_LOGIC;
			CLOCK    : in  STD_LOGIC;
			HOLDN    : in  std_ulogic;
			READ_EN  : in  STD_LOGIC;
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT Q16_8_RAM_576s
		PORT (
			RESET    : in  STD_LOGIC;
			CLOCK    : in  STD_LOGIC;
			HOLDN    : in  std_ulogic;
			WRITE_EN : in  STD_LOGIC;
			READ_EN  : in  STD_LOGIC;
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT Q16_8_opr_CtoV_RAM
		PORT (
			RESET    : in  STD_LOGIC;
			CLOCK    : in  STD_LOGIC;
			HOLDN    : in  std_ulogic;
			WRITE_EN : in  STD_LOGIC;
			READ_EN  : in  STD_LOGIC;
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;

	COMPONENT Q16_8_opr_VtoC_RAM
		PORT (
			RESET    : in  STD_LOGIC;
			CLOCK    : in  STD_LOGIC;
			HOLDN    : in  std_ulogic;
			WRITE_EN : in  STD_LOGIC;
			READ_EN  : in  STD_LOGIC;
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;
	-- PRAGMA END DECLARATION
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN SIGNAL
	SIGNAL RESULT_1 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_2 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_3 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_4 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_5 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_6 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_7 : STD_LOGIC_VECTOR(31 downto 0);
	
	SIGNAL READ_EN_1  : STD_LOGIC;
	SIGNAL READ_EN_2  : STD_LOGIC;
	SIGNAL READ_EN_3  : STD_LOGIC;
	SIGNAL READ_EN_4  : STD_LOGIC;
	SIGNAL READ_EN_5  : STD_LOGIC;
	SIGNAL READ_EN_6  : STD_LOGIC;
	SIGNAL READ_EN_7  : STD_LOGIC;

	SIGNAL WRITE_EN_1 : STD_LOGIC;
	SIGNAL WRITE_EN_2 : STD_LOGIC;
	SIGNAL WRITE_EN_3 : STD_LOGIC;
	SIGNAL WRITE_EN_4 : STD_LOGIC;
	SIGNAL WRITE_EN_5 : STD_LOGIC;
	
	SIGNAL sINPUT_1 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL sINPUT_2 : STD_LOGIC_VECTOR(31 downto 0);
	
	-- PRAGMA END SIGNAL
	-------------------------------------------------------------------------
BEGIN

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) INTERFACE_COMB_4 : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
	sINPUT_1 <= inp.op1(31 downto 0);
	sINPUT_2 <= inp.op2(31 downto 0);
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
  	PROCESS(inp.instr, cancel)
    	variable op  : std_logic_vector(1 downto 0);
    	variable op3 : std_logic_vector(5 downto 0);
    	variable opf : std_logic_vector(8 downto 0);
  	BEGIN
      	op  := inp.instr(31 downto 30);
		opf := inp.instr(13 downto  5);
      	op3 := inp.instr(24 downto 19);

		READ_EN_1  <= '0';
		READ_EN_2  <= '0';
		READ_EN_3  <= '0';
		READ_EN_4  <= '0';
		READ_EN_5  <= '0';
		READ_EN_6  <= '0';
		READ_EN_7  <= '0';

		WRITE_EN_1 <= '0';
		WRITE_EN_2 <= '0';
		WRITE_EN_3 <= '0';
		WRITE_EN_4 <= '0';
		WRITE_EN_5 <= '0';

		if( op = "10" ) AND (cancel = '0') THEN
			IF ( op3 = "011101" ) THEN
				if opf = "000000001" THEN
					READ_EN_1  <= '1';			-- 0x01
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING READ_1 SIGNAL");
					-- synthesis translate_on 
				ELSif opf = "000000010" THEN
					WRITE_EN_1 <= '1';			-- 0x02
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING WRITE_1 SIGNAL");
					-- synthesis translate_on 
				ELSif opf = "000000011" THEN
					READ_EN_2  <= '1';			-- 0x03
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING READ_2 SIGNAL");
					-- synthesis translate_on 
				ELSif opf = "000000100" THEN
					WRITE_EN_2 <= '1';			-- 0x04
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING WRITE_2 SIGNAL");
					-- synthesis translate_on 
				ELSif opf = "000000101" THEN
					READ_EN_3  <= '1';			-- 0x05
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING READ_3 SIGNAL (ldipos)");
					-- synthesis translate_on 
				ELSif opf = "000000110" THEN
					READ_EN_4  <= '1';			-- 0x06
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING READ_4 SIGNAL");
					-- synthesis translate_on 
				ELSif opf = "000000111" THEN
					READ_EN_5  <= '1';			-- 0x07
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING READ_5 SIGNAL");
					-- synthesis translate_on 
				ELSif opf = "000001000" THEN
					WRITE_EN_3  <= '1';			-- 0x08
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING WRITE_3 SIGNAL");
					-- synthesis translate_on 
				ELSif opf = "000001001" THEN
					READ_EN_6  <= '1';			-- 0x09
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING READ_6 SIGNAL");
					-- synthesis translate_on 
				ELSif opf = "000001010" THEN
					WRITE_EN_4  <= '1';			-- 0x0A
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING WRITE_4 SIGNAL (Q16_8_opr_VtoC_RAM)");
					-- synthesis translate_on 
				ELSif opf = "000001011" THEN
					READ_EN_7  <= '1';			-- 0x0B
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING READ_7 SIGNAL");
					-- synthesis translate_on 
				ELSif opf = "000001100" THEN
					-- synthesis translate_off 
					--printmsg("(INTERFACE_COMB_4) ===> GENERATING WRITE SIGNAL TO RESOURCE (7)");
					-- synthesis translate_on 
					WRITE_EN_5  <= '1';			-- 0x0C
				ELSE
					-- synthesis translate_off 
					printmsg("(INTERFACE_COMB_4) ===> GENERATING AN OUPS PROBLEM");
					-- synthesis translate_on 
				END IF;
			END IF;
		END IF;
  	END PROCESS;
	-------------------------------------------------------------------------
	

	-------------------------------------------------------------------------
	-- PRAGMA BEGIN INSTANCIATION
	RESOURCE_1 : Q16_8_C_to_V_RAM   PORT MAP (rst, clk, holdn, WRITE_EN_1, READ_EN_1, sINPUT_1,           RESULT_1);
	RESOURCE_2 : Q16_8_V_to_C_RAM   PORT MAP (rst, clk, holdn, WRITE_EN_2, READ_EN_2, sINPUT_1,           RESULT_2);
	RESOURCE_3 : Q16_8_ROM_iPos     PORT MAP (rst, clk, holdn,             READ_EN_3,                     RESULT_3);
	RESOURCE_4 : Q16_8_ROM_2Pos     PORT MAP (rst, clk, holdn,             READ_EN_4,                     RESULT_4);
	RESOURCE_5 : Q16_8_opr_CtoV_RAM PORT MAP (rst, clk, holdn, WRITE_EN_3, READ_EN_5, sINPUT_1, sINPUT_2, RESULT_5);
	RESOURCE_6 : Q16_8_opr_VtoC_RAM PORT MAP (rst, clk, holdn, WRITE_EN_4, READ_EN_6, sINPUT_1, sINPUT_2, RESULT_6);
	RESOURCE_7 : Q16_8_RAM_576s     PORT MAP (rst, clk, holdn, WRITE_EN_5, READ_EN_7, sINPUT_1,           RESULT_7);
	-- PRAGMA END INSTANCIATION
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN RESULT SELECTION
	WITH inp.instr(13 downto 5) SELECT
		outp.result <= 
					RESULT_1 WHEN "000000001",
					RESULT_1 WHEN "000000010",
					RESULT_2 WHEN "000000011",
					RESULT_2 WHEN "000000100",
					RESULT_3 WHEN "000000101",
					RESULT_4 WHEN "000000110",
					RESULT_5 WHEN "000000111",
					RESULT_5 WHEN "000001000",
					RESULT_6 WHEN "000001001",
					RESULT_6 WHEN "000001010",
					RESULT_7 WHEN "000001011",
					RESULT_7 WHEN "000001100",
					STD_LOGIC_VECTOR( TO_SIGNED(-1, 32) ) WHEN OTHERS;
	-- PRAGMA END RESULT SELECTION
	-------------------------------------------------------------------------
	
end; 