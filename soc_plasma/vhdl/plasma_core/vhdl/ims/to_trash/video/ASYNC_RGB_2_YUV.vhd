library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

--library ims;
--use ims.coprocessor.all;
--use ims.conversion.all;

--  
-- LES DONNEES ARRIVENT SOUS LA FORME (0x00 & B & G & R)
-- ET ELLES RESSORTENT SOUS LA FORME  (0x00 & V & U & Y)
--
entity ASYNC_RGB_2_YUV is 
	port(
		rst		   : in  STD_LOGIC; 
		clk		   : in  STD_LOGIC; 
		flush      : in  std_logic;
		holdn      : in  std_ulogic;
		INPUT_1	   : in  STD_LOGIC_VECTOR(31 downto 0); 
		write_en   : in  std_logic;
		in_full    : out  std_logic;
		OUTPUT_1   : out STD_LOGIC_VECTOR(31 downto 0);
		read_en    : in  std_logic;
		out_empty  : out  std_logic;
		Next_Empty : out  std_logic
	); 
end ASYNC_RGB_2_YUV; 

architecture rtl of ASYNC_RGB_2_YUV is

    COMPONENT CUSTOM_FIFO
    PORT(
        rst        : IN  std_logic;
        clk        : IN  std_logic;
        flush      : IN  std_logic;
        holdn      : IN  std_logic;
        INPUT_1    : IN  std_logic_vector(31 downto 0);
        write_en   : IN  std_logic;
        in_full    : OUT  std_logic;
        OUTPUT_1   : OUT  std_logic_vector(31 downto 0);
        read_en    : IN  std_logic;
        out_empty  : OUT  std_logic;
        Next_Empty : OUT  std_logic
    );
    END COMPONENT;

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

	signal AFTER_FIFO   : STD_LOGIC_VECTOR(31 downto 0);
	signal READ_INP     : STD_LOGIC;
	signal INPUT_EMPTY  : STD_LOGIC;
	signal INPUT_nEMPTY : STD_LOGIC;
	
	signal BEFORE_FIFO : STD_LOGIC_VECTOR(31 downto 0);
	signal WRITE_OUTP  : STD_LOGIC;
	signal OUTPUT_FULL : STD_LOGIC;

	signal START_COMPUTE : STD_LOGIC;


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


	inFifo: CUSTOM_FIFO PORT MAP (
        rst        => rst,
        clk        => clk,
        flush      => '0',
        holdn      => '0',
        INPUT_1    => INPUT_1,
        write_en   => write_en,
        in_full    => in_full,
        OUTPUT_1   => AFTER_FIFO,
        read_en    => READ_INP,
        out_empty  => INPUT_EMPTY,
        Next_Empty => INPUT_nEMPTY
    );


	ouFIFO: CUSTOM_FIFO PORT MAP (
        rst        => rst,
        clk        => clk,
        flush      => '0',
        holdn      => '0',
        INPUT_1    => BEFORE_FIFO,
        write_en   => WRITE_OUTP,
        in_full    => OUTPUT_FULL,
        OUTPUT_1   => OUTPUT_1,
        read_en    => read_en,
        out_empty  => out_empty,
        Next_Empty => Next_Empty
    );

	-- ON MAPPE LES E/S DU CIRCUIT SUR LES E/S DES FIFOS
   INPUT_R     <= AFTER_FIFO( 7 downto  0);
   INPUT_G     <= AFTER_FIFO(15 downto  8);
   INPUT_B     <= AFTER_FIFO(23 downto 16);
	BEFORE_FIFO <= "00000000" & INPUT_V & INPUT_U & INPUT_Y;

	WRITE_OUTP	<= PIPE_START(2);
	
	process(rst, clk)
	begin
		if rst = '0' then
			--REPORT "RESET";
			INPUT_Y <= (others => '0');
			INPUT_U <= (others => '0');
			INPUT_V <= (others => '0');
			PIPE_START    <= "0000";
			START_COMPUTE <= '0';
			READ_INP      <= '0';

     elsif clk'event and clk = '1' then
			START_COMPUTE <= not INPUT_nEMPTY;
			READ_INP      <= not INPUT_nEMPTY; --START_COMPUTE;
			PIPE_START    <= PIPE_START(2 downto 0) & START_COMPUTE;

			-- ON MULTIPLIE LES DONNEES ENTRANTES PAR LES CONSTANTES
			-- CODEES EN VIRGULE FIXE
         if START_COMPUTE = '1' then
				--REPORT "RUNNING FIRST SLICE...";
				--printmsg("(PGDC) ===> (001) DATA ARE (" & to_int_str(INPUT_B,6) & ", " & to_int_str(INPUT_G,6) & ", " & to_int_str(INPUT_R,6) & ")");
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

			if PIPE_START(0) = '1' then
				--REPORT "RUNNING SECOND SLICE...";
				s_rgb_out_y  <=              rgb_in_r_reg_Y   + (rgb_in_g_reg_Y  + rgb_in_b_reg_Y);
				s_rgb_out_cb <= (s_rgb_128 - rgb_in_r_reg_Cb) - (rgb_in_g_reg_Cb + rgb_in_b_reg_Cb);
				s_rgb_out_cr <= (s_rgb_128 + rgb_in_r_reg_Cr) - (rgb_in_g_reg_Cr - rgb_in_b_reg_Cr);
			end if;

			if PIPE_START(1) = '1' then
				--REPORT "RUNNING THIRD SLICE...";
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
	end process;
 
 --process(INPUT_Y, INPUT_U, INPUT_V)
 --BEGIN
--	printmsg("(PGDC) ===> (111) DATA ARE (" & to_int_str(INPUT_V,6) & ", " & to_int_str(INPUT_U,6) & ", " & to_int_str(INPUT_Y,6) & ")");
 --END PROCESS;
 
end rtl;
