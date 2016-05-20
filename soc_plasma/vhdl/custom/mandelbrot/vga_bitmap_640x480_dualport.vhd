-------------------------------------------------------------------------------
-- Bitmap VGA display with 640x480 pixel resolution
-------------------------------------------------------------------------------
-- V 1.1.2 (2015/11/29)
--  Bertrand Le Gal (bertrand.legal@enseirb-matmeca.fr)
--  Some little modifications to support data reading 
--  from file for RAM initilization.
--
-- V 1.1.1 (2015/07/28)
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
  port(clk          : in  std_logic;
		 clk_vga      : in  std_logic;
       reset        : in  std_logic;
       VGA_hs       : out std_logic;   -- horisontal vga syncr.
       VGA_vs       : out std_logic;   -- vertical vga syncr.
       iter      : out std_logic_vector(7 downto 0);   -- iter output
       ADDR1         : in  std_logic_vector(15 downto 0);
       data_in1      : in  std_logic_vector(7 downto 0);
       data_write1   : in  std_logic;
		 ADDR2         : in  std_logic_vector(15 downto 0);
       data_in2      : in  std_logic_vector(7 downto 0);
       data_write2   : in  std_logic;
	          ADDR3         : in  std_logic_vector(15 downto 0);
       data_in3      : in  std_logic_vector(7 downto 0);
       data_write3   : in  std_logic;
		 ADDR4         : in  std_logic_vector(15 downto 0);
       data_in4      : in  std_logic_vector(7 downto 0);
       data_write4   : in  std_logic;
	          ADDR5         : in  std_logic_vector(15 downto 0);
       data_in5      : in  std_logic_vector(7 downto 0);
       data_write5   : in  std_logic;
		 ADDR6         : in  std_logic_vector(15 downto 0);
       data_in6      : in  std_logic_vector(7 downto 0);
       data_write6  : in  std_logic;
	          ADDR7         : in  std_logic_vector(15 downto 0);
       data_in7      : in  std_logic_vector(7 downto 0);
       data_write7   : in  std_logic;
		 ADDR8         : in  std_logic_vector(15 downto 0);
       data_in8      : in  std_logic_vector(7 downto 0);
       data_write8   : in  std_logic);
end VGA_bitmap_640x480;

architecture Behavioral of VGA_bitmap_640x480 is

	-- Graphic RAM type. this object is the content of the displayed image
	type GRAM is array (0 to 38399) of std_logic_vector(7 downto 0); --153599
	signal  screen1, screen2,screen3, screen4,screen5, screen6,screen7        : GRAM;-- := ram_function_name("../mandelbrot.bin"); -- the memory representation of the image
    
	signal h_counter     : integer range 0 to 3199:=0;     -- counter for H sync. (size depends of frequ because of division)
	signal v_counter     : integer range 0 to 520 :=0;     -- counter for V sync. (base on v_counter, so no frequ issue)

	signal TOP_line      : boolean := false;               -- this signal is true when the current pixel column is visible on the screen
	signal TOP_display   : boolean := false;               -- this signal is true when the current pixel line is visible on the screen

	signal pix_read_addr : integer range 0 to 307199:=0;  -- the address at which displayed data is read
	signal pix_read_addr1 : integer range 0 to 38399:=0;  -- the address at which displayed data is read

	--signal next_pixel,next_pixel1,next_pixel2    : std_logic_vector(3 downto 0);  -- the data coding the value of the pixel to be displayed
   signal pix_read_addrb : integer range 0 to 38399 := 0;  -- the address at which displayed data is read

   signal next_pixel1 , next_pixel2, next_pixel3 , next_pixel4, next_pixel5 , next_pixel6, next_pixel7     : std_logic_vector(7 downto 0);  -- the data coding the value of the pixel to be displayed
   signal next_pixel    : std_logic_vector(7 downto 0);  -- the data coding the value of the pixel to be displayed
	signal proc : std_logic_vector(2 downto 0);
begin

