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
use ieee.numeric_std.all;

use work.ipbus.ALL;
use work.mac_arbiter_decl.all;

entity top is port(
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

architecture rtl of top is

	constant N_IPB: integer := 8;
	signal clk125, ipb_clk, locked, rst, onehz : STD_LOGIC;
	signal mac_txd, mac_rxd : STD_LOGIC_VECTOR(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxclko, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe : STD_LOGIC;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	signal txd_bus: mac_arbiter_slv_array(N_IPB-1 downto 0);
	signal txdvld_bus: mac_arbiter_sl_array(N_IPB-1 downto 0);
	signal txack_bus: mac_arbiter_sl_array(N_IPB-1 downto 0);

	component clock_s6 port(
		sysclk_p, sysclk_n : in STD_LOGIC;
		ext_rst: in std_logic;
		clko125, clko25, locked, rsto, onehz : out STD_LOGIC);
	end component;
	
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

	clocks: clock_s6 port map(
		sysclk_p => sysclk_p,
		sysclk_n => sysclk_n,
		clko125 => clk125,
		clko25 => ipb_clk,
		locked => locked,
		ext_rst => '0',
		rsto => rst,
		onehz => onehz
		);
		
	leds <= ('0', '0', locked, onehz);
	
--	Ethernet MAC core and PHY interface
-- In this version, consists of hard MAC core and GMII interface to external PHY
-- Can be replaced by any other MAC / PHY combination
	
	eth: eth_s6_gmii port map(
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

	begin
    
		ipbus: entity work.ipbus_wrapper port map(
			ipb_clk => ipb_clk,
			rst => rst,
			mac_txclk => clk125,
			mac_rxclk => mac_rxclko,
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
		
		mac_addr <= X"020ddba115" & dip_switch & std_logic_vector(to_unsigned(i, 4));
		ip_addr <= X"c0a8c8" & dip_switch & std_logic_vector(to_unsigned(i, 4));
		
		slaves: entity work.slaves port map(
			ipb_clk => ipb_clk,
			rst => rst,
    		ipb_in => ipb_master_out,
			ipb_out => ipb_master_in,
    		gpio => open
		);
	 
	end generate;-- ipbus control logic
	
end rtl;

