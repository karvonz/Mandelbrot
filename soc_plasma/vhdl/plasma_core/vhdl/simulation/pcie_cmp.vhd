LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

LIBRARY work;
USE work.txt_util.ALL;
USE work.conversion.ALL;

ENTITY PCIE_CMP IS
    PORT(
	clk	   : IN STD_LOGIC;
	INPUT	   : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	data_valid : IN STD_LOGIC
	);
END;

ARCHITECTURE logic OF PCIE_CMP IS
BEGIN

    PROCESS
	FILE data_file	     : TEXT OPEN read_mode IS "pcie_out_ref.txt";
	FILE test_status     : TEXT OPEN write_mode IS "status.txt";
	VARIABLE data_line   : STRING(1 TO 32);
	VARIABLE TMP_DATA    : STD_LOGIC_VECTOR (31 DOWNTO 0);
	VARIABLE counter     : INTEGER := 0;
	VARIABLE ErrDetected : INTEGER := 0;
	VARIABLE WarDetected : INTEGER := 0;
	VARIABLE EquDetected : INTEGER := 0;
    BEGIN
	WHILE NOT endfile(data_file) LOOP
	    WAIT UNTIL RISING_EDGE(CLK);

	    IF data_valid = '1' THEN
		--
		-- ON LIT UNE INFORMATION PROVENANT DU FICHIER
		--
		str_read(data_file, data_line);
		TMP_DATA := TO_STD_LOGIC_VECTOR(data_line(1 TO 32));
		counter  := counter + 1;
		
		IF TMP_DATA = INPUT THEN
		    EquDetected := EquDetected + 1;
		ELSE
		    WarDetected := WarDetected + 1;
		    ErrDetected := ErrDetected + 1;
		    REPORT "   => ERROR DETECTED FOR DATA " & INTEGER'IMAGE(counter-1) SEVERITY note;
		    REPORT "      +> REFERENCE DATA " & to_bin_str(TMP_DATA) SEVERITY note;
		    REPORT "      +> PRODUCED  DATA " & to_bin_str(INPUT)    SEVERITY note;
		END IF;

		IF (counter MOD 10) = 0 THEN
		    IF (ErrDetected /= 0) OR (WarDetected /= 0) THEN
			REPORT " + DATA COMPARED = " & INTEGER'IMAGE(counter)     & " / IDENTIQUE = " & INTEGER'IMAGE(EquDetected) & " / ERREURS   = " & INTEGER'IMAGE(ErrDetected) & " / " SEVERITY note;
		    ELSE
			REPORT " + DATA COMPARED = " & INTEGER'IMAGE(counter)     & " / IDENTIQUE = " & INTEGER'IMAGE(EquDetected) SEVERITY note;
		    END IF;
		END IF;

		--
		-- ON ESSAYE DE DETERMINER SI L'ON A TERMINE LE TESTBENCH (PLUS DE VALEUR DISPONIBLE)
		--
		IF endfile(data_file) THEN
		
			--
			-- ON MEMORISE DANS UN FICHIER EXTERNE LE RESULTAT DU TESTBENCH AFIN DE SIMPLIFIER LA
			-- CONCEPTION DE TESTS DE NON REGRESSION !
			--
			IF (ErrDetected /= 0) THEN 
				WRITE( test_status, "FAILURE (ERROR(s))");
				REPORT "     - ERREURS  = " & to_int_str(int_to_slv(ErrDetected)) & " for the testbench " SEVERITY note;
			ELSIF (WarDetected /= 0) THEN
				WRITE( test_status, "FAILURE (WARNING(s))");
				REPORT "     - WARNINGS = " & to_int_str(int_to_slv(WarDetected)) & " for the testbench " SEVERITY note;
			ELSE
				WRITE( test_status, "SUCCESS");
			END IF;
		
		    REPORT "END OF FILE DETECTED !" SEVERITY failure;
		END IF;
		
	    END IF;
	END LOOP;
	
	

	ASSERT false REPORT "IT IS GOOD" SEVERITY failure;
	--
	-- FIN DE FICHIER EXTERNE
	--
	
    END PROCESS;

END;
