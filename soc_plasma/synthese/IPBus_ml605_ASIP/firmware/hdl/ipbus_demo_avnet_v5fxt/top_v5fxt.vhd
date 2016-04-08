-- Top-level design for ipbus demo
--
-- This version is for xc5vfx30t on Avnet V5FXT demo board
-- Uses the v5 hard ethernet MAC with GMII inteface to an external Gb PHY
--
-- If you want to do performance testing, you can configure this design to
-- have up to 16 seperate IPbus controllers sharing the same MAC block.
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 23/2/11

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.ALL;
use work.bus_arb_decl.all;
use work.mac_arbiter_decl.all;

entity top is port(
	sys_clk_pin : in STD_LOGIC;
	leds: out STD_LOGIC_VECTOR(3 downto 0);
	gmii_tx_clk, gmii_tx_en, gmii_tx_er : out STD_LOGIC;
	gmii_txd : out STD_LOGIC_VECTOR(7 downto 0);
	gmii_rx_clk, gmii_rx_dv, gmii_rx_er: in STD_LOGIC;
	gmii_rxd : in STD_LOGIC_VECTOR(7 downto 0);
	phy_rstb : out STD_LOGIC;
	dip_switch: in std_logic_vector(3 downto 0)
	);
end top;

architecture rtl of top is

	constant N_IPB: integer := 6;
	signal clk125, clk200, ipb_clk, locked, rst_125, rst_ipb, onehz : STD_LOGIC;
	signal mac_txd, mac_rxd : STD_LOGIC_VECTOR(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxclko, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe : STD_LOGIC;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	signal txd_bus: mac_arbiter_slv_array(N_IPB-1 downto 0);
	signal txdvld_bus: mac_arbiter_sl_array(N_IPB-1 downto 0);
	signal txack_bus: mac_arbiter_sl_array(N_IPB-1 downto 0);

begin

--	DCM clock generation for internal bus, ethernet, IO delay logic
-- Input clock 100MHz

	clocks: entity work.clocks_v5_extphy port map(
		sysclk => sys_clk_pin,
		clko_125 => clk125,
		clko_200 => clk200,
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
	
	eth: entity work.eth_v5_gmii port map(
		clk125 => clk125,
		clk200 => clk200,
		rst => rst_125,
		locked => locked,
		gmii_tx_clk => gmii_tx_clk,
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
		signal oob_moti: trans_moti;
		signal oob_tomi: trans_tomi;

	begin
    
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
				mac_txd => txd_bus(i),
				mac_txdvld => txdvld_bus(i),
				mac_txack => txack_bus(i),
				ipb_out => ipb_master_out,
				ipb_in => ipb_master_in,
				mac_addr => mac_addr,
				ip_addr => ip_addr,
				oob_moti_bus(0) => oob_moti,
				oob_tomi_bus(0) => oob_tomi
			);
		
		mac_addr <= X"020ddba115" & dip_switch & std_logic_vector(to_unsigned(i, 4));
		ip_addr <= X"c0a8c8" & dip_switch & std_logic_vector(to_unsigned(i, 4));
		
		slaves: entity work.slaves port map(
			ipb_clk => ipb_clk,
			rst => rst_ipb,
    		ipb_in => ipb_master_out,
			ipb_out => ipb_master_in,
    		gpio => open,
			oob_moti => oob_moti,
			oob_tomi => oob_tomi
		);
	 
	end generate;-- ipbus control logic

end rtl;

