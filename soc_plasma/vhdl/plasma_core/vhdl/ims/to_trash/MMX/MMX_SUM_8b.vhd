library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library ims;
--use ims.coprocessor.all;

entity MMX_SUM_8b is
	port (
		INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
		INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
end;

architecture rtl of MMX_SUM_8b is
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
		variable opCode  : STD_LOGIC_VECTOR(8 downto 0);
		variable rTemp1  : STD_LOGIC_VECTOR(7 downto 0);
		variable rTemp2  : STD_LOGIC_VECTOR(7 downto 0);
		variable rTemp3  : STD_LOGIC_VECTOR(7 downto 0);
		variable rTemp4  : STD_LOGIC_VECTOR(7 downto 0);

		variable rTempS1 : UNSIGNED( 8 downto 0);
		variable rTempS2 : UNSIGNED( 8 downto 0);
		variable rTempS3 : UNSIGNED( 8 downto 0);
		variable rTempS4 : UNSIGNED( 8 downto 0);
		variable rTempS5 : UNSIGNED( 9 downto 0);
		variable rTempS6 : UNSIGNED( 9 downto 0);
		variable rTempS7 : UNSIGNED(10 downto 0);
	begin
		rTempS1  := UNSIGNED('0' & INPUT_1( 7 downto   0)) + UNSIGNED('0' & INPUT_2( 7 downto  0));
		rTempS2  := UNSIGNED('0' & INPUT_1(15 downto   8)) + UNSIGNED('0' & INPUT_2(15 downto  8));
		rTempS3  := UNSIGNED('0' & INPUT_1(23 downto  16)) + UNSIGNED('0' & INPUT_2(23 downto  16));
		rTempS4  := UNSIGNED('0' & INPUT_1(31 downto  24)) + UNSIGNED('0' & INPUT_2(31 downto  24));
		rTempS5  := UNSIGNED('0' & rTempS1) + UNSIGNED('0' & rTempS2);
		rTempS6  := UNSIGNED('0' & rTempS3) + UNSIGNED('0' & rTempS4);
		rTempS7  := UNSIGNED('0' & rTempS5) + UNSIGNED('0' & rTempS6);
		OUTPUT_1 <= "000000000000000000000" & STD_LOGIC_VECTOR(rTempS7);
	end process;
	-------------------------------------------------------------------------

end; 
