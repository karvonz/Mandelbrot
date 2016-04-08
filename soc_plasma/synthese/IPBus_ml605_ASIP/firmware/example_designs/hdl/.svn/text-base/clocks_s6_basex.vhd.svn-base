-- clocks_s6_basex
--
-- Generates a 1/4 rate ipbus clock from the 125MHz GTP reference
-- Includes reset logic for ipbus
--
-- Dave Newbold, April 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.VComponents.all;

entity clocks_s6_basex is port(
	clko_125: in std_logic;
	clko_ipb: out std_logic;
	locked: out std_logic;
	rsto_125: out std_logic;
	rsto_ipb: out std_logic;
	onehz: out std_logic
	);

end clocks_s6_basex;

architecture rtl of clocks_s6_basex is

	signal clk_ipb_i, clk_ipb_b, d25, d25_d, dcm_locked: std_logic;
	signal rst: std_logic := '1';
	
	component clock_divider_s6 port(
		clk: in std_logic;
		d25: out std_logic;
		d28: out std_logic
	);
	end component;
	
begin

	locked <= dcm_locked;
	rst <= rst_i;
	clko_ipb <= clk_ipb_b;

	bufg0: BUFG port map(
		i => clk_ipb_i,
		o => clk_ipb_b
	);

	dcm0: DCM_CLKGEN
		generic map(
			CLKIN_PERIOD => 8.0,
			CLKFX_MULTIPLY => 2,
			CLKFX_DIVIDE => 8
		)
		port map(
			clkin => clk125,
			clkfx => clk_ipb_i,
			locked => dcm_locked,
			rst => '0'
		);
		
	clkdiv: clock_divider_s6 port map(
		clk => clk125,
		d25 => d25,
		d28 => onehz
	);
	
	process(clk125)
	begin
		if rising_edge(clk125) then
			d25_d <= d25;
			if d25='1' and d25_d='0' then
				rst <= not dcm_locked;
			end if;
		end if;
	end process;
	
	process(clk_ipb_b)
	begin
		if rising_edge(clk_ipb_b) then
			rsto_ipb <= rst;
		end if;
	end process;
	
	rsto_125 <= rst;

end rtl;
