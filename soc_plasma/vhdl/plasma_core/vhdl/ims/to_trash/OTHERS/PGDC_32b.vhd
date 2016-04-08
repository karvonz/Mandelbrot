----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:18:09 02/17/2011 
-- Design Name: 
-- Module Name:    PGDC_32b - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.conversion.all;

entity PGDC_32b is
	PORT(
		rst		  : in  STD_LOGIC; 
		clk		  : in  STD_LOGIC; 
		start	  : in  STD_LOGIC; 
		INPUT_1	  : in  STD_LOGIC_VECTOR(31 downto 0); 
		INPUT_2	  : in  STD_LOGIC_VECTOR(31 downto 0); 
		working   : out std_logic;
		OUTPUT_1  : out STD_LOGIC_VECTOR(31 downto 0)
	);
end PGDC_32b;

architecture Behavioral of PGDC_32b is
	signal A 		   : std_logic_vector(31 downto 0);
	signal B 		   : std_logic_vector(31 downto 0);
  	signal state  	   : std_logic_vector(1  downto 0);
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		ASSERT false REPORT "(IMS) PGDC_32b : ALLOCATION OK !";
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	
	-------------------------------------------------------------------------
  	REG : process(clk, rst)
		variable min      : std_logic_vector(31 downto 0);
		variable max      : std_logic_vector(31 downto 0);
		variable res      : std_logic_vector(31 downto 0);
  		variable decision : std_logic;
  	begin 
	
		if (rst = '1') then
			state   <= "00";
		elsif clk'event and clk = '1' then 

			case state is
				
				-----------------------------------------------------------------
				-- ON ATTEND LA COMMANDE DE START
				-----------------------------------------------------------------
    			when "00" =>
					if (start = '1') then 
						A        <= INPUT_1;
						B        <= INPUT_2;
						state    <= "01";
						--REPORT "TIME START";
						--printmsg("(PGDC) ===> (000) THE START SIGNAL HAS BEEN RECEIVED !");
						--printmsg("(PGDC) ===> (000) MEMORISATION PROCESS (" & to_int_str(INPUT_1,6) & ")");
						--printmsg("(PGDC) ===> (000) MEMORISATION PROCESS (" & to_int_str(INPUT_2,6) & ")");
					else
						A <= A;
						B <= A;
						state <= "00";
					end if;

				-----------------------------------------------------------------
				-- ON COMMENCE LE CALCUL
				-----------------------------------------------------------------
    			when "01" =>
					-- ON CHOISI LES OPERANDES POUR LE CALCUL A VENIR
					if( SIGNED(A) > SIGNED(B) ) then
						decision := '1';
						min := B;
						max := A;
					else
						decision := '0';
						min := A;
						max := B;
					end if;

					-- ON REALISE LA SOUSTRACTION DU GRAND MOINS LE PETIT
					res := STD_LOGIC_VECTOR(SIGNED(max) - SIGNED(min));

					-- ON MEMORISE LE RESULTAT DU CALCUL
					if( decision = '1' ) then
						A <= res;
						B <= B;
					else
						A <= A;
						B <= res;
					end if;
					state <= "10";

				-----------------------------------------------------------------
				-- ON TEST LES DONNEES (FIN D'ITERATION)
				-----------------------------------------------------------------
    			when "10" =>
					if(SIGNED(A) = SIGNED(B)) then
						state   <= "00";
					elsif( SIGNED(A) = TO_SIGNED(0,32) ) then
						state   <= "00";
					elsif( SIGNED(B) = TO_SIGNED(0,32) ) then
						A        <= STD_LOGIC_VECTOR(TO_SIGNED(0,32));
						state    <= "00";
					else
						state <= "01";
					end if;

    			when others =>
					state <= "00";
    		end case;
    	end if;		-- if clock
  	end process;
	-------------------------------------------------------------------------

	------------------------------------------------------------------------------------------------------
	-- ON PLACE LA SORTIE WORKING A '1' DES QUE LE CALCUL COMMENCE (RECEPTION DU SIGNAL START) ET TANT QUE
	-- LE CALCUL EST EN COURS (STATE /= WAITING)
	working <= '1' WHEN state /= "000"	ELSE start;
	OUTPUT_1 <= A;
	------------------------------------------------------------------------------------------------------

end Behavioral;

