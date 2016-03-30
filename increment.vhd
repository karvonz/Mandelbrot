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
           xinc : in  STD_LOGIC;
           yinc : in  STD_LOGIC;
           x : out  STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           y : out  STD_LOGIC_VECTOR (XY_RANGE-1 downto 0));
end increment;

architecture Behavioral of increment is

signal xs, ys : signed(XY_RANGE-1 downto 0);

begin

process(clock,reset)
begin
	if reset = '1' then
		x<=(others=>'0');
		xs<=XSTART;
		y<=(others=>'0');
		ys<=YSTART;
	elsif rising_edge(clock) then
		if xinc = '1' then
			xs<=xs+XPAS;
		elsif yinc='1' then
			ys<=ys+YPAS;
			xs<=XSTART;
		end if;
	end if;
end process;

x<=std_logic_vector(xs);
y<=std_logic_vector(ys);


end Behavioral;

