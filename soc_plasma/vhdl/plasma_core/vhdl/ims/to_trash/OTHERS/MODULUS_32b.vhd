library	IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all; 

entity MODULUS_32b is 
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
end MODULUS_32b; 

-- ready = 0 indique que le circuit est pret a calculer
--			  1 signifie que le circuit est occupe

-- nready = 1 indique que le calcul est termine (1 cycle suffit)

architecture behav of MODULUS_32b is 
	signal buf	: STD_LOGIC_VECTOR(63 downto 0); 
	signal dbuf	: STD_LOGIC_VECTOR(31 downto 0); 
	signal sm	: INTEGER range 0 to 32; 

	alias buf1 is buf(63 downto 32); 
	alias buf2 is buf(31 downto 0);
	
begin 

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
						OUTPUT_1 <= buf1;
						if start = '1' then 
							buf1     <= (others => '0'); 
							buf2     <= INPUT_1; 
							dbuf     <= INPUT_2; 
							sm       <= sm + 1;	-- le calcul est en cours
						else
							sm    <= sm;
						end if;

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
							snready  := '1';  -- le resultat du calcul est disponible
							sm       <= 0;
						end if; 
				end case; 

				-- On transmet les signaux au systeme
				ready  <= sready;
				nready <= snready;
					
				end if; -- Fin du process de calcul
			end if; 
	end process; 

end behav;
