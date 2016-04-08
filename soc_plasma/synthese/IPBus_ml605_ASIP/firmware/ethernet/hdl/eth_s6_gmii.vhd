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

entity eth_s6_gmii is
	generic(
		IODEL: integer := 10
	);
	port(
		clk125: in std_logic;
		rst: in std_logic;
		gmii_gtx_clk: out std_logic;
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

end eth_s6_gmii;

architecture rtl of eth_s6_gmii is

	signal rx_clk, rx_clk_io: std_logic;
	signal txd_e, rxd_r: std_logic_vector(7 downto 0);
	signal tx_en_e, tx_er_e, rx_dv_r, rx_er_r: std_logic;
	signal gmii_rxd_del: std_logic_vector(7 downto 0);
	signal gmii_rx_dv_del, gmii_rx_er_del: std_logic;

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

begin

	rxclko <= rx_clk;

	bufio0: bufio2 port map(
		i => gmii_rx_clk,
		ioclk => rx_clk_io
	);
	
	bufg0: bufg port map(
		i => gmii_rx_clk,
		o => rx_clk
	);
	
	iodelgen: for i in 7 downto 0 generate
	begin
		iodelay: iodelay2
			generic map(
				DELAY_SRC => "IDATAIN",
				IDELAY_TYPE => "FIXED",
				IDELAY_VALUE => IODEL
			)
			port map(
				idatain => gmii_rxd(i),
				dataout => gmii_rxd_del(i),
				cal => '0',
				ce => '0',
				clk => '0',
				inc => '0',
				ioclk0 => '0',
				ioclk1 => '0',
				odatain => '0',
				rst => '0',
				t => '1'
			); -- Delay element for phase alignment
	
	end generate;
	
	iodelay_dv: iodelay2
		generic map(
			DELAY_SRC => "IDATAIN",
			IDELAY_TYPE => "FIXED",
			IDELAY_VALUE => IODEL
		)
		port map(
			idatain => gmii_rx_dv,
			dataout => gmii_rx_dv_del,
			cal => '0',
			ce => '0',
			clk => '0',
			inc => '0',
			ioclk0 => '0',
			ioclk1 => '0',
			odatain => '0',
			rst => '0',
			t => '1'
		); -- Delay element on rx clock for phase alignment
		
	iodelay_er: iodelay2
		generic map(
			DELAY_SRC => "IDATAIN",
			IDELAY_TYPE => "FIXED",
			IDELAY_VALUE => IODEL
		)
		port map(
			idatain => gmii_rx_er,
			dataout => gmii_rx_er_del,
			cal => '0',
			ce => '0',
			clk => '0',
			inc => '0',
			ioclk0 => '0',
			ioclk1 => '0',
			odatain => '0',
			rst => '0',
			t => '1'
		); -- Delay element for phase alignment

	process(rx_clk_io) -- FFs for incoming GMII data (need to be IOB FFs)
	begin
		if rising_edge(rx_clk_io) then
			rxd_r <= gmii_rxd_del;
			rx_dv_r <= gmii_rx_dv_del;
			rx_er_r <= gmii_rx_er_del;
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
	
	oddr0: oddr2 port map(
		q => gmii_gtx_clk,
		c0 => clk125,
		c1 => not clk125,
		ce => '1',
		d0 => '0',
		d1 => '1',
		r => '0',
		s => '0'
	); -- DDR register for clock forwarding

	mac: soft_emac_gmii_4_5 port map(
		reset => rst,
		emacphytxd => txd_e,
		emacphytxen => tx_en_e,
		emacphytxer => tx_er_e,
		phyemacrxd => rxd_r,
		phyemacrxdv => rx_dv_r,
		phyemacrxer => rx_er_r,
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
		rxgmiimiiclk => rx_clk,
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
	
end rtl;
