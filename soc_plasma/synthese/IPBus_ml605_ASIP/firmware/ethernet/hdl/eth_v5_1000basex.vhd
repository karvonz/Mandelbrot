-- Contains the instantiation of the Xilinx MAC IP plus the PHY interface
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

entity eth_v5_1000basex is
	port(
		basex_clkp, basex_clkn: in std_logic;
		basex_txp, basex_txn: out std_logic;
		basex_rxp, basex_rxn: in std_logic;
		sync_acq: out std_logic;
		locked: out std_logic;
		clk125_o : out std_logic;
		rst: in std_logic;
		txd: in std_logic_vector(7 downto 0);
		txdvld: in std_logic;
		txack: out std_logic;
		rxclko: out std_logic;
		rxd: out std_logic_vector(7 downto 0);
		rxdvld: out std_logic;
		rxgoodframe: out std_logic;
		rxbadframe: out std_logic
	);

end eth_v5_1000basex;

architecture rtl of eth_v5_1000basex is

	signal clkin, refclk125, refclk125_buf, clk125, clk125_buf, clk62_5, clk62_5_buf: std_logic;
	signal phy_locked, dcm_locked: std_logic;

begin

   clkbuf: ibufds port map(
      i => basex_clkp,
      ib => basex_clkn,
      o => clkin
    );
	 
	bufg_ref: bufg port map(
		i => refclk125,
		o => refclk125_buf
	);
	
	dcm: DCM_BASE
		generic map(
			clkin_period => 8.0
		)
		port map(
			clkin => refclk125_buf,
			clk0 => clk125,
			clkfb => clk125_buf,
			clkdv => clk62_5,
			locked => dcm_locked,
			rst => rst
		);

	bufg_125: bufg port map(
		i => clk125,
		o => clk125_buf
	);
	
	bufg_62_5: bufg port map(
		i => clk62_5,
		o => clk62_5_buf
	);

	rxclko <= clk125_buf;
	clk125_o <= clk125_buf;
	locked <= phy_locked and dcm_locked;

	mac: entity work.v5_emac_v1_8_1000basex_block port map(
      CLK125_OUT => refclk125,
      CLK125 => clk125_buf,
      CLK62_5 => clk62_5_buf,
      EMAC1CLIENTRXD => rxd,
      EMAC1CLIENTRXDVLD => rxdvld,
      EMAC1CLIENTRXGOODFRAME => rxgoodframe,
      EMAC1CLIENTRXBADFRAME => rxbadframe,
      EMAC1CLIENTRXFRAMEDROP => open,
      EMAC1CLIENTRXSTATS => open,
      EMAC1CLIENTRXSTATSVLD => open,
      EMAC1CLIENTRXSTATSBYTEVLD => open,
      CLIENTEMAC1TXD => txd,
      CLIENTEMAC1TXDVLD => txdvld,
      EMAC1CLIENTTXACK => txack,
      CLIENTEMAC1TXFIRSTBYTE => '0',
      CLIENTEMAC1TXUNDERRUN => '0',
      EMAC1CLIENTTXCOLLISION => open,
      EMAC1CLIENTTXRETRANSMIT => open,
      CLIENTEMAC1TXIFGDELAY => (others => '0'),
      EMAC1CLIENTTXSTATS => open,
      EMAC1CLIENTTXSTATSVLD => open,
      EMAC1CLIENTTXSTATSBYTEVLD => open,
      CLIENTEMAC1PAUSEREQ => '0',
      CLIENTEMAC1PAUSEVAL => (others => '0'),
      EMAC1CLIENTSYNCACQSTATUS => sync_acq,
      EMAC1ANINTERRUPT => open,
      TXP_1 => basex_txp,
      TXN_1 => basex_txn,
      RXP_1 => basex_rxp,
      RXN_1 => basex_rxn,
      PHYAD_1 => (others => '0'),
      RESETDONE_1 => phy_locked,
      TXN_0_UNUSED => open,
      TXP_0_UNUSED => open,
      RXN_0_UNUSED => '0',
      RXP_0_UNUSED => '0',
      CLK_DS => clkin,
      GTRESET => rst,
      RESET => rst
   );

end rtl;
