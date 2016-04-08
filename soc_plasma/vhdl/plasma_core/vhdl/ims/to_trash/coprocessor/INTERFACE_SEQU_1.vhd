library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library grlib;
--use grlib.stdlib.all;

library ims;
use ims.coprocessor.all;
use ims.conversion.all;

entity INTERFACE_SEQU_1 is
port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    holdn   : in  std_ulogic;
    inp     : in  sequential32_in_type;
    outp    : out sequential32_out_type
);
end;

architecture rtl of INTERFACE_SEQU_1 is

	-------------------------------------------------------------------------
	-- PRAGMA BEGIN DECLARATION
	-- PRAGMA END DECLARATION
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
	-- PRAGMA BEGIN SIGNAL
	-- PRAGMA END SIGNAL
	-------------------------------------------------------------------------
	
	SIGNAL INPUT_1    : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL INPUT_2    : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL FLUSH      : STD_LOGIC;
	SIGNAL START      : STD_LOGIC;
	SIGNAL dInstr     : STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL aInstr     : STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL eInstr     : STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL mInstr     : STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL op1d    	  : std_logic_vector(1 downto 0);
	SIGNAL op3d       : std_logic_vector(5 downto 0);
	SIGNAL op1a    	  : std_logic_vector(1 downto 0);
	SIGNAL op3a       : std_logic_vector(5 downto 0);
	SIGNAL op1e    	  : std_logic_vector(1 downto 0);
	SIGNAL op3e       : std_logic_vector(5 downto 0);

	SIGNAL holdI      : std_logic;

	SIGNAL gclock    : std_logic;
	SIGNAL gValue    : std_logic;
	SIGNAL gpipeline : std_logic; -- a, e, m
	
