library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

entity COMB_RLE_CONCAT is 
	port(
		INPUT_1	 : in  STD_LOGIC_VECTOR(31 downto 0); 
		INPUT_2	 : in  STD_LOGIC_VECTOR(31 downto 0); 
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	); 
end COMB_RLE_CONCAT; 

architecture rtl of COMB_RLE_CONCAT is
begin

	process(INPUT_1, INPUT_2)
	   VARIABLE iValue : UNSIGNED(7 downto 0);
	   VARIABLE iCount : UNSIGNED(7 downto 0);
	begin
		iValue := SIGNED  (INPUT_1( 11 downto  0));
		iCount := UNSIGNED(INPUT_1(  3 downto  0));
		iValue := iValue - TO_SIGNED(2048, 12);
		OUTPUT_1 <= "0000000000000000" & STD_LOGIC_VECTOR( iCount ) & STD_LOGIC_VECTOR( iValue );
	end process;
 
end rtl;
