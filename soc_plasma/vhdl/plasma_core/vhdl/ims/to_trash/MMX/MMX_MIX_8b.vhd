library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library ims;
--use ims.coprocessor.all;

entity MMX_MIX_8b is
	port (
		INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
		INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
end;

architecture rtl of MMX_MIX_8b is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		REPORT "(IMS) MMX 8bis MIX RESSOURCE : ALLOCATION OK !";
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
		CASE INPUT_2(7 downto 0) is
			when  "00000001" => rTemp1 := INPUT_1( 7 downto  0);
			when  "00000010" => rTemp1 := INPUT_1(15 downto  8);
			when  "00000011" => rTemp1 := INPUT_1(23 downto 16);
			when  "00000100" => rTemp1 := INPUT_1(31 downto 24);
			when others 	 => rTemp1 := "00000000";
		end case;
		CASE INPUT_2(15 downto 8) is
			when  "00000001" => rTemp2 := INPUT_1( 7 downto  0);
			when  "00000010" => rTemp2 := INPUT_1(15 downto  8);
			when  "00000011" => rTemp2 := INPUT_1(23 downto 16);
			when  "00000100" => rTemp2 := INPUT_1(31 downto 24);
			when others 	 => rTemp2 := "00000000";
		end case;
		CASE INPUT_2(23 downto 16) is
			when  "00000001" => rTemp3 := INPUT_1( 7 downto  0);
			when  "00000010" => rTemp3 := INPUT_1(15 downto  8);
			when  "00000011" => rTemp3 := INPUT_1(23 downto 16);
			when  "00000100" => rTemp3 := INPUT_1(31 downto 24);
			when others 	 => rTemp3 := "00000000";
		end case;
		CASE INPUT_2(31 downto 24) is
			when  "00000001" => rTemp4 := INPUT_1( 7 downto  0);
			when  "00000010" => rTemp4 := INPUT_1(15 downto  8);
			when  "00000011" => rTemp4 := INPUT_1(23 downto 16);
			when  "00000100" => rTemp4 := INPUT_1(31 downto 24);
			when others 	 => rTemp4 := "00000000";
		end case;
		OUTPUT_1 <= (rTemp4 & rTemp3 & rTemp2 & rTemp1);
	end process;
	-------------------------------------------------------------------------

end; 
