library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity  Q8_4_ADD is
port (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
end;

architecture rtl of Q8_4_ADD is
begin

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1, INPUT_2)
		VARIABLE OP1 : SIGNED(8 downto 0);
		VARIABLE OP2 : SIGNED(8 downto 0);
		VARIABLE OP3 : SIGNED(8 downto 0);
  	begin
		OP1 := SIGNED( INPUT_1(7) & INPUT_1(7 downto 0) );
		OP2 := SIGNED( INPUT_2(7) & INPUT_2(7 downto 0) );
		OP3 := OP1 + OP2;
		
		if( OP3 > TO_SIGNED(127, 8) ) THEN 
			OUTPUT_1 <= STD_LOGIC_VECTOR(TO_SIGNED( 127, 32)); 
		elsif( OP3 < TO_SIGNED(-128, 8) ) THEN 
			OUTPUT_1 <= STD_LOGIC_VECTOR(TO_SIGNED(-128, 32)); 
		else
			OUTPUT_1 <= STD_LOGIC_VECTOR( RESIZE( OP3(7 downto 0), 32) ); 
		end if;
	END PROCESS;
	-------------------------------------------------------------------------

end; 
