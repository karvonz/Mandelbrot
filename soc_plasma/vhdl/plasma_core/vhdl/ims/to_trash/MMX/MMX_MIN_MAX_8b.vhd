library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library ims;
--use ims.coprocessor.all;

entity MMX_MIN_MAX_8b is
	port (
		INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
		INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
		FONCTION : in  STD_LOGIC_VECTOR( 1 downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
end;

architecture rtl of MMX_MIN_MAX_8b is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		REPORT "(IMS) MMX 8bis MIN RESSOURCE : ALLOCATION OK !";
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	computation : process (INPUT_1, INPUT_2)
		variable rTemp1  : STD_LOGIC_VECTOR(7 downto 0);
		variable rTemp2  : STD_LOGIC_VECTOR(7 downto 0);
		variable rTemp3  : STD_LOGIC_VECTOR(7 downto 0);
		variable rTemp4  : STD_LOGIC_VECTOR(7 downto 0);

		variable bTemp1  : STD_LOGIC;
		variable bTemp2  : STD_LOGIC;
		variable bTemp3  : STD_LOGIC;
		variable bTemp4  : STD_LOGIC;
	begin
		IF( UNSIGNED(INPUT_1( 7 downto  0)) < UNSIGNED(INPUT_2( 7 downto  0)) ) THEN bTemp1 := 1; ELSE bTemp1 := 0; END IF;
		IF( UNSIGNED(INPUT_1(15 downto  8)) < UNSIGNED(INPUT_2(15 downto  8)) ) THEN bTemp2 := 1; ELSE bTemp2 := 0; END IF;
		IF( UNSIGNED(INPUT_1(23 downto 16)) < UNSIGNED(INPUT_2(23 downto 16)) ) THEN bTemp3 := 1; ELSE bTemp3 := 0; END IF;
		IF( UNSIGNED(INPUT_1(31 downto 24)) < UNSIGNED(INPUT_2(31 downto 24)) ) THEN bTemp4 := 1; ELSE bTemp4 := 0; END IF;

		bTemp1 := bTemp1 XOR FONCTION(0);
		bTemp2 := bTemp2 XOR FONCTION(0);
		bTemp3 := bTemp3 XOR FONCTION(0);
		bTemp4 := bTemp4 XOR FONCTION(0);

		CASE bTemp1 IS
			WHEN '0'    => rTemp1 := INPUT_1(7 downto  0);
			WHEN '1'    => rTemp1 := INPUT_2(7 downto  0);
			WHEN OTHERS => null;
		END CASE;
		
		CASE bTemp2 IS
			WHEN '0'    => rTemp2 := INPUT_1(15 downto 8);
			WHEN '1'    => rTemp2 := INPUT_2(15 downto 8);
			WHEN OTHERS => null;
		END CASE;
		
		CASE bTemp3 IS
			WHEN '0'    => rTemp3 := INPUT_1(23 downto 16);
			WHEN '1'    => rTemp3 := INPUT_2(23 downto 16);
			WHEN OTHERS => null;
		END CASE;
		
		CASE bTemp4 IS
			WHEN '0'    => rTemp4 := INPUT_1(31 downto 24);
			WHEN '1'    => rTemp4 := INPUT_2(31 downto 24);
			WHEN OTHERS => null;
		END CASE;
		
		OUTPUT_1 <= (rTemp4 & rTemp3 & rTemp2 & rTemp1);
	end process;
	-------------------------------------------------------------------------

end; 
