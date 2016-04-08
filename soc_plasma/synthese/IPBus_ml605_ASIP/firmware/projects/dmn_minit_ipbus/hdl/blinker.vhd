-- blinker
--
-- Hideously inefficient pulse stretcher
--
-- Dave Newbold, July 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity blinker is port(
	clk: in std_logic;
	go: in std_logic;
	blink: out std_logic
	);

end blinker;

architecture rtl of blinker is

	signal ctr: unsigned(24 downto 0);
	signal term: std_logic;

begin

	process(clk)
	begin
		if go = '1' then
			ctr <= (others => '0');
			blink <= '1';
		elsif term = '0' then
			ctr <= ctr + 1;
		else
			blink <= '0';
		end if;
	end process;

	term <= '1' when ctr = (24 downto 0 => '1') else '0';

end rtl;

