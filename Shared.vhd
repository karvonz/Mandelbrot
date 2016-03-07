library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package CONSTANTS is
	-- Fixed format --
	constant FIXED : INTEGER := 24; --Number of bits
   
	-- Data size --
	constant XY_RANGE : INTEGER := 32; --Number of bits for x and y data
	constant ITER_RANGE : INTEGER := 10; --Number of bits for iteration number
	constant ITER_MAX : INTEGER := 1023; --Max number of iteration
	constant QUATRE : STD_LOGIC_VECTOR (XY_RANGE-1 downto 0) := 
end CONSTANTS;