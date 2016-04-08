library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

--  
-- LES DONNEES ARRIVENT SOUS LA FORME (0x00 & B & G & R)
-- ET ELLES RESSORTENT SOUS LA FORME  (0x00 & V & U & Y)
--
entity RGB_2_Y is 
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
end RGB_2_Y; 

architecture rtl of RGB_2_YUV is
	constant s_rgb_30  : UNSIGNED(11 downto 0) := "001001100100";
	constant s_rgb_59  : UNSIGNED(11 downto 0) := "010010110010";
	constant s_rgb_11  : UNSIGNED(11 downto 0) := "000011101001";

   SIGNAL INPUT_R : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL INPUT_G : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL INPUT_B : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL INPUT_Y : STD_LOGIC_VECTOR(7 downto 0);

   SIGNAL s_rgb_out_y     : UNSIGNED(19 downto 0) := (others => '0');
   SIGNAL rgb_in_r_reg_Y  : UNSIGNED(19 downto 0):= (others => '0');
   SIGNAL rgb_in_g_reg_Y  : UNSIGNED(19 downto 0):= (others => '0');
   SIGNAL rgb_in_b_reg_Y  : UNSIGNED(19 downto 0):= (others => '0');
	
begin

   INPUT_R  <= INPUT_1( 7 downto  0);
   INPUT_G  <= INPUT_1(15 downto  8);
   INPUT_B  <= INPUT_1(23 downto 16);

	OUTPUT_1 <= "000000000000000000000000" & INPUT_Y;

	process(INPUT_R, INPUT_G, INPUT_B)
	begin
		rgb_in_r_reg_Y  <= s_rgb_30 * UNSIGNED(INPUT_R);
		rgb_in_g_reg_Y  <= s_rgb_59 * UNSIGNED(INPUT_G);
		rgb_in_b_reg_Y  <= s_rgb_11 * UNSIGNED(INPUT_B);
		s_rgb_out_y     <=              rgb_in_r_reg_Y   + (rgb_in_g_reg_Y  + rgb_in_b_reg_Y);
		INPUT_Y         <= STD_LOGIC_VECTOR(s_rgb_out_y(19 downto 12));
	end process;
 

end rtl;
