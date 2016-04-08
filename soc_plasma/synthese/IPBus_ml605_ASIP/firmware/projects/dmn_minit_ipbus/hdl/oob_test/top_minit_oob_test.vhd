-- Top-level design for ipbus demo
--
-- This version should work on the miniT-R2, all versions
-- Uses the v5 hard EMAC core with 1000basex interface
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
	osc_p, osc_n: in std_logic;
	led: out std_logic_vector(3 downto 0);
	clk_cntrl: out std_logic_vector(23 downto 0);
	enet_clkp, enet_clkn: in std_logic;
	enet_txp, enet_txn: out std_logic;
	enet_rxp, enet_rxn: in std_logic;
	uc_spi_miso: out std_logic;
	uc_spi_mosi: in std_logic;
	uc_spi_sck: in std_logic;
	uc_spi_cs_b: in std_logic
	);
end top;

architecture rtl of top is

	signal ethclk125, ipb_clk, locked, onehz, serdes_locked: std_logic;
	signal rst_125, rst_62_5, rst_ipb: std_logic;
	signal usrclk125, usrclk62_5: std_logic;
	signal mac_txd, mac_rxd: std_logic_vector(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxclko, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe: std_logic;
	signal sync_acq, eth_active: std_logic;
	signal ipb_master_out: ipb_wbus;
	signal ipb_master_in: ipb_rbus;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal spi_ready, spi_done, spi_wen: std_logic;
	signal spi_raddr, spi_waddr: std_logic_vector(9 downto 0);
	signal spi_rdata, spi_wdata: std_logic_vector(31 downto 0);
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_v5_minit_osc port map(
		sysclk_p => osc_p,
		sysclk_n => osc_n,
		clko_125 => usrclk125,
		clko_62_5 => usrclk62_5,
		clko_ipb => ipb_clk,
		locked => locked,
		rsto_125 => rst_125,
		rsto_62_5 => rst_62_5,
		rsto_ipb => rst_ipb,
		onehz => onehz
		);
		
	clk_cntrl <= X"004000";
		
	led(3 downto 0) <= (serdes_locked and sync_acq and locked, '0', eth_active, onehz);
	
	blink: entity work.blinker port map(
		clk => ethclk125,
		go => mac_txack,
		blink => eth_active
	);
	
--	Ethernet MAC core and PHY interface
	
	eth: entity work.eth_v5_1000basex port map(
		basex_clkp => enet_clkp,
		basex_clkn => enet_clkn,
		basex_txp => enet_txp,
		basex_txn => enet_txn,
		basex_rxp => enet_rxp,
		basex_rxn => enet_rxn,
		sync_acq => sync_acq,
		locked => serdes_locked,
		clk125_o => ethclk125,
		rst => rst_125, -- effectively an async reset
		txd => mac_txd,
		txdvld => mac_txdvld,
		txack => mac_txack,
		rxd => mac_rxd,
		rxclko => mac_rxclko,
		rxdvld => mac_rxdvld,
		rxgoodframe => mac_rxgoodframe,
		rxbadframe => mac_rxbadframe
	);

-- SPI interface

--	spi: entity work.spi_interface port map(
--		clk => usrclk125,
--		rst => rst_125,
--		spi_miso => uc_spi_miso,
--		spi_mosi => uc_spi_mosi,
--		spi_sck => uc_spi_sck,
--		spi_cs_b => uc_spi_cs_b,
--		user_clk => ipb_clk,
--		user_rst => '0',
--		cfgreq_in => '0',
--		cfgrdy_out => open,
--		transrdy_out => spi_ready,
--		transdone_in => spi_done,
--		buf_waddr_in => spi_waddr,
--		buf_wdata_in => spi_wdata,
--		buf_wen_in => spi_wen,
--		buf_raddr_in => spi_raddr,
--		buf_rdata_out => spi_rdata
--	);
	
	loopback: entity work.spi_loopback port map(
		clk => ipb_clk,
		rst => rst_ipb,
		spi_ready => spi_ready,
		spi_raddr => spi_raddr,
		spi_rdata => spi_rdata,
		spi_done => spi_done,
		spi_waddr => spi_waddr,
		spi_wdata => spi_wdata,
		spi_wen => spi_wen
	);

-- ipbus control logic

	ipbus: entity work.ipbus_ctrl port map(
		ipb_clk => ipb_clk,
		rst => rst_ipb,
		mac_txclk => ethclk125,
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
	ip_addr <= X"c0a800f0"; -- 192.168.0.240

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		rst => rst_ipb,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
-- Top level ports from here
		gpio => open,
		oob_ready => spi_ready,
		oob_raddr => spi_raddr,
		oob_rdata => spi_rdata,
		oob_waddr => spi_waddr,
		oob_wdata => spi_wdata,
		oob_wen => spi_wen,
		oob_done => spi_done
	);

end rtl;

