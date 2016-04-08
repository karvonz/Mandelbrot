library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library ims;
use ims.coprocessor.all;
use ims.conversion.all;

--  
-- LES DONNEES ARRIVENT SOUS LA FORME (0x00 & B & G & R)
-- ET ELLES RESSORTENT SOUS LA FORME  (0x00 & V & U & Y)
--
entity RGB_2_YUV is 
	port(
		rst		: in  STD_LOGIC; 
		clk		: in  STD_LOGIC; 
		start		: in  STD_LOGIC; 
		flush    : in  std_logic;
		holdn    : in  std_ulogic;
		INPUT_1	: in  STD_LOGIC_VECTOR(31 downto 0); 
		ready    : out std_logic;
		nready   : out std_logic;
		icc      : out std_logic_vector(3  downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	); 
end RGB_2_YUV; 

architecture rtl of RGB_2_YUV is
	constant s_rgb_30  : UNSIGNED(24 downto 0) := "0010011001000101101000011";
	constant s_rgb_59  : UNSIGNED(24 downto 0) := "0100101100100010110100001";
	constant s_rgb_11  : UNSIGNED(24 downto 0) := "0000111010010111100011010";
	constant s_rgb_17  : UNSIGNED(24 downto 0) := "0001010110011001010001011";
	constant s_rgb_33  : UNSIGNED(24 downto 0) := "0010101001100110101110100";
	constant s_rgb_50  : UNSIGNED(24 downto 0) := "0100000000000000000000000";
	constant s_rgb_42  : UNSIGNED(24 downto 0) := "0011010110010111101000100";
	constant s_rgb_08  : UNSIGNED(24 downto 0) := "0000101001101000010111011";
	constant s_rgb_128 : UNSIGNED(31 downto 0) := "10000000000000000000000000000000"; -- TO_UNSIGNED(128, 32); --"10000000000000000000000000000000";

	signal PIPE_START  : STD_LOGIC_VECTOR(3 downto 0);

   SIGNAL INPUT_R : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL INPUT_G : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL INPUT_B : STD_LOGIC_VECTOR(7 downto 0);

   SIGNAL INPUT_Y : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL INPUT_U : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL INPUT_V : STD_LOGIC_VECTOR(7 downto 0);

   SIGNAL s_rgb_out_y     : UNSIGNED(32 downto 0) := (others => '0');
   SIGNAL s_rgb_out_cb    : UNSIGNED(32 downto 0) := (others => '0');
   SIGNAL s_rgb_out_cr    : UNSIGNED(32 downto 0) := (others => '0');
   
   SIGNAL rgb_in_r_reg_Y  : UNSIGNED(32 downto 0):= (others => '0');
   SIGNAL rgb_in_g_reg_Y  : UNSIGNED(32 downto 0):= (others => '0');
   SIGNAL rgb_in_b_reg_Y  : UNSIGNED(32 downto 0):= (others => '0');
	
   SIGNAL rgb_in_r_reg_Cb : UNSIGNED(32 downto 0):= (others => '0');
   SIGNAL rgb_in_g_reg_Cb : UNSIGNED(32 downto 0):= (others => '0');
   SIGNAL rgb_in_b_reg_Cb : UNSIGNED(32 downto 0):= (others => '0');
	
   SIGNAL rgb_in_r_reg_Cr : UNSIGNED(32 downto 0):= (others => '0');
   SIGNAL rgb_in_g_reg_Cr : UNSIGNED(32 downto 0):= (others => '0');
   SIGNAL rgb_in_b_reg_Cr : UNSIGNED(32 downto 0):= (others => '0');

begin

   INPUT_R  <= INPUT_1( 7 downto  0);
   INPUT_G  <= INPUT_1(15 downto  8);
   INPUT_B  <= INPUT_1(23 downto 16);

	OUTPUT_1 <= "00000000" & INPUT_V & INPUT_U & INPUT_Y;

	-- NOUS NECESSITONS N CYCLES MAIS LE SIGNAL nREADY PEUT
	-- ETRE SOUMIS 2 CYCLES AVANT LA FIN ;-)
	nready <= PIPE_START(1);
	ready  <= PIPE_START(1) OR PIPE_START(0) OR start;
	icc    <= "0000";

	process(rst, clk)
	begin
     if rst = '0' then
		INPUT_Y <= (others => '0');
        INPUT_U <= (others => '0');
        INPUT_V <= (others => '0');
		PIPE_START    <= "0000";

     elsif rising_edge(clk) then

    		if (flush = '1') then
				PIPE_START <= "0000";

			elsif (holdn = '0') then
				PIPE_START <= PIPE_START;
	  
			else
			-- ON NE REAGIT PAS IMMEDIATEMENT LORSQUE L'ON RECOIT LE SIGNAL
			-- START CAR IL EST DELIVRE PAR L'ETAGE DE DECODAGE (LES ENTREES
			-- DU CALCUL NE SERONT DISPONIBLES QU'UN CYCLE APRES).
			PIPE_START <= PIPE_START(2 downto 0) & start;
			
			--if start = '1' then
				--REPORT "COMPUTATION START...";
				--printmsg("(RGB) ===> (000) COMPUTATION START...");
			--end if;

			-- ON MULTIPLIE LES DONNEES ENTRANTES PAR LES CONSTANTES
			-- CODEES EN VIRGULE FIXE
         if PIPE_START(0) = '1' then
				--REPORT "RUNNING FIRST SLICE...";
				--printmsg("(RGB) ===> (001) RUNNING FIRST SLICE...");
				--printmsg("(RGB) ===> (001) DATA ARE (" & to_int_str(INPUT_B,6) & ", " & to_int_str(INPUT_G,6) & ", " & to_int_str(INPUT_R,6) & ")");
				rgb_in_r_reg_Y  <= s_rgb_30 * UNSIGNED(INPUT_R);
				rgb_in_g_reg_Y  <= s_rgb_59 * UNSIGNED(INPUT_G);
				rgb_in_b_reg_Y  <= s_rgb_11 * UNSIGNED(INPUT_B);
				rgb_in_r_reg_Cb <= s_rgb_17 * UNSIGNED(INPUT_R);
				rgb_in_g_reg_Cb <= s_rgb_33 * UNSIGNED(INPUT_G);
				rgb_in_b_reg_Cb <= s_rgb_50 * UNSIGNED(INPUT_B);
				rgb_in_r_reg_Cr <= s_rgb_50 * UNSIGNED(INPUT_R);
				rgb_in_g_reg_Cr <= s_rgb_42 * UNSIGNED(INPUT_G);
				rgb_in_b_reg_Cr <= s_rgb_08 * UNSIGNED(INPUT_B);
			end if;

			if PIPE_START(1) = '1' then
				--REPORT "RUNNING SECOND SLICE...";
				--printmsg("(RGB) ===> (010) RUNNING SECOND SLICE...");
				s_rgb_out_y  <=              rgb_in_r_reg_Y   + (rgb_in_g_reg_Y  + rgb_in_b_reg_Y);
				s_rgb_out_cb <= (s_rgb_128 - rgb_in_r_reg_Cb) - (rgb_in_g_reg_Cb + rgb_in_b_reg_Cb);
				s_rgb_out_cr <= (s_rgb_128 + rgb_in_r_reg_Cr) - (rgb_in_g_reg_Cr - rgb_in_b_reg_Cr);
			end if;

			if PIPE_START(2) = '1' then
				--REPORT "RUNNING THIRD SLICE...";
				--printmsg("(RGB) ===> (011) RUNNING THIRD SLICE...");
				if (s_rgb_out_y(23)='1') then
					INPUT_Y <= STD_LOGIC_VECTOR(s_rgb_out_y(31 downto 24) + 1);
				else
					INPUT_Y <= STD_LOGIC_VECTOR(s_rgb_out_y(31 downto 24));
				end if;
            
				if (s_rgb_out_cb(23)='1') then
                INPUT_U <= STD_LOGIC_VECTOR(s_rgb_out_cb(31 downto 24) + 1);
            else
                INPUT_U <= STD_LOGIC_VECTOR(s_rgb_out_cb(31 downto 24));
            end if;
            
            if (s_rgb_out_cr(23)='1') then
                INPUT_V <= STD_LOGIC_VECTOR(s_rgb_out_cr(31 downto 24) + 1);
            else
                INPUT_V <= STD_LOGIC_VECTOR(s_rgb_out_cr(31 downto 24));
            end if;
				--printmsg("(PGDC) ===> (011) DATA Y = (" & to_int_str( STD_LOGIC_VECTOR(s_rgb_out_y (31 downto 24)),6) & ")");
				--printmsg("(PGDC) ===> (011) DATA U = (" & to_int_str( STD_LOGIC_VECTOR(s_rgb_out_cb(31 downto 24)),6) & ")");
				--printmsg("(PGDC) ===> (011) DATA V = (" & to_int_str( STD_LOGIC_VECTOR(s_rgb_out_cr(31 downto 24)),6) & ")");

         else
            INPUT_Y <= INPUT_Y;
            INPUT_U <= INPUT_U;
            INPUT_V <= INPUT_V;
         end if;
     end if;
     end if;
 end process;
 
 --process(INPUT_Y, INPUT_U, INPUT_V)
 --BEGIN
--	printmsg("(PGDC) ===> (111) DATA ARE (" & to_int_str(INPUT_V,6) & ", " & to_int_str(INPUT_U,6) & ", " & to_int_str(INPUT_Y,6) & ")");
 --END PROCESS;
 
end rtl;