--------------------------------------------------------------------------------

  -- pix_read_addrb <= pix_read_addr when pix_read_addr < 153599 else pix_read_addr - 153599;

   process (clk)
   begin
      if (clk'event and clk = '1') then
         if (data_write1 = '1') then
            screen1(to_integer(unsigned(ADDR1))) <=  data_in1 ;
         end if;
      end if;
   end process;

   process (clk_vga)
   begin
      if (clk_vga'event and clk_vga = '1') then
         next_pixel1 <= screen1(pix_read_addr1) ;
      end if;
   end process;

   process (clk)
   begin
      if (clk'event and clk = '1') then
         if (data_write2 = '1') then
            screen2(to_integer(unsigned(ADDR2))) <= data_in2 ;
         end if;
      end if;
   end process;

   process (clk_vga)
   begin
      if (clk_vga'event and clk_vga = '1') then
         next_pixel2 <= screen2(pix_read_addr1);
      end if;
   end process;
   
      process (clk)
   begin
      if (clk'event and clk = '1') then
         if (data_write3 = '1') then
            screen3(to_integer(unsigned(ADDR3))) <=  data_in3 ;
         end if;
      end if;
   end process;

   process (clk_vga)
   begin
      if (clk_vga'event and clk_vga = '1') then
         next_pixel3 <= screen3(pix_read_addr1) ;
      end if;
   end process;

   process (clk)
   begin
      if (clk'event and clk = '1') then
         if (data_write4 = '1') then
            screen4(to_integer(unsigned(ADDR4))) <= data_in4 ;
         end if;
      end if;
   end process;

   process (clk_vga)
   begin
      if (clk_vga'event and clk_vga = '1') then
         next_pixel4 <= screen4(pix_read_addr1);
      end if;
   end process;
   
      process (clk)
   begin
      if (clk'event and clk = '1') then
         if (data_write5 = '1') then
            screen5(to_integer(unsigned(ADDR5))) <=  data_in5 ;
         end if;
      end if;
   end process;

   process (clk_vga)
   begin
      if (clk_vga'event and clk_vga = '1') then
         next_pixel5 <= screen5(pix_read_addr1) ;
      end if;
   end process;

   process (clk)
   begin
      if (clk'event and clk = '1') then
         if (data_write6 = '1') then
            screen6(to_integer(unsigned(ADDR6))) <= data_in6 ;
         end if;
      end if;
   end process;

   process (clk_vga)
   begin
      if (clk_vga'event and clk_vga = '1') then
         next_pixel6 <= screen6(pix_read_addr1);
      end if;
   end process;
   
      process (clk)
   begin
      if (clk'event and clk = '1') then
         if (data_write7 = '1') then
            screen7(to_integer(unsigned(ADDR7))) <=  data_in7 ;
         end if;
      end if;
   end process;

   process (clk_vga)
   begin
      if (clk_vga'event and clk_vga = '1') then
         next_pixel7 <= screen7(pix_read_addr1) ;
      end if;
   end process;

--   process (clk)
--   begin
--      if (clk'event and clk = '1') then
--         if (data_write8 = '1') then
--            screen8(to_integer(unsigned(ADDR8))) <= data_in8 ;
--         end if;
--      end if;
--   end process;
--
--   process (clk_vga)
--   begin
--      if (clk_vga'event and clk_vga = '1') then
--         next_pixel8 <= screen8(pix_read_addr1);
--      end if;
--   end process;

   process (clk_vga)
   begin
      if (clk_vga'event and clk_vga = '1') then
         IF proc= "000" THEN
            next_pixel <= next_pixel1;
        ELSif proc ="001" then
            next_pixel <= next_pixel2;
        ELSif proc ="010" then
            next_pixel <= next_pixel3;
        ELSif proc ="011" then
            next_pixel <= next_pixel4;
        ELSif proc ="100" then
            next_pixel <= next_pixel5;
	    ELSif proc ="101" then
            next_pixel <= next_pixel6;
        ELSif proc ="110" then
            next_pixel <= next_pixel7;
		else
			next_pixel <= (others=>'0');
         END IF;
      end if;
   end process;


--process (next_pixel)
--begin
--   if (clk_vga'event and clk_vga = '1') then
--				next_pixel <= To_StdLogicVector( ram_out(pix_read_addr)              );
--	end if;
--end process;

--ram_out <= screen1 when to_unsigned(pix_read_addr,18)(17) = '0' else screen2;


--------------------------------------------------------------------------------
process(pix_read_addr)
begin
IF pix_read_addr < 38399 THEN
            proc <= "000";
		  ELSif pix_read_addr < 76799 THEN
            proc <= "001";
		  ELSif pix_read_addr < 115199 THEN
            proc <= "010";
        ELSif pix_read_addr < 153599 THEN
            proc <= "011";
        ELSif pix_read_addr < 191999 THEN
            proc <= "100";
        ELSif pix_read_addr < 153599 THEN
            proc <= "101";
	     ELSif pix_read_addr < 230399 THEN
            proc <= "110";
	  	  else
	 	      proc <= "111";

         END IF;
end process; 

--proc<='0' when (pix_read_addr <153599) else '1';


pixel_read_addr : process(clk_vga, clk)
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

pixel_read_addr1 : process(clk_vga, clk)
begin
   if clk_vga'event and clk_vga='1' then
      if reset = '1' or (not TOP_display) then
         pix_read_addr1 <= 0;
      elsif TOP_line and (h_counter mod 4)=0 then
         pix_read_addr1 <= pix_read_addr1 + 1;
	  elsif (pix_read_addr1 = 38399) then
		 pix_read_addr1 <= 0;
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
--	  elsif (pix_read_addrb = 153599) then
--		 pix_read_addrb <= 0;
--      end if;
--   end if;
--end process;

--process(pix_read_addr)
--begin
--    if pix_read_addr < 153599 then
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
            when 3136 => TOP_line <= false;   -- start of Tfp   ( 784 ->  784 +  15 = 799) -- 3136 = 784*4
            when others => null;
         end case;
      
      
--         if    h_counter=2    then VGA_hs   <= '0';     -- start of Tpw   (  0  ->   0 +   95) -- +2 because of delay in RAM
--         elsif h_counter=386  then VGA_hs   <= '1';     -- start of Tbp   (  96 ->   96 +  47 = 143) -- 384=96*4 -- -- +2 because of delay in RAM
--         elsif h_counter=576  then TOP_line <= true;    -- start of Tdisp ( 144 ->  144 + 639 = 783)  -- 576=144*4
--         elsif h_counter=3136 then TOP_line <= false;   -- start of Tfp   ( 784 ->  784 +  15 = 799) -- 3136 = 784*4
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

