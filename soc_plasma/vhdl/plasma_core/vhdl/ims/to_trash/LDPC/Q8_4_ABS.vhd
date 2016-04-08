library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Q8_4_ABS is
port (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
end;

architecture rtl of Q8_4_ABS is
begin

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1)
		VARIABLE temp  : SIGNED(7 downto 0);
  	begin
		temp := abs( SIGNED( INPUT_1(7 downto 0) ) );
		OUTPUT_1 <= STD_LOGIC_VECTOR( RESIZE(temp, 32) );
	END PROCESS;
	-------------------------------------------------------------------------

end; 
