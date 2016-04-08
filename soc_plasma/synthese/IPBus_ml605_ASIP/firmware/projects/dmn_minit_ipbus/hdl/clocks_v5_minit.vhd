-- clocks_v5_minit
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

entity clocks_v5_minit is port(
	clki_125: in std_logic;
	clko_ipb: out std_logic;
	locked: out std_logic;
	rsto: out std_logic;
	onehz: out std_logic
	);

end clocks_v5_minit;

architecture rtl of clocks_v5_minit is
	
	signal locked_int, clko_ipb_int: std_logic;
	signal rst: std_logic := '1';
	signal d25, d25_d: std_logic;
	
	component clock_divider_s6 port(
		clk: in std_logic;
		d25: out std_logic;
		d28: out std_logic
	);
	end component;

begin

	bufgipb: BUFG port map(
		i => clko_ipb_int,
		o => clko_ipb
	);
	
	dcm: DCM_BASE
		generic map(
			clkfx_divide => 8,
			clkfx_multiply => 2,
			clkin_period => 8.0,
			clk_feedback => "NONE"
		)
		port map(
			clkin => clki_125,
			clkfx => clko_ipb_int,
			clkfb => '0',
			locked => locked_int,
			rst => '0'
		);
		
	locked <= locked_int;
	
	clkdiv: clock_divider_s6 port map(
		clk => clki_125,
		d25 => d25,
		d28 => onehz
	);
	
	-- Reset generator (~100ms reset pulse)
	
	process(clki_125)
	begin
		if rising_edge(clki_125) then
			d25_d <= d25;
			if d25='1' and d25_d='0' then
				rst <= not locked_int;
			end if;
		end if;
	end process;
	
	rsto <= rst;
			
end rtl;

