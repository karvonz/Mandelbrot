library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ims;
use ims.coprocessor.all;

entity INTERFACE_ASYN_1 is
	port (
		rst        : in  std_ulogic;
		clk        : in  std_ulogic;
		holdn      : in  std_ulogic;
		inp  	   : in  async32_in_type;
		outp 	   : out async32_out_type
	);
end;

architecture rtl of INTERFACE_ASYN_1 is

	-------------------------------------------------------------------------
	-- PRAGMA BEGIN DECLARATION
	-- PRAGMA END DECLARATION
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN SIGNAL
	-- PRAGMA END SIGNAL
	-------------------------------------------------------------------------

	signal A 		: std_logic_vector(31 downto 0);
	signal B 		: std_logic_vector(31 downto 0);
  	signal wBuffer  : std_logic_vector(1  downto 0);
  	signal rBuffer  : std_logic_vector(1  downto 0);
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		printmsg("(IMS) INTERFACE_ASYN_1 : ALLOCATION OK !");
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN INSTANCIATION
	-- PRAGMA END INSTANCIATION
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	-- PRAGMA BEGIN RESULT SELECTION
	outp.result <= inp.op1(31 downto 0) AND inp.op2(31 downto 0);

	-- PRAGMA END RESULT SELECTION
	-------------------------------------------------------------------------

end;

