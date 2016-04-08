-- Top-level design for ipbus demo
--
-- This version is for xc6slx16 on Xilinx SP601 eval board
-- Uses the s6 soft TEMAC core with GMII inteface to an external Gb PHY
-- You will need a license for the MAC core
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 23/2/11

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;

entity top is port(
	gtp_clkp, gtp_clkn: in std_logic;
	gtp_txp, gtp_txn: out std_logic;
	gtp_rxp, gtp_rxn: in std_logic;
	sfp_los: in std_logic;
	leds: out STD_LOGIC_VECTOR(3 downto 0);
	dip_switch: in std_logic_vector(3 downto 0)
	);
end top;

architecture rtl of top is

	signal clk125, ipb_clk, locked, rst, onehz : STD_LOGIC;
	signal mac_txd, mac_rxd : STD_LOGIC_VECTOR(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxclko, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe : STD_LOGIC;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	
begin

--	DCM clock generation for internal bus, ethernet

	clocks: entity work.clocks_s6_basex port map(
		clk125 => clk125,
		ipb_clk => ipb_clk,
		locked => locked,
		rst => rst,
		onehz => onehz
	);
		
	leds <= ('0', sfp_los, locked, onehz);
	
--	Ethernet MAC core and PHY interface

	eth: entity work.eth_s6_1000basex port map(
		gtp_clkp => gtp_clkp,
		gtp_clkn => gtp_clkn,
		gtp_txp => gtp_txp,
		gtp_txn => gtp_txn,
		gtp_rxp => gtp_rxp,
		gtp_rxn => gtp_rxn,
		clk125_out => clk125,
		rst => rst,
		locked => locked,
		txd => mac_txd,
		txdvld => mac_txdvld,
		txack => mac_txack,
		rxclko => mac_rxclko,
		rxd => mac_rxd,
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
		
	mac_addr <= X"020ddba115" & dip_switch & X"0"; -- Careful here, arbitrary addresses do not always work
	ip_addr <= X"c0a8c8" & dip_switch & X"0"; -- 192.168.200.X

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		rst => rst,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
-- Top level ports from here
		gpio => open
	);

end rtl;

