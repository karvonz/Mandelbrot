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

entity coproc_4 is
   port(
		clock          : in  std_logic;
		--clock_vga      : in  std_logic;
		reset          : in  std_logic;
		INPUT_1        : in  std_logic_vector(31 downto 0);
		INPUT_1_valid  : in  std_logic;
		OUTPUT_1       : out std_logic_vector(31 downto 0);
		--VGA_hs       	: out std_logic;   -- horisontal vga syncr.
     -- VGA_vs       	: out std_logic;   -- vertical vga syncr.
      --iter      	: out std_logic_vector(3 downto 0)   -- red output
		data_write :out std_logic;
		ADDR         : out  std_logic_vector(17 downto 0);
		data_out      : out std_logic_vector(7 downto 0)
    --  VGA_green    	: out std_logic_vector(3 downto 0);   -- green output
    --  VGA_blue    	 : out std_logic_vector(3 downto 0)   -- blue output
	);
end; --comb_alu_1

architecture logic of coproc_4 is

	SIGNAL mem : UNSIGNED(31 downto 0);
	signal tmp_addr : std_logic_vector(17 downto 0);
	signal pixel : std_logic_vector(7 downto 0);
	--signal tmp_out : std_logic_vector(10 downto 0);
	signal counter : integer range 0 to 153599:= 0;
begin
	
	
	
	
	--tmp_addr <= INPUT_1(31 downto 13);
	--pixel <= INPUT_1(7 downto 0);
--	

	process (clock)
	begin
		IF clock'event AND clock = '1' THEN
			IF reset = '1' THEN
					counter <= 0;
			ELSE
				IF INPUT_1_valid = '1' THEN
						IF counter < 76799 THEN
							counter <= counter + 1;
						ELSE
							counter <= 0;
						END IF;
				END IF;
			END IF;
		END IF;
	end process;

--	
--
--	process (clock, reset)
--	begin
--		IF clock'event AND clock = '1' THEN
--			IF reset = '1' THEN
--				tmp_addr <= (others => '1');
--				pixel <= (others => '0');
--				data_write <= '0';
--			ELSE
--				IF INPUT_1_valid = '1' THEN
--					tmp_addr <= INPUT_1(31 downto 13);
--					pixel <= INPUT_1(7 downto 0);
--					data_write <= '1';
--				else
--					data_write <= '0';
--				END IF;
--			END IF;
--		END IF;
--	end process;
--	
	tmp_addr <= std_logic_vector(to_signed(counter, 18));
--	

		data_write <=INPUT_1_valid;
		data_out <=INPUT_1(7 downto 0);
		ADDR <= tmp_addr;
	
		OUTPUT_1 <= "00000000000000"&tmp_addr;

	
	
	
--	process (clock)
--	begin
--		IF clock'event AND clock = '1' THEN
--			IF reset = '1' THEN
--				mem <= TO_UNSIGNED( 0, 32);
--			ELSE
--				IF INPUT_1_valid = '1' THEN
----					   assert INPUT_1_valid /= '1' severity failure;
--					mem <= UNSIGNED(INPUT_1) + TO_UNSIGNED( 3, 32);
--				ELSE
--					mem <= mem;					
--				END IF;
--			END IF;
--		END IF;
--	end process;
	-------------------------------------------------------------------------

--	OUTPUT_1 <= STD_LOGIC_VECTOR( mem );
	-------------------------------------------------------------------------
--	process (clock, reset)
--	begin
--		IF clock'event AND clock = '1' THEN
--			IF reset = '1' THEN
--				mem <= TO_UNSIGNED( 0, 32);
--			ELSE
--				IF INPUT_1_valid = '1' THEN
--					mem <= UNSIGNED(INPUT_1) + TO_UNSIGNED( 4, 32);
--				ELSE
--					mem <= mem;
--				END IF;
--			END IF;
--		END IF;
--	end process;
--	-------------------------------------------------------------------------
--
--	OUTPUT_1 <= STD_LOGIC_VECTOR( mem );

end; --architecture logic
