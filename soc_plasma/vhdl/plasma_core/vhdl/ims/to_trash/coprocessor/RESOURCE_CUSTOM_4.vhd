library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library grlib;
--use grlib.stdlib.all;

--library gaisler;
--use gaisler.arith.all;

library ims;
use ims.coprocessor.all;
use ims.conversion.all;

entity RESOURCE_CUSTOM_4 is
port (
    inp  : in  custom32_in_type;
    outp : out custom32_out_type
);
end;

architecture rtl of RESOURCE_CUSTOM_4 is
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		printmsg("(IMS) RESOURCE_CUSTOM_4 : ALLOCATION OK !");
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	computation : process (inp.op1, inp.op2)
		Variable A : SIGNED(31 downto 0);
		Variable B : SIGNED(31 downto 0);
		Variable C : SIGNED(31 downto 0);
	begin
		A := SIGNED( inp.op1(31 downto 0) );
		B := SIGNED( inp.op2(31 downto 0) );
		C := A + B + 1;
	   outp.result <= STD_LOGIC_VECTOR( C(31) & C(31 downto 1) );
	end process;
	-------------------------------------------------------------------------

end;

