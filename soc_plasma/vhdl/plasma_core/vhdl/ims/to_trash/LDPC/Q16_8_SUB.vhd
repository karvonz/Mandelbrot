library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- synthesis translate_off 
library ims;
use ims.coprocessor.all;
-- synthesis translate_on 
-------------------------------------------------------------------------

entity Q16_8_SUB is
port (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
end;

architecture rtl of Q16_8_SUB is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	PROCESS
  	BEGIN
    	WAIT FOR 1 ns;
		printmsg("(IMS) Q16_8_SUB : ALLOCATION OK !");
    	WAIT;
  	END PROCESS;
	-- synthesis translate_on 
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
  	PROCESS (INPUT_1, INPUT_2)
		VARIABLE OP1 : SIGNED(16 downto 0);
		VARIABLE OP2 : SIGNED(16 downto 0);
		VARIABLE OP3 : SIGNED(16 downto 0);
  	begin
		OP1 := SIGNED( INPUT_1(15) & INPUT_1(15 downto 0) );
		OP2 := SIGNED( INPUT_2(15) & INPUT_2(15 downto 0) );
		OP3 := OP1 - OP2;
		
		if( OP3 > TO_SIGNED(32767, 17) ) THEN 
			OUTPUT_1 <= "0000000000000000" & STD_LOGIC_VECTOR(TO_SIGNED( 32767, 16)); 
		elsif( OP3 < TO_SIGNED(-32768, 17) ) THEN 
			OUTPUT_1 <= "0000000000000000" & STD_LOGIC_VECTOR(TO_SIGNED(-32768, 16)); 
		else
			OUTPUT_1 <= "0000000000000000" & STD_LOGIC_VECTOR( OP3(15 downto 0) ); 
		end if;
	END PROCESS;
	-------------------------------------------------------------------------

end; 
