---------------------------------------------------------------------
-- TITLE: Arithmetic Logic Unit
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 2/8/01
-- FILENAME: alu.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the ALU.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mlite_pack.all;

entity coproc_1 is
   port(
		clock          : in  std_logic;
		reset          : in  std_logic;
		INPUT_1        : in  std_logic_vector(31 downto 0);
		INPUT_1_valid  : in  std_logic;
		OUTPUT_1       : out std_logic_vector(31 downto 0)
	);
end; --comb_alu_1

architecture logic of coproc_1 is
	SIGNAL mem : UNSIGNED(31 downto 0);
	signal val0, val1, val2: unsigned(7 downto 0);
	signal r_0_0, r_0_1, r_0_2, r_1_0, r_1_1, r_1_2, r_2_0, r_2_1, r_2_2 : unsigned(7 downto 0);
   signal sum1, sum2 : unsigned(9 downto 0);

begin

	shift_register : process (clock, reset)
	begin
		IF clock'event AND clock = '1' THEN
			IF reset = '1' THEN
					r_0_0 <= (others => '0');
					r_0_1 <= (others => '0');
					r_0_2 <= (others => '0');
					r_1_0 <= (others => '0');
					r_1_1 <= (others => '0');
					r_1_2 <= (others => '0');
					r_2_0 <= (others => '0');
					r_2_1 <= (others => '0');
					r_2_2 <= (others => '0');
			ELSE
				IF INPUT_1_valid = '1' THEN
					r_0_0 <= val0;
					r_0_1 <= r_0_0;
					r_0_2 <= r_0_1;
					r_1_0 <= val1;
					r_1_1 <= r_1_0;
					r_1_2 <= r_1_1;
					r_2_0 <= val2;
					r_2_1 <= r_2_0;
					r_2_2 <= r_2_1;
				END IF;
			END IF;
		END IF;
	end process;
	-------------------------------------------------------------------------

val0 <= unsigned(INPUT_1(23 downto 16 ));
val1 <= unsigned(INPUT_1(15 downto 8 ));
val2 <= unsigned(INPUT_1(7 downto 0 ));

sum1 <= resize(   (resize(r_0_1,9) + resize(r_0_2,9)) , 10 ) + resize(r_1_2,10);
sum2 <= resize(   (resize(r_1_0,9) + resize(r_2_0,9)) , 10 ) + resize(r_2_1,10);

OUTPUT_1 <= std_logic_vector( resize(   (signed(resize(sum2,11)) - signed(resize(sum1,11))), 32));

end; --architecture logic