BEGIN

	-- ON SIMPLIFIE LE CODE POUR LA SUITE
	INPUT_1 <= inp.op1(31 downto 0);
	INPUT_2 <= inp.op2(31 downto 0);
	FLUSH   <= inp.flush;

  	DELAY_START : process(clk, rst)
  	BEGIN 
		IF (rst = '0') then
			START   <= '0';
		ELSE
			START   <= inp.start;
		END IF;
  	END PROCESS;
	
	dInstr  <= inp.dInstr(13 downto 5);
	aInstr  <= inp.aInstr(13 downto 5);
	eInstr  <= inp.eInstr(13 downto 5);
	mInstr  <= inp.mInstr(13 downto 5);

    -- op1d    <= inp.dInstr(31 downto 30);
    -- op3d    <= inp.dInstr(24 downto 19);

    -- op1a    <= inp.aInstr(31 downto 30);
    -- op3a    <= inp.aInstr(24 downto 19);

    -- op1e    <= inp.eInstr(31 downto 30);
    -- op3e    <= inp.eInstr(24 downto 19);
	
	-------------------------------------------------------------------------
	--
	-- VERSION FONCTIONNELLE DU PIPELINE ...
	--
  	--GATED_CLOCK : process(clk, rst)
  	--BEGIN 
	--	if (rst = '0') then
	--		gpipeline  <= '0';
	--	elsif clk'event and clk = '1' then 
	--		if HOLDn = '0' then
	--			gpipeline <= gpipeline;
	--		else
	--			gpipeline <= (aInstr(2) AND START) OR (gpipeline AND (NOT nREADY_3));
	--		end if;
	--	end if;
  	--END PROCESS;
	--gclock <= clk and (gpipeline OR (aInstr(2) AND START)); --gpipeline(0) OR gpipeline(1) OR gpipeline(2) OR (aInstr(2) AND START);

	
	
	--PROCESS( gclock )
	--BEGIN
		--if clk'event and clk = '1' then 
			--printmsg("(SEQ1) => (GCLOCK) VALUE (" & to_bin_str(gpipeline(0) & gpipeline(1) & gpipeline(2) & aInstr(2) & START & gclock) & ")");
			--if gclock = '1' then 
				--REPORT "(PGDC) CLOCK ENABLE (1)";
			--elsif gclock = '0' then 
				--REPORT "(PGDC) CLOCK DISABLE (1)";
			--else
				--REPORT "(PGDC) CLOCK XXXXXXX (1)";
			--end if;
		--end if;
  	--END PROCESS;

	--PROCESS( gpipeline )
	--BEGIN
		--if gpipeline'event then 
			--printmsg("(SEQ1) => (GCLOCK) VALUE (" & to_bin_str(gpipeline(0) & gpipeline(1) & gpipeline(2) & aInstr(2) & START & gclock) & ")");
			--if gpipeline = '1' then 
				--REPORT "(PGDC) gpipeline ENABLE (1)";
			--elsif gpipeline = '0' then 
				--REPORT "(PGDC) gpipeline DISABLE (1)";
			--else
				--REPORT "(PGDC) CLOCK XXXXXXX (1)";
			--end if;
		--end if;
  	--END PROCESS;


	--WITH gpipeline SELECT
	--	gclock <= '0' WHEN "000", '1' WHEN OTHERS;
	
	-------------------------------------------------------------------------

	-- PROCESS( inp )
	-- BEGIN
	-- if clk'event and clk = '1' then 
		-- IF inp.start = '1' THEN REPORT "(INT) inp.start = '1'"; END IF;

		-- IF( (inp.dInstr(31 downto 30) = "10") AND (inp.dInstr(24 downto 19) = "101111") ) THEN
			-- IF  (dInstr(0) AND inp.start) = '1' THEN REPORT "(INT) dSTART TO DIVIDER"; END IF;
			-- IF  (dInstr(1) AND inp.start) = '1' THEN REPORT "(INT) dSTART TO MODULUS"; END IF;
			-- IF  (dInstr(2) AND inp.start) = '1' THEN REPORT "(INT) dSTART TO PGCD";    END IF;
			-- IF ((dInstr(2) AND inp.start) = '1') AND (holdn = '0') THEN REPORT "(INT) dSTART AND holdN"; END IF;
			-- printmsg("(INT) dSTART MEMORISATION PROCESS (" & to_int_str(INPUT_1,6) & ")");
			-- printmsg("(INT) dSTART MEMORISATION PROCESS (" & to_int_str(INPUT_2,6) & ")");
			-- printmsg("(INT) dSTART INSTRUCTION          (" & to_bin_str(dInstr) & ")");
		-- END IF;
	
		-- IF START(0) = '1' THEN REPORT "(INT) aSTART = '1'"; END IF;
		-- case op1a is
			-- when "10" =>
				-- case op3a is
					-- when "101111"   => 
						-- IF  (START(0) AND aInstr(0)) = '1' THEN REPORT "(INT) aSTART TO DIVIDER"; END IF;
						-- IF  (START(0) AND aInstr(1)) = '1' THEN REPORT "(INT) aSTART TO MODULUS"; END IF;
						-- IF  (START(0) AND aInstr(2)) = '1' THEN REPORT "(INT) aSTART TO PGCD";    END IF;
						-- IF ((START(0) AND aInstr(2)) = '1') AND (holdn = '0') THEN REPORT "(INT) aSTART AND holdN"; END IF;
						-- printmsg("(INT) aSTART MEMORISATION PROCESS (" & to_int_str(INPUT_1,6) & ")");
						-- printmsg("(INT) aSTART MEMORISATION PROCESS (" & to_int_str(INPUT_2,6) & ")");
						-- printmsg("(INT) aSTART INSTRUCTION          (" & to_bin_str(aInstr) & ")");
					-- when others => null;
				-- end case;
			-- when others => null;
		-- end case;
	
		-- IF START(1) = '1' THEN REPORT "(INT) eSTART = '1'"; END IF;
		-- case op1e is
			-- when "10" =>
				-- case op3e is
					-- when "101111"   => 
						-- IF  (START(1) AND eInstr(0)) = '1' THEN REPORT "(INT) eSTART TO DIVIDER"; END IF;
						-- IF  (START(1) AND eInstr(1)) = '1' THEN REPORT "(INT) eSTART TO MODULUS"; END IF;
						-- IF  (START(1) AND eInstr(2)) = '1' THEN REPORT "(INT) eSTART TO PGCD";    END IF;
						-- IF ((START(1) AND eInstr(2)) = '1') AND (holdn = '0') THEN REPORT "(INT) eSTART AND holdN"; END IF;
						-- printmsg("(INT) eSTART MEMORISATION PROCESS (" & to_int_str(INPUT_1,6) & ")");
						-- printmsg("(INT) eSTART MEMORISATION PROCESS (" & to_int_str(INPUT_2,6) & ")");
						-- printmsg("(INT) eSTART INSTRUCTION          (" & to_bin_str(eInstr) & ")");
					-- when others => null;
				-- end case;
			-- when others => null;
		-- end case;
	-- end if;
	-- end process;	
	
	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN START_SIGNAL_GENERATION
	-- PRAGMA END START_SIGNAL_GENERATION
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	-- PRAGMA BEGIN INSTANCIATION
	-- PRAGMA END INSTANCIATION
	-------------------------------------------------------------------------

	
	-------------------------------------------------------------------------
	-- PRAGMA BEGIN RESULT SELECTION
	-- PRAGMA END RESULT SELECTION
	-------------------------------------------------------------------------


	-------------------------------------------------------------------------
	-- PRAGMA BEGIN READY_SIGNAL_SELECTION
	-- PRAGMA END READY_SIGNAL_SELECTION
	-------------------------------------------------------------------------
	
END; 
