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

entity RESOURCE_CUSTOM_C is
port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    holdn   : in  std_ulogic;
    inp     : in  sequential32_in_type;
    outp    : out sequential32_out_type
);
end;

architecture rtl of RESOURCE_CUSTOM_C is
	signal A 		: std_logic_vector(31 downto 0);
	signal B 		: std_logic_vector(31 downto 0);
  	signal state  	: std_logic_vector(2  downto 0);
begin

  	reg : process(clk)
  		variable vready, vnready : std_logic;
  	begin 

    	vready  := '0';
		vnready := '0';

    	if rising_edge(clk) then 
      	if (rst = '0') then
				state <= "000";
    		elsif (inp.flush = '1') then
				state <= "000";
			elsif (holdn = '1') then
				state <= state;
			else
		    	case state is

					-- ON ATTEND LA COMMANDE DE START
    				when "000" =>
						if (inp.start = '1') then 
							--v.x(64) := divi.y(32);
							A <= inp.op1(31 downto 0);
							B <= inp.op2(31 downto 0);
							state <= "010";
						else
							state <= "000";
							A <= A;
							B <= B;
						end if;

					-- ON COMMENCE LE CALCUL
    				when "001" =>
						if( SIGNED(A) > SIGNED(B) ) then
							A <= STD_LOGIC_VECTOR(SIGNED(A) - SIGNED(B));
						else
							B <= STD_LOGIC_VECTOR(SIGNED(B) - SIGNED(A));
						end if;
						state <= "010";

					-- ON TEST LES DONNEES (FIN D'ITERATION)
    				when "010" =>
						if(SIGNED(A) = SIGNED(B)) then
							state   <= "011";
							vnready := '1';
						else
							state <= "001";
						end if;

    				when others =>
						-- ON INDIQUE QUE LE RESULTAT EST PRET
      				vready := '1';

						-- ON RETOURNE DANS L'ETAT INTIAL
      				state <= "000";
    			end case;

    			outp.ready  <= vready;
				outp.nready <= vnready;
			end if; 	-- if reset
    	end if;		-- if clock
  	end process;

   outp.result <= A;
   outp.icc    <= "0000";

end; 

