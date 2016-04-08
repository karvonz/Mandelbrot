-- Contains the instantiation of the Xilinx MAC & 1000baseX pcs/pma & GTP transceiver cores
--
-- Do not change signal names in here without correspondig alteration to the timing contraints file
--
-- Dave Newbold, April 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.VComponents.all;

entity eth_s6_1000basex is
	port(
		gtp_clkp, gtp_clkn: in std_logic;
		gtp_txp, gtp_txn: out std_logic;
		gtp_rxp, gtp_rxn: in std_logic;
		clk125_out: out std_logic;
		rst: in std_logic;
		locked: in std_logic;
		txd: in std_logic_vector(7 downto 0);
		txdvld: in std_logic;
		txack: out std_logic;
		rxclko: out std_logic;
		rxd: out std_logic_vector(7 downto 0);
		rxdvld: out std_logic;
		rxgoodframe: out std_logic;
		rxbadframe: out std_logic;
		hostclk: in std_logic;
		hostopcode: in std_logic_vector(1 downto 0);
		hostreq: in std_logic;
		hostmiimsel: in std_logic;
		hostaddr: in std_logic_vector(9 downto 0);
		hostwrdata: in std_logic_vector(31 downto 0);
		hostmiimrdy: out std_logic;
		hostrddata: out std_logic_vector(31 downto 0)
	);

end eth_s6_1000basex;

architecture rtl of eth_s6_1000basex is

	component soft_emac_gmii_4_5
		port (
		reset: in std_logic;
		emacphytxd: out std_logic_vector(7 downto 0);
		emacphytxen: out std_logic;
		emacphytxer: out std_logic;
		phyemacrxd: in std_logic_vector(7 downto 0);
		phyemacrxdv: in std_logic;
		phyemacrxer: in std_logic;
--		emacphymclkout: out std_logic;
--		emacphymdtri: out std_logic;
--		emacphymdout: out std_logic;
--		phyemacmdin: in std_logic;
		clientemactxd: in std_logic_vector(7 downto 0);
		clientemactxdvld: in std_logic;
		emacclienttxack: out std_logic;
		clientemactxunderrun: in std_logic;
		clientemactxifgdelay: in std_logic_vector(7 downto 0);
		clientemacpausereq: in std_logic;
		clientemacpauseval: in std_logic_vector(15 downto 0);
		emacclientrxd: out std_logic_vector(7 downto 0);
		emacclientrxdvld: out std_logic;
		emacclientrxgoodframe: out std_logic;
		emacclientrxbadframe: out std_logic;
		emacclienttxstats: out std_logic_vector(31 downto 0);
		emacclienttxstatsvld: out std_logic;
		emacclientrxstats: out std_logic_vector(27 downto 0);
		emacclientrxstatsvld: out std_logic;
		tieemacconfigvec: in std_logic_vector(67 downto 0); 
		txgmiimiiclk: in std_logic;
		rxgmiimiiclk: in std_logic;
		speedis100: out std_logic;
		speedis10100: out std_logic;
--		hostclk: in std_logic;
--		hostopcode: in std_logic_vector(1 downto 0);
--		hostreq: in std_logic;
--		hostmiimsel: in std_logic;
--		hostaddr: in std_logic_vector(9 downto 0);
--		hostwrdata: in std_logic_vector(31 downto 0);
--		hostmiimrdy: out std_logic;
--		hostrddata: out std_logic_vector(31 downto 0);
		corehassgmii: in std_logic);
	end component;

	signal gmii_txd, gmii_rxd: std_logic_vector(7 downto 0);
	signal gmii_tx_en, gmii_tx_er, gmii_rx_dv, gmii_rx_er: std_logic;
	signal gmii_rx_clk: std_logic;
	signal clkin, clk125, gtpclkout, gtpclkout_buf: std_logic;
	signal status: std_logic_vector(15 downto 0);

begin
	
	ibuf0: IBUFDS port map(
		i => gtp_clkp,
		ib => gtp_clkn,
		o => clkin
	);
	
	bufio0: BUFIO2
		generic map(
			divide => 1,
			divide_bypass => true
		)
		port map(
			divclk => gtpclkout_buf,
			i => gtpclkout,
			ioclk => open,
			serdesstrobe => open
		);

   bufg0: BUFG port map(
      i => gtpclkout_buf,
      o => clk125
   );

	clk125_out <= clk125;
	rxclko <= clk125;

	mac: soft_emac_gmii_4_5 port map(
		reset => rst,
		emacphytxd => gmii_txd,
		emacphytxen => gmii_tx_en,
		emacphytxer => gmii_tx_er,
		phyemacrxd => gmii_rxd,
		phyemacrxdv => gmii_rx_dv,
		phyemacrxer => gmii_rx_er,
--		emacphymclkout => open,
--		emacphymdtri => open,
--		emacphymdout => open,
--		phyemacmdin => '0',
		clientemactxd => txd,
		clientemactxdvld => txdvld,
		emacclienttxack => txack,
		clientemactxunderrun => '0',
		clientemactxifgdelay => (others => '0'),
		clientemacpausereq => '0',
		clientemacpauseval => (others => '0'),
		emacclientrxd => rxd,
		emacclientrxdvld => rxdvld,
		emacclientrxgoodframe => rxgoodframe,
		emacclientrxbadframe => rxbadframe,
		emacclienttxstats => open,
		emacclienttxstatsvld => open,
		emacclientrxstats => open,
		emacclientrxstatsvld => open,
		tieemacconfigvec => X"50204000000000000", 
		txgmiimiiclk => clk125,
		rxgmiimiiclk => clk125,
		speedis100 => open,
		speedis10100 => open,
--		hostclk => hostclk,
--		hostopcode => hostopcode,
--		hostreq => hostreq,
--		hostmiimsel => hostmiimsel,
--		hostaddr => hostaddr,
--		hostwrdata => hostwrdata,
--		hostmiimrdy => hostmiimrdy,
--		hostrddata => hostrddata,
		corehassgmii => '0'
	);
			
	phy: entity work.gig_eth_pcs_pma_v11_1_block port map(
      gtpclkout => gtpclkout,
      gtpreset0 => '0',  -- rely upon powerup reset for now
      gmii_txd0 => gmii_txd,
      gmii_tx_en0 => gmii_tx_en,
      gmii_tx_er0 => gmii_tx_er,
      gmii_rxd0 => gmii_rxd,
      gmii_rx_dv0 => gmii_rx_dv,
      gmii_rx_er0 => gmii_rx_er,
      gmii_isolate0 => open,
      configuration_vector0 => "0000",
      status_vector0 => status,
      reset0 => rst,
      signal_detect0 => '1',
      clkin => clkin,
      userclk2 => clk125,
      txp0 => gtp_txp,
      txn0 => gtp_txn,
      rxp0 => gtp_rxp,
      rxn0 => gtp_rxn,
      txp1 => open,
      txn1 => open,
      rxp1 => '0',
      rxn1 => '0'
     );
	  
end rtl;
