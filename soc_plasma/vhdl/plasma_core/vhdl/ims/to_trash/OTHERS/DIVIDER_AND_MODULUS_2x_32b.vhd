library	IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all; 

entity DIVIDER_AND_MODULUS_2x_32b is 
	port(
		rst		: in  STD_LOGIC; 
		clk		: in  STD_LOGIC; 
		start		: in  STD_LOGIC; 
		flush    : in  std_logic;
		holdn    : in  std_ulogic;
		INPUT_1	: in  STD_LOGIC_VECTOR(31 downto 0); 
		INPUT_2	: in  STD_LOGIC_VECTOR(31 downto 0); 
		FONCTION : in  STD_LOGIC_VECTOR(1 downto 0); 
		ready    : out std_logic;
		nready   : out std_logic;
		icc      : out std_logic_vector(3  downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	); 
END DIVIDER_AND_MODULUS_2x_32b; 

architecture behav of DIVIDER_AND_MODULUS_2x_32b is 
	constant SIZE 		: INTEGER := 32;
	signal buf	  		: STD_LOGIC_VECTOR((2 * SIZE - 1) downto 0); 
	signal dbuf	  		: STD_LOGIC_VECTOR((SIZE - 1) downto 0); 
	signal sm	  		: INTEGER range 0 to SIZE; 
	signal fFunction   	: std_logic;

	alias buf1 is buf((2 * SIZE - 1) downto SIZE); 
	alias buf2 is buf((SIZE - 1) downto 0); 
	
BEGIN 

	ICC <= "0000";

	-------------------------------------------------------------------------
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
			ready       <= '0'; 
			ready       <= sready;
			nready      <= snready;
			fFunction   <= '0';
			
		-- En cas de front montant de l'horloge alors on calcule
		elsif rising_edge(clk) then 

			-- Si Flush alors on reset le composant
    		if (flush = '1') then
				sm <= 0;

			-- Si le signal de maintient est actif alors on gel l'execution
			elsif (holdn = '0') then
				sm <= sm;

			-- Sinon on déroule l'execution de la division
			else
			
				case sm is 

					-- Etat d'attente du signal start
					when 0 => 

						if( fFunction = '1' ) then  
							OUTPUT_1 <= buf2; -- ON RETOURNE LE RESULTAT DE LA DIVISION
						else
							OUTPUT_1 <= buf1; -- ON RETOURNE LE RESTE DE LA DIVISION (MODULO)
						end if;

						if start = '1' then 
							buf1      <= (others => '0'); 
							buf2      <= INPUT_1; 
							dbuf      <= INPUT_2; 
							sm        <= sm + 1;	-- le calcul est en cours
							fFunction <= FONCTION(0);
						else
							sm    <= sm;
						end if;

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
						if sm /= 16 then 
							sm      <= sm + 1; 
							snready := '0';	 -- le resultat n'est pas disponible
						else 
							snready  := '1';  -- le resultat du calcul est disponible
							sm       <= 0;
						end if; 

					end case; 

				-- On transmet les signaux au systeme
    			ready  <= sready;
				nready <= snready;

			end if; -- clock
		end if; 	-- reset
	end process; 

end behav;
