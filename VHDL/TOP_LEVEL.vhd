----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:01:45 03/21/2016 
-- Design Name: 
-- Module Name:    TOP_LEVEL - Behavioral 
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
use work.CONSTANTS.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP_LEVEL is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  inib : in std_logic;
			  VGA_hs       : out std_logic;   -- horisontal vga syncr.
			  VGA_vs       : out std_logic;   -- vertical vga syncr.
			  VGA_red      : out std_logic_vector(3 downto 0);   -- red output
           VGA_green    : out std_logic_vector(3 downto 0);   -- green output
           VGA_blue     : out std_logic_vector(3 downto 0);       
			  data_out     : out std_logic_vector(bit_per_pixel - 1 downto 0));
end TOP_LEVEL;

architecture Behavioral of TOP_LEVEL is
component cpt_iter
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;		
			  inib : in std_logic;
           endcalcul : in  STD_LOGIC;
           iter : out  STD_LOGIC_VECTOR(ITER_RANGE-1 downto 0));
end component;

component Colorgen 
    Port ( iters : in STD_LOGIC_VECTOR (ITER_RANGE-1 downto 0);
	 			  itermax : in STD_LOGIC_VECTOR (ITER_RANGE-1 downto 0);

           color : out STD_LOGIC_VECTOR (bit_per_pixel-1 downto 0));
end component;

component FSM 
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           done : in STD_LOGIC;
			  stop : in std_logic;
           start : out STD_LOGIC);
end component;



component Iterator 
    Port ( go : in STD_LOGIC;
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           x0 : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           y0 : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			  itermax : in std_logic_vector(ITER_RANGE-1 downto 0);
           iters : out STD_LOGIC_VECTOR (ITER_RANGE-1 downto 0);
           done : out STD_LOGIC);
end component;

component increment
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           start : in  STD_LOGIC;
           x : out  STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           y : out  STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			  stop : out std_logic);
end component;

component VGA_bitmap_640x480
  generic(grayscale     : boolean := false);           -- should data be displayed in grayscale
  port(clk          : in  std_logic;
       reset        : in  std_logic;
       VGA_hs       : out std_logic;   -- horisontal vga syncr.
       VGA_vs       : out std_logic;   -- vertical vga syncr.
       VGA_red      : out std_logic_vector(3 downto 0);   -- red output
       VGA_green    : out std_logic_vector(3 downto 0);   -- green output
       VGA_blue     : out std_logic_vector(3 downto 0);   -- blue output

       -- ADDR         : in  std_logic_vector(13 downto 0);     
		 endcalcul : in std_logic;

       data_in      : in  std_logic_vector(bit_per_pixel - 1 downto 0);
       data_write   : in  std_logic;
       data_out     : out std_logic_vector(bit_per_pixel - 1 downto 0));
end component;

Signal doneS, startS,stopS, xincS, yincS : std_logic;
Signal xS, yS : std_logic_vector(XY_RANGE - 1 downto 0);
Signal colorS : STD_LOGIC_VECTOR (bit_per_pixel-1 downto 0);
Signal itersS, itermaxS : STD_LOGIC_VECTOR (ITER_RANGE-1 downto 0);
begin
InstColorgen : Colorgen
port map (itersS,itermaxS,colorS);

InstVGA: VGA_bitmap_640x480
Port map (clock,
				reset,
				VGA_hs,
				VGA_vs,
				VGA_red,
				VGA_green,
				VGA_blue,
				stopS,
				colorS,
				startS, 
				open); 
				
Instincrment: increment
Port map (clock,
	  reset,
	  startS,
	  xS,
	  yS,
	  stopS);
				
instFSM : FSM
	Port map (clock,
				 reset,
				 doneS,
				 stopS,
				 startS);

instIterator : Iterator
	Port map ( startS,
					clock,
					reset,
					xS,
					yS,
					itermaxS,
					itersS,
					doneS);
					
inst_cpt_iter: cpt_iter
	port map ( clock,
					reset,
					inib,
					stopS,
					itermaxS);

end Behavioral;