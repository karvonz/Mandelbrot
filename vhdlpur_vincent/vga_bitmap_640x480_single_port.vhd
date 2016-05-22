-------------------------------------------------------------------------------
-- Bitmap VGA display with 640x480 pixel resolution
-------------------------------------------------------------------------------
-- V 1.1.2 (2012/11/29)
--  Bertrand Le Gal (bertrand.legal@enseirb-matmeca.fr)
--  Some little modifications to support data reading 
--  from file for RAM initilization.
--
-- V 1.1.1 (2012/07/28)
--  Yannick Bornat (yannick.bornat@enseirb-matmeca.fr)
--
-- For more information on this module, refer to module page :
--  http://bornat.vvv.enseirb.fr/wiki/doku.php?id=en202:vga_bitmap
-- 
-- V1.1.1 :
--   - Comment additions
--   - Code cleanup
-- V1.1.0 :
--   - added capacity above 3bpp
--   - ability to display grayscale pictures
--   - Module works @ 100MHz clock frequency
-- V1.0.1 :
--   - Fixed : image not centered on screen
-- V1.0.0 :
--   - Initial release
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use std.textio.ALL;

entity VGA_bitmap_640x480 is
  port(--clk_vga          : in  std_logic;
		 clk_vga      : in  std_logic;
       reset        : in  std_logic;
       VGA_hs       : out std_logic;   -- horisontal vga syncr.
       VGA_vs       : out std_logic;   -- vertical vga syncr.
       iter      : out std_logic_vector(7 downto 0);   -- iter output
       ADDR1         : in  std_logic_vector(12 downto 0);
       data_in1      : in  std_logic_vector(7 downto 0);
       data_write1   : in  std_logic;
		 ADDR2         : in  std_logic_vector(12 downto 0);
       data_in2      : in  std_logic_vector(7 downto 0);
       data_write2   : in  std_logic;
		 ADDR3         : in  std_logic_vector(12 downto 0);
       data_in3      : in  std_logic_vector(7 downto 0);
       data_write3   : in  std_logic;
		 ADDR4         : in  std_logic_vector(12 downto 0);
       data_in4      : in  std_logic_vector(7 downto 0);
       data_write4   : in  std_logic;
		 ADDR5         : in  std_logic_vector(12 downto 0);
       data_in5      : in  std_logic_vector(7 downto 0);
       data_write5   : in  std_logic;
		 ADDR6         : in  std_logic_vector(12 downto 0);
       data_in6      : in  std_logic_vector(7 downto 0);
       data_write6   : in  std_logic;
		 ADDR7         : in  std_logic_vector(12 downto 0);
       data_in7      : in  std_logic_vector(7 downto 0);
       data_write7   : in  std_logic;
		 ADDR8         : in  std_logic_vector(12 downto 0);
       data_in8     : in  std_logic_vector(7 downto 0);
       data_write8   : in  std_logic;
		  ADDR9         : in  std_logic_vector(12 downto 0);
       data_in9      : in  std_logic_vector(7 downto 0);
       data_write9   : in  std_logic;
		 ADDR10         : in  std_logic_vector(12 downto 0);
       data_in10      : in  std_logic_vector(7 downto 0);
       data_write10   : in  std_logic;
		 ADDR11        : in  std_logic_vector(12 downto 0);
       data_in11     : in  std_logic_vector(7 downto 0);
       data_write11   : in  std_logic;
		 ADDR12         : in  std_logic_vector(12 downto 0);
       data_in12      : in  std_logic_vector(7 downto 0);
       data_write12   : in  std_logic;
		 ADDR13         : in  std_logic_vector(12 downto 0);
       data_in13      : in  std_logic_vector(7 downto 0);
       data_write13   : in  std_logic;
		 ADDR14         : in  std_logic_vector(12 downto 0);
       data_in14      : in  std_logic_vector(7 downto 0);
       data_write14   : in  std_logic;
		 ADDR15         : in  std_logic_vector(12 downto 0);
       data_in15      : in  std_logic_vector(7 downto 0);
       data_write15   : in  std_logic;
		 ADDR16         : in  std_logic_vector(12 downto 0);
       data_in16     : in  std_logic_vector(7 downto 0);
       data_write16   : in  std_logic
		 );
