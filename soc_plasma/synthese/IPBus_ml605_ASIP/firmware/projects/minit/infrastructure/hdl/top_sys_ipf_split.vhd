
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

LIBRARY work;
USE work.package_utilities.ALL;
USE work.package_types.ALL;

USE work.ethernet_mac_components.ALL;
USE work.ipbus_components.ALL;
USE work.ethernet_types.ALL;

ENTITY top_sys_ipf IS
  GENERIC (
    firmware_version      : std_logic_vector(7 DOWNTO 0):= x"02"; 
    firmware_day          : std_logic_vector(7 DOWNTO 0):= x"08"; 
    firmware_month        : std_logic_vector(7 DOWNTO 0):= x"09"; 
    firmware_year         : std_logic_vector(7 DOWNTO 0):= x"10"; 
    gtx_min          	  : natural := 0;
    gtx_max          	  : natural := 11	-- was 11
  );	   
  PORT (
    -- Main clks AND CONFIGURATION
    clk1_p, clk1_n        : IN  std_logic;
    clk2_p, clk2_n        : IN  std_logic;
    osc1_p, osc1_n        : IN  std_logic;
    osc2_p, osc2_n        : IN  std_logic;
    -- Clk distribution
    clk_cntrl             : OUT  std_logic_vector (23 DOWNTO 0);
    -- Opto control
    snap12_tx0_cntrl      : INOUT std_logic_vector(5 DOWNTO 0);
    snap12_rx0_cntrl      : INOUT std_logic_vector(5 DOWNTO 0);
    snap12_rx2_cntrl      : INOUT std_logic_vector(5 DOWNTO 0);
    -- Clk synthesis
    si5326_cntrl          : INOUT std_logic_vector (4 DOWNTO 0);
    -- Ethernet Fibre.  Check polarity AND PORT...
    enet_fibre_txp                 : OUT std_logic;
    enet_fibre_txn                 : OUT std_logic;
    enet_fibre_rxp                 : IN  std_logic;
    enet_fibre_rxn                 : IN  std_logic;
    enet_fibre_clkp              : IN  std_logic;
    enet_fibre_clkn              : IN  std_logic;
    -- Ethernet Backplane.  Check polarity AND PORT...
--     enet_bp_clkp         : IN  std_logic;
--     enet_bp_clkn         : IN  std_logic;
--     enet_bp_txp          : OUT std_logic;
--     enet_bp_txn          : OUT std_logic;
--     enet_bp_rxp          : IN  std_logic;
--     enet_bp_rxn          : IN  std_logic;
    -- Rx Serial
    rxn_ch0_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    rxn_ch1_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    rxp_ch0_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    rxp_ch1_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    -- Ref clock
    refclkp_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    refclkn_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    -- Tx Serial
    txn_ch0_out      : OUT  std_logic_vector(gtx_max DOWNTO gtx_min);
    txn_ch1_out      : OUT  std_logic_vector(gtx_max DOWNTO gtx_min);
    txp_ch0_out      : OUT  std_logic_vector(gtx_max DOWNTO gtx_min);
    txp_ch1_out      : OUT  std_logic_vector(gtx_max DOWNTO gtx_min);
    -- Misc
    cpld                  : IN  std_logic_vector (9 DOWNTO 0);
    hdr_p                 : OUT  std_logic_vector(3 DOWNTO 0) := (others=>'1');
    hdr_n                 : OUT  std_logic_vector(3 DOWNTO 0) := (others=>'0');
    led                   : OUT  std_logic_vector (3 DOWNTO 0));
END top_sys_ipf;

ARCHITECTURE behavioral OF top_sys_ipf IS

