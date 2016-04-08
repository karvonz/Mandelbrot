----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:38:59 01/04/2010 
-- Design Name: 
-- Module Name:    FiltreFIR_9taps - Behavioral 
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

ENTITY LWT_FIR1 is
	PORT (
		rst		 : in  STD_LOGIC; 
		clk		 : in  STD_LOGIC; 
		start	    : in  STD_LOGIC; 
		flush     : in  std_logic;
		holdn     : in  std_ulogic;
		INPUT_1	 : in  STD_LOGIC_VECTOR(31 downto 0); 
		ready     : out std_logic;
		nready    : out std_logic;
		icc       : out std_logic_vector(3  downto 0);
		OUTPUT_1  : out STD_LOGIC_VECTOR(31 downto 0)
	);
end LWT_FIR1;


architecture Behavioral of LWT_FIR1 is
	CONSTANT N   : INTEGER := 8;
	CONSTANT C   : INTEGER := 12;

	SIGNAL memXn : SIGNED(N-1 downto 0);
	SIGNAL memX1 : SIGNED(N-1 downto 0);
	SIGNAL memX2 : SIGNED(N-1 downto 0);
	SIGNAL memX3 : SIGNED(N-1 downto 0);
	SIGNAL memX4 : SIGNED(N-1 downto 0);
	SIGNAL memX5 : SIGNED(N-1 downto 0);
	SIGNAL memX6 : SIGNED(N-1 downto 0);
	SIGNAL memX7 : SIGNED(N-1 downto 0);
	SIGNAL memX8 : SIGNED(N-1 downto 0);

	SIGNAL tm_1 : SIGNED(N+C-1 downto 0);
	SIGNAL tm_2 : SIGNED(N+C-1 downto 0);
	SIGNAL tm_3 : SIGNED(N+C-1 downto 0);
	SIGNAL tm_4 : SIGNED(N+C-1 downto 0);
	SIGNAL tm_5 : SIGNED(N+C-1 downto 0);
	SIGNAL tm_6 : SIGNED(N+C-1 downto 0);
	SIGNAL tm_7 : SIGNED(N+C-1 downto 0);
	SIGNAL tm_8 : SIGNED(N+C-1 downto 0);
	SIGNAL tm_9 : SIGNED(N+C-1 downto 0);

	SIGNAL t2_1 : SIGNED(N+C-1 downto 0);
	SIGNAL t2_2 : SIGNED(N+C-1 downto 0);
	SIGNAL t2_3 : SIGNED(N+C-1 downto 0);
	SIGNAL t2_4 : SIGNED(N+C-1 downto 0);
	SIGNAL t2_5 : SIGNED(N+C-1 downto 0);

	SIGNAL t3_1 : SIGNED(N+C-1 downto 0);
	SIGNAL t3_2 : SIGNED(N+C-1 downto 0);
	SIGNAL t3_3 : SIGNED(N+C-1 downto 0);

	SIGNAL t4_1 : SIGNED(N+C-1 downto 0);
	SIGNAL t4_2 : SIGNED(N+C-1 downto 0);

	SIGNAL START_PIPE : std_logic_vector(4 downto 0);

