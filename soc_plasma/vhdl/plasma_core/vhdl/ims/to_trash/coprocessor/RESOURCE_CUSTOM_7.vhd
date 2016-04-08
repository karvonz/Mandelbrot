library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library grlib;
--use grlib.stdlib.all;

--library gaisler;
--use gaisler.arith.all;

library ims;
use ims.coprocessor.all;



entity RESOURCE_CUSTOM_7 is
port (
    inp  : in  custom32_in_type;
    outp : out custom32_out_type
);
end;

architecture rtl of RESOURCE_CUSTOM_7 is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		printmsg("(IMS) RESOURCE_CUSTOM_7 : ALLOCATION OK !");
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	computation : process (inp.op1, inp.op2)
	begin
		if( SIGNED(inp.op1) < SIGNED(inp.op2) ) then
			outp.result <= inp.op1(31 downto 0);
		else
			outp.result <= inp.op2(31 downto 0);
		end if;
	end process;
	-------------------------------------------------------------------------

end;

