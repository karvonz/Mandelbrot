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

library ieee;
use ieee.std_logic_1164.all;
use work.ipbus.all;
use work.bus_arb_decl.all;

entity top is port(
	gpio: out STD_LOGIC_VECTOR(3 downto 0)
	);
end top;

architecture rtl of top is

	signal clk125, ipb_clk, rst : STD_LOGIC;
	signal mac_txd, mac_rxd : STD_LOGIC_VECTOR(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe : STD_LOGIC;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	signal oob_moti: trans_moti;
	signal oob_tomi: trans_tomi;
	
begin

--	Simulated clocks

  clocks: entity work.clock_sim port map(
    clko125 => clk125,
    clko25 => ipb_clk,
    rsto => rst);

-- Simulated ethernet MAC
	
  eth: entity work.eth_mac_sim port map(
    clk125 => clk125,
		rst => rst,
		txd => mac_txd,
		txdvld => mac_txdvld,
		txack => mac_txack,
		rxd => mac_rxd,
		rxdvld => mac_rxdvld,
		rxgoodframe => mac_rxgoodframe,
		rxbadframe => mac_rxbadframe);

-- ipbus control logic

	ipbus: entity work.ipbus_ctrl
	 generic map(NOOB => 1)
	 port map(
		  ipb_clk => ipb_clk,
		  rst_ipb => rst,
		  rst_macclk => rst,
		  mac_txclk => clk125,
		  mac_rxclk => clk125,
		  mac_rxd => mac_rxd,
		  mac_rxdvld => mac_rxdvld,
		  mac_rxgoodframe => mac_rxgoodframe,
		  mac_rxbadframe => mac_rxbadframe,
		  mac_txd => mac_txd,
		  mac_txdvld => mac_txdvld,
		  mac_txack => mac_txack,
		  ipb_out => ipb_master_out,
		  ipb_in => ipb_master_in,
		  mac_addr => X"a0b0c0d1e1f1", -- Careful here, abitrary addresses do not necessarily work
		  ip_addr => X"c0a8c902", -- 192.168.201.2
		  oob_moti_bus(0) => oob_moti,
		  oob_tomi_bus(0) => oob_tomi
		);

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		rst => rst,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
-- Top level ports from here
		gpio => gpio,
		oob_moti => oob_moti,
		oob_tomi => oob_tomi
	);

end rtl;

