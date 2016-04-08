library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ims;
use ims.coprocessor.all;
use ims.conversion.all;

ENTITY INTERFACE_COMB_1 IS
PORT (
		inp  : IN  custom32_in_type;
		outp : OUT custom32_out_type
	);
END;

ARCHITECTURE RTL OF INTERFACE_COMB_1 IS

	-------------------------------------------------------------------------
	-- PRAGMA BEGIN DECLARATION
	COMPONENT Q16_8_DECISION
	port (
	    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
	    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
	END COMPONENT;

	COMPONENT Q16_8_FullXorMin
	PORT (
	    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
	    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
	    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
	END COMPONENT;

	COMPONENT START_32b
	port (
	    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
	    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
	END COMPONENT;

	COMPONENT STOP_32b
	port (
	    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
	    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
	END COMPONENT;
	-- PRAGMA END DECLARATION
	-------------------------------------------------------------------------

	SIGNAL sINPUT_1 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL sINPUT_2 : STD_LOGIC_VECTOR(31 downto 0);
	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN SIGNAL
	SIGNAL RESULT_1  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_2  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_3  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_4  : STD_LOGIC_VECTOR(31 downto 0);
	-- PRAGMA END SIGNAL
	-------------------------------------------------------------------------
	
BEGIN

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) INTERFACE_COMB_1 : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
	sINPUT_1 <= inp.op1(31 downto 0);
	sINPUT_2 <= inp.op2(31 downto 0);
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	-- PROCESS(inp.instr, inp.op1(31 downto 0), sINPUT_2, RESULT_7)
    	-- variable op  : std_logic_vector(1 downto 0);
    	-- variable op2 : std_logic_vector(2 downto 0);
    	-- variable op3 : std_logic_vector(5 downto 0);
  	-- BEGIN
      	-- op  := inp.instr(31 downto 30);
		-- op2 := inp.instr(24 downto 22);
      	-- op3 := inp.instr(24 downto 19);
		-- if( op = "10" ) THEN
			-- if( op3 = "001001" ) THEN
				-- if( inp.instr(13 downto 5) = "001000000" ) THEN
					-- printmsg("(PGDC) ===> FIXED POINT SUB A : (" & to_int_str(inp.op1 (15 downto 0),6) & ")...");
					-- printmsg("(PGDC) ===> FIXED POINT SUB B : (" & to_int_str(RESULT_7(15 downto 0),6) & ")...");
				-- END IF;
			-- END IF;
		-- END IF;
  	-- END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN INSTANCIATION
	RESOURCE_1 : Q16_8_DECISION PORT MAP (inp.op1(31 downto 0), RESULT_1);
	RESOURCE_2 : Q16_8_FullXorMin PORT MAP (inp.op1(31 downto 0), inp.op2(31 downto 0), RESULT_2);
	RESOURCE_3 : START_32b PORT MAP (inp.op1(31 downto 0), RESULT_3);
	RESOURCE_4 : STOP_32b PORT MAP (inp.op1(31 downto 0), RESULT_4);
	-- PRAGMA END INSTANCIATION
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	-- PRAGMA BEGIN RESULT SELECTION
	WITH inp.instr(13 downto 5) SELECT
		outp.result <= 
					RESULT_1 WHEN "000000001",
					RESULT_2 WHEN "000000010",
					RESULT_3 WHEN "000000100",
					RESULT_4 WHEN OTHERS;
	-- PRAGMA END RESULT SELECTION
	-------------------------------------------------------------------------

end; 
