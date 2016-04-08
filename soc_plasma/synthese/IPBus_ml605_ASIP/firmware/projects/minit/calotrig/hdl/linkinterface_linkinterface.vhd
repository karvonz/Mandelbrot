
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package linkinterface is

	CONSTANT Number_Of_Bits : INTEGER := 32;

	TYPE link_type IS RECORD
		DATA : STD_LOGIC_VECTOR( Number_Of_Bits-1 DOWNTO 0 );
		-- DATA_VALID : STD_LOGIC;
	END RECORD;

	-- Define all_links to be an unconstrained array of link_type
	-- A signal	of type all_links is then declared like		an_all_links_signal	:				all_links( size-1 downto 0 );
	-- A port	of type all_links is then declared like	 	an_all_links_port	:	[in|out]	all_links( size-1 downto 0 );
	TYPE all_links IS ARRAY( natural range <> ) of link_type;

end linkinterface;


