library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.CONSTANTS.ALL;
use WORK.FUNCTIONS.ALL;

entity Zoom is
	 generic( ystartini : STD_LOGIC_VECTOR(31 downto 0));
    Port ( bleft : in STD_LOGIC;
           bright : in STD_LOGIC;
           bup : in STD_LOGIC;
           bdwn : in STD_LOGIC;
           bctr : in STD_LOGIC;
			  clock : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  ce_param : in std_logic;
			  x_start : out STD_LOGIC_VECTOR(XY_RANGE-1 downto 0);
			  y_start : out STD_LOGIC_VECTOR(XY_RANGE-1 downto 0);
			  step : out STD_LOGIC_VECTOR(XY_RANGE-1 downto 0));
end Zoom;

architecture Behavioral of Zoom is

signal s_xstart, s_ystart, s_step : signed(XY_RANGE-1 downto 0);

begin
	process(clock, ce_param, reset, bup, bdwn, bleft, bright, bctr)
	begin
		if reset = '1' then
			s_xstart <= x"E0000000";
			s_ystart <= signed(ystartini);
			s_step <= x"00111111"; --Mandelbrot -2 1 x -1 1 sur 640x480
			
		elsif ((rising_edge(clock)) and (ce_param='1')) then -- TODO : Centrer le zoom
			if bctr = '1' then
--				if bup = '1' then
					s_xstart <= s_xstart + (mult(s_step srl 2,x"28000000",FIXED) sll 8);
					s_ystart <= s_ystart + (mult(s_step srl 2,x"1E000000",FIXED) sll 8);
					s_step <= s_step srl 1; --Zoom x2> réduction du step
--				elsif bdwn = '1' then
--					s_step <= s_step sll 1; --Dezoom x0.5> augmentation du step
--					s_xstart <= s_xstart + not (mult(s_step srl 2,x"28000000",FIXED) sll 8) + 1;
--					s_ystart <= s_ystart + not (mult(s_step srl 2,x"1E000000",FIXED) sll 8) +1;
--				end if;
			elsif bup = '1' then
				s_ystart <= s_ystart + (s_step sll 7);
			elsif bdwn = '1' then
				s_ystart <= s_ystart - (s_step sll 7);
			end if;
			

			
			if bleft = '1' then
				s_xstart <= s_xstart - (s_step sll 7);
				
			elsif bright = '1' then
				s_xstart <= s_xstart + (s_step sll 7);
			end if;
		end if;
	end process;
	x_start <= STD_LOGIC_VECTOR(s_xstart);
	y_start <= STD_LOGIC_VECTOR(s_ystart);
	step <= STD_LOGIC_VECTOR(s_step);
end Behavioral;

