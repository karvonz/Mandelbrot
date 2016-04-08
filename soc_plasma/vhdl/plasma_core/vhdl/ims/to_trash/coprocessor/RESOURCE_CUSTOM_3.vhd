library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ims;
use ims.coprocessor.all;

entity RESOURCE_CUSTOM_3 is
port (
		inp  : in  custom32_in_type;
		outp : out custom32_out_type
	);
end;

architecture rtl of RESOURCE_CUSTOM_3 is
	SIGNAL instr  : STD_LOGIC_VECTOR(8 downto 0);

	-------------------------------------------------------------------------
	-- PRAGMA BEGIN DECLARATION
	COMPONENT MMX_ADD_8b
		PORT (
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;

	COMPONENT MMX_SUB_8b
		PORT (
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;

	COMPONENT MMX_MUL_8b
		PORT (
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;

	COMPONENT MMX_MAX_8b
		PORT (
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT MMX_MIN_8b
		PORT (
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;

	COMPONENT MMX_SUM_8b
		PORT (
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;

	COMPONENT MMX_MIX_8b
		PORT (
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;

	COMPONENT MMX_EQU_8b
		PORT (
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;

	COMPONENT XOR_MIN_8b
		PORT (
			INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
			INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
			OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;
	-- PRAGMA END DECLARATION
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN SIGNAL
	SIGNAL RESULT_1  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_2  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_3  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_4  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_5  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_6  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_7  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_8  : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL RESULT_9  : STD_LOGIC_VECTOR(31 downto 0);
	-- PRAGMA END SIGNAL
	-------------------------------------------------------------------------
	
begin

	-- ON RECUPERE LE CODE DE L'OPERATION A REALISER
	instr <= inp.instr(13 downto 5);

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		printmsg("(IMS) RESOURCE_CUSTOM_3 : ALLOCATION OK !");
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN INSTANCIATION
	RESOURCE_1 : MMX_ADD_8b PORT MAP (inp.op1(31 downto 0), inp.op2(31 downto 0), RESULT_1);
	RESOURCE_2 : MMX_SUB_8b PORT MAP (inp.op1(31 downto 0), inp.op2(31 downto 0), RESULT_2);
	RESOURCE_3 : MMX_MUL_8b PORT MAP (inp.op1(31 downto 0), inp.op2(31 downto 0), RESULT_3);
	RESOURCE_4 : MMX_MAX_8b PORT MAP (inp.op1(31 downto 0), inp.op2(31 downto 0), RESULT_4);
	RESOURCE_5 : MMX_MIN_8b PORT MAP (inp.op1(31 downto 0), inp.op2(31 downto 0), RESULT_5);
	RESOURCE_6 : MMX_SUM_8b PORT MAP (inp.op1(31 downto 0), inp.op2(31 downto 0), RESULT_6);
	RESOURCE_7 : MMX_MIX_8b PORT MAP (inp.op1(31 downto 0), inp.op2(31 downto 0), RESULT_7);
	RESOURCE_8 : MMX_EQU_8b PORT MAP (inp.op1(31 downto 0), inp.op2(31 downto 0), RESULT_8);
	RESOURCE_9 : XOR_MIN_8b PORT MAP (inp.op1(31 downto 0), inp.op2(31 downto 0), RESULT_9);
	-- PRAGMA END INSTANCIATION
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
	-- PRAGMA BEGIN RESULT SELECTION
	WITH inp.instr(13 downto 5) SELECT
		outp.result <= 	RESULT_1 when "000000001",
						RESULT_2 when "000000010",
						RESULT_3 when "000000100",
						RESULT_4 when "000001000",
						RESULT_5 when "000010000",
						RESULT_6 when "000100000",
						RESULT_7 when "001000000",
						RESULT_8 when "010000000",
						RESULT_9 when others;
	-- PRAGMA END RESULT SELECTION
	-------------------------------------------------------------------------

end; 