-- signals from Greg's design
  SIGNAL clk1, clk2, osc1, osc2: std_logic;
  SIGNAL clk125, clk125_p, clk125_n: std_logic;
  SIGNAL clk62_5, clk62_5_p, clk62_5_n: std_logic;
  -- SIGNAL clk125_refclk_after_gtx, clk125_refclk_after_gtx_p, clk125_refclk_after_gtx_n: std_logic;
  -- SIGNAL clk125_refclk_before_gtx, clk125_refclk_before_gtx_p, clk125_refclk_before_gtx_n: std_logic;
  SIGNAL rst_b, rst: std_logic;
  SIGNAL rst_powerup_b, rst_short: std_logic;
  SIGNAL blink: std_logic;
  SIGNAL led_int: std_logic_vector(3 DOWNTO 0);

  SIGNAL ipbus_strobe               : std_logic;
  SIGNAL ipbus_wdata                : std_logic_vector(31 DOWNTO 0);
  SIGNAL ipbus_addr                 : std_logic_vector(31 DOWNTO 0);
  SIGNAL ipbus_rdata                : std_logic_vector(31 DOWNTO 0);
  SIGNAL ipbus_ack                  : std_logic;
  SIGNAL ipbus_write                : std_logic;
  SIGNAL ipbus_err                 : std_logic;

  SIGNAL test                : std_logic_vector(31 DOWNTO 0);
  SIGNAL debug                : std_logic_vector(7 DOWNTO 0);
  SIGNAL enet_ok,enet_gtx_rst    : std_logic; 
  SIGNAL enet_bp_ok, enet_mac_rst    : std_logic; 
-- END signals from Greg's design

  
-- signals from Dave's design  
  -- SIGNAL clk125 : std_logic; 
  -- SIGNAL clk200 : std_logic; 
  -- SIGNAL int_clk : std_logic; 
  -- SIGNAL locked : std_logic; 
  -- SIGNAL ctr125 : std_logic; 
  -- SIGNAL rst : std_logic; 

  -- SIGNAL ctr125_d : std_logic; 
  SIGNAL mac_txd : std_logic_vector(7 DOWNTO 0);
  SIGNAL mac_rxd : std_logic_vector(7 DOWNTO 0);
  SIGNAL mac_txdvld : std_logic; 
  SIGNAL mac_txack : std_logic; 
  SIGNAL mac_rxclk : std_logic; 
  SIGNAL mac_rxdvld : std_logic; 
  SIGNAL mac_rxgoodframe : std_logic; 
  SIGNAL mac_rxbadframe : std_logic; 
  -- SIGNAL wb_dat_i: std_logic_vector(31 DOWNTO 0);
  -- SIGNAL wb_dat_o: std_logic_vector(31 DOWNTO 0);
  -- SIGNAL wb_adr: std_logic_vector(31 DOWNTO 0);
  -- SIGNAL wb_stb : std_logic; 
  -- SIGNAL wb_we : std_logic; 
  -- SIGNAL wb_ack : std_logic; 
  -- SIGNAL wb_err : std_logic;
-- signals from Dave's design	
 
  SIGNAL hard_resets_int : std_logic_vector(31 DOWNTO 0);
  SIGNAL reset_mac , reset_comms : std_logic;  

 
  CONSTANT slave: std_logic_vector(31 DOWNTO 0) := x"00000000";
  CONSTANT firmware: std_logic_vector(31 DOWNTO 0):= firmware_year & firmware_month & firmware_day & firmware_version;

-- COMPONENT main_pbus IS
	-- PORT(
		-- rst_async                  : IN std_logic;
		-- clk                        : IN std_logic;
		-- ipbus_write_in              : IN std_logic;
		-- ipbus_en_in                 : IN std_logic;
		-- ipbus_wdata_in              : IN std_logic_vector(31 DOWNTO 0);
		-- ipbus_add_in                : IN std_logic_vector(31 DOWNTO 0);
		-- ipbus_rdata_out             : OUT std_logic_vector(31 DOWNTO 0);
		-- ipbus_ack_out               : OUT std_logic;
		-- led_out                    : OUT std_logic_vector(3 DOWNTO 0)
	-- );
