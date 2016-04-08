library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library ims;
--use ims.coprocessor.all;

entity MMX_EQU_8b is
	port (
		INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
		INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
end;

architecture rtl of MMX_EQU_8b is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		REPORT "(IMS) MMX 8bis EQU RESSOURCE : ALLOCATION OK !";
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
	begin
		if( UNSIGNED(INPUT_1( 7 downto  0)) = UNSIGNED(INPUT_2( 7 downto  0)) ) then rTemp1 := "11111111";	else rTemp1 := "00000000";	end if;
		if( UNSIGNED(INPUT_1(15 downto  8)) = UNSIGNED(INPUT_2(15 downto  8)) ) then rTemp2 := "11111111";  else rTemp2 := "00000000";  end if;
		if( UNSIGNED(INPUT_1(23 downto 16)) = UNSIGNED(INPUT_2(23 downto 16)) ) then rTemp3 := "11111111";	else rTemp3 := "00000000";	end if;
		if( UNSIGNED(INPUT_1(31 downto 24)) = UNSIGNED(INPUT_2(31 downto 24)) ) then rTemp4 := "11111111";	else rTemp4 := "00000000";	end if;
		OUTPUT_1 <= (rTemp4 & rTemp3 & rTemp2 & rTemp1);
	end process;
	-------------------------------------------------------------------------

end; 
