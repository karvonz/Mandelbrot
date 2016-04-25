-- mac_arbiter
--
-- Arbitrates access by several packet sources to a single MAC core
-- This version implements simple round-robin polling
--
-- Dave Newbold, March 2011
--
-- $Id: mac_arbiter.vhd 350 2011-04-28 17:52:45Z phdmn $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.mac_arbiter_decl.all;

entity mac_arbiter is
	generic(NSRC: positive);
	port(
		txclk: in std_logic;
		src_txd_bus: in mac_arbiter_slv_array(NSRC-1 downto 0);
		src_txdvld_bus: in mac_arbiter_sl_array(NSRC-1 downto 0);
		src_txack_bus: out mac_arbiter_sl_array(NSRC-1 downto 0);
		mac_txd: out std_logic_vector(7 downto 0);
		mac_txdvld: out std_logic;
		mac_txack: in std_logic
	);
	
end mac_arbiter;

architecture rtl of mac_arbiter is

	signal src: unsigned(3 downto 0) := "0000"; -- Up to sixteen ports...
	signal sel: integer := 0;

begin

	sel <= to_integer(src);

	process(txclk)
	begin
		if rising_edge(txclk) then
			if src_txdvld_bus(sel)='0' then
				if src/=(NSRC-1) then
					src <= src + 1;
				else
					src <= (others=>'0');
				end if;
			end if;
		end if;
	end process;

	mac_txdvld <= src_txdvld_bus(sel);
	mac_txd <= src_txd_bus(sel);

	ackgen: for i in NSRC-1 downto 0 generate
	begin
		src_txack_bus(i) <= mac_txack when sel=i else '0';
	end generate;

end rtl;
