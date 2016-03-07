library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.CONSTANTS.ALL;

entity Calc is
    Port ( start : in STD_LOGIC;
           ydata : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           xdata : in STD_LOGIC_VECTOR (XY_RANGE-1 downto 0);
           done : out STD_LOGIC;
           iters : out STD_LOGIC_VECTOR (ITER_RANGE-1 downto 0));
end Calc;

architecture Behavioral of Calc is

begin


end Behavioral;
