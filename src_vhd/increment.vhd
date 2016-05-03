library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.CONSTANTS.all;
use work.CONFIG_MANDELBROT.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity increment is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           start : in  STD_LOGIC;
			  x_start : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			  y_start : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			  step : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           x : out  STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           y : out  STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			  stop : out std_logic);
end increment;

architecture Behavioral of increment is

signal xs, ys : signed(XY_RANGE-1 downto 0);
signal xcount : integer range 0 to XRES-1:=0;
signal ycount : integer range 0 to YRES-1:=0;

begin

process(clock, reset,start,x_start,y_start,step)
begin
if reset='1' then 
	xcount<=0;
	ycount<=0;
	xs<= signed(x_start);
	ys<= signed(y_start);
	stop<='0';
elsif rising_edge(clock) then
	if(start='1') then
	if xcount = XRES-1 then
		if ycount = YRES-1 then
			xcount <= 0;
			ycount <= 0;
			xs<=signed(x_start);
			ys<=signed(y_start);
			stop<='1';
		else
			xcount <= 0;
			ycount <= ycount+1;
			ys<=ys+signed(step);
			xs<=signed(x_start);
			stop<='0';
		end if;
	else
			stop<='0';
			xs<=xs+signed(step);
			xcount<=xcount+1;
		end if;
	end if;
end if;
end process;

x<=std_logic_vector(xs);
y<=std_logic_vector(ys);


end Behavioral;