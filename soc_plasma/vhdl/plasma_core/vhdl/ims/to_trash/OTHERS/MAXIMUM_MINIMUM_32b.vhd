----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:19:12 02/17/2011 
-- Design Name: 
-- Module Name:    MINIMUM_MAXIMUM_32b - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MINIMUM_MAXIMUM_32b is
port (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
    FONCTION : in  STD_LOGIC_VECTOR( 1 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
end MINIMUM_MAXIMUM_32b;

architecture rtl of MINIMUM_MAXIMUM_32b is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	wait for 1 ns;
		REPORT "(IMS) MINIMUM RESOURCE : ALLOCATION OK !";
    	wait;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1, INPUT_2, FONCTION)
		variable decision : std_logic;
  	begin
		if( SIGNED(INPUT_1) < SIGNED(INPUT_2) ) then
			decision := '1';
		else
			decision := '0';
		end if;
		
		-- SI LE BIT DE POIDS FAIBLE = 1 CE SIGNIFIE QUE L'ON
		-- VEUT CALCULER LE MINIMUM DES 2 NOMBRES
		decision := decision xor FONCTION(1);
		
		if( decision = '1' ) then
			OUTPUT_1 <= INPUT_1;
		else
			OUTPUT_1 <= INPUT_2;
		end if;
	end process;
	-------------------------------------------------------------------------

end; 
