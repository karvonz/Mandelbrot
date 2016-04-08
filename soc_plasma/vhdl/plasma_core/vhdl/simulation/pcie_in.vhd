LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
--use work.mlite_pack.all;
-- The libraries ieee.std_logic_unsigned and std.textio will need to be included

LIBRARY work;
USE work.txt_util.ALL;

ENTITY PCIE_IN IS
    PORT(
	clk	      : IN  STD_LOGIC;
	fifo_out_data : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	fifo_compteur : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	fifo_read_en  : IN  STD_LOGIC;
	fifo_full     : OUT STD_LOGIC;
	fifo_empty    : OUT STD_LOGIC;
	fifo_valid    : OUT STD_LOGIC
	);
END;

ARCHITECTURE logic OF PCIE_IN IS
BEGIN

    PROCESS
	FILE data_file	   : TEXT OPEN read_mode IS "pcie_in.txt";
	VARIABLE data_line : STRING(1 TO 32);
    BEGIN
	REPORT "COUCOU" SEVERITY note;
	--
	-- ON REGARDE SI LE FICHIER EST FOURNI ...
	--
	IF NOT endfile(data_file) THEN
	    str_read(data_file, data_line);
	    fifo_out_data <= TO_STD_LOGIC_VECTOR(data_line(1 TO 32));
	    fifo_compteur <= STD_LOGIC_VECTOR(TO_UNSIGNED(1, 32));
	    fifo_full	  <= '0';
	    fifo_valid	  <= '1';
	    IF NOT endfile(data_file) THEN
		fifo_empty <= '0';
	    ELSE
		fifo_empty <= '1';
	    END IF;

	ELSE
	    fifo_out_data <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	    fifo_compteur <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32));
	    fifo_full	  <= '0';
	    fifo_valid	  <= '0';
	    fifo_empty	  <= '1';
	END IF;

	--
	-- TANT QU'IL RESTE DES DONNEES DANS LE FICHIER, ON ATTEND QUE LE PROCESSEUR
	-- VIENNE LES LIRE ...
	--
	WAIT UNTIL RISING_EDGE(CLK);

	WHILE NOT endfile(data_file) LOOP
	    WAIT UNTIL RISING_EDGE(CLK);
	    IF fifo_read_en = '1' THEN

		--
		-- ON SOUHAITE LE PASSAGE A LA DONNEE SUIVANTE.
		--
		fifo_out_data <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
		fifo_compteur <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32));
		fifo_valid    <= '0';
		fifo_empty    <= '1';
--		REPORT "Waiting N clock cycles" SEVERITY note;
--		WAIT UNTIL RISING_EDGE(CLK);
--		WAIT UNTIL RISING_EDGE(CLK);
--		WAIT UNTIL RISING_EDGE(CLK);
--		WAIT UNTIL RISING_EDGE(CLK);
--		WAIT UNTIL RISING_EDGE(CLK);
--		WAIT UNTIL RISING_EDGE(CLK);
--		WAIT UNTIL RISING_EDGE(CLK);
--		WAIT UNTIL RISING_EDGE(CLK);
--		WAIT UNTIL RISING_EDGE(CLK);
		WAIT UNTIL RISING_EDGE(CLK);

		IF NOT endfile(data_file) THEN
		    str_read(data_file, data_line);
		    fifo_out_data <= TO_STD_LOGIC_VECTOR(data_line(1 TO 32));
		    fifo_compteur <= STD_LOGIC_VECTOR(TO_UNSIGNED(1, 32));
		    fifo_valid	  <= '1';
		    fifo_empty	  <= '0';
		ELSE
		    fifo_out_data <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
		    fifo_compteur <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32));
		    fifo_valid	  <= '0';
		    fifo_empty	  <= '1';
		END IF;
	    END IF;
	END LOOP;

	WHILE endfile(data_file) LOOP
	    WAIT UNTIL RISING_EDGE(CLK);
	    IF fifo_read_en = '1' THEN
		fifo_valid <= '0';
		fifo_empty <= '1';
	    END IF;
	END LOOP;

	--
	-- UNE FOIS QUE TOUTES LES DONNEES ONT ETE TRAITEES, ON SE "BLOQUE"
	--
--		REPORT "## ON N'A PLUS DE DONNEES ##";
	WHILE endfile(data_file) LOOP
	    WAIT UNTIL rising_edge(clk);
	    fifo_valid <= '0';
	    fifo_empty <= '1';
--			if fifo_write_en = '1' then

--			end if;
	END LOOP;

    END PROCESS;

    --fifo_valid    <= '0';
    fifo_full <= '0';
    --fifo_compteur <= (OTHERS => '0');

END;  --architecture logic
