library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library ims;
--use ims.coprocessor.all;

entity MMX_SUB_8b is
	port (
		INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
		INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
end;

architecture rtl of MMX_SUB_8b is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		REPORT "(IMS) MMX 8bis ADD RESSOURCE : ALLOCATION OK !";
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	computation : process (INPUT_1, INPUT_2)
		variable rTemp1  : STD_LOGIC_VECTOR(8 downto 0);
		variable rTemp2  : STD_LOGIC_VECTOR(8 downto 0);
		variable rTemp3  : STD_LOGIC_VECTOR(8 downto 0);
		variable rTemp4  : STD_LOGIC_VECTOR(8 downto 0);
	begin
		rTemp1 := STD_LOGIC_VECTOR( SIGNED('0' & INPUT_1( 7 downto  0)) - SIGNED('0' & INPUT_2( 7 downto  0)) );
		rTemp2 := STD_LOGIC_VECTOR( SIGNED('0' & INPUT_1(15 downto  8)) - SIGNED('0' & INPUT_2(15 downto  8)) );
		rTemp3 := STD_LOGIC_VECTOR( SIGNED('0' & INPUT_1(23 downto 16)) - SIGNED('0' & INPUT_2(23 downto 16)) );
		rTemp4 := STD_LOGIC_VECTOR( SIGNED('0' & INPUT_1(31 downto 24)) - SIGNED('0' & INPUT_2(31 downto 24)) );
		if( rTemp1(8) = '1' ) then rTemp1(7 downto 0) := "00000000"; end if;
		if( rTemp2(8) = '1' ) then rTemp2(7 downto 0) := "00000000"; end if;
		if( rTemp3(8) = '1' ) then rTemp3(7 downto 0) := "00000000"; end if;
		if( rTemp4(8) = '1' ) then rTemp4(7 downto 0) := "00000000"; end if;
		OUTPUT_1 <= (rTemp4(7 downto 0) & rTemp3(7 downto 0) & rTemp2(7 downto 0) & rTemp1(7 downto 0));
	end process;
	-------------------------------------------------------------------------

end; 