end VGA_bitmap_640x480;

architecture Behavioral of VGA_bitmap_640x480 is


component RAM_single_port 
    Port ( clk : in  STD_LOGIC;
           data_write : in  STD_LOGIC;
			  data_in : in STD_LOGIC_VECTOR(7 downto 0);
           ADDR : in  STD_LOGIC_VECTOR (12 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

   
	signal h_counter     : integer range 0 to 3199:=0;     -- counter for H sync. (size depends of frequ because of division)
	signal v_counter     : integer range 0 to 520 :=0;     -- counter for V sync. (base on v_counter, so no frequ issue)

	signal TOP_line      : boolean := false;               -- this signal is true when the current pixel column is visible on the screen
	signal TOP_display   : boolean := false;               -- this signal is true when the current pixel line is visible on the screen

	signal pix_read_addr : integer range 0 to 307199:=0;  -- the address at which displayed data is read
	signal pix_read_addr1, pix_read1 : integer range 0 to 19199:=0;  -- the address at which displayed data is read

	--signal next_pixel,next_pixel1,next_pixel2    : std_logic_vector(3 downto 0);  -- the data coding the value of the pixel to be displayed
   signal pix_read_addrb : integer range 0 to 38399 := 0;  -- the address at which displayed data is read

   signal next_pixel1, data_temp1, data_temp2 , data_outtemp1, data_outtemp2,data_temp3, data_temp4 , data_outtemp3, data_outtemp4, data_temp5, data_temp6 , data_outtemp5, data_outtemp6,data_temp7, data_temp8 , data_outtemp7, data_outtemp8  : std_logic_vector(7 downto 0);  -- the data coding the value of the pixel to be displayed
   signal data_temp9, data_temp10 , data_outtemp9, data_outtemp10,data_temp11, data_temp12 , data_outtemp11, data_outtemp12, data_temp13, data_temp14 , data_outtemp13, data_outtemp14,data_temp15, data_temp16 , data_outtemp15, data_outtemp16  : std_logic_vector(7 downto 0);
	signal next_pixel2   : std_logic_vector(7 downto 0);  -- the data coding the value of the pixel to be displayed
   signal next_pixel    : std_logic_vector(7 downto 0);  -- the data coding the value of the pixel to be displayed
	--signal data_writetemp1, data_writetemp2 : std_logic;
	
   signal ADDRtemp1, ADDRtemp2, ADDRtemp3, ADDRtemp4, ADDRtemp5, ADDRtemp6, ADDRtemp7, ADDRtemp8    : std_logic_vector(12 downto 0);  -- the data coding the value of the pixel to be displayed
   signal ADDRtemp9, ADDRtemp10, ADDRtemp11, ADDRtemp12, ADDRtemp13, ADDRtemp14, ADDRtemp15, ADDRtemp16    : std_logic_vector(12 downto 0);  -- the data coding the value of the pixel to be displayed

begin

--------------------------------------------------------------------------------

RAM1: RAM_single_port
port map (clk_vga,
				data_write1,
				data_in1,
				ADDRtemp1,
				data_outtemp1);
				
RAM2: RAM_single_port
port map (clk_vga,
				data_write2,
				data_in2,
				ADDRtemp2,
				data_outtemp2);

RAM3: RAM_single_port
port map (clk_vga,
				data_write3,
				data_in3,
				ADDRtemp3,
				data_outtemp3);
				
RAM4: RAM_single_port
port map (clk_vga,
				data_write4,
				data_in4,
				ADDRtemp4,
				data_outtemp4);
				
RAM5: RAM_single_port
port map (clk_vga,
				data_write5,
				data_in5,
				ADDRtemp5,
				data_outtemp5);
				
RAM6: RAM_single_port
port map (clk_vga,
				data_write6,
				data_in6,
				ADDRtemp6,
				data_outtemp6);

RAM7: RAM_single_port
port map (clk_vga,
				data_write7,
				data_in7,
				ADDRtemp7,
				data_outtemp7);
				
RAM8: RAM_single_port
port map (clk_vga,
				data_write8,
				data_in8,
				ADDRtemp8,
				data_outtemp8);				


RAM9: RAM_single_port
port map (clk_vga,
				data_write9,
				data_in9,
				ADDRtemp9,
				data_outtemp9);
				
RAM10: RAM_single_port
port map (clk_vga,
				data_write10,
				data_in10,
				ADDRtemp10,
				data_outtemp10);

RAM11: RAM_single_port
port map (clk_vga,
				data_write11,
				data_in11,
				ADDRtemp11,
				data_outtemp11);
				
RAM12: RAM_single_port
port map (clk_vga,
				data_write12,
				data_in12,
				ADDRtemp12,
				data_outtemp12);
				
RAM13: RAM_single_port
port map (clk_vga,
				data_write13,
				data_in13,
				ADDRtemp13,
				data_outtemp13);
				
RAM14: RAM_single_port
port map (clk_vga,
				data_write14,
				data_in14,
				ADDRtemp14,
				data_outtemp14);

RAM15: RAM_single_port
port map (clk_vga,
				data_write15,
				data_in15,
				ADDRtemp15,
				data_outtemp15);
				
RAM16: RAM_single_port
port map (clk_vga,
				data_write16,
				data_in16,
				ADDRtemp16,
				data_outtemp16);

  -- pix_read_addrb <= pix_read_addr when pix_read_addr < 123599 else pix_read_addr - 123599;
	
	ADDRtemp1<= ADDR1 when (data_write1 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp2<= ADDR2 when (data_write2 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp3<= ADDR3 when (data_write3 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp4<= ADDR4 when (data_write4 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp5<= ADDR5 when (data_write5 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp6<= ADDR6 when (data_write6 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp7<= ADDR7 when (data_write7 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp8<= ADDR8 when (data_write8 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp9<= ADDR9 when (data_write9 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp10<= ADDR10 when (data_write10 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp11<= ADDR11 when (data_write11 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp12<= ADDR12 when (data_write12 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp13<= ADDR13 when (data_write13 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp14<= ADDR14 when (data_write14 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp15<= ADDR15 when (data_write15 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	ADDRtemp16<= ADDR16 when (data_write16 = '1') else std_logic_vector(to_unsigned(pix_read1, 13)) ;
	--data_writetemp1 <= clk_VGA when (data_write1 = '0') else '1' ;
	--data_writetemp2 <= clk_VGA when (data_write2 = '0') else '1' ;
	
	


	

--   process (clk)
--   begin
--      if (clk'event and clk = '1') then
--         if (data_write1 = '1') then
--            screen1(to_integer(unsigned(ADDR1))) <=  data_in1 ;
--         end if;
--      end if;
--   end process;
--
--   process (clk_vga)
--   begin
--      if (clk_vga'event and clk_vga = '1') then
--         next_pixel1 <= screen1(pix_read_addrb) ;
--      end if;
--   end process;
--
--   process (clk)
--   begin
--      if (clk'event and clk = '1') then
--         if (data_write2 = '1') then
--            screen2(to_integer(unsigned(ADDR2))) <= data_in2 ;
--         end if;
--      end if;
--   end process;
--
--   process (clk_vga)
--   begin
--      if (clk_vga'event and clk_vga = '1') then
--         next_pixel2 <= screen2(pix_read_addrb);
--      end if;
--   end process;

   process (clk_vga)
   begin
      if (clk_vga'event and clk_vga = '1') then
         IF pix_read_addr < 19199 THEN
            next_pixel <= data_outtemp1;
		  ELSif pix_read_addr < 38399 THEN
            next_pixel <= data_outtemp2;
		  ELSif pix_read_addr < 57599 THEN
            next_pixel <= data_outtemp3;
        ELSif pix_read_addr < 76799 THEN
            next_pixel <= data_outtemp4;
        ELSif pix_read_addr < 95999 THEN
            next_pixel <= data_outtemp5;
        ELSif pix_read_addr < 115199 THEN
            next_pixel <= data_outtemp6;
	     ELSif pix_read_addr < 134399 THEN
            next_pixel <= data_outtemp7;
		  ELSif pix_read_addr < 153599 THEN
            next_pixel <= data_outtemp8;
		  ELSif pix_read_addr < 172799 THEN
            next_pixel <= data_outtemp9;
	     ELSif pix_read_addr < 191999 THEN
            next_pixel <= data_outtemp10;
  		ELSif pix_read_addr < 211199 THEN
            next_pixel <= data_outtemp11;
     ELSif pix_read_addr < 230399 THEN
            next_pixel <= data_outtemp12;
     ELSif pix_read_addr < 249599 THEN
            next_pixel <= data_outtemp13;
	     ELSif pix_read_addr < 268799 THEN
            next_pixel <= data_outtemp14;
	     ELSif pix_read_addr < 28799 THEN
            next_pixel <= data_outtemp15;
	  	  else
	 	      next_pixel <= data_outtemp16;

         END IF;
      end if;
   end process;

--process (clk_vga)
--begin
--   if (clk_vga'event and clk_vga = '1') then
--         if (data_write1 = '1') then
--            screen1(to_integer(unsigned(ADDR1))) <= data_in1;
--            next_pixel1 <= data_in1;
--         else
--            next_pixel1 <= screen1(to_integer(unsigned(ADDR1)));
--         end if;
--   end if;
--end process;
--
--process (clk_vga)
--begin
--   if (clk_vga'event and clk_vga = '1') then
--         if (data_write2 = '1') then
--            screen2(to_integer(unsigned(ADDR2))) <= data_in2;
--            next_pixel2 <= data_in2;
--         else
--            next_pixel2 <= screen2(to_integer(unsigned(ADDR2));
--         end if;
--   end if;
--end process;

--process (next_pixel)
--begin
--   if (clk_vga'event and clk_vga = '1') then
--				next_pixel <= To_StdLogicVector( ram_out(pix_read_addr)              );
--	end if;
--end process;

--ram_out <= screen1 when to_unsigned(pix_read_addr,13)(12) = '0' else screen2;


--------------------------------------------------------------------------------

--proc<='0' when (pix_read_addr <123599) else '1';


pixel_read_addr : process(clk_vga)
begin
   if clk_vga'event and clk_vga='1' then
      if reset = '1' or (not TOP_display) then
         pix_read_addr <= 0;
      elsif TOP_line and (h_counter mod 4)=0 then
         pix_read_addr <= pix_read_addr + 1;
	  elsif (pix_read_addr = 307199) then
		 pix_read_addr <= 0;
      end if;
   end if;
end process;

pixel_read1 : process(clk_vga)
begin
   if clk_vga'event and clk_vga='1' then
      if reset = '1' or (not TOP_display) then
         pix_read1 <= 0;
      elsif TOP_line and (h_counter mod 4)=0 then
         pix_read1 <= pix_read1 + 1;
	  elsif (pix_read1 = 19199) then
		 pix_read1 <= 0;
      end if;
   end if;
end process;

--pixel_read_addrb : process(clk_vga, clk)
--begin
--   if clk_vga'event and clk_vga='1' then
--      if reset = '1' or (not TOP_display) then
--         pix_read_addrb <= 0;
--      elsif TOP_line and (h_counter mod 4)=0 then
--         pix_read_addrb <= pix_read_addrb + 1;
--	  elsif (pix_read_addrb = 123599) then
--		 pix_read_addrb <= 0;
--      end if;
--   end if;
--end process;

--process(pix_read_addr)
--begin
--    if pix_read_addr < 123599 then
--        ram_number <= '0';
--    elsif pix_read_addr <307199 then
--        ram_number <= '1';
--    else
--        ram_number <= '0';
--    end if;
--end process;

-- this process manages the horizontal synchro using the counters
process(clk_vga)
begin
   if clk_vga'event and clk_vga='1' then
      if reset = '1' then
         VGA_vs    <= '0';
         TOP_display <= false;
      else
         case v_counter is
            when 0   => VGA_vs      <= '0';   -- start of Tpw   (  0 ->   0 +   1)
            when 2   => VGA_vs      <= '1';   -- start of Tbp   (  2 ->   2 +  28 =  30)
            when 31  => TOP_display <= true;  -- start of Tdisp ( 31 ->  31 + 479 = 510)  
            when 511 => TOP_display <= false; -- start of Tfp   (511 -> 511 +   9 = 520)
            when others   => null;
         end case;
--            if v_counter =   0 then VGA_vs      <= '0'; -- start of Tpw   (  0 ->   0 +   1)
--         elsif v_counter =   2 then VGA_vs      <= '1'; -- start of Tbp   (  2 ->   2 +  28 =  30)
--         elsif v_counter =  75 then TOP_display <= true; -- start of Tdisp ( 31 ->  31 + 479 = 510)
--         elsif v_counter = 475 then TOP_display <= false; -- start of Tfp   (511 -> 511 +   9 = 520)
--         end if;
      end if;
   end if;
end process;



process(clk_vga)
begin
   if clk_vga'event and clk_vga='1' then
      if (not TOP_line) or (not TOP_display) then
         iter   <= "00000000";
      else
         iter<= next_pixel;
         
      end if;
   end if;
end process;





-- this process manages the horizontal synchro using the counters
process(clk_vga)
begin
   if clk_vga'event and clk_vga='1' then
      if reset = '1' then
         VGA_hs <= '0';
         TOP_line <= false;
      else
         case h_counter is
            when    2 => VGA_hs   <= '0';     -- start of Tpw   (  0  ->   0 +   95) -- +2 because of delay in RAM
            when  386 => VGA_hs   <= '1';     -- start of Tbp   (  96 ->   96 +  47 = 143) -- 384=96*4 -- -- +2 because of delay in RAM
            when  576 => TOP_line <= true;    -- start of Tdisp ( 144 ->  144 + 639 = 783)  -- 576=144*4
            when 3136 => TOP_line <= false;   -- start of Tfp   ( 784 ->  784 +  12 = 799) -- 3136 = 784*4
            when others => null;
         end case;
      
      
--         if    h_counter=2    then VGA_hs   <= '0';     -- start of Tpw   (  0  ->   0 +   95) -- +2 because of delay in RAM
--         elsif h_counter=386  then VGA_hs   <= '1';     -- start of Tbp   (  96 ->   96 +  47 = 143) -- 384=96*4 -- -- +2 because of delay in RAM
--         elsif h_counter=576  then TOP_line <= true;    -- start of Tdisp ( 144 ->  144 + 639 = 783)  -- 576=144*4
--         elsif h_counter=3136 then TOP_line <= false;   -- start of Tfp   ( 784 ->  784 +  12 = 799) -- 3136 = 784*4
--         end if;
      end if;
   end if;
end process;

-- counter management for synchro
process(clk_vga)
begin
   if clk_vga'event and clk_vga='1' then
      if reset='1' then
         h_counter <= 0;
         v_counter <= 0;
      else
         if h_counter = 3199 then
            h_counter <= 0;
            if v_counter = 520 then
               v_counter <= 0;
            else
               v_counter <= v_counter + 1;
            end if;
         else
            h_counter <= h_counter +1;      
         end if;
      end if;
   end if;
end process;



end Behavioral;

