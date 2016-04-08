library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ims;
use ims.coprocessor.all;

entity RESOURCE_CUSTOM_5 is
	port (
		inp  : in  custom32_in_type;
		outp : out custom32_out_type
	);
end;

architecture rtl of RESOURCE_CUSTOM_5 is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		printmsg("(IMS) RESOURCE_CUSTOM_5 : ALLOCATION OK !");
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	computation : process (inp)
	begin
	end process;

end;
