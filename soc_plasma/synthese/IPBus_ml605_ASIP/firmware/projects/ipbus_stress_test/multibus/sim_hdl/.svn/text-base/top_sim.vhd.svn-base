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
use ieee.numeric_std.all;

use work.ipbus.all;
use work.mac_arbiter_decl.all;

entity top is port(
	gpio: out STD_LOGIC_VECTOR(3 downto 0)
	);
end top;

architecture rtl of top is

  constant N_IPB: integer := 2;
	signal clk125, ipb_clk, rst : STD_LOGIC;
	signal mac_txd, mac_rxd : STD_LOGIC_VECTOR(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe : STD_LOGIC;
  signal txd_bus: mac_arbiter_slv_array(N_IPB-1 downto 0);
  signal txdvld_bus: mac_arbiter_sl_array(N_IPB-1 downto 0);
  signal txack_bus: mac_arbiter_sl_array(N_IPB-1 downto 0);
	
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

  arb: entity work.mac_arbiter
    generic map(
      NSRC => N_IPB
    )
    port map(
      txclk => clk125,
      src_txd_bus => txd_bus,
      src_txdvld_bus => txdvld_bus,
      src_txack_bus => txack_bus,
      mac_txd => mac_txd,
      mac_txdvld => mac_txdvld,
      mac_txack => mac_txack
    );
	
  ipbus_gen: for i in N_IPB-1 downto 0 generate

    signal ipb_master_out: ipb_wbus;
    signal ipb_master_in: ipb_rbus;
    signal mac_addr: std_logic_vector(47 downto 0);
    signal ip_addr: std_logic_vector(31 downto 0);

  begin
    
    ipbus: entity work.ipbus_wrapper port map(
		  ipb_clk => ipb_clk,
		  rst => rst,
		  mac_txclk => clk125,
		  mac_rxclk => clk125,
		  mac_rxd => mac_rxd,
		  mac_rxdvld => mac_rxdvld,
		  mac_rxgoodframe => mac_rxgoodframe,
		  mac_rxbadframe => mac_rxbadframe,
		  mac_txd => txd_bus(i),
		  mac_txdvld => txdvld_bus(i),
		  mac_txack => txack_bus(i),
		  ipb_master_out => ipb_master_out,
		  ipb_master_in => ipb_master_in,
		  mac_addr => mac_addr,
		  ip_addr => ip_addr
		);
		
		mac_addr <= X"a0b0c0d1e1f" & std_logic_vector(to_unsigned(i, 4));
    ip_addr <= X"c0a8c9f" & std_logic_vector(to_unsigned(i, 4));
    

  	 slaves: entity work.slaves port map(
		  ipb_clk => ipb_clk,
		  rst => rst,
    		ipb_in => ipb_master_out,
	 	  ipb_out => ipb_master_in,
    		gpio => open
	 );
	 
	end generate;

end rtl;

