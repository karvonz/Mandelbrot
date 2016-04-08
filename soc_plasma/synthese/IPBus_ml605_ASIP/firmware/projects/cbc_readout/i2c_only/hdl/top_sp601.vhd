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
use work.ipbus.ALL;

--! Use UNISIM for Xilix primitives
Library UNISIM;
use UNISIM.vcomponents.all;

entity top is port(
	sysclk_p, sysclk_n : in STD_LOGIC;
	leds: out STD_LOGIC_VECTOR(3 downto 0);
	gmii_gtx_clk, gmii_tx_en, gmii_tx_er : out STD_LOGIC;
	gmii_txd : out STD_LOGIC_VECTOR(7 downto 0);
	gmii_rx_clk, gmii_rx_dv, gmii_rx_er: in STD_LOGIC;
	gmii_rxd : in STD_LOGIC_VECTOR(7 downto 0);
	phy_rstb : out STD_LOGIC;
	dip_switch: in std_logic_vector(3 downto 0);  --! Used to set MAC,IP
	-- Main I2C signals
	i2c_sda_io: inout std_logic;
	i2c_scl_io: inout std_logic;
        -- CBC I2C signals
	cbc_i2c_sda_i : in std_logic;  --! Input from CBC cbc_i2c_sda_i
	cbc_i2c_sda_o: out std_logic;  --! Active low. SDA pulled low when enb is high 
	cbc_i2c_scl_o: out std_logic;  --! I2C Clock output.
        -- CBC "fast" signals.
        cbc_trg_o : out std_logic;      --! Trigger to CBC
        ext_trg_o : out std_logic;      --! Trigger to pulsegen
        cbc_reset_o : out std_logic;    --! CBC reset
	cbc_data_n_i: in std_logic;     --! Data from CBC. Inverted
        cbc_data_clk_o : out std_logic  --! Clock to CBC
        -- GPIO signals for monitoring
--        GPIO_HDR : out std_logic_vector(1 downto 0)
	);
end top;

architecture rtl of top is

	signal clk125, ipb_clk, locked, rst, onehz : STD_LOGIC;
        signal ipb_clk_n : STD_LOGIC;
	signal mac_txd, mac_rxd : STD_LOGIC_VECTOR(7 downto 0);
	signal mac_txdvld, mac_txack, mac_rxclko, mac_rxdvld, mac_rxgoodframe, mac_rxbadframe : STD_LOGIC;
	signal ipb_master_out : ipb_wbus;
	signal ipb_master_in : ipb_rbus;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);

        signal s_cbc_data: std_logic; 
	-- signals for main I2C
	signal i2c_sda_oen_s: std_logic;
	signal i2c_scl_oen_s: std_logic;

	component clock_s6 port(
          sysclk_p, sysclk_n : in STD_LOGIC;
          ext_rst: in std_logic;
          clko125, clko25, locked, rsto, onehz : out STD_LOGIC);
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

        eth: entity work.eth_s6_gmii port map(
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
		rxbadframe => mac_rxbadframe,
		hostclk => ipb_clk,
		hostopcode => "00",
		hostreq => '0',
		hostmiimsel => '0',
		hostaddr => (others => '0'),
		hostwrdata => (others => '0'),
		hostmiimrdy => open,
		hostrddata => open
	);
	
	phy_rstb <= '1';
	
-- ipbus control logic

        ipbus: entity work.ipbus_ctrl port map(
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
		ipb_out => ipb_master_out,
		ipb_in => ipb_master_in,
		mac_addr => mac_addr,
		ip_addr => ip_addr
		);
				
		mac_addr <= X"020ddba115" & dip_switch & X"0"; -- Careful here, arbitrary addresses do not always work
		ip_addr <= X"c0a8c8" & dip_switch & X"0"; -- 192.168.200.X

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.
	slaves: entity work.slaves port map(
		ipb_clk => ipb_clk,
		rst => rst,
		ipb_in => ipb_master_out,
		ipb_out => ipb_master_in,
-- Top level ports from here
		gpio => open,
		-- Main I2C signals
		i2c_scl_i => i2c_scl_io ,
		i2c_scl_oen_o => i2c_scl_oen_s ,
		i2c_sda_i => i2c_sda_io,
		i2c_sda_oen_o => i2c_sda_oen_s,
                -- CBC I2C signals
		cbc_i2c_sda_i => cbc_i2c_sda_i,  --! cbc_i2c_sda_i
                cbc_i2c_sda_enb_o => cbc_i2c_sda_o,
                cbc_i2c_scl_o => cbc_i2c_scl_o,
                -- CBC "fast" signals
                cbc_trg_o => cbc_trg_o,
                ext_trg_o => ext_trg_o,
                cbc_reset_o => cbc_reset_o, 
                cbc_data_i => s_cbc_data
	);

        s_cbc_data <= not cbc_data_n_i;  --! Sort out inversion of data line

        ipb_clk_n <= not ipb_clk;
        ODDR2_inst : ODDR2
          generic map(
            DDR_ALIGNMENT => "NONE",
            INIT => '0',
            SRTYPE => "SYNC"
            )
          port map (
            Q => cbc_data_clk_o, -- 1-bit output data
            C0 =>ipb_clk , -- 1-bit clock input
            C1 => ipb_clk_n , -- 1-bit clock input
            CE => '1', -- 1-bit clock enable input
            D0 => '1', -- 1-bit data input (associated with C0)
            D1 => '0', --1-bit data input (associated with C1)
            R => '0', -- 1-bit reset input
            S => '0' -- 1-bit set input
            );

        
        
        -- For main I2C bus, need to put in a tri-state....
	i2c_scl_io <= '0' when (i2c_scl_oen_s = '0') else 'Z';
	i2c_sda_io <= '0' when (i2c_sda_oen_s = '0') else 'Z';

        -- Feed output from core back to input. Needed??
        --cbc_i2c_sda_i_s <= cbc_i2c_sda_i and cbc_i2c_sda_o_s;
	--cbc_i2c_sda_o <= cbc_i2c_sda_o_s;

        -- purpose: Copies the CBC input data to the GPIO header to avoid it getting optimized away
        -- type   : combinational
        -- inputs : ipb_clk
        -- outputs: gpio_hdr[0] , gpio_hdr[1]
--        mirror_data: process (ipb_clk , ipb_clk_n , cbc_data_n_i)
--        begin  -- process mirror_data
--          if rising_edge(ipb_clk) then
--            gpio_hdr(0) <= cbc_data_n_i;
--          end if;
--          if rising_edge(ipb_clk_n) then
--            gpio_hdr(1) <= cbc_data_n_i;
--          end if;
--        end process mirror_data;
        
end rtl;

