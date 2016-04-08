LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;

ENTITY tb_top_sys IS
END tb_top_sys;


ARCHITECTURE behavioral OF tb_top_sys IS


  COMPONENT top_sys IS
  GENERIC (
    sim                   : boolean := false;
    firmware_version      : std_logic_vector(7 DOWNTO 0):= x"01"; 
    firmware_day          : std_logic_vector(7 DOWNTO 0):= x"12"; 
    firmware_month        : std_logic_vector(7 DOWNTO 0):= x"08"; 
    firmware_year         : std_logic_vector(7 DOWNTO 0):= x"10"; 
    gtx_min          	  : natural := 0;
    gtx_max          	  : natural := 11);	  -- was 11 
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
    --     enet_fibre_txp                 : OUT std_logic;
    --     enet_fibre_txn                 : OUT std_logic;
    --     enet_fibre_rxp                 : IN  std_logic;
    --     enet_fibre_rxn                 : IN  std_logic;
    --     enet_fibre_clkp              : IN  std_logic;
    --     enet_fibre_clkn              : IN  std_logic;
    -- Ethernet Backplane.  Check polarity AND PORT...
    enet_bp_clkp         : IN  std_logic;
    enet_bp_clkn         : IN  std_logic;
    enet_bp_txp          : OUT std_logic;
    enet_bp_txn          : OUT std_logic;
    enet_bp_rxp          : IN  std_logic;
    enet_bp_rxn          : IN  std_logic;
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
    hdr_p                   : OUT  std_logic_vector(3 DOWNTO 0);
    hdr_n                   : OUT  std_logic_vector(3 DOWNTO 0);
    led                   : OUT  std_logic_vector (3 DOWNTO 0));
  END COMPONENT;

  COMPONENT temac_config IS
    PORT(
      reset                       : OUT std_logic;
      host_clk                    : OUT std_logic;
      sync_acq_status_0           : IN  std_logic;

      emac0_configuration_busy    : OUT boolean;
      emac0_monitor_finished_1g   : IN  boolean;
      emac0_monitor_finished_100m : IN  boolean;
      emac0_monitor_finished_10m  : IN  boolean;

      emac1_configuration_busy    : OUT boolean;
      emac1_monitor_finished_1g   : IN  boolean;
      emac1_monitor_finished_100m : IN  boolean;
      emac1_monitor_finished_10m  : IN  boolean);
  END COMPONENT;

  
  COMPONENT temac_phy_driver_top_sys IS
  PORT(
    clk125m                 : IN std_logic;
    txp                     : IN  std_logic;
    txn                     : IN  std_logic;
    rxp                     : OUT std_logic;
    rxn                     : OUT std_logic; 
    configuration_busy      : IN  boolean;
    monitor_finished_1g     : OUT boolean;
    monitor_finished_100m   : OUT boolean;
    monitor_finished_10m    : OUT boolean);
