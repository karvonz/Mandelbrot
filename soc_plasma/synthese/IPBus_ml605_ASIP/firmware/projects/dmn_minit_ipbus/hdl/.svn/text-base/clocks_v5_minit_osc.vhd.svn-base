-- clocks_v5_minit_osc
--
-- Generates variety of clocks from 125MHz xtal reference
-- Includes reset logic for ipbus
--
-- Dave Newbold, July 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.VComponents.all;

entity clocks_v5_minit_osc is port(
	sysclk_p, sysclk_n: in std_logic;  -- 125MHz clock from xtal
	clko_125: out std_logic;        -- 125MHz buffered user clock
	clko_62_5: out std_logic;       -- 62.5MHz buffered user clock
	clko_ipb: out std_logic;        -- 31.25MHz buffered clock for ipbus
	locked: out std_logic;          -- locked signal from DCM
	rsto_125: out std_logic;            -- reset pulse at system start
	rsto_62_5: out std_logic;            -- reset pulse at system start
	rsto_ipb: out std_logic;            -- reset pulse at system start
	onehz: out std_logic            -- ~1Hz pulse for blinkenlights
	);

end clocks_v5_minit_osc;

architecture rtl of clocks_v5_minit_osc is
	
	signal locked_int, clko_ipb_int, clko_ipb_buf, clko_125_int, clko_125_buf, clko_62_5_int, clko_62_5_buf: std_logic;
	signal sysclk: std_logic;
	signal rst: std_logic := '1';
	signal d25, d25_d: std_logic;
	
	component clock_divider_s6 port(
		clk: in std_logic;
		d25: out std_logic;
		d28: out std_logic
	);
	end component;

begin

	clkbuf: ibufds port map(
		i => sysclk_p,
		ib => sysclk_n,
		o => sysclk
	);

	bufg125: BUFG port map(
		i => clko_125_int,
		o => clko_125_buf
	);
	
	clko_125 <= clko_125_buf;

	bufg62_5: BUFG port map(
		i => clko_62_5_int,
		o => clko_62_5_buf
	);

	clko_62_5 <= clko_62_5_buf;
	
	bufgipb: BUFG port map(
		i => clko_ipb_int,
		o => clko_ipb_buf
	);
	
	clko_ipb <= clko_ipb_buf;
	
	dcm: DCM_BASE
		generic map(
			clkin_divide_by_2 => TRUE,
			clkin_period => 8.0
		)
		port map(
			clkin => sysclk,
			clk2x => clko_125_int,
			clk0 => clko_62_5_int,
			clkdv => clko_ipb_int,
			clkfb => clko_62_5_buf,
			locked => locked_int,
			rst => '0'
		);
		
	locked <= locked_int;
	
	clkdiv: clock_divider_s6 port map(
		clk => sysclk,
		d25 => d25,
		d28 => onehz
	);
	
	-- Reset generator (~100ms reset pulse)
	
	process(sysclk)
	begin
		if rising_edge(sysclk) then
			d25_d <= d25;
			if d25='1' and d25_d='0' then
				rst <= not locked_int;
			end if;
		end if;
	end process;
	
	process(clko_125_buf)
	begin
		if rising_edge(clko_125_buf) then
			rsto_125 <= rst;
		end if;
	end process;

	process(clko_62_5_buf)
	begin
		if rising_edge(clko_62_5_buf) then
			rsto_62_5 <= rst;
		end if;
	end process;
	
		process(clko_ipb_buf)
	begin
		if rising_edge(clko_ipb_buf) then
			rsto_ipb <= rst;
		end if;
	end process;
			
end rtl;

