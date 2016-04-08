-- Top-level design for ipbus demo
--
-- This version is for simulation of the ipbus firmware and slaves
-- It instantiates behavioural models of the ethernet mac and clock generator
--
-- The sim ethernet mac allows the design to be stimulated with packet information from a file
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, March 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;

entity top is port(
	gpio: out STD_LOGIC_VECTOR(3 downto 0);
	);
end top;

architecture rtl of top is

	signal clk125, ipb_clk, rst : STD_LOGIC;
	signal mac_txd, mac_rxd : STD_LOGIC_VECTOR(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxclko, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe : STD_LOGIC;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	
begin

--	Simulated clocks

  clocks: entity work.clock_sim port map(
    clko125 => clk125,
    clko25 => ipb_clk,
    rsto => rst);

--	Ethernet MAC core and PHY interface
-- In this version, consists of hard MAC core and GMII interface to external PHY
-- Can be replaced by any other MAC / PHY combination
	
	eth: eth_s6_gmii
		generic map(IODEL_VAL => 0)
		port map(
			clk125 => clk125,
			rst => rst,
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
			rxbadframe => mac_rxbadframe);
	
	phy_rstb <= '1';
	
-- ipbus control logic

	ipbus: entity work.ipbus_wrapper port map(
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
		ipb_master_out => ipb_master_out,
		ipb_master_in => ipb_master_in,
		mac_addr => X"a0b0c0d0e0f1", -- Careful here, abitrary addresses do not necessarily work
		ip_addr => X"c0a8c8f1" -- 192.168.200.241
		);

-- The ipbus fabric, including address select logic and slaves
-- The slaves can expose top-level ports via this interface.
-- One can structure things differently if required

	ipbus_fabric: entity work.ipbus_fabric port map(
		ipb_clk => ipb_clk,
		rst => rst,
		ipb_slave_in => ipb_master_out,
		ipb_slave_out => ipb_master_in,
-- Top level ports from here
		gpio => open
	);

end rtl;

