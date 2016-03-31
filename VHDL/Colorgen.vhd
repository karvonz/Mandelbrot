library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.CONSTANTS.ALL;
use WORK.FUNCTIONS.ALL;

entity Colorgen is
    Port ( iters : in STD_LOGIC_VECTOR (ITER_RANGE-1 downto 0);
           color : out STD_LOGIC_VECTOR (bit_per_pixel-1 downto 0));
end Colorgen;

architecture Behavioral of Colorgen is

begin
	color <= not iters(bit_per_pixel - 1 downto 0);
end Behavioral;