library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY Q16_8_Check_Processor is
	PORT (
		RESET        : in  STD_LOGIC;
		CLOCK        : in  STD_LOGIC;
		HOLDN        : in  std_ulogic;

		-- SIGNAUX DE COMMANDE DU CO-PROCESSEUR
		WRITE_EN          : in  STD_LOGIC;
		READ_EN           : in  STD_LOGIC;
		COMPUTE_NODE      : in  STD_LOGIC;
		COMPUTE_MESG      : in  STD_LOGIC;
		FIRST_NODE        : in  STD_LOGIC;
		FIRST_CHECK       : in  STD_LOGIC;
		MODE_LDST         : in  STD_LOGIC;
		MODE_EXEC         : in  STD_LOGIC;
		SOFT_RESET        : in  STD_LOGIC;
		STORE_NODE_COUNT  : in  STD_LOGIC;
		STORE_MESG_COUNT  : in  STD_LOGIC;
		WRITE_NODE_INDEX  : in  STD_LOGIC;
		
		-- INTERFACES D'E/S DU CO-PROCESSEUR
		INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
END;

architecture aQ16_8_Check_Processor of Q16_8_Check_Processor is

	-- ON DEFINIT LES PARAMETRES DE L'ARCHITECTURE INTERNE
	CONSTANT SAT_MIN_VARIABLE : SIGNED(19 downto 0) := TO_SIGNED(-32768, 20);
	CONSTANT SAT_MAX_VARIABLE : SIGNED(19 downto 0) := TO_SIGNED( 32767, 20);
	CONSTANT SAT_MIN_MESSAGE  : SIGNED(19 downto 0) := TO_SIGNED(-32768, 20);
	CONSTANT SAT_MAX_MESSAGE  : SIGNED(19 downto 0) := TO_SIGNED( 32767, 20);

	-- MEMOIRE QUI VA CONTENIR LES VALEURS DES NOEUDS
	type ram_type is array (0 to 1024-1) of SIGNED (19 downto 0);                 
	signal RAM_node        : ram_type;
	SIGNAL READ_node       : UNSIGNED(15 downto 0);
	SIGNAL WRITE_node      : UNSIGNED(15 downto 0);
	--SIGNAL READ_node       : UNSIGNED(15 downto 0);
	SIGNAL SORTIE_NODE     : SIGNED(19 downto 0);
	SIGNAL SORTIE_NEW_NODE : SIGNED(19 downto 0);
	
	-- MEMOIRE QUI VA CONTENIR LES VALEURS DES MESSAGES
	type ra2_type is array (0 to 2048-1) of SIGNED (15 downto 0);                 
	signal RAM_msgs        : ra2_type;
	SIGNAL READ_msgs       : UNSIGNED(15 downto 0);
	SIGNAL WRITE_msgs      : UNSIGNED(15 downto 0);
	SIGNAL SORTIE_MESG     : SIGNED(15 downto 0);
	SIGNAL SORTIE_NEW_MESG : SIGNED(15 downto 0);

	-- MEMOIRE QUI VA CONTENIR LA POSTION DES NOEUDS VARIABLES A
	-- UTILISER EN FONCTION DU NOEUD CHECK COURANT
	type ra3_type is array (0 to 59) of UNSIGNED (10 downto 0);                 
	signal RAM_pNode    : ra3_type;
	SIGNAL READ_nPos    : UNSIGNED(15 downto 0);
	SIGNAL WRITE_nPos   : UNSIGNED(15 downto 0);
	SIGNAL SORTIE_pNode : UNSIGNED(10 downto 0);

	-- FIFO QUI VA CONTENIR LA VALEUR DES CONTRIBUTIONS
	type buffer_ancien is array (0 to 15) of SIGNED (19 downto 0);
	SIGNAL RAM_CONTRIB   : buffer_ancien;
	SIGNAL READ_CONTRIB  : UNSIGNED(3  downto 0);
	SIGNAL WRITE_CONTRIB : UNSIGNED(3  downto 0);
	SIGNAL LAST_CONTRIB  : SIGNED  (19 downto 0);
	
	-- FIFO QUI VA CONTENIR LA VALEUR DES POSITIONS DES NOEUDS
	type buffer_posVar is array (0 to 15) of UNSIGNED (10 downto 0);
	signal RAM_POSVAR   : buffer_posVar;
	SIGNAL READ_POSVAR  : UNSIGNED(3  downto 0);
	SIGNAL WRITE_POSVAR : UNSIGNED(3  downto 0);
	SIGNAL LAST_POSVAR  : UNSIGNED(10 downto 0);
	
	--
	--
	--

	SIGNAL MAX_NODES  : UNSIGNED(15 downto 0) := TO_UNSIGNED(32, 16);
	SIGNAL MAX_MESGS  : UNSIGNED(15 downto 0) := TO_UNSIGNED(32, 16);
	
	SIGNAL SORTIE_CONTRIB  : SIGNED(19 downto 0);
	
	--SIGNAL MEMOIRE_CONTRIB : SIGNED  (16 downto 0);
	
	SIGNAL MEMOIRE_XOR_MIN1 : UNSIGNED(14 downto 0);
	SIGNAL MEMOIRE_XOR_MIN2 : UNSIGNED(14 downto 0);
	SIGNAL MEMOIRE_XOR_SIGN : STD_LOGIC;

	SIGNAL STAGE_2_XOR_MIN1 : UNSIGNED(14 downto 0);
	SIGNAL STAGE_2_XOR_MIN2 : UNSIGNED(14 downto 0);
	SIGNAL STAGE_2_XOR_SIGN : STD_LOGIC;
	
	SIGNAL mTAGE_2_XOR_MIN1 : UNSIGNED(14 downto 0);
	SIGNAL mTAGE_2_XOR_MIN2 : UNSIGNED(14 downto 0);
	SIGNAL mTAGE_2_XOR_SIGN : STD_LOGIC;
	
	SIGNAL SORTIE_XOR_MIN1 : UNSIGNED(14 downto 0);
	SIGNAL SORTIE_XOR_MIN2 : UNSIGNED(14 downto 0);
	SIGNAL SORTIE_XOR_SIGN : STD_LOGIC;
	
	SIGNAL pCOMPUTE_NODE : STD_LOGIC;
	SIGNAL pCOMPUTE_MESG : STD_LOGIC;
	SIGNAL ppOMPUTE_MESG : STD_LOGIC;
	SIGNAL pFIRST_NODE   : STD_LOGIC;
	SIGNAL pFIRST_CHECK  : STD_LOGIC;
	--SIGNAL pFIRST_ITER   : STD_LOGIC;

	-- MEMORISATION DE L'ETAT COURANT DU CO-PROCESSEUR (CHARGEMENT ET
	-- DECHARGEMENT DE DONNEES - OU - CALCUL). CELA MODIFIE LA MANIERE
	-- D'ACCEDER A LA MEMOIRE VARIABLE.
	SIGNAL IS_LOADING_MODE : STD_LOGIC;

	-- SIGNAUX PERMETTANT DE SAVOIR SI L'ON REALISE LA PREMIERE ITERATION
	-- DU DECODEUR (ON INHIBE LES SIGNAUX DE LA RAM MESSAGES).
	SIGNAL FIRST_LOOP_COUNTER : UNSIGNED(15 downto 0);
	SIGNAL IS_FIRST_LOOP      : STD_LOGIC;
	
	-- SIGNAL PERMETTANT D'IDENTIFIER L'INSTRUCTION QUE LE PROCESSEUR DE CALCUL
	-- DOIT EXECUTER (UTILE POUR LA MISE AU POINT)
	SIGNAL   INSTRUCTION            : STD_LOGIC_VECTOR(11 downto 0);
	CONSTANT INSTR_WRITE_VARIABLE   : STD_LOGIC_VECTOR(11 downto 0) := "100000000000";
	CONSTANT INSTR_READ_VARIABLE    : STD_LOGIC_VECTOR(11 downto 0) := "010000000000";
	CONSTANT INSTR_EXEC_FIRST_NODE  : STD_LOGIC_VECTOR(11 downto 0) := "001001000000";
	CONSTANT INSTR_EXEC_NODE        : STD_LOGIC_VECTOR(11 downto 0) := "001000000000";
	CONSTANT INSTR_EXEC_FIRST_MESG  : STD_LOGIC_VECTOR(11 downto 0) := "000110000000";
	CONSTANT INSTR_EXEC_MESG        : STD_LOGIC_VECTOR(11 downto 0) := "000100000000";
	CONSTANT INSTR_SWITCH_LDST_MODE : STD_LOGIC_VECTOR(11 downto 0) := "000000100000";
	CONSTANT INSTR_SWITCH_EXEC_MODE : STD_LOGIC_VECTOR(11 downto 0) := "000000010000";
	CONSTANT INSTR_SOFT_RESET       : STD_LOGIC_VECTOR(11 downto 0) := "000000001000";
	CONSTANT INSTR_STORE_NODE_COUNT : STD_LOGIC_VECTOR(11 downto 0) := "000000000100";
	CONSTANT INSTR_STORE_MESG_COUNT : STD_LOGIC_VECTOR(11 downto 0) := "000000000010";
	CONSTANT INSTR_WRITE_NODE_INDEX : STD_LOGIC_VECTOR(11 downto 0) := "000000000001";
	CONSTANT INSTR_EXEC_NOP         : STD_LOGIC_VECTOR(11 downto 0) := "000000000000";

	-- INSTUCTION POUR LE MODE PIPELINE
	CONSTANT INSTR_EXEC_F_NODE_MESG : STD_LOGIC_VECTOR(11 downto 0) := "001111000000";
	CONSTANT INSTR_EXEC_NODE_MESG   : STD_LOGIC_VECTOR(11 downto 0) := "001100000000";
	
	-- SIGNAL PERMETTANT DE SAVOIR DANS QUEL ETAT SE TROUVE ACTUELLEMENT LE CIRCUIT
	type instr is (s_reset, h_reset, ld_node, st_pvar, c_node, c_msg, c_fnode, c_fmsg, nop, maxN, maxM, ld_var, st_var, set_ldst, set_exec, oups, c_node_msg, c_fnode_fmsg); 
   SIGNAL etat : instr := nop;
	
