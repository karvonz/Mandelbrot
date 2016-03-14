library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package CONSTANTS is
	-- Fixed format --
	constant FIXED : INTEGER := 24; --Number of bits for , part
   
	-- Data size --
	constant XY_RANGE : INTEGER := 32; --Number of bits for x and y data
	constant ITER_RANGE : INTEGER := 10; --Number of bits for iteration number
	constant ITER_MAX : INTEGER := 1023; --Max number of iteration
	constant QUATRE : STD_LOGIC_VECTOR (XY_RANGE-1 downto 0) := std_logic_vector(to_unsigned(4,32) );
end CONSTANTS;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package FUNCTIONS is
	function mult(A : STD_LOGIC_VECTOR; B : STD_LOGIC_VECTOR; QF : integer) return STD_LOGIC_VECTOR;
end FUNCTIONS;

package body FUNCTIONS is
	--Maths functions
	function mult(A : SIGNED; B : SIGNED; QF : integer) return SIGNED is
		CONSTANT DMAX_R : integer := A'LENGTH + B'LENGTH;
		CONSTANT PHI : integer := A'LENGTH - QF;
		VARIABLE r  : SIGNED(DMAX_R-1 DOWNTO 0);

	begin
		r := A*B;
		return r(DMAX_R - PHI - 1 downto QF);
	end mult;
	
	function mult(A : STD_LOGIC_VECTOR; B : STD_LOGIC_VECTOR; QF : integer) return STD_LOGIC_VECTOR is
	begin
		return STD_LOGIC_VECTOR(mult(SIGNED(A),SIGNED(B),QF));
	end mult;
	
end FUNCTIONS;
