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
	 generic( ystart : std_logic_vector(31 downto 0) := x"00000000");
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  inib : in std_logic;
			  bleft : in STD_LOGIC;
           bright : in STD_LOGIC;
           bup : in STD_LOGIC;
           bdwn : in STD_LOGIC;
           bctr : in STD_LOGIC;
			  ADDR : out std_logic_vector( ADDR_BIT_MUX-1 downto 0);
			  data_write : out STD_LOGIC;
			  data_out     : out std_logic_vector(ITER_RANGE - 1 downto 0));
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
			  x_start : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			  y_start : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			  step : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           x : out  STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           y : out  STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			  stop : out std_logic);
end component;

component Zoom
generic( ystartini : STD_LOGIC_VECTOR(31 downto 0));
	port ( bleft : in STD_LOGIC;
           bright : in STD_LOGIC;
           bup : in STD_LOGIC;
           bdwn : in STD_LOGIC;
           bctr : in STD_LOGIC;
			  clock : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  ce_param : in STD_LOGIC;
			  x_start : out STD_LOGIC_VECTOR(XY_RANGE-1 downto 0);
			  y_start : out STD_LOGIC_VECTOR(XY_RANGE-1 downto 0);
			  step : out STD_LOGIC_VECTOR(XY_RANGE-1 downto 0));
end component;

component ClockManager 
    Port ( clock : in std_logic;
           reset : in std_logic;
           ce_param : out std_logic);
end component;

component ADDR_calculator     Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           data_write : in  STD_LOGIC;
           endcalcul : in  STD_LOGIC;
           ADDRout : out  STD_LOGIC_VECTOR (ADDR_BIT_MUX-1 downto 0));
end component;

Signal doneS, startS,stopS, xincS, yincS, s_param : std_logic;
Signal xS, yS : std_logic_vector(XY_RANGE - 1 downto 0);
Signal s_xstart, s_ystart, s_step : std_logic_vector(XY_RANGE - 1 downto 0);
Signal colorS : STD_LOGIC_VECTOR (bit_per_pixel-1 downto 0);
Signal itersS, itermaxS : STD_LOGIC_VECTOR (ITER_RANGE-1 downto 0);
begin


InstADDR: ADDR_calculator
port map( clock,
				reset,
				doneS, --start
				stopS,
				ADDR);

				
Instincrment: increment
Port map (clock,
	  reset,
	  startS,
	  s_xstart,
	  s_ystart,
	  s_step,
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

inst_zoom : Zoom
   generic map(ystart)
	port map (bleft, bright, bup, bdwn, bctr, clock, reset, s_param, s_xstart, s_ystart, s_step);

inst_clock_manager : ClockManager
	port map (clock, reset, s_param);
	
	data_write<=startS;
	data_out<=itersS;

end Behavioral;