BEGIN

	-- ON COMPOSE LE CODE INSTRUCTION A PARTIR DES SIGNAUX DE BASE
	INSTRUCTION <=  WRITE_EN & READ_EN & COMPUTE_NODE & COMPUTE_MESG & FIRST_NODE & FIRST_CHECK & MODE_LDST & MODE_EXEC & SOFT_RESET & STORE_NODE_COUNT & STORE_MESG_COUNT & WRITE_NODE_INDEX;

	-- EN FONCTION DE LA VALEUR DE L'INSTRUCTION ON MEMORISE (POUR AFFICHAGE UNIQUEMENT)
	-- LE NOM DE L'ACTION REALISEE PAR LE CO-PROCESSEUR
	PROCESS (INSTRUCTION, RESET)
	BEGIN
		if reset = '0' then
			etat <= h_reset;
		ELSE
			CASE INSTRUCTION IS
				WHEN INSTR_WRITE_VARIABLE    => etat <= st_var;
				WHEN INSTR_READ_VARIABLE     => etat <= ld_var;
				WHEN INSTR_EXEC_FIRST_NODE   => etat <= c_fnode;
				WHEN INSTR_EXEC_NODE         => etat <= c_node;
				WHEN INSTR_EXEC_FIRST_MESG   => etat <= c_fmsg;
				WHEN INSTR_EXEC_MESG         => etat <= c_msg;
				WHEN INSTR_SWITCH_LDST_MODE  => etat <= set_ldst;
				WHEN INSTR_SWITCH_EXEC_MODE  => etat <= set_exec;
				WHEN INSTR_SOFT_RESET        => etat <= s_reset;
				WHEN INSTR_STORE_NODE_COUNT  => etat <= maxN;
				WHEN INSTR_STORE_MESG_COUNT  => etat <= maxM;
				WHEN INSTR_WRITE_NODE_INDEX  => etat <= st_pvar;
				WHEN INSTR_EXEC_F_NODE_MESG  => etat <= c_fnode_fmsg;
				WHEN INSTR_EXEC_NODE_MESG    => etat <= c_node_msg;
				WHEN INSTR_EXEC_NOP          => etat <= nop;
				WHEN OTHERS                  => etat <= oups;
			END CASE;
		END IF;
	END PROCESS;



	PROCESS(clock, reset)
	BEGIN
		IF reset = '0' then
			pCOMPUTE_NODE <= '0';
			pCOMPUTE_MESG <= '0';
			pFIRST_NODE   <= '0';
			pFIRST_CHECK  <= '0';
			--pFIRST_ITER   <= '0';
			ppOMPUTE_MESG <= '0';
		ELSIF clock'event and clock = '1' then
			pCOMPUTE_NODE <= COMPUTE_NODE;
			pCOMPUTE_MESG <= COMPUTE_MESG;
			pFIRST_NODE   <= FIRST_NODE;
			pFIRST_CHECK  <= FIRST_CHECK;
			--pFIRST_ITER   <= FIRST_ITER;
			ppOMPUTE_MESG <= pCOMPUTE_MESG;
		END IF;
	END PROCESS;


	-------------------------------------------------------------------------
	--
	-- PROCESSUS GERANT LE BASCULEMENT DU CO-PROCESSEUR DU MODE DE CHARGEMENT
	-- DECHARGEMENT DES DONNEES VERS LE MODE DE CALCUL ET VICE ET VERSA.
	--
	process(clock, reset)
	begin
		if reset = '0' then
			IS_LOADING_MODE <= '1';
		elsif clock'event and clock = '1' then
			IF MODE_LDST = '1' THEN
				IS_LOADING_MODE <= '1';
			ELSIF MODE_EXEC = '1' THEN
				IS_LOADING_MODE <= '0';
			ELSE
				IS_LOADING_MODE <= IS_LOADING_MODE;
			END IF;
		end if;
	END process;



	-------------------------------------------------------------------------
	--
	-- PROCESSUS GERANT LE BASCULEMENT DU MODE PREMIERE ITERATION DU DECODEUR
	-- LDPC (TRANSITOIRE) VERS LE MODE EXECUTION CONTINUE (RAM MESSAGE)
	--
	PROCESS(clock, reset)
		VARIABLE TEMP : UNSIGNED(15 downto 0);
	BEGIN
		IF reset = '0' THEN
			FIRST_LOOP_COUNTER <= TO_UNSIGNED(0, 15);
			IS_FIRST_LOOP      <= '1';
		ELSIF clock'event AND clock = '1' THEN
			TEMP := FIRST_LOOP_COUNTER;
			IF pCOMPUTE_NODE = '1' AND holdn = '1' THEN -- ON UTILISE PCOMPUTE_NODE POUR DECALER D'UN CYCLE
				TEMP := TEMP + TO_UNSIGNED(1, 16);		  -- LA TRANSITION SUR IS_FIRST_LOOP SINON ON A UN SOUCIS
				IF TEMP >= MAX_MESGS THEN
					TEMP := MAX_MESGS;
					IS_FIRST_LOOP <= '0';
				ELSE
					IS_FIRST_LOOP <= IS_FIRST_LOOP;
				END IF;
			END IF;
			FIRST_LOOP_COUNTER <= TEMP;
		END IF;
	END PROCESS;



	-------------------------------------------------------------------------
	--
	-- PROCESSUS GERANT LA RECEPTION DU NOMBRE DE NOEUDS VARIABLES DANS LE
	-- DECODEUR LDPC COURANT
	--
	process(clock, reset)
	begin
		if reset = '0' then
			MAX_NODES <= TO_UNSIGNED(0, 16);
		elsif clock'event and clock = '1' then
			if STORE_NODE_COUNT = '1' AND holdn = '1' then
				MAX_NODES <= UNSIGNED( INPUT_1(15 downto 0) );
			ELSE
				MAX_NODES <= MAX_NODES;
			end if;
		end if;
	END process;



	-------------------------------------------------------------------------
	--
	-- PROCESSUS GERANT LA RECEPTION DU NOMBRE DE MESSAGES A CALCULER ET
	-- A TRANSMETTRE DANS LE DECODEUR LDPC COURANT
	--
	process(clock, reset)
	begin
		if reset = '0' then
			MAX_MESGS <= TO_UNSIGNED(0, 16);
		elsif clock'event and clock = '1' then
			if STORE_MESG_COUNT = '1' AND holdn = '1' then
				MAX_MESGS <= UNSIGNED( INPUT_1(15 downto 0) );
			ELSE
				MAX_MESGS <= MAX_MESGS;
			end if;
		end if;
	END process;



	-------------------------------------------------------------------------
	--
	-- PROCESSUS GERANT L'ECRITURE DES DONNEES DANS LA MEMOIRE
	-- CONTENANT LA VALEUR DES NOEUDS VARIABLES
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(15 downto 0);
	begin
		if reset = '0' then
			WRITE_nPos <= TO_UNSIGNED(0, 16);

		elsif clock'event and clock = '1' then
			
			-- ON MEMORISE LA DONNEE DANS LA MEMOIRE
			if WRITE_NODE_INDEX = '1' AND holdn = '1' then
				RAM_pNode( to_integer(WRITE_nPos) ) <= UNSIGNED( INPUT_1(10 downto 0) );
			END IF;

			-- ON FAIT AVANCER LE COMPTEUR SI NECESSAIRE
			TEMP := WRITE_nPos;
			if WRITE_NODE_INDEX = '1' AND holdn = '1' then
				TEMP := TEMP + TO_UNSIGNED(1, 16);
				IF TEMP = MAX_MESGS THEN
					TEMP := TO_UNSIGNED(0, 16);
				END IF;
			END IF;
			WRITE_nPos <= TEMP;
		end if;
	end process;

	--
	-- PROCESSUS GERANT LA LECTURE DES DONNEES DANS LA MEMOIRE
	-- CONTENANT LA VALEUR DES NOEUDS VARIABLES
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(15 downto 0);
	begin
		if reset = '0' then
			READ_nPos <= TO_UNSIGNED(0, 16);
		elsif clock'event and clock = '1' then
			TEMP := READ_nPos;
			if COMPUTE_NODE = '1' AND holdn = '1' then
				TEMP := TEMP + TO_UNSIGNED(1, 16);
				IF TEMP = MAX_MESGS THEN
					TEMP := TO_UNSIGNED(0, 16);
				END IF;
			end if;
			READ_nPos    <= TEMP;
			SORTIE_pNode <= UNSIGNED( RAM_pNode( to_integer(TEMP) ) );
		end if;
	end process;


	-------------------------------------------------------------------------
	--
	-- PROCESSUS GERANT L'ECRITURE DES DONNEES DANS LA MEMOIRE
	-- CONTENANT LA VALEUR DES NOEUDS VARIABLES
	--
	process(clock, reset)
		VARIABLE TEMP    : UNSIGNED(15 downto 0);
		VARIABLE ADRESSE : UNSIGNED(15 downto 0);
		VARIABLE DONNEE  :   SIGNED(19 downto 0);
	begin
		if reset = '0' then
			WRITE_node <= TO_UNSIGNED(0, 16);
		elsif clock'event and clock = '1' then

			-- ON GERE L'ECRITURE DES DONNEES DANS LA MEMOIRE (DONNEES PROVENANT DE L'EXTERIEUR)
			--if WRITE_EN = '1' AND holdn = '1' then
			--	 RAM_node( to_integer(WRITE_node  ) ) <= SIGNED( INPUT_1(19 downto 0) );
			-- ON GERE L'ECRITURE DES DONNEES DANS LA MEMOIRE (DONNEES INTERNES DE CALCUL)
			--elsif ppOMPUTE_MESG = '1' AND holdn = '1' then
			--	 RAM_node( to_integer(LAST_POSVAR) ) <= SIGNED( sortie_new_node );
			--end if;
			
			-- ON SELECTIONNE L'ADRESSE ET LA DONNEE EN FONCTION DU MODE DANS LEQUEL
			-- SE TROUVE LE CO-PROCESSEUR
			IF IS_LOADING_MODE = '1' THEN
				ADRESSE := WRITE_node;
				DONNEE  := SIGNED( INPUT_1(19 downto 0) );
			ELSE
				ADRESSE := "00000" & LAST_POSVAR;
				DONNEE  := SIGNED( sortie_new_node );
			END IF;

			-- ON ECRIT LA DONNEE DANS LA MEMOIRE SI CELA EST NECESSAIRE
			IF ((WRITE_EN      = '1' AND holdn = '1') AND IS_LOADING_MODE = '1') OR
				((ppOMPUTE_MESG = '1' AND holdn = '1') AND IS_LOADING_MODE = '0') THEN
				 RAM_node( to_integer(ADRESSE) ) <= SIGNED( DONNEE );
			END IF;

			-- ON GERE L'EVOLUTION DU COMPTEUR QUI NOUS DIT OU ECRIRE
			TEMP := WRITE_node;
			if WRITE_EN = '1' AND holdn = '1' then
				TEMP := TEMP + TO_UNSIGNED(1, 16);
				IF TEMP = MAX_NODES THEN
					TEMP := TO_UNSIGNED(0, 16);
				END IF;
			end if;
			WRITE_node <= TEMP;

		end if;
	end process;

	--
	-- PROCESSUS GERANT LA LECTURE DES DONNEES DANS LA MEMOIRE
	-- CONTENANT LA VALEUR DES NOEUDS VARIABLES
	--
	process(clock, reset)
		VARIABLE ADRESSE : UNSIGNED(15 downto 0);
	begin
		if reset = '0' then

		elsif clock'event and clock = '1' then

			-- ON SELECTIONNE L'ADRESSE ET LA DONNEE EN FONCTION DU MODE DANS LEQUEL
			-- SE TROUVE LE CO-PROCESSEUR
			IF IS_LOADING_MODE = '1' THEN
				ADRESSE := READ_node;
			ELSE
				ADRESSE := "00000" & SORTIE_pNode;
			END IF;
			SORTIE_NODE <= RAM_node( to_integer(ADRESSE) );