END COMPONENT temac_phy_driver_top_sys;
  
  
--   COMPONENT temac_phy_driver_top_sys IS
--     PORT(
--       clk125m                 : IN std_logic;
--       txp                     : IN  std_logic;
--       txn                     : IN  std_logic;
--       rxp                     : OUT std_logic;
--       rxn                     : OUT std_logic; 
--       configuration_busy      : IN  boolean;
--       monitor_finished_1g     : OUT boolean;
--       monitor_finished_100m   : OUT boolean;
--       monitor_finished_10m    : OUT boolean);
--   END COMPONENT;


    CONSTANT  gtx_min          : natural := 0;
    CONSTANT  gtx_max          : natural := 11;

    SIGNAL reset                : std_logic                     := '1';

    -- EMAC0
    SIGNAL tx_client_clk_0      : std_logic;
    SIGNAL tx_ifg_delay_0       : std_logic_vector(7 DOWNTO 0)  := (OTHERS => '0'); -- IFG stretching NOT used IN demo.
    SIGNAL rx_client_clk_0      : std_logic;
    SIGNAL pause_val_0          : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pause_req_0          : std_logic                     := '0';

    -- 1000BASE-X PCS/PMA Signals
    SIGNAL txp_0                : std_logic;
    SIGNAL txn_0                : std_logic;
    SIGNAL rxp_0                : std_logic;
    SIGNAL rxn_0                : std_logic;
    SIGNAL sync_acq_status_0    : std_logic;
    SIGNAL phyad_0              : std_logic_vector(4 DOWNTO 0);

    -- Clock signals
    SIGNAL host_clk             : std_logic                     := '0';
    SIGNAL gtx_clk              : std_logic;

    SIGNAL mgtclk_p             : std_logic := '0';   
    SIGNAL mgtclk_n             : std_logic := '1';

    SIGNAL emac0_configuration_busy    : boolean := false;
    SIGNAL emac0_monitor_finished_1g   : boolean := false;
    SIGNAL emac0_monitor_finished_100m : boolean := false;
    SIGNAL emac0_monitor_finished_10m  : boolean := false;

    SIGNAL emac1_configuration_busy    : boolean := false;
    SIGNAL emac1_monitor_finished_1g   : boolean := false;
    SIGNAL emac1_monitor_finished_100m : boolean := false;
    SIGNAL emac1_monitor_finished_10m  : boolean := false;

    -- MINI-T5 signals
    SIGNAL hdr_p, hdr_n : std_logic_vector(3 DOWNTO 0);
    SIGNAL cpld : std_logic_vector(9 DOWNTO 0);
    SIGNAL si5326_cntrl :  std_logic_vector (4 DOWNTO 0);
    SIGNAL snap12_tx0_cntrl  : std_logic_vector(5 DOWNTO 0);
    SIGNAL snap12_rx0_cntrl  : std_logic_vector(5 DOWNTO 0);
    SIGNAL snap12_rx2_cntrl  : std_logic_vector(5 DOWNTO 0);

    SIGNAL gtx_clk_p, gtx_clk_n : std_logic_vector(gtx_max DOWNTO gtx_min);
    SIGNAL tx_ch0_p, tx_ch0_n : std_logic_vector(gtx_max DOWNTO gtx_min);
    SIGNAL tx_ch1_p, tx_ch1_n : std_logic_vector(gtx_max DOWNTO gtx_min);
    SIGNAL rx_ch0_p, rx_ch0_n : std_logic_vector(gtx_max DOWNTO gtx_min);
    SIGNAL rx_ch1_p, rx_ch1_n : std_logic_vector(gtx_max DOWNTO gtx_min);