begin

	--
	-- GESTION DES SIGNAUX DE SYNCHRONISATION EN PROVENANCE DU SYSTEME
	--
	PROCESS( clk, rst )
	BEGIN
		IF (rst = '0') THEN
			START_PIPE <= (OTHERS => '0');
		ELSIF clk'event and clk = '1' THEN
    		IF (flush = '1') THEN
				START_PIPE <= (OTHERS => '0');
			ELSIF (holdn = '0') THEN
				START_PIPE <= START_PIPE;
			ELSE
				START_PIPE <= START_PIPE(3 downto 0) & start;
			END IF;
		END IF;
	END PROCESS;


	--
	-- ON CREE UNE TRANCHE DE PIPELINE POUR LES MULTIPLICATIONS
	--	
	PROCESS( clk, rst )
	BEGIN
		IF (rst = '0') THEN
			tm_1 <= (OTHERS => '0');
			tm_2 <= (OTHERS => '0');
			tm_3 <= (OTHERS => '0');
			tm_4 <= (OTHERS => '0');
			tm_5 <= (OTHERS => '0');
			tm_6 <= (OTHERS => '0');
			tm_7 <= (OTHERS => '0');
			tm_8 <= (OTHERS => '0');
			tm_9 <= (OTHERS => '0');
		ELSIF clk'event and clk = '1' then
			IF START_PIPE(0) = '1' THEN
				tm_1 <= TO_SIGNED( INTEGER( REAL(  0.02674874108097600 ) * REAL(2**(C-1)) ), C ) * memXn;
				tm_2 <= TO_SIGNED( INTEGER( REAL( -0.01686411844287495 ) * REAL(2**(C-1)) ), C ) * memX1;
				tm_3 <= TO_SIGNED( INTEGER( REAL( -0.07822326652898785 ) * REAL(2**(C-1)) ), C ) * memX2;
				tm_4 <= TO_SIGNED( INTEGER( REAL(  0.26686411844287230 ) * REAL(2**(C-1)) ), C ) * memX3;
				tm_5 <= TO_SIGNED( INTEGER( REAL(  0.60294901823635790 ) * REAL(2**(C-1)) ), C ) * memX4;
				tm_6 <= TO_SIGNED( INTEGER( REAL(  0.26686411844287230 ) * REAL(2**(C-1)) ), C ) * memX5;
				tm_7 <= TO_SIGNED( INTEGER( REAL( -0.07822326652898785 ) * REAL(2**(C-1)) ), C ) * memX6;
				tm_8 <= TO_SIGNED( INTEGER( REAL( -0.01686411844287495 ) * REAL(2**(C-1)) ), C ) * memX7;
				tm_9 <= TO_SIGNED( INTEGER( REAL(  0.02674874108097600 ) * REAL(2**(C-1)) ), C ) * memX8;
			ELSE
				tm_1 <= tm_1;
				tm_2 <= tm_2;
				tm_3 <= tm_3;
				tm_4 <= tm_4;
				tm_5 <= tm_5;
				tm_6 <= tm_6;
				tm_7 <= tm_7;
				tm_8 <= tm_8;
				tm_9 <= tm_9;
			END IF;
		END IF;
	END PROCESS;
	
		
	--
	-- ON CREE UNE TRANCHE DE PIPELINE POUR LES SOMMES PARTIELLES 1/4
	--	
	PROCESS( clk, rst )
	BEGIN
		IF (rst = '0') THEN
			t2_1 <= (OTHERS => '0');
			t2_2 <= (OTHERS => '0');
			t2_3 <= (OTHERS => '0');
			t2_4 <= (OTHERS => '0');
			t2_5 <= (OTHERS => '0');
		ELSIF clk'event and clk = '1' then
			IF START_PIPE(1) = '1' THEN
				t2_1 <= tm_1 + tm_2;
				t2_2 <= tm_3 + tm_4;
				t2_3 <= tm_5 + tm_6;
				t2_4 <= tm_7 + tm_8;
				t2_5 <= tm_9;
			ELSE
				t2_1 <= t2_1;
				t2_2 <= t2_2;
				t2_3 <= t2_3;
				t2_4 <= t2_4;
				t2_5 <= t2_5;
			END IF;
		END IF;
	END PROCESS;

	--
	-- ON CREE UNE TRANCHE DE PIPELINE POUR LES SOMMES PARTIELLES 2/4
	--	
	PROCESS( clk, rst )
	BEGIN
		IF (rst = '0') THEN
			t3_1 <= (OTHERS => '0');
			t3_2 <= (OTHERS => '0');
			t3_3 <= (OTHERS => '0');
		ELSIF clk'event and clk = '1' then
			IF START_PIPE(2) = '1' THEN
				t3_1 <= t2_1 + t2_2;
				t3_2 <= t2_3 + t2_4;
				t3_3 <= t2_5;
			ELSE
				t3_1 <= t3_1;
				t3_2 <= t3_2;
				t3_3 <= t3_3;
			END IF;
		END IF;
	END PROCESS;

	
	--
	-- ON CREE UNE TRANCHE DE PIPELINE POUR LES SOMMES PARTIELLES 3/4
	--	
	PROCESS( clk, rst )
		VARIABLE RESU : SIGNED(N+C-1 downto 0);
	BEGIN
		IF (rst = '0') THEN
			t4_1 <= (OTHERS => '0');
			t4_2 <= (OTHERS => '0');
		ELSIF clk'event and clk = '1' then
			IF START_PIPE(3) = '1' THEN
				t4_1 <= t3_1 + t3_2;
				t4_2 <= t3_3;
			ELSE
				t4_1 <= t4_1;
				t4_2 <= t4_2;
			END IF;
		END IF;
	END PROCESS;

			-- ON CREE UNE TRANCHE DE PIPELINE POUR LES GROUPES DE RESULTATS 8 BITS
	--
	-- ON CREE UNE TRANCHE DE PIPELINE POUR LES SOMMES PARTIELLES 1/4
	--	
	PROCESS( clk, rst )
		VARIABLE RESU : SIGNED(N+C-1 downto 0);
	BEGIN
		IF (rst = '0') THEN
			OUTPUT_1     <= (OTHERS => '0');
		ELSIF clk'event and clk = '1' then
			IF START_PIPE(4) = '1' THEN
				RESU := t4_1 + t4_2;
				OUTPUT_1 <= STD_LOGIC_VECTOR( RESIZE(RESU(N+C-1 downto C-1), 32) );
			END IF;
		END IF;
	END PROCESS;

	--
	-- ON REALISE LE VIEILLISSEMENT DES ECHANTILLONS DANS LE TEMPS
	--	
	PROCESS( clk, rst )
		VARIABLE RESU : SIGNED(N+C-1 downto 0);
	BEGIN
		IF (rst = '0') THEN
				memXn <= (OTHERS => '0');
				memX1 <= (OTHERS => '0');
				memX2 <= (OTHERS => '0');
				memX3 <= (OTHERS => '0');
				memX4 <= (OTHERS => '0');
				memX5 <= (OTHERS => '0');
				memX6 <= (OTHERS => '0');
				memX7 <= (OTHERS => '0');
				memX8 <= (OTHERS => '0');
		ELSIF clk'event and clk = '1' then
			IF START_PIPE(1) = '1' THEN
				memXn <= SIGNED(INPUT_1(7 DOWNTO 0));
				memX1 <= memXn;
				memX2 <= memX1;
				memX3 <= memX2;
				memX4 <= memX3;
				memX5 <= memX4;
				memX6 <= memX5;
				memX7 <= memX6;
				memX8 <= memX7;
			ELSE
				memXn <= memXn;
				memX1 <= memX1;
				memX2 <= memX2;
				memX3 <= memX3;
				memX4 <= memX4;
				memX5 <= memX5;
				memX6 <= memX6;
				memX7 <= memX7;
				memX8 <= memX8;
			END IF;
		END IF;
	END PROCESS;


end Behavioral;

