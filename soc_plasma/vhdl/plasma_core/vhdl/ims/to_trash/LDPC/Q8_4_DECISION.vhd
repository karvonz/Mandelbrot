library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Q8_4_DECISION is
port (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
end;

architecture rtl of Q8_4_DECISION is
begin

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1)
		VARIABLE temp  : SIGNED(7 downto 0);
  	begin
		temp := SIGNED( INPUT_1(7 downto 0) );
		IF temp < TO_SIGNED(0, 8) THEN
			OUTPUT_1 <= STD_LOGIC_VECTOR( TO_UNSIGNED(0, 32) );
		ELSE
			OUTPUT_1 <= STD_LOGIC_VECTOR( TO_UNSIGNED(1, 32) );
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------

END; 