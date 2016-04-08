library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library grlib;
--use grlib.stdlib.all;

--library gaisler;
--use gaisler.arith.all;

library ims;
use ims.coprocessor.all;



--type sequential32_in_type is record
--  op1              : std_logic_vector(32 downto 0); -- operand 1
--  op2              : std_logic_vector(32 downto 0); -- operand 2
--  flush            : std_logic;
--  signed           : std_logic;
--  start            : std_logic;
--end record;

--type sequential32_out_type is record
--  ready           : std_logic;
--  nready          : std_logic;
--  icc             : std_logic_vector(3 downto 0);
--  result          : std_logic_vector(31 downto 0);
--end record;

entity RESOURCE_CUSTOM_B is
port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    holdn   : in  std_ulogic;
    inp     : in  sequential32_in_type;
    outp    : out sequential32_out_type
);
end;

architecture rtl of RESOURCE_CUSTOM_B is
	signal A 		: std_logic_vector(31 downto 0);
	signal B 		: std_logic_vector(31 downto 0);
	signal C 		: std_logic_vector(31 downto 0);
	signal t        : std_logic;
begin

	A <= inp.op1(31 downto 0);
	B <= inp.op2(31 downto 0);

    pipeline : process(clk) begin
      	if rising_edge(clk) then
         	if (holdn = '1') then
            	C 			<= A and B;
				outp.nready <= inp.start; 
			end if;
       	end if;
    end process;

	outp.ready  <= '0';
	outp.result <= C;
	outp.icc    <= "0000";

end; 

