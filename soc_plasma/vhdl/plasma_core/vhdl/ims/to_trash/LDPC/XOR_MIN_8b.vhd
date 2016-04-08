library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library ims;
--use ims.coprocessor.all;

entity XOR_MIN_8b is
port (
    INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
    INPUT_2  : in  STD_LOGIC_VECTOR(31 downto 0);
    OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
);
end;

architecture rtl of XOR_MIN_8b is
begin

	-------------------------------------------------------------------------
  	PROCESS (INPUT_1, INPUT_2)
		VARIABLE rTemp1  : STD_LOGIC_VECTOR(7 downto 0);
		VARIABLE rTemp2  : STD_LOGIC_VECTOR(7 downto 0);
		VARIABLE rTemp3  : STD_LOGIC_VECTOR(7 downto 0);
		VARIABLE rTemp4  : STD_LOGIC_VECTOR(7 downto 0);
  	begin
		-- ON TRAITE LE PREMIER MOT DE 8 BITS CONTENU DANS LES OPERANDES
		if( UNSIGNED(INPUT_1( 6 downto  0)) < UNSIGNED(INPUT_2( 6 downto  0)) ) then rTemp1(6 downto 0) := INPUT_1(	6 downto  0);	else rTemp1(6 downto 0) := INPUT_2( 6 downto  0);	end if;
		rTemp1(7) := INPUT_1(7)  xor INPUT_2(7);

		-- ON TRAITE LE SECOND MOT DE 8 BITS CONTENU DANS LES OPERANDES
		if( UNSIGNED(INPUT_1(14 downto  8)) < UNSIGNED(INPUT_2(14 downto  8)) ) then rTemp2(6 downto 0) := INPUT_1(14 downto  8);	else rTemp2(6 downto 0) := INPUT_2(14 downto  8);	end if;
		rTemp2(7) := INPUT_1(15) xor INPUT_2(15);

		-- ON TRAITE LE TROISIEME MOT DE 8 BITS CONTENU DANS LES OPERANDES
		if( UNSIGNED(INPUT_1(22 downto 16)) < UNSIGNED(INPUT_2(22 downto 16)) ) then rTemp3(6 downto 0) := INPUT_1(22 downto 16);	else rTemp3(6 downto 0) := INPUT_2(22 downto 16);	end if;
		rTemp3(7) := INPUT_1(23) xor INPUT_2(23);

		-- ON TRAITE LE QUATRIEME MOT DE 8 BITS CONTENU DANS LES OPERANDES
		if( UNSIGNED(INPUT_1(30 downto 24)) < UNSIGNED(INPUT_2(30 downto 24)) ) then rTemp4(6 downto 0) := INPUT_1(30 downto 24);	else rTemp4(6 downto 0) := INPUT_2(30 downto 24);	end if;
		rTemp4(7) := INPUT_1(31) xor INPUT_2(31);
		
		-- ON REGROUPE LES 4 MOTS AFIN DE RECONSTITUER LE RESULTAT SUR 32 BITS
		OUTPUT_1 <= (rTemp4 & rTemp3 & rTemp2 & rTemp1);
	END PROCESS;
	-------------------------------------------------------------------------

end; 