-- END COMPONENT;



  


  
  COMPONENT core_sys IS
  GENERIC(
    firmware         : std_logic_vector(31 DOWNTO 0);
    slave            : std_logic_vector(31 DOWNTO 0);
    i2c_clk_speed    : natural := 100000;
    gtx_min          : natural := 0;
    gtx_max          : natural := 0;
    gtx_clk          : natural := 0;
    local_lhc_bunch_count     : integer := lhc_bunch_count;   -- USE 200 FOR sim ELSE lhc_bunch_count
    sim_mode                  : string     := "FAST";         -- Set TO Fast Functional Simulation Model
    sim_gtx_reset_speedup     : integer    := 0;              -- Set TO 1 TO speed up sim reset
    sim_pll_perdiv2           : bit_vector := x"0d0");        -- Set TO the VCO Unit Interval time);
  PORT (
    fabric_reset_in        : IN std_logic;
    fabric_clk1x_in        : IN std_logic;
    link_reset_in          : IN std_logic;
    link_clk1x_in          : IN std_logic;
    -- Parallel BUS
    ipbus_addr_in     : IN std_logic_vector(31 DOWNTO 0);
    ipbus_wdata_in    : IN std_logic_vector(31 DOWNTO 0);
    ipbus_strobe_in   : IN std_logic;
    ipbus_write_in    : IN std_logic;
    ipbus_rdata_out   : OUT std_logic_vector(31 DOWNTO 0);
    ipbus_ack_out     : OUT std_logic;
    ipbus_berr_out    : OUT std_logic;
    -- Rx Serial
    rxn_ch0_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    rxn_ch1_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    rxp_ch0_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    rxp_ch1_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    -- Ref clock
    refclkp_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    refclkn_in       : IN   std_logic_vector(gtx_max DOWNTO gtx_min);
    -- Tx Serial
    txn_ch0_out      : OUT  std_logic_vector(gtx_max DOWNTO gtx_min);
    txn_ch1_out      : OUT  std_logic_vector(gtx_max DOWNTO gtx_min);
    txp_ch0_out      : OUT  std_logic_vector(gtx_max DOWNTO gtx_min);
    txp_ch1_out      : OUT  std_logic_vector(gtx_max DOWNTO gtx_min);
    -- Clock synthesis control
    si5326_cntrl     : INOUT std_logic_vector(4 DOWNTO 0);
    snap12_tx0_cntrl : INOUT std_logic_vector(5 DOWNTO 0);
    snap12_rx0_cntrl : INOUT std_logic_vector(5 DOWNTO 0);
    snap12_rx2_cntrl : INOUT std_logic_vector(5 DOWNTO 0);
    debug_out	     : OUT std_logic_vector(7 DOWNTO 0);
    test_out         : OUT std_logic_vector(31 DOWNTO 0));
  END COMPONENT;

 
begin

  -- Ethernet interface
  -- ipbus_fibre: enet_gtx_ch0_top
  -- PORT MAP (
    -- reset_in => enet_mac_rst,
    -- clk125_in => osc1,
    -- clk125_out => clk125,
    -- gtx_powerdownpll_in => enet_gtx_rst, 
    -- gtx_powerdownclk_in => enet_gtx_rst,
    -- enet_tx_p_out => enet_fibre_txp,
    -- enet_tx_n_out => enet_fibre_txn,
    -- enet_rx_p_in => enet_fibre_rxp,
    -- enet_rx_n_in => enet_fibre_rxn,
    -- enet_clk_p_in => enet_fibre_clkp,
    -- enet_clk_n_in => enet_fibre_clkn,
    -- enet_ok_out => enet_ok, 
    -- ipbus_rdata_in => ipbus_rdata,
    -- ipbus_wdata_out => ipbus_wdata,
    -- ipbus_strobe_out => ipbus_strobe,
    -- ipbus_write_out => ipbus_write,
    -- ipbus_ack_in => ipbus_ack,
    -- ipbus_berr_in => ipbus_berr,
    -- ipbus_addr_out => ipbus_addr,
    -- ipbus_test_out => OPEN);

