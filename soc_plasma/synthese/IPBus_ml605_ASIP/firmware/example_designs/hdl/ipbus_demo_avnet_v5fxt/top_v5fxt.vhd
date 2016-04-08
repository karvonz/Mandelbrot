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
use IEEE.NUMERIC_STD.ALL;

use work.ipbus.ALL;
use work.bus_arb_decl.all;
use work.mac_arbiter_decl.all;

entity top is port(
	sysclk_n   : in STD_LOGIC;
	sysclk_p   : in STD_LOGIC;
	sysclk_66  : in STD_LOGIC;
	RESET      : in STD_LOGIC;
	
	leds         : out STD_LOGIC_VECTOR(7 downto 0);
	i_uart       : in STD_LOGIC;
	o_uart       : out STD_LOGIC;
	gmii_tx_clk  : out STD_LOGIC;
	gmii_gtx_clk : out STD_LOGIC;
	gmii_tx_en   : out STD_LOGIC;
	gmii_tx_er   : out STD_LOGIC;
	gmii_txd : out STD_LOGIC_VECTOR(7 downto 0);
	gmii_rx_clk, gmii_rx_dv, gmii_rx_er: in STD_LOGIC;
	gmii_rxd : in STD_LOGIC_VECTOR(7 downto 0);
	PHY_RESETB : out STD_LOGIC;
	dip_switch: in std_logic_vector(3 downto 0)
	);
end top;

