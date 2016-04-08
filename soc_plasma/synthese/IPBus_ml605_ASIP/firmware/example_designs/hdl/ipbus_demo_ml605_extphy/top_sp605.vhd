-- Top-level design for ipbus demo
--
-- This version is for xc6vlx240t on Xilinx ML605 eval board
-- Uses the v6 hard EMAC core with GMII interface to an external Gb PHY
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, May 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;

library unisim;
use unisim.VComponents.all;

entity top is port(
	sysclk_p, sysclk_n: in std_logic;
	leds: out std_logic_vector(7 downto 0);
	gmii_gtx_clk, gmii_tx_en, gmii_tx_er: out std_logic;
	gmii_txd: out std_logic_vector(7 downto 0);
	gmii_rx_clk, gmii_rx_dv, gmii_rx_er: in std_logic;
	gmii_rxd: in std_logic_vector(7 downto 0);
	phy_rstb: out std_logic;
	userio_p, userio_n: out std_logic
	);
end top;

architecture rtl of top is

	signal clk125, clk200, ipb_clk, locked, rst, onehz: std_logic;
	signal mac_txd, mac_rxd: std_logic_vector(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxclko, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe: std_logic;
	signal ipb_master_out: ipb_wbus;
	signal ipb_master_in: ipb_rbus;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_v6 port map(
		sysclk_p => sysclk_p,
		sysclk_n => sysclk_n,
		clko125 => clk125,
		clko200 => clk200,
		clko_ipb => ipb_clk,
		locked => locked,
		rsto => rst,
		onehz => onehz
		);
		
	leds(3 downto 0) <= ('0', '0', locked, onehz);
	
--	Ethernet MAC core and PHY interface
	
	eth: entity work.eth_v6_gmii port map(
		clk125 => clk125,
		clk200 => clk200,
		rst => rst,
		locked => locked,
		gmii_gtx_clk => gmii_gtx_clk,
		gmii_tx_en => gmii_tx_en,
		gmii_tx_er => gmii_tx_er,
		gmii_txd => gmii_txd,
		gmii_rx_clk => gmii_rx_clk,
		gmii_rx_dv => gmii_rx_dv,
		gmii_rx_er => gmii_rx_er,
		gmii_rxd => gmii_rxd,
		txd => mac_txd,
		txdvld => mac_txdvld,
		txack => mac_txack,
		rxd => mac_rxd,
		rxclko => mac_rxclko,
		rxdvld => mac_rxdvld,
		rxgoodframe => mac_rxgoodframe,
		rxbadframe => mac_rxbadframe
	);
	
	phy_rstb <= '1';
	
-- ipbus control logic

	ipbus: entity work.ipbus_ctrl port map(
		ipb_clk => ipb_clk,
		rst => rst,
		mac_txclk => clk125,
		mac_rxclk => mac_rxclko,
		mac_rxd => mac_rxd,
		mac_rxdvld => mac_rxdvld,
		mac_rxgoodframe => mac_rxgoodframe,
		mac_rxbadframe => mac_rxbadframe,
		mac_txd => mac_txd,
		mac_txdvld => mac_txdvld,
		mac_txack => mac_txack,
		ipb_out => ipb_master_out,
		ipb_in => ipb_master_in,
		mac_addr => mac_addr,
		ip_addr => ip_addr
		);
		
		mac_addr <= X"000A3501EAF2"; -- Careful here, arbitrary addresses do not always work
		ip_addr <= X"c0a8010a"; -- 192.168.1.10

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		rst => rst,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
-- Top level ports from here
		gpio => leds(7 downto 4)
	);

	obuf0: obufds port map(
		i => clk125,
		o => userio_p,
		ob => userio_n
	);

end rtl;

