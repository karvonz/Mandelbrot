library	IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all; 

--library ims;
--use ims.coprocessor.all;
--use ims.conversion.all;

entity DIVIDER_32b is 
	port(
		rst		 : in  STD_LOGIC; 
		clk		 : in  STD_LOGIC; 
		start	 : in  STD_LOGIC; 
		flush    : in  std_logic;
		holdn    : in  std_ulogic;
		INPUT_1	 : in  STD_LOGIC_VECTOR(31 downto 0); 
		INPUT_2	 : in  STD_LOGIC_VECTOR(31 downto 0); 
		ready    : out std_logic;
		nready   : out std_logic;
		icc      : out std_logic_vector(3 downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	); 
end DIVIDER_32b; 

-- ready = 0 indique que le circuit est pret a calculer
--			  1 signifie que le circuit est occupe

-- nready = 1 indique que le calcul est termine (1 cycle suffit)

architecture behav of DIVIDER_32b is 
	signal buf	: STD_LOGIC_VECTOR(63 downto 0); 
	signal dbuf	: STD_LOGIC_VECTOR(31 downto 0); 
	signal sm	: INTEGER range 0 to 32; 

	alias buf1 is buf(63 downto 32); 
	alias buf2 is buf(31 downto 0);
	
	signal start_delay : std_logic;
	
begin 

	-------------------------------------------------------------------------
	-- synthesis translate_off 
--  	process
--  	begin
--    	wait for 1 ns;
--		ASSERT false REPORT "(IMS) DIVIDER_32b : ALLOCATION OK !";
--    	wait;
--  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	
	-------------------------------------------------------------------------
	reg : process(rst, clk) 
  		variable sready, snready : std_logic;
	begin 
	
		sready  := '0';
		snready := '0';
	
		-- Si l'on recoit une demande de reset alors on reinitialise
		if rst = '0' then 
			OUTPUT_1 <= (others => '0'); 
			sm       <= 0; 
			ready    <= '0'; 
			ready    <= sready;
			nready   <= snready;
			start_delay <= '0';
			
		-- En cas de front montant de l'horloge alors on calcule
		elsif rising_edge(clk) then 

		
			-- Si Flush alors on reset le composant
    		if (flush = '1') then
				sm <= 0;
				start_delay <= '0';

			-- Si le signal de maintient est actif alors on gel l'execution
			elsif (holdn = '0') then
				sm <= sm;
				start_delay <= start_delay;

			-- Sinon on déroule l'execution de la division
			else
				start_delay <= start;
			
				case sm is 
					-- Etat d'attente du signal start
					when 0 => 
						--buf1     <= (others => '0'); 
						--buf2     <= INPUT_1; 
						--dbuf     <= INPUT_2; 
						OUTPUT_1 <= buf2; 
						if start_delay = '1' then 
							buf1     <= (others => '0'); 
							buf2     <= INPUT_1; 
							dbuf     <= INPUT_2; 
							sm       <= sm + 1;	-- le calcul est en cours
--							printmsg("(mDIV) ===> (000) THE START SIGNAL HAS BEEN RECEIVED !");
--							printmsg("(mDIV) ===> (OP1) MEMORISATION PROCESS (" & to_int_str(INPUT_1,6) & ")");
--							printmsg("(mDIV) ===> (OP2) MEMORISATION PROCESS (" & to_int_str(INPUT_2,6) & ")");
						else
							--printmsg("(mDIV) ===> (000) WAITING FOR THE START SIGNAL...");
							sm    <= sm;
						end if;

					-- when 1 => 
						-- printmsg("(mDIV) ===> (001) READING THE INPUT DATA");
						-- buf1     <= (others => '0'); 
						-- buf2     <= INPUT_1; 
						-- dbuf     <= INPUT_2; 
						-- sm       <= sm + 1;	-- le calcul est en cours
						-- if ( (INPUT_1(30) /= '-') AND (INPUT_1(30) /= 'X') AND (INPUT_1(30) /= 'U')) then
							-- printmsg("(mDIV) ===> (OP1) MEMORISATION PROCESS (" & to_int_str(INPUT_1,6) & ")");
						-- end if;
						-- if ( (INPUT_2(30) /= '-') AND (INPUT_2(30) /= 'X') AND (INPUT_2(30) /= 'U')) then
							-- printmsg("(mDIV) ===> (OP2) MEMORISATION PROCESS (" & to_int_str(INPUT_2,6) & ")");
						-- end if;

					-- when 34 => 
						-- OUTPUT_1 <= buf2; 
						-- snready  := '1';  -- le resultat du calcul est disponible
						-- sm       <= 0; 
						-- printmsg("(mDIV) ===> (010) THE COMPUTATION IS FINISHED :-)");
						
					-- Tous les autres états sont utiles au calcul
					when others => 
						sready := '1';	-- le calcul est en cours
						sm     <= 0; 
					
						if buf(62 downto 31) >= dbuf then 
							buf1 <= '0' & (buf(61 downto 31) - dbuf(30 downto 0)); 
							buf2 <= buf2(30 downto 0) & '1'; 
						else 
							buf <= buf(62 downto 0) & '0'; 
						end if; 

						if sm /= 32 then 
							sm      <= sm + 1; 
							snready := '0';	 -- le resultat n'est pas disponible
						else 
							--OUTPUT_1 <= buf2(30 downto 0) & '1';  
							snready  := '1';  -- le resultat du calcul est disponible
							sm       <= 0;
--							printmsg("(mDIV) ===> (OP1) MEMORISATION PROCESS (" & to_int_str(buf2(30 downto 0) & '1',6) & ")");
						end if; 
				end case; 

				-- On transmet les signaux au systeme
				ready  <= sready;
				nready <= snready;
					
				end if; -- Fin du process de calcul
			end if; 
	end process; 

end behav;
