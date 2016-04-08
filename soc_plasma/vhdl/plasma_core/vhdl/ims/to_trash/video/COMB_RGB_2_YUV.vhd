library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

--  
-- LES DONNEES ARRIVENT SOUS LA FORME (0x00 & B & G & R)
-- ET ELLES RESSORTENT SOUS LA FORME  (0x00 & V & U & Y)
--
entity COMB_RGB_2_YUV is 
	port(
		INPUT_1	: in  STD_LOGIC_VECTOR(31 downto 0); 
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	); 
end COMB_RGB_2_YUV; 

architecture rtl of COMB_RGB_2_YUV is
	constant s_rgb_30  : UNSIGNED(11 downto 0) := "001001100100";
	constant s_rgb_59  : UNSIGNED(11 downto 0) := "010010110010";
	constant s_rgb_11  : UNSIGNED(11 downto 0) := "000011101001";
	constant s_rgb_17  : UNSIGNED(11 downto 0) := "000101011001";
	constant s_rgb_33  : UNSIGNED(11 downto 0) := "001010100110";
	constant s_rgb_50  : UNSIGNED(11 downto 0) := "010000000000";
	constant s_rgb_42  : UNSIGNED(11 downto 0) := "001101011001";
	constant s_rgb_08  : UNSIGNED(11 downto 0) := "000010100110";
	constant s_rgb_128 :   SIGNED(11 downto 0) := TO_SIGNED(128, 20);
begin

	process(INPUT_1)
	   VARIABLE INPUT_R : UNSIGNED(7 downto 0);
	   VARIABLE INPUT_G : UNSIGNED(7 downto 0);
	   VARIABLE INPUT_B : UNSIGNED(7 downto 0);

	   VARIABLE rgb_in_r_reg_Y  : UNSIGNED(19 downto 0):= (others => '0');
	   VARIABLE rgb_in_g_reg_Y  : UNSIGNED(19 downto 0):= (others => '0');
	   VARIABLE rgb_in_b_reg_Y  : UNSIGNED(19 downto 0):= (others => '0');
	   VARIABLE rgb_in_r_reg_Cb : UNSIGNED(19 downto 0):= (others => '0');
	   VARIABLE rgb_in_g_reg_Cb : UNSIGNED(19 downto 0):= (others => '0');
	   VARIABLE rgb_in_b_reg_Cb : UNSIGNED(19 downto 0):= (others => '0');
	   VARIABLE rgb_in_r_reg_Cr : UNSIGNED(19 downto 0):= (others => '0');
	   VARIABLE rgb_in_g_reg_Cr : UNSIGNED(19 downto 0):= (others => '0');
	   VARIABLE rgb_in_b_reg_Cr : UNSIGNED(19 downto 0):= (others => '0');
		
	   VARIABLE s_rgb_out_y  : SIGNED(20 downto 0):= (others => '0');
	   VARIABLE s_rgb_out_cb : SIGNED(20 downto 0):= (others => '0');
	   VARIABLE s_rgb_out_cr : SIGNED(20 downto 0):= (others => '0');

	   VARIABLE INPUT_Y : SIGNED(8 downto 0);
	   VARIABLE INPUT_U : SIGNED(8 downto 0);
	   VARIABLE INPUT_V : SIGNED(8 downto 0);
		
	begin
		-- ON ISOLE L'INFORMATION UTILE
		INPUT_R  := UNSIGNED(INPUT_1( 7 downto  0));
		INPUT_G  := UNSIGNED(INPUT_1(15 downto  8));
		INPUT_B  := UNSIGNED(INPUT_1(23 downto 16));

		-- ON REALISE TOUTES LES MULTIPLICATIONS PAR DES VALEURS CONSTANTES
		rgb_in_r_reg_Y  := s_rgb_30 * INPUT_R; -- RESULTAT SUR 20 BITS
		rgb_in_g_reg_Y  := s_rgb_59 * INPUT_G; -- RESULTAT SUR 20 BITS
		rgb_in_b_reg_Y  := s_rgb_11 * INPUT_B; -- RESULTAT SUR 20 BITS
		rgb_in_r_reg_Cb := s_rgb_17 * INPUT_R; -- RESULTAT SUR 20 BITS
		rgb_in_g_reg_Cb := s_rgb_33 * INPUT_G; -- RESULTAT SUR 20 BITS
		rgb_in_b_reg_Cb := s_rgb_50 * INPUT_B; -- RESULTAT SUR 20 BITS
		rgb_in_r_reg_Cr := s_rgb_50 * INPUT_R; -- RESULTAT SUR 20 BITS
		rgb_in_g_reg_Cr := s_rgb_42 * INPUT_G; -- RESULTAT SUR 20 BITS
		rgb_in_b_reg_Cr := s_rgb_08 * INPUT_B; -- RESULTAT SUR 20 BITS

		-- ON SOMME COMME IL CONVIENT TOUS LES RESULTATS TEMPORAIRES
		s_rgb_out_y  :=              SIGNED('0' & rgb_in_r_reg_Y)   + (SIGNED('0' & rgb_in_g_reg_Y)  + SIGNED('0' & rgb_in_b_reg_Y));
		s_rgb_out_cb := (s_rgb_128 - SIGNED('0' & rgb_in_r_reg_Cb)) - (SIGNED('0' & rgb_in_g_reg_Cb) + SIGNED('0' & rgb_in_b_reg_Cb));
		s_rgb_out_cr := (s_rgb_128 + SIGNED('0' & rgb_in_r_reg_Cr)) - (SIGNED('0' & rgb_in_g_reg_Cr) - SIGNED('0' & rgb_in_b_reg_Cr));

		-- ON RECUPERE SEULEMENT LES BITS QUI NOUS INTERESSENT
		INPUT_Y := s_rgb_out_y (20 downto 12);
		INPUT_U := s_rgb_out_cb(20 downto 12);
		INPUT_V := s_rgb_out_cr(20 downto 12);

		-- ON REALISE LA SATURATION DES DONNEES ENTRE 0 ET 255
		if ( INPUT_Y > TO_SIGNED(255, 9) ) then INPUT_Y := TO_SIGNED(255, 9); elsif ( INPUT_Y < TO_SIGNED(0, 9) ) then INPUT_Y := TO_SIGNED(0, 9); end if;
		if ( INPUT_U > TO_SIGNED(255, 9) ) then INPUT_U := TO_SIGNED(255, 9); elsif ( INPUT_U < TO_SIGNED(0, 9) ) then INPUT_U := TO_SIGNED(0, 9); end if;
		if ( INPUT_V > TO_SIGNED(255, 9) ) then INPUT_V := TO_SIGNED(255, 9); elsif ( INPUT_V < TO_SIGNED(0, 9) ) then INPUT_V := TO_SIGNED(0, 9); end if;

		-- ON GENERE LA SORTIE DU COMPOSANT
		OUTPUT_1 <= "00000000" & STD_LOGIC_VECTOR(INPUT_V(7 downto 0)) & STD_LOGIC_VECTOR(INPUT_U(7 downto 0)) & STD_LOGIC_VECTOR(INPUT_Y(7 downto 0));
		
	end process;
 
end rtl;