--   -- Ethernet interface
--   ipbus_backplane: enet_gtx_ch1_top
--   PORT MAP (
--     reset_in => enet_mac_rst,
--     clk125_in => osc1,
--     clk125_out => clk125,
--     clk125_refclk_after_gtx => clk125_refclk_after_gtx,
--     clk125_refclk_before_gtx => clk125_refclk_before_gtx,
--     gtx_powerdownpll_in => enet_gtx_rst, 
--     gtx_powerdownclk_in => enet_gtx_rst,
--     enet_tx_p_out => enet_bp_txp,
--     enet_tx_n_out => enet_bp_txn,
--     enet_rx_p_in => enet_bp_rxp,
--     enet_rx_n_in => enet_bp_rxn,
--     enet_clk_p_in => enet_bp_clkp,
--     enet_clk_n_in => enet_bp_clkn,
--     enet_ok_out => enet_ok, 
--     ipbus_rdata_in => ipbus_rdata,
--     ipbus_wdata_out => ipbus_wdata,
--     ipbus_strobe_out => ipbus_strobe,
--     ipbus_write_out => ipbus_write,
--     ipbus_ack_in => ipbus_ack,
--     ipbus_berr_in => ipbus_berr,
--     ipbus_addr_out => ipbus_addr,
--     ipbus_test_out => OPEN);

	-- clks_soft_mac_inst : clks_soft_mac
	-- PORT MAP(
		-- clki => sys_clk_pin,
		-- clko => clk125,
		-- clko2x => clk200,
		-- -- clkd4 => int_clk,
		-- locked => locked,
		-- rsto => rst
    -- );

	-- divctr_inst : divctr
	-- PORT MAP(
		-- clk => clk125,
		-- clkdiv => ctr125
	-- );

	reset_mac <= '0'; --rst OR hard_resets_int(30);

	clks_hard_mac_inst: clks_hard_mac
	PORT MAP(
		clk_125_in => osc1,
		clk_125_out => clk125, 
		clk_62_5_out => clk62_5, 
		rst => reset_mac
	);

	mac_top : hard_mac_top
	GENERIC MAP(
		ethernet_channel => FIBRE
	)
	PORT MAP(
		clk_125_in => clk125,
		clk_62_5_in => clk62_5,
		rst => reset_mac,
		gtx_powerdownpll_in => enet_gtx_rst, 
		gtx_powerdownclk_in => enet_gtx_rst,
		enet_tx_p_out => enet_fibre_txp,
		enet_tx_n_out => enet_fibre_txn,
		enet_rx_p_in => enet_fibre_rxp,
		enet_rx_n_in => enet_fibre_rxn,
		enet_clk_p_in => enet_fibre_clkp,
		enet_clk_n_in => enet_fibre_clkn,
		enet_ok_out => enet_ok, 
		txd => mac_txd,
		txdvld => mac_txdvld,
		txack => mac_txack,
		rxclko => mac_rxclk,
		rxd => mac_rxd,
		rxdvld => mac_rxdvld,
		rxgoodframe => mac_rxgoodframe,
		rxbadframe => mac_rxbadframe
	);

	

	reset_comms <= '0'; --rst OR hard_resets_int(31);
	
	comms_top_inst : comms_top 
	PORT MAP (
		clk => clk125,
		reset => reset_comms,
		txclk => clk125,
		rxclk => mac_rxclk,
		rxd => mac_rxd,
		rxdvld => mac_rxdvld,
		rxgoodframe => mac_rxgoodframe,
		rxbadframe => mac_rxbadframe,
		txd => mac_txd,
		txdvld => mac_txdvld,
		txack => mac_txack,
		ipbus_rdata => ipbus_rdata,
		ipbus_wdata => ipbus_wdata,
		ipbus_strobe => ipbus_strobe,
		ipbus_write =>  ipbus_write,
		ipbus_ack => ipbus_ack,
		ipbus_err => ipbus_err,
		ipbus_addr => ipbus_addr,
		hard_resets => hard_resets_int
	);

	
	
	
  -- Core system seprated from control sys TO make simulation easier
	core_sys_inst: core_sys
	GENERIC MAP(
		firmware                => firmware,
		slave                   => slave,
		i2c_clk_speed           => 100000,
		gtx_min                 => gtx_min,
		gtx_max                 => gtx_max,
		gtx_clk                 => 4,               -- GTX_DUAL_X0Y6 (MGT115)
		local_lhc_bunch_count   => lhc_bunch_count,
		sim_mode                => "SLOW",          -- Set TO Fast Functional Simulation Model
		sim_gtx_reset_speedup   => 0,               -- Set TO 1 TO speed up sim reset
		sim_pll_perdiv2         => x"0d0"
	)          -- Set TO the VCO Unit Interval time);
	PORT MAP(
		fabric_reset_in         => rst,
		fabric_clk1x_in         => clk125,
		link_reset_in           => rst,
		link_clk1x_in           => osc1,
		-- Parallel BUS
		ipbus_addr_in            => ipbus_addr,
		ipbus_wdata_in           => ipbus_wdata,
		ipbus_strobe_in          => ipbus_strobe,
		ipbus_write_in           => ipbus_write,
		ipbus_rdata_out          => ipbus_rdata,
		ipbus_ack_out            => ipbus_ack, 
		ipbus_berr_out           => ipbus_err,
		-- Rx Serial
		rxn_ch0_in              => rxn_ch0_in,
		rxn_ch1_in              => rxn_ch1_in,
		rxp_ch0_in              => rxp_ch0_in,
		rxp_ch1_in              => rxp_ch1_in,
		-- Ref clock
		refclkp_in              => refclkp_in, 
		refclkn_in              => refclkn_in,
		-- Tx Serial
		txn_ch0_out             => txn_ch0_out,
		txn_ch1_out             => txn_ch1_out,
		txp_ch0_out             => txp_ch0_out,
		txp_ch1_out             => txp_ch1_out,
		-- Clock synthesis control
		si5326_cntrl            => si5326_cntrl,
		snap12_tx0_cntrl        => snap12_tx0_cntrl,
		snap12_rx0_cntrl        => snap12_rx0_cntrl,
		snap12_rx2_cntrl        => snap12_rx2_cntrl,
		debug_out               => debug,
		test_out                => test
	);

	
	

	

  -- The following refers comments refer TO the output 
  -- destination from the crosspoint switch

  --  FOR the refclks: clk_cntrl(0-15)
  --------------------------------------------------
  -- sx0  sx1  input chan
  --------------------------------------------------
  --  0    0     1: CLK1
  --  0    1     2: CLK2
  --  1    0     3: OSC1
  --  1    1     4: OSC2

  --  FOR the clk1 AND clk2 SELECT: clk_cntrl(16-23)
  --------------------------------------------------
  -- sx0  sx1  input chan
  --------------------------------------------------
  --  0    0     1: FCLKA   
  --  0    1     2: TCLKA
  --  1    0     3: TCLKC
  --  1    1     4: SI5326-CLK1

  clk_cntrl(0) <= '1';  -- refclk3: u15, PORT s10
  clk_cntrl(1) <= '0';  -- refclk3: u15, PORT s11
  clk_cntrl(2) <= '1';  -- refclk2: u15, PORT s20
  clk_cntrl(3) <= '0';  -- refclk2: u15, PORT s21
  clk_cntrl(4) <= '1';  -- refclk1: u15, PORT s30
  clk_cntrl(5) <= '0';  -- refclk1: u15, PORT s31
  clk_cntrl(6) <= '1';  -- refclk0: u15, PORT s40
  clk_cntrl(7) <= '0';  -- refclk0: u15, PORT s41
  clk_cntrl(8) <= '1';  -- refclk7: u20, PORT s10
  clk_cntrl(9) <= '0';  -- refclk7: u20, PORT s11
  clk_cntrl(10) <= '1';  -- refclk6: u20, PORT s20
  clk_cntrl(11) <= '0';  -- refclk6: u20, PORT s21
  clk_cntrl(12) <= '1';  -- refclk6: u20, PORT s30
  clk_cntrl(13) <= '0';  -- refclk6: u20, PORT s31
  clk_cntrl(14) <= '1';  -- refclk6: u20, PORT s40
  clk_cntrl(15) <= '0';  -- refclk6: u20, PORT s41
  clk_cntrl(16) <= '1';  -- clk1 TO bufs: u24, PORT s10
  clk_cntrl(17) <= '1';  -- clk1 TO bufs: u24, PORT s11
  clk_cntrl(18) <= '0';  -- clk2 TO bufs: u24, PORT s20
  clk_cntrl(19) <= '0';  -- clk2 TO bufs: u24, PORT s21
  clk_cntrl(20) <= '0';  -- NOT used: u24, PORT s30
  clk_cntrl(21) <= '0';  -- NOT used: u24, PORT s31
  clk_cntrl(22) <= '0';  -- si5326 input: u24, PORT s40
  clk_cntrl(23) <= '0';  -- si5326 input: u24, PORT s41

  -- Reset generation
  reset_gen : COMPONENT srl16
  PORT MAP (
    a0 => '1',
    a1 => '1',
    a2 => '1',
    a3 => '1',
    clk => osc1,
    d => '1',
    q => rst_powerup_b);

  rst_short <= NOT (rst_powerup_b); -- AND cpld(0); 

  -- IN Xilinx ethernet simulation reset is 15us.
  enet_rst_legthen : PROCESS(osc1)
    VARIABLE enet_rst_cnt : natural;
  BEGIN
    IF (osc1 = '1' AND osc1'event) THEN
      IF (rst_short = '1') THEN
        enet_rst_cnt := 20000;  -- 160us
        enet_gtx_rst <= '1';
      ELSIF (enet_rst_cnt > 0) THEN
        enet_rst_cnt := enet_rst_cnt - 1;
        enet_gtx_rst <= '1';
      ELSE
        enet_gtx_rst <= '0';
      END IF;
    END IF;
  END PROCESS enet_rst_legthen;

  -- IN Xilinx ethernet simulation reset is 15us.
  enet_bp_rst_legthen : PROCESS(osc1)
    VARIABLE enet_rst_cnt : natural;
  BEGIN
    IF (osc1 = '1' AND osc1'event) THEN
      IF (rst_short = '1') THEN
        enet_rst_cnt := 40000;  -- 320us
        enet_mac_rst <= '1';
      ELSIF (enet_rst_cnt > 0) THEN
        enet_rst_cnt := enet_rst_cnt - 1;
        enet_mac_rst <= '1';
      ELSE
        enet_mac_rst <= '0';
      END IF;
    END IF;
  END PROCESS enet_bp_rst_legthen;


  -- IN Xilinx TEMAC simulation reset is 15us.
  rst_legthen : PROCESS(clk125, enet_ok, enet_gtx_rst)
    VARIABLE rst_cnt : natural;
    VARIABLE init: std_logic;
  BEGIN
    IF (enet_ok /= '1') OR (enet_gtx_rst = '1') THEN
      rst <= '1';
      init := '1';
    ELSIF (clk125 = '1' AND clk125'event) THEN
      IF (init = '1') THEN
        init := '0';
        rst_cnt := 2500;   -- 20us
        rst <= '1';
      ELSIF (rst_cnt > 0) THEN
        rst_cnt := rst_cnt - 1;
        rst <= '1';
      ELSE
        rst <= '0';
      END IF;
    END IF;
  END PROCESS rst_legthen;

  rst_b <= NOT rst;

  osc1_buf : COMPONENT ibufgds
  GENERIC MAP(
    diff_term => true,
    iostandard => "LVDS_25")
  PORT MAP(
    o  => osc1,
    i => osc1_p,
    ib => osc1_n);

  osc2_buf : COMPONENT ibufgds
  GENERIC MAP(
    diff_term => true,
    iostandard => "LVDS_25")
  PORT MAP(
    o  => osc2,
    i => osc2_p,
    ib => osc2_n);

  clk1_buf : COMPONENT ibufgds
  GENERIC MAP(
    diff_term => true,
    iostandard => "LVDS_25")
  PORT MAP(
    o  => clk1,
    i => clk1_p,
    ib => clk1_n);

  clk2_buf : COMPONENT ibufgds
  GENERIC MAP(
    diff_term => true,
    iostandard => "LVDS_25")
  PORT MAP(
    o  => clk2,
    i => clk2_p,
    ib => clk2_n);


  lengthen_led_pulses : FOR i IN 3 TO 3 GENERATE
    leds_inst: pulse_lengthen
    GENERIC MAP( 
        pulse_length => 4000000,
        pulse_init   => '1')
    PORT MAP( 
        clk         => osc1,
        reset_b     => rst_powerup_b,
        pulse_short => led_int(i),
        pulse_long  => led(i));
  END GENERATE;  

  led_int(0) <= rst;
  led_int(1) <= enet_gtx_rst;
  led_int(2) <= test(3);
  led_int(3) <= blink;

  led(0) <= enet_gtx_rst;
  led(1) <= enet_mac_rst;
  led(2) <= rst;
  -- led(3) <= test(3);


  hdr_p(0) <= enet_ok; --debug(0);
  hdr_n(0) <= enet_bp_ok; --debug(1);
  hdr_p(1) <= clk125_p;
  hdr_n(1) <= clk125_n;
  -- hdr_p(2) <= clk125_refclk_after_gtx_p;
  -- hdr_n(2) <= clk125_refclk_after_gtx_n;
  -- hdr_p(3) <= clk125_refclk_before_gtx_p;
  -- hdr_n(3) <= clk125_refclk_before_gtx_n; -- debug(7);
  hdr_p(2) <= clk125_p;
  hdr_n(2) <= clk125_n;
  hdr_p(3) <= clk62_5_p;
  hdr_n(3) <= clk62_5_n; -- debug(7);
  
  clk125_lvds : COMPONENT obufds
  GENERIC MAP(
      IOSTANDARD => "LVDS_25")
  PORT MAP(
      I => clk125,
      O  => clk125_p,
      OB => clk125_n);

  clk62_5_lvds : COMPONENT obufds
  GENERIC MAP(
      IOSTANDARD => "LVDS_25")
  PORT MAP(
      I => clk62_5,
      O  => clk62_5_p,
      OB => clk62_5_n);

	  
  -- clk125_refclk_after_gtx_lvds : COMPONENT obufds
  -- GENERIC MAP(
      -- IOSTANDARD => "LVDS_25")
  -- PORT MAP(
      -- I => clk125_refclk_after_gtx,
      -- O  => clk125_refclk_after_gtx_p,
      -- OB => clk125_refclk_after_gtx_n);

  -- clk125_refclk_before_gtx_lvds : COMPONENT obufds
  -- GENERIC MAP(
      -- IOSTANDARD => "LVDS_25")
  -- PORT MAP(
      -- I => clk125_refclk_before_gtx,
      -- O  => clk125_refclk_before_gtx_p,
      -- OB => clk125_refclk_before_gtx_n);

  blink_inst: blinker
  GENERIC MAP( 
    blink_period => 125000000)
  PORT MAP( 
    clk         => osc1,
    reset_b     => rst_powerup_b,
    blink_out   => blink);

END behavioral;

