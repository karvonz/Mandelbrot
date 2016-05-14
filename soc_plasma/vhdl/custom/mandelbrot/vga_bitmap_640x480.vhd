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
       iter      : out std_logic_vector(3 downto 0);   -- red output
      --VGA_green    : out std_logic_vector(3 downto 0);   -- green output
      -- VGA_blue     : out std_logic_vector(3 downto 0);   -- blue output

       ADDR         : in  std_logic_vector(18 downto 0);
       data_in      : in  std_logic_vector(3 downto 0);
       data_write   : in  std_logic);
       --data_out     : out std_logic_vector(bit_per_pixel - 1 downto 0));
end VGA_bitmap_640x480;

architecture Behavioral of VGA_bitmap_640x480 is

	-- Graphic RAM type. this object is the content of the displayed image
	type GRAM is array (0 to 307199) of BIT_vector(3 downto 0); 

    impure function ram_function_name (ram_file_name : in string) return GRAM is                                                   
       FILE ram_file      : text is in ram_file_name;
       variable line_name : line;
       variable ram_name  : GRAM;
	 begin                                                        
       for I in GRAM'range loop                                  
           readline (ram_file, line_name);                             
           read (line_name, ram_name(I));                                  
       end loop;                                                    
       return ram_name;                                                  
	end function;                                                

	signal screen        : GRAM;-- := ram_function_name("../mandelbrot.bin"); -- the memory representation of the image

	signal h_counter     : integer range 0 to 3199:=0;     -- counter for H sync. (size depends of frequ because of division)
	signal v_counter     : integer range 0 to 520 :=0;     -- counter for V sync. (base on v_counter, so no frequ issue)

	signal TOP_line      : boolean := false;               -- this signal is true when the current pixel column is visible on the screen
	signal TOP_display   : boolean := false;               -- this signal is true when the current pixel line is visible on the screen

	signal pix_read_addr : integer range 0 to 307199:=0;  -- the address at which displayed data is read

	signal next_pixel    : std_logic_vector(3 downto 0);  -- the data coding the value of the pixel to be displayed

begin


-- This process performs data access (read and write) to the memory
--memory_read : process(clk_vga)
--begin
--   if clk_vga'event and clk_vga='1' then
--      next_pixel <= To_StdLogicVector( screen(pix_read_addr)              );
--      data_out   <= To_StdLogicVector( screen(to_integer(unsigned(ADDR))) );
----      if data_write = '1' then
----         screen(to_integer(unsigned(ADDR))) <= TO_BitVector( data_in );
----      end if;
--   end if;
--end process;
--

--------------------------------------------------------------------------------

process (clk)
begin
   if (clk'event and clk = '1') then
--      if (<enableA> = '1') then
         if (data_write = '1') then
            screen(to_integer(unsigned(ADDR))) <= TO_BitVector( data_in );
         end if;
        -- data_out <= To_StdLogicVector( screen(to_integer(unsigned(ADDR))) );
--      end if;
   end if;
end process;

process (clk_vga)
begin
   if (clk_vga'event and clk_vga = '1') then
--      if (<enableB> = '1') then
      next_pixel <= To_StdLogicVector( screen(pix_read_addr)              );
--      end if;
   end if;
end process;

--------------------------------------------------------------------------------


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
         iter   <= "0000";
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