begin



  dut_top : top_sys
  GENERIC MAP(
    sim => true,
    gtx_min => gtx_min,
    gtx_max => gtx_max)
  PORT MAP(
    -- Main clks AND CONFIGURATION
    clk1_p            => '0',
    clk1_n            => '1',
    clk2_p            => '0',
    clk2_n            => '1',
    osc1_p            => mgtclk_p,
    osc1_n            => mgtclk_n,
    osc2_p            => '0',
    osc2_n            => '1',
    clk_cntrl         => open,
    -- Opto control
    snap12_tx0_cntrl  => snap12_tx0_cntrl,
    snap12_rx0_cntrl  => snap12_rx0_cntrl,
    snap12_rx2_cntrl  => snap12_rx2_cntrl,
    -- Clock synthesis control
    si5326_cntrl      => si5326_cntrl,
    -- Ethernet Fibre.  Check polarity AND PORT...
    --     enet_fibre_txp                 : OUT std_logic;
    --     enet_fibre_txn                 : OUT std_logic;
    --     enet_fibre_rxp                 : IN  std_logic;
    --     enet_fibre_rxn                 : IN  std_logic;
    --     enet_fibre_clkp              : IN  std_logic;
    --     enet_fibre_clkn              : IN  std_logic;
    -- Ethernet Backplane.  Check polarity AND PORT...
    enet_bp_clkp        => mgtclk_p,
    enet_bp_clkn        => mgtclk_n,
    enet_bp_txp         => open, -- txp_0,
    enet_bp_txn         => open,  -- txn_0,
    enet_bp_rxp         => rxp_0,
    enet_bp_rxn         => rxn_0,
    -- Rx Serial
    rxn_ch0_in              => rx_ch0_n,
    rxn_ch1_in              => rx_ch1_n,
    rxp_ch0_in              => rx_ch0_p,
    rxp_ch1_in              => rx_ch1_p,
    -- Ref clock
    refclkp_in              => gtx_clk_p,
    refclkn_in              => gtx_clk_n,
    -- Tx Serial
    txn_ch0_out             => tx_ch0_n,
    txn_ch1_out             => tx_ch1_n,
    txp_ch0_out             => tx_ch0_p,
    txp_ch1_out             => tx_ch1_p,
    cpld                    => cpld,
    hdr_p                   => hdr_p,
    hdr_n                   => hdr_n,
    led                     => OPEN);

  -- NOT implemented because switch round the wrong way
  cpld(0) <= NOT reset;
  cpld(9 DOWNTO 1) <= (OTHERS => '0');
  sync_acq_status_0 <= hdr_p(0);

  -- si5326_cntrl(0) is driven by fpga (rst_b)
  si5326_cntrl(1) <= '0';  -- int_c1b
  si5326_cntrl(2) <= '0';  -- lol
  si5326_cntrl(3) <= 'H';  -- i2c scl
  si5326_cntrl(4) <= 'H';  -- i2c sda

  snap12_tx0_cntrl <= (OTHERS => 'Z');
  snap12_rx0_cntrl <= (OTHERS => 'Z');
  snap12_rx2_cntrl <= (OTHERS => 'Z');

  gtx_loop: FOR i IN gtx_min TO gtx_max GENERATE 
    gtx_clk_p(i) <= gtx_clk;  
    gtx_clk_n(i) <= NOT gtx_clk;
  END GENERATE;

    ----------------------------------------------------------------------------
    -- Flow Control is unused IN this demonstration
    ----------------------------------------------------------------------------
    pause_req_0 <= '0';
    pause_val_0 <= "0000000000000000";

    -- Tie-off EMAC0 PHY address TO a default value
    phyad_0 <= "00001";

    ----------------------------------------------------------------------------
    -- Clock drivers
    ----------------------------------------------------------------------------

    -- Drive GTX_CLK at 125 MHz
    p_gtx_clk : PROCESS 
    BEGIN
        gtx_clk <= '0';
        WAIT FOR 10 ns;
        LOOP
            WAIT FOR 4 ns;
            gtx_clk <= '1';
            WAIT FOR 4 ns;
            gtx_clk <= '0';
        END LOOP;
    END PROCESS p_gtx_clk;



    -- Drive Gigabit Transceiver differential clock WITH 125MHz
    mgtclk_p <= gtx_clk;
    mgtclk_n <= NOT gtx_clk;

  ----------------------------------------------------------------------
  -- Instantiate the EMAC0 PHY stimulus AND monitor
  ----------------------------------------------------------------------

    phy0_test: temac_phy_driver_top_sys
    PORT MAP (
      clk125m                 => gtx_clk,

      ------------------------------------------------------------------
      -- GMII Interface
      ------------------------------------------------------------------
      txp                     => txp_0,
      txn                     => txn_0,
      rxp                     => rxp_0,
      rxn                     => rxn_0, 

      ------------------------------------------------------------------
      -- Test Bench Semaphores
      ------------------------------------------------------------------
      configuration_busy      => emac0_configuration_busy,
      monitor_finished_1g     => emac0_monitor_finished_1g,
      monitor_finished_100m   => emac0_monitor_finished_100m,
      monitor_finished_10m    => emac0_monitor_finished_10m
      );

  ----------------------------------------------------------------------
  -- Instantiate the No-Host CONFIGURATION Stimulus
  ----------------------------------------------------------------------

  config_test: temac_config
    PORT MAP (
      reset                       => reset,
      ------------------------------------------------------------------
      -- Host Interface: host_clk is always required
      ------------------------------------------------------------------
      host_clk                    => host_clk,

      sync_acq_status_0           => sync_acq_status_0,

      emac0_configuration_busy    => emac0_configuration_busy,
      emac0_monitor_finished_1g   => emac0_monitor_finished_1g,
      emac0_monitor_finished_100m => emac0_monitor_finished_100m,
      emac0_monitor_finished_10m  => emac0_monitor_finished_10m,

      emac1_configuration_busy    => emac1_configuration_busy,
      emac1_monitor_finished_1g   => emac1_monitor_finished_1g,
      emac1_monitor_finished_100m => emac1_monitor_finished_100m,
      emac1_monitor_finished_10m  => emac1_monitor_finished_10m 

      );



END behavioral;

