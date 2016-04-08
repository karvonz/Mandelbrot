-- Top-level design for ipbus demo
--
-- This version is for xc6slx16 on Xilinx SP601 eval board
-- Uses the s6 soft TEMAC core with GMII inteface to an external Gb PHY
-- You will need a license for the core
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 23/2/11

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;
use work.bus_arb_decl.all;

entity top_sp605 is port(
	sysclk_p, sysclk_n : in STD_LOGIC;
	leds: out STD_LOGIC_VECTOR(3 downto 0);
	gmii_gtx_clk, gmii_tx_en, gmii_tx_er : out STD_LOGIC;
	gmii_txd : out STD_LOGIC_VECTOR(7 downto 0);
	gmii_rx_clk, gmii_rx_dv, gmii_rx_er: in STD_LOGIC;
	gmii_rxd : in STD_LOGIC_VECTOR(7 downto 0);
	phy_rstb : out STD_LOGIC;
	dip_switch: in std_logic_vector(3 downto 0)
	);
end top;

architecture rtl of top_sp605 is

	signal clk125, ipb_clk, locked, rst_125, rst_ipb, onehz : STD_LOGIC;
	signal mac_txd, mac_rxd : STD_LOGIC_VECTOR(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxclko, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe : STD_LOGIC;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal oob_moti: trans_moti;
	signal oob_tomi: trans_tomi;

	component eth_s6_gmii port(
		clk125, rst : in STD_LOGIC;
		gmii_gtx_clk, gmii_tx_en, gmii_tx_er : out STD_LOGIC;
		gmii_txd : out STD_LOGIC_VECTOR(7 downto 0);
		gmii_rx_clk, gmii_rx_dv, gmii_rx_er : in STD_LOGIC;
		gmii_rxd : in STD_LOGIC_VECTOR(7 downto 0);
		txd : in STD_LOGIC_VECTOR(7 downto 0);
		txdvld : in STD_LOGIC;
		rxd : out STD_LOGIC_VECTOR(7 downto 0);
		txack, rxclko, rxdvld, rxgoodframe, rxbadframe : out STD_LOGIC);
	end component;
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_s6_extphy port map(
		sysclk_p => sysclk_p,
		sysclk_n => sysclk_n,
		clko_125 => clk125,
		clko_ipb => ipb_clk,
		locked => locked,
		rsto_125 => rst_125,
		rsto_ipb => rst_ipb,
		onehz => onehz
		);
		
	leds <= ('0', '0', locked, onehz);
	
--	Ethernet MAC core and PHY interface
-- In this version, consists of hard MAC core and GMII interface to external PHY
-- Can be replaced by any other MAC / PHY combination
	
	eth: entity work.eth_s6_gmii port map(
		clk125 => clk125,
		rst => rst_125,
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
		rxbadframe => mac_rxbadframe,
		hostclk => ipb_clk,
		hostopcode => "00",
		hostreq => '0',
		hostmiimsel => '0',
		hostaddr => (others => '0'),
		hostwrdata => (others => '0'),
		hostmiimrdy => open,
		hostrddata => open
	);
	
	phy_rstb <= '1';
	
-- ipbus control logic

	ipbus: entity work.ipbus_ctrl
		generic map(NOOB => 1)
		port map(
			ipb_clk => ipb_clk,
			rst_ipb => rst_ipb,
			rst_macclk => rst_125,
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
			ip_addr => ip_addr,
			oob_moti_bus(0) => oob_moti,
			oob_tomi_bus(0) => oob_tomi
		);
		
		mac_addr <= X"020ddba115" & dip_switch & X"0"; -- Careful here, arbitrary addresses do not always work
		ip_addr <= X"c0a8c8" & dip_switch & X"0"; -- 192.168.200.X

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		rst => rst_ipb,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
-- Top level ports from here
		gpio => open,
		oob_moti => oob_moti,
		oob_tomi => oob_tomi
	);

end rtl;

