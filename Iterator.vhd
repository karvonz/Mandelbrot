library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.CONSTANTS.ALL;
use WORK.FUNCTIONS.ALL;


entity Iterator is
    Port ( go : in STD_LOGIC;
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           x0 : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           y0 : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           iters : out STD_LOGIC_VECTOR (ITER_RANGE-1 downto 0);
           done : out STD_LOGIC);
end Iterator;

architecture Behavioral of Iterator is
component Calc is
	Port(	y0 : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			x0 : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			yi : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			xi : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			yi1 : out STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
			xi1 : out STD_LOGIC_VECTOR (XY_RANGE-1 downto 0));
end component;

signal xi1 : STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
signal yi1 : STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
signal xi : STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
signal yi : STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
signal mod2 : SIGNED (XY_RANGE-1 downto 0);
signal cptiters : integer;
signal donestate : STD_LOGIC;

begin
	fCalc : Calc
	port map(y0=>y0,x0=>x0,yi=>yi,xi=>xi,yi1=>yi1,xi1=>xi1);

	process(clock, reset, go)
	begin
		if reset='1' then
			donestate<='1';
			mod2<=(others=>'0');
			xi<=(others=>'0');
			yi<=(others=>'0');
			cptiters<=0;
		
		elsif rising_edge(clock) then
			if ((go='1') and (donestate='1')) then --Start iteration
				donestate<='0';
				mod2<=(others=>'0');
				cptiters<=0;
				xi<=(others=>'0');
				yi<=(others=>'0');
			elsif((cptiters<ITER_MAX) and (mod2 < QUATRE)) then --Still <4
				mod2 <= SIGNED(mult(xi1,xi1,FIXED)) + SIGNED(mult(yi1,yi1,FIXED));
				xi<=xi1;  --Updating values
				yi<=yi1;
				cptiters <= cptiters + 1; 
				
			else  --computing done
				donestate <= '1';
			end if;
		end if;
	end process;
	
	iters<=std_logic_vector(to_unsigned(cptiters,ITER_RANGE));
	done<=donestate;	
end Behavioral;