architecture rtl of top is

	constant N_IPB: integer := 1; --6;
	signal clk125, clk200, ipb_clk, locked, rst_125, rst_ipb, onehz : STD_LOGIC;
	signal mac_txd, mac_rxd : STD_LOGIC_VECTOR(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxclko, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe : STD_LOGIC;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in  : ipb_rbus;
	signal txd_bus    : mac_arbiter_slv_array(N_IPB-1 downto 0);
	signal txdvld_bus : mac_arbiter_sl_array(N_IPB-1 downto 0);
	signal txack_bus  : mac_arbiter_sl_array(N_IPB-1 downto 0);
	signal reset_sig  : std_logic;
	signal sig_gmii_tx_en  : std_logic;
	signal sig_gmii_tx_er  : std_logic;
	signal sig_gmii_tx_clk : std_logic;
	signal gpio_leds : STD_LOGIC_VECTOR(7 downto 0);

	SIGNAL cntXX  : integer;
	SIGNAL cnt50  : integer;
	SIGNAL cnt125 : integer;
	SIGNAL cnt200 : integer;
	signal lXX    : std_logic;
	signal l50    : std_logic;
	signal l125   : std_logic;
	signal l200   : std_logic;
	SIGNAL max_cntXX  : integer :=  50000000;
	SIGNAL max_cnt50  : integer :=  50000000;
	SIGNAL max_cnt125 : integer := 125000000;
	SIGNAL max_cnt200 : integer := 200000000;
	signal reset_i : std_logic;

begin

--	DCM clock generation for internal bus, ethernet, IO delay logic
-- Input clock 100MHz
	reset_sig  <= NOT locked;
	PHY_RESETB <= reset_sig;

	clocks: entity work.clocks_v5_extphy port map(
		sysclk_n    => sysclk_n,
		sysclk_p    => sysclk_p,
		sysclk_66   => sysclk_66,
		clko_125    => clk125,
		clko_200    => clk200,
		clko_ipb    => ipb_clk,
		locked      => locked,
		rsto_125    => rst_125,
		rsto_ipb    => rst_ipb,
		onehz       => onehz
		);
	
	gmii_tx_en <= sig_gmii_tx_en; 
	gmii_tx_er <= sig_gmii_tx_er; 

	leds <= l200 & l125 & l50 & lXX & locked & reset_sig & RESET & rst_ipb; -- gpio_leds (3 downto 0);


	process(gmii_rx_clk)
	begin
		if rising_edge(gmii_rx_clk) then
			if RESET = '1' then
				cntXX <= 0;
				lXX   <= '0';
			else
				if cntXX = max_cntXX then
					lXX   <= not lXX;
					cntXX <= 0;
				else
					cntXX <= cntXX + 1;
				end if;
			end if;
		end if;
	end process;

	process(ipb_clk)
	begin
		if rising_edge(ipb_clk) then
			if RESET = '1' then
				cnt50 <= 0;
				l50   <= '0';
			else
				if cnt50 = max_cnt50 then
					l50   <= not l50;
					cnt50 <= 0;
				else
					cnt50 <= cnt50 + 1;
				end if;
			end if;
		end if;
	end process;

	process(clk125)
	begin
		if rising_edge(clk125) then
			if RESET = '1' then
				cnt125 <= 0;
				l125   <= '0';
			else
				if cnt125 = max_cnt125 then
					l125   <= not l125;
					cnt125 <= 0;
				else
					cnt125 <= cnt125 + 1;
				end if;
			end if;
		end if;
	end process;

	process(clk200)
	begin
		if rising_edge(clk200) then
			if RESET = '1' then
				cnt200 <= 0;
				l200   <= '0';
			else
				if cnt200 = max_cnt200 then
					l200   <= not l200;
					cnt200 <= 0;
				else
					cnt200 <= cnt200 + 1;
				end if;
			end if;
		end if;
	end process;
--
--	--
--	-- COMPTEUR POUR L'HORLOGE A 200 MHz
--	--
--	process(clk200)
--	begin
--		if rising_edge(clk200) then
--			if reset_sig = '1' then
--				cnt200 <= 0;
--				d2     <= '0';
--			else
--				if cnt200 = (200000000/2) then
--					d2     <= not d2;
--					cnt200 <= 0;
--				else
--					cnt200 <= cnt200 + 1;
--				end if;
--			end if;
--		end if;
--	end process;
--
--
--	--
--	-- COMPTEUR POUR L'HORLOGE A 32.5 MHz
--	--
--	process(ipb_clk)
--	begin
--		if rising_edge(ipb_clk) then
--			if reset_sig = '1' then
--				cnt325 <= 0;
--				d3     <= '0';
--			else
--				if cnt325 = (25000000/2) then
--					d3     <= not d3;
--					cnt325 <= 0;
--				else
--					cnt325 <= cnt325 + 1;
--				end if;
--			end if;
--		end if;
--	end process;
--
--
--	--
--	-- COMPTEUR POUR L'HORLOGE A 125 MHz
--	--
--	process(clk125)
--	begin
--		if rising_edge(clk125) then
--			if reset_sig = '1' then
--				cnt150a<= 0;
--				d4     <= '0';
--			else
--				if cnt150a = (125000000/2) then
--					d4      <= not d4;
--					cnt150a <= 0;
--				else
--					cnt150a <= cnt150a + 1;
--				end if;
--			end if;
--		end if;
--	end process;
--
--	--
--	-- COMPTEUR POUR L'HORLOGE A 100MHz
--	--
--	process(clk125)
--	begin
--		if rising_edge(mac_txdvld) then
--			if reset_sig = '1' then
--				d5  <= '0';
--			else
--				d5  <= not d5;
--			end if;
--		end if;
--	end process;
--
--
--	process(ipb_clk)
--	begin
--		if rising_edge(sys_clk_pin) then
--			if reset_sig = '1' then
----				d4 <= '0';
----				d5 <= '0';
--				d6 <= '0';
--			else
----				d2 <= ipb_master_out.ipb_strobe or d2; -- 
----				d3 <= sig_gmii_tx_en  or d3;
----				d4 <= sig_gmii_tx_er  or d4;
----				d5 <= mac_rxgoodframe or d5;
----				d6 <= mac_rxbadframe  or d6;
--				d6 <= mac_rxgoodframe or d5;
--			end if;
--		end if;
--	end process;
	
--	Ethernet MAC core and PHY interface
-- In this version, consists of hard MAC core and GMII interface to external PHY
-- Can be replaced by any other MAC / PHY combination
	gmii_tx_clk  <= '0';-- sig_gmii_tx_clk; --'0';--sig_gmii_tx_clk;
	gmii_gtx_clk <= sig_gmii_tx_clk;
	eth: entity work.eth_v5_gmii port map(
		clk125        => clk125,
		clk200        => clk200,
		rst           => RESET,
		locked        => locked,
		gmii_tx_clk   => sig_gmii_tx_clk,
		gmii_tx_en    => sig_gmii_tx_en,
		gmii_tx_er    => sig_gmii_tx_er,
		gmii_txd      => gmii_txd,
		gmii_rx_clk   => gmii_rx_clk,
		gmii_rx_dv    => gmii_rx_dv,
		gmii_rx_er    => gmii_rx_er,
		gmii_rxd      => gmii_rxd,
		txd           => mac_txd,
		txdvld        => mac_txdvld,
		txack         => mac_txack,
		rxd           => mac_rxd,
		rxclko        => mac_rxclko,
		rxdvld        => mac_rxdvld,
		rxgoodframe   => mac_rxgoodframe,
		rxbadframe    => mac_rxbadframe
	);
	
--	reset_sig  <= rst_125; --'1';
	
	arb: entity work.mac_arbiter
		generic map(
			NSRC => N_IPB
		)
		port map(
			txclk          => clk125,
			src_txd_bus    => txd_bus,
			src_txdvld_bus => txdvld_bus,
			src_txack_bus  => txack_bus,
			mac_txd        => mac_txd,
			mac_txdvld     => mac_txdvld,
			mac_txack      => mac_txack
		);
	
	ipbus_gen: for i in N_IPB-1 downto 0 generate

		signal ipb_master_out: ipb_wbus;
		signal ipb_master_in: ipb_rbus;
		signal mac_addr: std_logic_vector(47 downto 0);
		signal ip_addr: std_logic_vector(31 downto 0);
		signal oob_moti: trans_moti;
		signal oob_tomi: trans_tomi;

	begin
    
		mac_addr <= X"020ddba11510"; -- Careful here, arbitrary addresses do not always work
		ip_addr  <= X"c0a8c810";-- & dip_switch; 	  -- 192.168.200.(16 + dip_switch)

--		mac_addr <= X"020ddba115" & dip_switch & std_logic_vector(to_unsigned(i, 4));
--		ip_addr  <= X"c0a8c8"     & dip_switch & std_logic_vector(to_unsigned(i, 4));
--		ip_addr  <= X"c0a8c805"; -- 192.168.200.5
		ipbus: entity work.ipbus_ctrl
			generic map(NOOB => 1)
			port map(
				ipb_clk      => ipb_clk,
				rst_ipb      => RESET,
				rst_macclk   => RESET,
				mac_txclk    => clk125,
				mac_rxclk    => mac_rxclko,
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
		
		
		slaves: entity work.slaves port map(
			ipb_clk  => ipb_clk,
			rst      => RESET,
			i_uart   => i_uart,
			o_uart   => o_uart,
    		ipb_in   => ipb_master_out,
			ipb_out  => ipb_master_in,
    		gpio     => gpio_leds,
			oob_moti => oob_moti,
			oob_tomi => oob_tomi
		);
	 
	end generate;-- ipbus control logic

end rtl;