--			TEMP := READ_node;
--			if read_en = '1' AND holdn = '1' then
--				TEMP := TEMP + TO_UNSIGNED(1, 16);
--				IF TEMP = MAX_NODES THEN
--					TEMP := TO_UNSIGNED(0, 16);
--				END IF;
--			end if;
--			READ_node   <= TEMP;
--			SORTIE_NODE <= RAM_node( to_integer(TEMP) );
		end if;
	end process;

	--
	-- COMPTEUR UTILISE POUR GENERER LES ADRESSES DE LECTURE DES DONNEES (VARIABLE)
	-- EN VUE DE LA RESTITUTION DE CES DERNIERES VERS LE SYSTEME (DECISION)
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(15 downto 0);
	begin
		if reset = '0' then
			READ_node <= TO_UNSIGNED(0, 16);
		elsif clock'event and clock = '1' then
			TEMP := READ_node;
			if READ_EN = '1' AND holdn = '1' then
				TEMP := TEMP + TO_UNSIGNED(1, 16);
				IF TEMP = MAX_NODES THEN
					TEMP := TO_UNSIGNED(0, 16);
				END IF;
			END IF;
			READ_node <= TEMP;
		end if;
	end process;
	
	
	-------------------------------------------------------------------------
	--
	-- PROCESSUS GERANT L'ECRITURE DES DONNEES DANS LA MEMOIRE
	-- CONTENANT LES MESSAGES (CHECK => NODE)
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(15 downto 0);
	begin
		if reset = '0' then
			WRITE_msgs <= TO_UNSIGNED(0, 16);
		elsif clock'event and clock = '1' then

			-- ON GERE L'ECRITURE DES DONNEES DANS LA MEMOIRE
			if ppOMPUTE_MESG = '1' AND holdn = '1' then
				 RAM_msgs( to_integer(WRITE_msgs) ) <= SIGNED( sortie_new_mesg(15 downto 0) );
			end if;

			-- ON FAIT EVOLUTER LE COMPTEUR EN CONSEQUENCE
			TEMP := WRITE_msgs;
			if ppOMPUTE_MESG = '1' AND holdn = '1' then
				TEMP := TEMP + TO_UNSIGNED(1, 16);
				IF TEMP = MAX_MESGS THEN
					TEMP := TO_UNSIGNED(0, 16);
				END IF;
			end if;
			WRITE_msgs <= TEMP;

		end if;
	end process;

	--
	-- PROCESSUS GERANT LA LECTURE DES DONNEES DANS LA MEMOIRE
	-- CONTENANT LES MESSAGES (CHECK => NODE)
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(15 downto 0);
	begin
		if reset = '0' then
			READ_msgs <= TO_UNSIGNED(0, 16);
		elsif clock'event and clock = '1' then
			TEMP := READ_msgs;

			if pCOMPUTE_NODE = '1' AND holdn = '1' then

				TEMP := TEMP + TO_UNSIGNED(1, 16);
				IF TEMP = MAX_MESGS THEN
					TEMP := TO_UNSIGNED(0, 16);
				END IF;
			end if;
			READ_msgs   <= TEMP;
			SORTIE_MESG <= SIGNED(RAM_msgs( to_integer(TEMP) ));
		end if;
	end process;



	-------------------------------------------------------------------------
	--
	-- PROCESSUS ASSURANT LE CALCUL DES CONTRIBUTIONS EN SORTIE DES MEMOIRES
	--
  	PROCESS (SORTIE_NODE, SORTIE_MESG, IS_FIRST_LOOP)
  	BEGIN
	
		IF ( IS_FIRST_LOOP = '0' ) THEN
		--IF ( pFIRST_ITER = '0' ) THEN
			SORTIE_CONTRIB <= SORTIE_NODE - SORTIE_MESG;
		ELSE
			SORTIE_CONTRIB <= SORTIE_NODE; --RESIZE(SORTIE_NODE, 17);
		END IF;
	END PROCESS;



	-------------------------------------------------------------------------
	--
	-- PROCESSUS GERANT LE CALCUL DE LA VALEUR DE LA SORTIE DU PROCESSEUR
	-- DE CALCUL (PRISE DE DECISION SUR LA VALEUR DU BIT RECU PAR LE DECODEUR).
	--
	PROCESS(SORTIE_NODE, IS_LOADING_MODE)
	begin
		IF IS_LOADING_MODE = '1' THEN
			OUTPUT_1 <= STD_LOGIC_VECTOR( RESIZE(SORTIE_NODE, 32) );
			--if SORTIE_NODE > TO_SIGNED(0, 16) then
			--	OUTPUT_1 <= "1000000000" & STD_LOGIC_VECTOR(SORTIE_NODE); --STD_LOGIC_VECTOR( TO_UNSIGNED(1, 32) );
			--else
			--	OUTPUT_1 <= "0000000000" & STD_LOGIC_VECTOR(SORTIE_NODE); --STD_LOGIC_VECTOR( TO_UNSIGNED(0, 32) );
			--end if;
		ELSE
				OUTPUT_1 <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
		END IF;
	end process;
	
	
	-------------------------------------------------------------------------
	--
	-- PROCESSUS GERANT LE CALCUL DE LA VALEUR XOR_MIN
	--
  	PROCESS (SORTIE_CONTRIB, MEMOIRE_XOR_MIN1, MEMOIRE_XOR_MIN2, MEMOIRE_XOR_SIGN, pFIRST_CHECK)
		VARIABLE OPT  : SIGNED(16 downto 0);
		VARIABLE OP1  : SIGNED(15 downto 0);
		VARIABLE vP1  : UNSIGNED(14 downto 0);
		VARIABLE MIN1 : UNSIGNED(14 downto 0);
		VARIABLE MIN2 : UNSIGNED(14 downto 0);
		VARIABLE SIGN : STD_LOGIC;
  	BEGIN
	
		-- ON CALCULE LA CONTRIBUTION DU NOEUD VARIABLE (MESSAGE NODE => CHECK)
		-- CALCUL SATURE [-32768, 32767]
		OPT := SORTIE_CONTRIB(16 downto 0);
		IF OPT > TO_SIGNED( 32767, 17) THEN
			OPT := TO_SIGNED( 32767, 17);
		ELSIF OPT < TO_SIGNED(-32768, 17) THEN
			OPT := TO_SIGNED(-32767, 17);
		END IF;
	
		-- ON RECUPERE NOS OPERANDES
		OP1  := SIGNED(      OPT    (15 downto  0));

		IF pFIRST_CHECK = '0' THEN
			MIN1 := MEMOIRE_XOR_MIN1; -- VALEUR ABSOLUE => PAS DE BIT DE SIGNE (TJS POSITIF)
			MIN2 := MEMOIRE_XOR_MIN2; -- VALEUR ABSOLUE => PAS DE BIT DE SIGNE (TJS POSITIF)
			SIGN := MEMOIRE_XOR_SIGN;
		ELSE
			MIN1 := TO_UNSIGNED(32767, 15);
			MIN2 := TO_UNSIGNED(32767, 15);
			SIGN := '0';
		END IF;
		
		-- ON CALCULE LA VALEUR ABSOLUE DE L'ENTREE
		OP1 := abs( OP1 );
		vP1 := UNSIGNED(OP1(14 downto 0));
		
		-- ON CALCULE LE MIN QUI VA BIEN
		IF vP1 < MIN1 THEN
			MIN2 := MIN1;
			MIN1 := vP1;
		ELSIF UNSIGNED(OP1(14 downto 0)) < MIN2 THEN
			MIN2 := vP1;
		END IF;

		-- ON S'OCCUPE DU BIT DE SIGNE DU RESULTAT
		SIGN := SIGN XOR ( NOT SORTIE_CONTRIB(15) );

		-- ON REFORME LE RESULTAT AVANT DE LE RENVOYER
		SORTIE_XOR_MIN1 <= MIN1; 
		SORTIE_XOR_MIN2 <= MIN2; 
		SORTIE_XOR_SIGN <= SIGN; 
	END PROCESS;
	-------------------------------------------------------------------------


	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(15 downto 0);
	begin
		if reset = '0' then
			STAGE_2_XOR_MIN1 <= TO_UNSIGNED(0, 15);
			STAGE_2_XOR_MIN2 <= TO_UNSIGNED(0, 15);
			STAGE_2_XOR_SIGN <= '0'; 
			mTAGE_2_XOR_MIN1 <= TO_UNSIGNED(0, 15);
			mTAGE_2_XOR_MIN2 <= TO_UNSIGNED(0, 15);
			mTAGE_2_XOR_SIGN <= '0'; 
		elsif clock'event and clock = '1' then
			--IF pFIRST_NODE = '1' THEN
			IF FIRST_NODE = '1' THEN
				mTAGE_2_XOR_MIN1 <= SORTIE_XOR_MIN1;
				mTAGE_2_XOR_MIN2 <= SORTIE_XOR_MIN2;
				mTAGE_2_XOR_SIGN <= SORTIE_XOR_SIGN; 
			END IF;
			STAGE_2_XOR_MIN1 <= mTAGE_2_XOR_MIN1;
			STAGE_2_XOR_MIN2 <= mTAGE_2_XOR_MIN2;
			STAGE_2_XOR_SIGN <= mTAGE_2_XOR_SIGN; 
		end if;
	end process;


	-------------------------------------------------------------------------
	--
	-- PROCESSUS EN CHARGE DE LA MEMORISATION DE LA VALEUR DE SORTIE DE L'OPERATEUR
	-- XOR_MIN LORSQUE CELA EST NECESSAIRE (CALCUL D'UN NOEUD CHECK EN COURS).
	--
	process(clock, reset)
		VARIABLE TEMP : UNSIGNED(15 downto 0);
	begin
		if reset = '0' then
			MEMOIRE_XOR_MIN1 <= TO_UNSIGNED(0, 15);
			MEMOIRE_XOR_MIN2 <= TO_UNSIGNED(0, 15);
			MEMOIRE_XOR_SIGN <= '0';
		elsif clock'event and clock = '1' then
--			IF COMPUTE_NODE = '1' THEN
			IF pCOMPUTE_NODE = '1' THEN
				MEMOIRE_XOR_MIN1 <= SORTIE_XOR_MIN1;
				MEMOIRE_XOR_MIN2 <= SORTIE_XOR_MIN2;
				MEMOIRE_XOR_SIGN <= SORTIE_XOR_SIGN;
			ELSE
				MEMOIRE_XOR_MIN1 <= MEMOIRE_XOR_MIN1;
				MEMOIRE_XOR_MIN2 <= MEMOIRE_XOR_MIN2;
				MEMOIRE_XOR_SIGN <= MEMOIRE_XOR_SIGN;
			END IF;
		end if;
	end process;
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	--
	-- PROCESSUS EN CHARGE DU CALCUL DE LA NOUVELLE VALEUR DU NOEUD VARIABLE
	-- ET DE LA NOUVELLE VALEUR DU MESSAGE (CHECK => NODE).
	--
  	PROCESS (LAST_CONTRIB, STAGE_2_XOR_MIN1, STAGE_2_XOR_MIN2, STAGE_2_XOR_SIGN)
		VARIABLE OPT   : SIGNED(16 downto 0);
		VARIABLE OP1   : SIGNED(15 downto 0);
		VARIABLE aOP1  : SIGNED(15 downto 0);
		VARIABLE MIN1  : SIGNED(15 downto 0);
		VARIABLE MIN2  : SIGNED(15 downto 0);
		VARIABLE CST1  : SIGNED(15 downto 0);
		VARIABLE CST2  : SIGNED(15 downto 0);
		VARIABLE RESU  : SIGNED(15 downto 0);
		VARIABLE RESUp : SIGNED(15 downto 0);
		VARIABLE MESSG : SIGNED(15 downto 0);
		VARIABLE TEMPV : SIGNED(19 downto 0);
		VARIABLE iSIGN : STD_LOGIC;
		VARIABLE sSIGN : STD_LOGIC;
  	BEGIN
		--
		-- ON RECUPERE NOS OPERANDES
		--
		OPT := LAST_CONTRIB(16 downto 0);
		IF( OPT > TO_SIGNED( 32767, 17) ) THEN	OPT := TO_SIGNED( 32767, 17);
		ELSIF OPT < TO_SIGNED(-32768, 17) THEN	OPT := TO_SIGNED(-32767, 17);
		END IF;
		
		OP1   := OPT(15 downto  0);              -- DONNEE SIGNEE SUR 16 bits
		MIN1  := SIGNED('0' & STAGE_2_XOR_MIN1); -- DONNEE TJS POSITIVE SUR 16 BITS
		MIN2  := SIGNED('0' & STAGE_2_XOR_MIN2); -- DONNEE TJS POSITIVE SUR 16 BITS
		iSIGN := OPT(15);                        -- ON EXTRAIT LA VALEUR DU SIGNE DE LA SOMME
		sSIGN := STAGE_2_XOR_SIGN;               -- ON EXTRAIT LA VALEUR DU SIGNE DE LA SOMME
		
		--
		aOP1 := abs( OP1 );
		
		--
		CST1 := MIN2 - TO_SIGNED(38, 16); -- BETA_FIX;
		CST2 := MIN1 - TO_SIGNED(38, 16); -- BETA_FIX; 
		IF CST1 < TO_SIGNED(0, 16) THEN CST1 := TO_SIGNED(0, 16); END IF;
		IF CST2 < TO_SIGNED(0, 16) THEN CST2 := TO_SIGNED(0, 16); END IF;

		--
		if ( aOP1 = MIN1 ) THEN
			RESU := CST1;
		ELSE
			RESU := CST2;
		END IF;
		
		--
		RESUp := -RESU;
		iSIGN := iSIGN XOR sSIGN;
		
		--
		IF( iSIGN = '0' ) THEN 
			MESSG := RESU;
		ELSE
			MESSG := RESUp;
		END IF;
		
		-- ON CALCULE LA NOUVELLE VALEUR DU MESSAGE (CHECK => NODE)
		SORTIE_NEW_MESG <= MESSG;

		-- ON CALCULE LA NOUVELLE VALEUR DU NOEUD VARIABLE
		TEMPV := LAST_CONTRIB + MESSG;
		IF TEMPV > TO_SIGNED( 32767, 20) THEN
			TEMPV := TO_SIGNED( 32767, 20);
		ELSIF TEMPV < TO_SIGNED(-32768, 20) THEN
			TEMPV := TO_SIGNED(-32767, 20);
		END IF;
		SORTIE_NEW_NODE <= TEMPV; --(15 downto 0);
		
	END PROCESS;
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	--
	--
	-- DESCRIPTION DE LA MEMOIRE EN CHARGE DE LA MEMORISATION DES CONTRIBUTIONS
	-- (CALCULS TEMPORAIRES NECESSAIRES POUR L'ETAPES DE XOR_MIN)
	--
	--
	-------------------------------------------------------------------------

	-- ON MEMORISE LA CALCUL TEMPORAIRE DE LA CONTRIBUTION DANS UNE MEMOIRE TAMPON
	process(clock)
		VARIABLE AW  : INTEGER RANGE 0 to 15;
	begin
		if reset = '0' then
			WRITE_CONTRIB <= TO_UNSIGNED(0, 4);
		elsif clock'event and clock = '1' then
		
			-- ON MEMORISE LA PREMIERE CONTRIBUTION
			if pCOMPUTE_NODE = '1' AND holdn = '1' then
				AW := to_integer( WRITE_CONTRIB );
				RAM_CONTRIB( AW ) <= SORTIE_CONTRIB;
				WRITE_CONTRIB     <= WRITE_CONTRIB + TO_UNSIGNED(1, 4);
			
			-- ON NE MEMORISE RIEN DU TOUT...
			ELSE
				WRITE_CONTRIB     <= WRITE_CONTRIB;
			end if;
		end if;
	end process;


	-- ON RESTITUE LES CALCULS TEMPORAIRES DE LA CONTRIBUTION
	process(clock)
	begin
		if reset = '0' then
			READ_CONTRIB <= TO_UNSIGNED(0, 4);
		elsif clock'event and clock = '1' then
			IF pCOMPUTE_MESG = '1' AND holdn = '1' then
				READ_CONTRIB <= READ_CONTRIB + TO_UNSIGNED(1, 4);
			ELSE
				READ_CONTRIB <= READ_CONTRIB;
			END IF;
			LAST_CONTRIB <= RAM_CONTRIB( to_integer(READ_CONTRIB) );
		end if;
	end process;
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
	--
	--
	-- DESCRIPTION DE LA MEMOIRE EN CHARGE DE LA MEMORISATION DES CONTRIBUTIONS
	-- (CALCULS TEMPORAIRES NECESSAIRES POUR L'ETAPES DE XOR_MIN)
	--
	--
	-------------------------------------------------------------------------

	-- ON MEMORISE LA CALCUL TEMPORAIRE DE LA CONTRIBUTION DANS UNE MEMOIRE TAMPON
	process(clock)
		VARIABLE AW  : INTEGER RANGE 0 to 15;
	begin
		if reset = '0' then
			WRITE_POSVAR <= TO_UNSIGNED(0, 4);

		elsif clock'event and clock = '1' then
		
			-- ON MEMORISE LA PREMIERE CONTRIBUTION
			if COMPUTE_NODE = '1' AND holdn = '1' then
				AW := to_integer( WRITE_POSVAR );
				RAM_POSVAR( AW ) <= SORTIE_pNODE;
				WRITE_POSVAR     <= WRITE_POSVAR + TO_UNSIGNED(1, 4);
			
			-- ON NE MEMORISE RIEN DU TOUT...
			ELSE
				WRITE_POSVAR <= WRITE_POSVAR;
			end if;
		end if;
	end process;


	-- ON RESTITUE LES CALCULS TEMPORAIRES DE LA CONTRIBUTION
	process(clock)
	begin
		if reset = '0' then
			READ_POSVAR <= TO_UNSIGNED(0, 4);
		elsif clock'event and clock = '1' then
			IF pCOMPUTE_MESG = '1' AND holdn = '1' then
				READ_POSVAR <= READ_POSVAR + TO_UNSIGNED(1, 4);
			ELSE
				READ_POSVAR <= READ_POSVAR;
			END IF;
			LAST_POSVAR <= RAM_POSVAR( to_integer(READ_POSVAR) );
		end if;
	end process;
	-------------------------------------------------------------------------


END aQ16_8_Check_Processor;