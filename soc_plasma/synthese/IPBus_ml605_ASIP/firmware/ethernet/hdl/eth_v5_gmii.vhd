-- Contains the instantiation of the Xilinx MAC IP plus the GMII PHY interface
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

entity eth_v5_gmii is
	port(
		clk125: in std_logic;
		clk200: in std_logic;
		rst: in std_logic;
		locked: in std_logic;
		gmii_tx_clk: out std_logic;
		gmii_txd: out std_logic_vector(7 downto 0);
		gmii_tx_en: out std_logic;
		gmii_tx_er: out std_logic;
		gmii_rx_clk: in std_logic;
		gmii_rxd: in std_logic_vector(7 downto 0);
		gmii_rx_dv: in std_logic;
		gmii_rx_er: in std_logic;
		txd: in std_logic_vector(7 downto 0);
		txdvld: in std_logic;
		txack: out std_logic;
		rxclko: out std_logic;
		rxd: out std_logic_vector(7 downto 0);
		rxdvld: out std_logic;
		rxgoodframe: out std_logic;
		rxbadframe: out std_logic
	);

end eth_v5_gmii;

architecture rtl of eth_v5_gmii is

	signal rx_clk, gmii_rx_clk_del: std_logic;
	signal txd_e, rxd_r: std_logic_vector(7 downto 0);
	signal tx_en_e, tx_er_e, rx_dv_r, rx_er_r: std_logic;

	attribute IODELAY_GROUP: string;
	attribute IODELAY_GROUP of idelayctrl0: label is "iodel_gmii_rx";
	attribute IODELAY_GROUP of iodelay0:    label is "iodel_gmii_rx";

begin

	rxclko <= rx_clk;
	
--	idelayctrl0: idelayctrl port map(
--		refclk => clk200,
--		rst => rst
--	); -- V5 delay element controller
    idelayctrl0 : IDELAYCTRL port map (
      RDY    => open,
      REFCLK => clk200,
      RST    => rst
    );

--	iodelay0: iodelay
--		generic map(
--			IDELAY_TYPE => "FIXED",
--			IDELAY_VALUE => 0,
--			SIGNAL_PATTERN => "CLOCK"
--		)
--		port map(
--			idatain => gmii_rx_clk,
--			dataout => gmii_rx_clk_del,
--			t => '1',
--			ce => '0',
--			inc => '0',
--			c => '0',
--			rst => '0'
--		); -- Delay element on rx clock for phase alignment
    iodelay0 : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      DELAY_SRC             => "I",
      SIGNAL_PATTERN        => "CLOCK",
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN => gmii_rx_clk,
      ODATAIN => '0',
      DATAOUT => gmii_rx_clk_del,
      DATAIN  => '0',
      C       => '0',
      T       => '0',
      CE      => '0',
      INC     => '0',
      RST     => '0'
    );
	
		
--	bufg0: bufg port map(
--		i => gmii_rx_clk_del,
--		o => rx_clk
--	);
    bufg0 : BUFG port map (
      I => gmii_rx_clk_del,
      O => rx_clk
    );


	process(rx_clk) -- FFs for incoming GMII data (need to be IOB FFs)
	begin
		if rising_edge(rx_clk) then
			rxd_r <= gmii_rxd;
			rx_dv_r <= gmii_rx_dv;
			rx_er_r <= gmii_rx_er;
		end if;
	end process;

	process(clk125) -- FFs for outgoing GMII data (need to be IOB FFs)
	begin
		if rising_edge(clk125) then
			gmii_txd <= txd_e;
			gmii_tx_en <= tx_en_e;
			gmii_tx_er <= tx_er_e;
		end if;
	end process;
	
	oddr0: oddr port map(
		q => gmii_tx_clk,
		c => clk125,
		ce => '1',
		d1 => '0',
		d2 => '1',
		r => '0',
		s => '0'
	); -- DDR register for clock forwarding

	emac0: entity work.v6_emac_v1_8 port map(
--			EMAC0CLIENTRXCLIENTCLKOUT => open,
		CLIENTEMACRXCLIENTCLKIN => rx_clk,
		EMACCLIENTRXD => rxd,
		EMACCLIENTRXDVLD => rxdvld,
--		EMACCLIENTRXDVLDMSW => open,
		EMACCLIENTRXGOODFRAME => rxgoodframe,
		EMACCLIENTRXBADFRAME => rxbadframe,
--		EMAC0CLIENTRXFRAMEDROP =>
--   	EMAC0CLIENTRXSTATS =>
--		EMAC0CLIENTRXSTATSVLD =>
--		EMAC0CLIENTRXSTATSBYTEVLD =>
-- 	EMAC0CLIENTTXCLIENTCLKOUT => 
		CLIENTEMACTXCLIENTCLKIN => clk125,
		CLIENTEMACTXD => txd,
		CLIENTEMACTXDVLD => txdvld,
		CLIENTEMACTXDVLDMSW => '0',
		EMACCLIENTTXACK => txack,
		CLIENTEMACTXFIRSTBYTE => '0',
		CLIENTEMACTXUNDERRUN => '0',
--		EMAC0CLIENTTXCOLLISION =>
--		EMAC0CLIENTTXRETRANSMIT =>
		CLIENTEMACTXIFGDELAY => (others => '0'),
--		EMAC0CLIENTTXSTATS =>
--		EMAC0CLIENTTXSTATSVLD =>
--		EMAC0CLIENTTXSTATSBYTEVLD =>
		CLIENTEMACPAUSEREQ => '0',
		CLIENTEMACPAUSEVAL => (others => '0'),
		GTX_CLK => clk125, -- PATCH BLG'0',
		PHYEMACTXGMIIMIICLKIN => clk125,
--		EMAC0PHYTXGMIIMIICLKOUT =>
		GMII_TXD => txd_e,
		GMII_TX_EN => tx_en_e,
		GMII_TX_ER => tx_er_e,
		GMII_RXD => rxd_r,
		GMII_RX_DV => rx_dv_r,
		GMII_RX_ER => rx_er_r,
		GMII_RX_CLK => rx_clk,
		MMCM_LOCKED => locked,
		RESET => '0'
	);

end rtl;
