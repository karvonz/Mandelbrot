library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ims;
use ims.coprocessor.all;

entity CPL_ADD_16b is
	port (
		rst		  : in  STD_LOGIC; 
		clk		  : in  STD_LOGIC; 
		start	  : in  STD_LOGIC; 
		flush     : in  std_logic;
		holdn     : in  std_ulogic;
		INPUT_1	  : in  STD_LOGIC_VECTOR(31 downto 0); 
		INPUT_2	  : in  STD_LOGIC_VECTOR(31 downto 0); 
		ready     : out std_logic;
		nready    : out std_logic;
		icc       : out std_logic_vector(3  downto 0);
		OUTPUT_1  : out STD_LOGIC_VECTOR(31 downto 0)
	);
end;

architecture rtl of CPL_ADD_16b is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		printmsg("(IMS) COMPLEX 16bis ADD RESSOURCE : ALLOCATION OK !");
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	computation : process (INPUT_1, INPUT_2)
		variable rTemp1  : STD_LOGIC_VECTOR(15 downto 0);
		variable rTemp2  : STD_LOGIC_VECTOR(15 downto 0);
	begin
		rTemp1 := STD_LOGIC_VECTOR( SIGNED(INPUT_1(15 downto  0)) + SIGNED(INPUT_2(15 downto  0)) );
		rTemp2 := STD_LOGIC_VECTOR( SIGNED(INPUT_1(31 downto 16)) + SIGNED(INPUT_2(31 downto 16)) );
		--if( rTemp1(16) = '1' ) then
		--	rTemp1(7 downto 0) := "1111111111111111";
		--end if;
		--if( rTemp2(16) = '1' ) then
		--	rTemp2(7 downto 0) := "1111111111111111";
		--end if;
		OUTPUT_1 <= (rTemp2 & rTemp1);
	end process;
	-------------------------------------------------------------------------

end; 
