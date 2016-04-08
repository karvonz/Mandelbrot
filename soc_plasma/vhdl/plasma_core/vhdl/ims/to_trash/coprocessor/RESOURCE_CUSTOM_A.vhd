library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib;
use grlib.stdlib.all;

library ims;
use ims.coprocessor.all;
use ims.conversion.all;

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

entity RESOURCE_CUSTOM_A is
port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    holdn   : in  std_ulogic;
    inp     : in  sequential32_in_type;
    outp    : out sequential32_out_type
);
end;

architecture rtl of RESOURCE_CUSTOM_A is
	signal A 			: std_logic_vector(31 downto 0);
	signal B 			: std_logic_vector(31 downto 0);
  	signal state  		: std_logic_vector(2  downto 0);
	signal gated_clock 	: std_logic;
	signal nIdle       	: std_logic;
begin

	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		printmsg("(IMS) RESOURCE_CUSTOM_1 : ALLOCATION OK !");
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	
	-------------------------------------------------------------------------
  	process(clk)
		variable gated : std_logic;
  	begin 
		if clk'event and clk = '1' then
			gated := '0';

			--IF ( (inp.dInstr(31 downto 30) & inp.dInstr(24 downto 19)) = "10101111" ) THEN
				--	REPORT "(PGDC) PGDC IS IN THE REGISTER SELECTION PIPELINE STAGE";
				--gated := '1';
			--END IF;
			IF ( (inp.aInstr(31 downto 30) & inp.aInstr(24 downto 19)) = "10101111" ) THEN
				--	REPORT "(PGDC) PGDC IS IN THE REGISTER SELECTION PIPELINE STAGE";
				gated := '1';
			END IF;
			IF ( (inp.eInstr(31 downto 30) & inp.eInstr(24 downto 19)) = "10101111" ) THEN
				--	REPORT "(PGDC) PGDC IS IN THE EXECUTION PIPELINE STAGE";
				gated := '1';
			END IF;
			--IF ( (inp.mInstr(31 downto 30) & inp.mInstr(24 downto 19)) = "10101111" ) THEN
				--	REPORT "(PGDC) PGDC IS IN THE MEMORY PIPELINE STAGE";
			--	gated := '1';
			--END IF;
			--IF ( (inp.xInstr(31 downto 30) & inp.xInstr(24 downto 19)) = "10101111" ) THEN
				--	REPORT "(PGDC) PGDC IS IN THE EXCEPTION PIPELINE STAGE";
				--gated := '1';
			--END IF;

			-- synthesis translate_off 
			IF   ( (nIdle = '0') AND (gated = '1') ) THEN
				--printmsg( "(PGDC) ENABLING THE PGDC CLOCK GENERATION" );
			ELSIF( (nIdle = '1') AND (gated = '0') ) THEN
				--printmsg( "(PGDC) DISABLING THE PGDC CLOCK GENERATION" );
			END IF;
			-- synthesis translate_on 

			nIdle <= gated;
    	end if;

	end process;
	-------------------------------------------------------------------------

	
	-------------------------------------------------------------------------
	gated_clock <= clk AND nIdle;
	-------------------------------------------------------------------------

	
	-------------------------------------------------------------------------
  	--process(inp.op1, inp.op2)
  	--begin
		--At <= inp.op1(31 downto 0);
		--Bt <= inp.op2(31 downto 0);
		--if( nIdle = '1' )then
		--	REPORT   "(PGDC) (At, Bt) MEMORISATION PROCESS";
		--	if ( (At(30) /= '-') AND (At(30) /= 'X') AND (At(30) /= 'U')) then
		--		printmsg("(PGDC) =====> (At) MEMORISATION PROCESS (" & to_int_str(inp.op1(31 downto 0),6) & ")");
		--	end if;
		--	if ( (Bt(30) /= '-') AND (Bt(30) /= 'X') AND (Bt(30) /= 'U')) then
		--		printmsg("(PGDC) =====>(Bt) MEMORISATION PROCESS (" & to_int_str(inp.op2(31 downto 0),6) & ")");
		--	end if;
		--	--printmsg("(PGDC) (At, Bt) MEMORISATION PROCESS (" & to_int_str(inp.op1(31 downto 0),6) & " & " & to_int_str(inp.op1(31 downto 0),6) & ")");
		--end if;
  	--end process;
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
  	--process(inp.start)
  	--begin
	--	if (inp.start = '1') then 
	--		REPORT   "(PGDC) (START) THE START SIGNAL BECOME UP";
	--	else
	--		REPORT   "(PGDC) (START) THE START SIGNAL BECOME DOWN";
	--	end if;
  	--end process;
	-------------------------------------------------------------------------

	
	-------------------------------------------------------------------------
	-- DESCRIPTION ORIGINALE QUI FONCTIONNE TRES TRES BIEN
  	-- reg : process(clk)
  		-- variable vready, vnready : std_logic;
  	-- begin 
    	-- vready  := '0';
		-- vnready := '0';
		
		-- if clk'event and clk = '1' then 
			-- if (rst = '0') then
				-- state <= "000";
    		-- elsif (inp.flush = '1') then
				-- state <= "000";
			-- elsif (holdn = '0') then
				-- state <= state;
			-- else
		    	-- case state is
					--ON ATTEND LA COMMANDE DE START
    				-- when "000" =>
						-- if (inp.start = '1') then 
							-- A <= inp.op1(31 downto 0);
							-- B <= inp.op2(31 downto 0);
							-- state <= "001";
						-- else
							-- state <= "000";
							-- A <= A;
							-- B <= B;
						-- end if;

					--ON COMMENCE LE CALCUL
    				-- when "001" =>
						-- A <= inp.op1(31 downto 0);
						-- B <= inp.op2(31 downto 0);
						-- state <= "011";

					--ON COMMENCE LE CALCUL
    				-- when "010" =>
						-- if( SIGNED(A) > SIGNED(B) ) then
							-- A <= STD_LOGIC_VECTOR(SIGNED(A) - SIGNED(B));
						-- else
							-- B <= STD_LOGIC_VECTOR(SIGNED(B) - SIGNED(A));
						-- end if;
						-- state <= "011";


					--ON TEST LES DONNEES (FIN D'ITERATION)
    				-- when "011" =>
						-- if(SIGNED(A) = SIGNED(B)) then
							-- state   <= "100";
							-- vnready := '1';
						-- elsif( SIGNED(A) = TO_SIGNED(0,32) ) then
							-- state   <= "100";
							-- vnready := '1';
						-- elsif( SIGNED(B) = TO_SIGNED(0,32) ) then
							-- A <= STD_LOGIC_VECTOR(TO_SIGNED(0,32));
							-- state   <= "100";
							-- vnready := '1';
						-- else
							-- state <= "010";
						-- end if;

    				-- when "100" =>
						--ON INDIQUE QUE LE RESULTAT EST PRET
						-- vready := '1';

						--ON RETOURNE DANS L'ETAT INTIAL
						-- state <= "000";
						
    				-- when others =>
						-- state <= "000";
    			-- end case;

    			-- outp.ready  <= vready;
				-- outp.nready <= vnready;
			-- end if; 	-- if reset
    	-- end if;		-- if clock
  	-- end process;
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
  	reg : process(clk, rst)
  		variable vready, vnready : std_logic;
  	begin 
    	vready  := '0';
		vnready := '0';
		
		if (rst = '0') then
			state       <= "000";
   			outp.ready  <= vready;
			outp.nready <= vnready;
		elsif clk'event and clk = '1' then 
    		
    		if (inp.flush = '1') then
				state <= "000";
			elsif (holdn = '0') then
				state <= state;
			else
		    	case state is
					-- ON ATTEND LA COMMANDE DE START
    				when "000" =>
						if (inp.start = '1') then 
							A <= inp.op1(31 downto 0);
							B <= inp.op2(31 downto 0);
							state <= "001";
							--printmsg("(PGDC) THE START SIGNAL IS UP");
							--if ( (inp.op1(30) /= '-') AND (inp.op1(30) /= 'X') AND (inp.op1(30) /= 'U')) then
							--	printmsg("(PGDC) ===> (OP1) MEMORISATION PROCESS (" & to_int_str(inp.op1(31 downto 0),6) & ")");
							--end if;
							--if ( (inp.op2(30) /= '-') AND (inp.op2(30) /= 'X') AND (inp.op2(30) /= 'U')) then
							--	printmsg("(PGDC) ===> (OP2) MEMORISATION PROCESS (" & to_int_str(inp.op2(31 downto 0),6) & ")");
							--end if;
						else
							state <= "000";
							A <= A;
							B <= B;
						end if;

					-- ON COMMENCE LE CALCUL
    				when "001" =>
						--printmsg("(PGDC) INPUT DATA READING");
						--if ( (inp.op1(30) /= '-') AND (inp.op1(30) /= 'X') AND (inp.op1(30) /= 'U')) then
						--	printmsg("(PGDC) ===> (OP1) MEMORISATION PROCESS (" & to_int_str(inp.op1(31 downto 0),6) & ")");
						--end if;
						--if ( (inp.op2(30) /= '-') AND (inp.op2(30) /= 'X') AND (inp.op2(30) /= 'U')) then
						--	printmsg("(PGDC) ===> (OP2) MEMORISATION PROCESS (" & to_int_str(inp.op2(31 downto 0),6) & ")");
						--end if;
						A <= inp.op1(31 downto 0);
						B <= inp.op2(31 downto 0);
						state <= "011";

					-- ON COMMENCE LE CALCUL
    				when "010" =>
						if( SIGNED(A) > SIGNED(B) ) then
							A <= STD_LOGIC_VECTOR(SIGNED(A) - SIGNED(B));
						else
							B <= STD_LOGIC_VECTOR(SIGNED(B) - SIGNED(A));
						end if;
						state <= "011";


					-- ON TEST LES DONNEES (FIN D'ITERATION)
    				when "011" =>
						if(SIGNED(A) = SIGNED(B)) then
							state   <= "100";
							vnready := '1';
						elsif( SIGNED(A) = TO_SIGNED(0,32) ) then
							state   <= "100";
							vnready := '1';
						elsif( SIGNED(B) = TO_SIGNED(0,32) ) then
							A <= STD_LOGIC_VECTOR(TO_SIGNED(0,32));
							state   <= "100";
							vnready := '1';
						else
							state <= "010";
						end if;

    				when "100" =>
						--printmsg("(PGDC) ===> COMPUTATION IS NOW FINISHED (" & to_int_str(A,6) & ")");
						-- ON INDIQUE QUE LE RESULTAT EST PRET
						vready := '1';

						-- ON RETOURNE DANS L'ETAT INTIAL
						state <= "000";
						
    				when others =>
						state <= "000";
    			end case;

    			outp.ready  <= vready;
				outp.nready <= vnready;
			end if; 	-- if reset
    	end if;		-- if clock
  	end process;
	-------------------------------------------------------------------------

	outp.result <= A;
    outp.icc    <= "0000";

end; 