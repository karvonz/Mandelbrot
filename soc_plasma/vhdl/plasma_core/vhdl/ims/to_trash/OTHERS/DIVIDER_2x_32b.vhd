library	IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all; 

--library ims;
--use ims.coprocessor.all;
--use ims.conversion.all;

entity DIVIDER_2x_32b is 
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
		icc      : out std_logic_vector(3  downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
END; 

architecture behav of DIVIDER_2x_32b is 
	constant SIZE : INTEGER := 32;
	signal buf	  : STD_LOGIC_VECTOR((2 * SIZE - 1) downto 0); 
	signal dbuf	  : STD_LOGIC_VECTOR((SIZE - 1) downto 0); 
	signal sm	  : INTEGER range 0 to SIZE; 

	alias buf1 is buf((2 * SIZE - 1) downto SIZE); 
	alias buf2 is buf((SIZE - 1) downto 0); 
	
BEGIN 

	process(rst, clk) 
  		variable sready, snready : std_logic;
		variable tbuf	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable xx1   : std_logic;
		variable xx2   : std_logic;
		variable yy    : STD_LOGIC_VECTOR((2 * SIZE - 1) downto 0);
	begin

		sready  := '0';
		snready := '0';
	
		-- Si l'on recoit une demande de reset alors on reinitialise
		if rst = '0' then 
			OUTPUT_1    <= (others => '0'); 
			sm          <=  0; 
			ready       <= sready;
			nready      <= snready;
			
		-- En cas de front montant de l'horloge alors on calcule
		elsif rising_edge(clk) then 

			-- Si Flush alors on reset le composant
    		if (flush = '1') then
				sm <= 0;

			-- Si le signal de maintient est actif alors on gel l'execution
			elsif (holdn = '0') AND (sm /= 0) then
				sm <= sm;

			-- Sinon on déroule l'execution de la division
			else
			
				case sm is 

					-- Etat d'attente du signal start
					when 0 => 
						OUTPUT_1 <= buf2; 
						if start = '1' then 
							buf1     <= (others => '0'); 
							--printmsg("(DIVx2) ===> (001) STARTING THE COMPUTATION...)");
							--buf2     <= INPUT_1;
							--dbuf     <= INPUT_2;
							sm       <= sm + 1;	-- le calcul est en cours
						else
							sm       <= sm;
						end if;

					when 1 => 
						--printmsg("(DIVx2) ===> (001) MEMORISATION PROCESS (" & to_int_str(INPUT_1,6) & ")");
						--printmsg("(DIVx2) ===> (001) MEMORISATION PROCESS (" & to_int_str(INPUT_2,6) & ")");
						buf2     <= INPUT_1;
						dbuf     <= INPUT_2;
						sm       <= sm + 1;	-- le calcul est en cours
						
					when others => 
						sready := '1';	-- le calcul est en cours
						sm     <= 0; 
				
						-- ON TRAITE LE PREMIER BIT DE L'ITERATION
						if buf((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
							tbuf((2 * SIZE - 1) downto SIZE) := '0' & (buf((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
							tbuf((SIZE - 1)     downto    0) := buf2((SIZE - 2) downto 0) & '1'; -- ON POUSSE LE RESULTAT
						else 
							tbuf := buf((2 * SIZE - 2) downto 0) & '0';
						end if; 

						-- ON TRAITE LE SECOND BIT DE L'ITERATION
						if tbuf((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
							buf1 <= '0' & (tbuf((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
							buf2 <= tbuf((SIZE - 2) downto 0) & '1'; 
						else 
							buf <= tbuf((2 * SIZE - 2) downto 0) & '0'; 
						end if; 

						-- EN FONCTION DE LA VALEUR DU COMPTEUR ON CHOISI NOTRE DESTIN
						if sm /= (17) then 
							sm      <= sm + 1; 
							snready := '0';	 -- le resultat n'est pas disponible
						else 
							--if tbuf((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
								--printmsg("(DIVx2) ===> (111) COMPUTATION IS FINISHED (" & to_int_str(tbuf((SIZE - 2) downto 0) & '1',6) & ")");
							--else 
								--printmsg("(DIVx2) ===> (111) COMPUTATION IS FINISHED (" & to_int_str(tbuf((SIZE - 2) downto 0) & '0',6) & ")");
							--end if; 
							snready  := '1';  -- le resultat du calcul est disponible
							sm       <= 0;
						end if; 

					end case; 

				-- On transmet les signaux au systeme
    			ready  <= sready;
				nready <= snready;

			end if; 
		end if; 
	end process; 

end behav;
