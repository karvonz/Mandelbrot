
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY unisim;
USE unisim.vcomponents.ALL;
LIBRARY work;
USE work.package_types.ALL;
USE work.package_utilities.ALL;
USE work.package_links.ALL;

ENTITY minit_gtx IS
GENERIC(
  -- Simulation attributes
  SIM_MODE                : string     := "FAST"; -- Set TO Fast Functional Simulation Model
  SIM_GTX_RESET_SPEEDUP   : integer    := 0;      -- Set TO 1 TO speed up sim reset
  SIM_PLL_PERDIV2         : bit_vector := x"0d0"; -- Set TO the VCO Unit Interval time 
  LOCAL_LHC_BUNCH_COUNT   : integer    := LHC_BUNCH_COUNT);
PORT(
   -- Link clk
   link_clk1x_in                : IN   std_logic;
   link_clk2x_in                : IN   std_logic;
   link_reset_in                : IN   std_logic;
   -- GTP PLL clks
   txoutclk_out                 : OUT   std_logic;
   plllkdet_out                 : OUT   std_logic;
   -- REGISTER interface
   ro_regs_ch0                  : OUT type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
   ro_regs_ch1                  : OUT type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
   rw_regs_ch0                  : IN type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
   rw_regs_ch1                  : IN type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
   rw_regs_default_ch0          : OUT type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
   rw_regs_default_ch1          : OUT type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
   -- ACCESS TO Pattern Inject/Capture RAM
   ram_stb_ch0                  : IN std_logic;
   ram_stb_ch1                  : IN std_logic;
   ram_wen_ch0                  : IN std_logic;
   ram_wen_ch1                  : IN std_logic;
   ram_add_ch0                  : IN std_logic_vector(9 DOWNTO 0);
   ram_add_ch1                  : IN std_logic_vector(9 DOWNTO 0);
   ram_wdata_ch0                : IN std_logic_vector(31 DOWNTO 0);
   ram_wdata_ch1                : IN std_logic_vector(31 DOWNTO 0);
   ram_ack_ch0                  : OUT std_logic;
   ram_ack_ch1                  : OUT std_logic;
   ram_rdata_ch0                : OUT std_logic_vector(31 DOWNTO 0);
   ram_rdata_ch1                : OUT std_logic_vector(31 DOWNTO 0);
   -- Pattern Inject/Capture control
   ttc_cntrl_in                 : IN std_logic_vector(1 DOWNTO 0);
   ttc_time_in                   : IN std_logic_vector(8 DOWNTO 0);
   -- Dynamic Reconfiguration PORT (DRP)
   drp_addr_in                  : IN std_logic_vector(6 DOWNTO 0);   
   drp_clk_in                   : IN std_logic;                      
   drp_en_in                    : IN std_logic;                      
   drp_data_in                  : IN std_logic_vector(15 DOWNTO 0);  
   drp_data_out                 : OUT std_logic_vector(15 DOWNTO 0); 
   drp_rdy_out                  : OUT std_ulogic;                    
   drp_we_in                    : IN std_logic;                      
   -- Sync channels together 
   sync_master_in               : IN std_logic;
   sync_slave_ch0_out           : OUT std_logic;
   sync_slave_ch1_out           : OUT std_logic;
   -- Rx parallel data OUT
   rx_data_ch0_out              : OUT  std_logic_vector(31 DOWNTO 0);
   rx_data_ch1_out              : OUT  std_logic_vector(31 DOWNTO 0);
   rx_data_valid_ch0_out        : OUT  std_logic;
   rx_data_valid_ch1_out        : OUT  std_logic;
   -- Rx serdes IN
   rxn_ch0_in                   : IN   std_logic;
   rxn_ch1_in                   : IN   std_logic;
   rxp_ch0_in                   : IN   std_logic;
   rxp_ch1_in                   : IN   std_logic;
   -- Ref clock
   refclkp_in                   : IN   std_logic;
   refclkn_in                   : IN   std_logic;
   refclk_out                   : OUT std_logic;
   -- Tx parallel data IN
   tx_data_ch0_in               : IN   std_logic_vector(31 DOWNTO 0);
   tx_data_ch1_in               : IN   std_logic_vector(31 DOWNTO 0);
   tx_data_valid_ch0_in         : IN   std_logic;
   tx_data_valid_ch1_in         : IN   std_logic;
   -- Tx serdes data OUT
   txn_ch0_out                  : OUT  std_logic;
   txn_ch1_out                  : OUT  std_logic;
   txp_ch0_out                  : OUT  std_logic;
   txp_ch1_out                  : OUT  std_logic);
END minit_gtx;

ARCHITECTURE behave OF minit_gtx IS

COMPONENT minit_gtx_tile IS
  GENERIC(
    -- Simulation attributes
    TILE_SIM_MODE                : string    := "FAST"; -- Set TO Fast Functional Simulation Model
    TILE_SIM_GTX_RESET_SPEEDUP    : integer   := 0; -- Set TO 1 TO speed up sim reset
    TILE_SIM_PLL_PERDIV2         : bit_vector:= x"0d0"); -- Set TO the VCO Unit Interval time 
  PORT(
    ------------------------ Loopback AND Powerdown Ports ----------------------
    LOOPBACK0_IN                            : IN   std_logic_vector(2 DOWNTO 0);
    LOOPBACK1_IN                            : IN   std_logic_vector(2 DOWNTO 0);
    RXPOWERDOWN0_IN                         : IN   std_logic;
    RXPOWERDOWN1_IN                         : IN   std_logic;
    TXPOWERDOWN0_IN                         : IN   std_logic;
    TXPOWERDOWN1_IN                         : IN   std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    RXCHARISCOMMA0_OUT                      : OUT  std_logic_vector(3 DOWNTO 0);
    RXCHARISCOMMA1_OUT                      : OUT  std_logic_vector(3 DOWNTO 0);
    RXCHARISK0_OUT                          : OUT  std_logic_vector(3 DOWNTO 0);
    RXCHARISK1_OUT                          : OUT  std_logic_vector(3 DOWNTO 0);
    RXDISPERR0_OUT                          : OUT  std_logic_vector(3 DOWNTO 0);
    RXDISPERR1_OUT                          : OUT  std_logic_vector(3 DOWNTO 0);
    RXNOTINTABLE0_OUT                       : OUT  std_logic_vector(3 DOWNTO 0);
    RXNOTINTABLE1_OUT                       : OUT  std_logic_vector(3 DOWNTO 0);
    ------------------- Receive Ports - Clock Correction Ports -----------------
    RXCLKCORCNT0_OUT                        : OUT  std_logic_vector(2 DOWNTO 0);
    RXCLKCORCNT1_OUT                        : OUT  std_logic_vector(2 DOWNTO 0);
    --------------- Receive Ports - Comma Detection AND Alignment --------------
    RXBYTEISALIGNED0_OUT                    : OUT  std_logic;
    RXBYTEISALIGNED1_OUT                    : OUT  std_logic;
    RXENMCOMMAALIGN0_IN                     : IN   std_logic;
    RXENMCOMMAALIGN1_IN                     : IN   std_logic;
    RXENPCOMMAALIGN0_IN                     : IN   std_logic;
    RXENPCOMMAALIGN1_IN                     : IN   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    RXDATA0_OUT                             : OUT  std_logic_vector(31 DOWNTO 0);
    RXDATA1_OUT                             : OUT  std_logic_vector(31 DOWNTO 0);
    RXRESET0_IN                             : IN   std_logic;
    RXRESET1_IN                             : IN   std_logic;
    RXUSRCLK0_IN                            : IN   std_logic;
    RXUSRCLK1_IN                            : IN   std_logic;
    RXUSRCLK20_IN                           : IN   std_logic;
    RXUSRCLK21_IN                           : IN   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling AND Eq.,CDR ------
    RXCDRRESET0_IN                          : IN   std_logic;
    RXCDRRESET1_IN                          : IN   std_logic;
    RXN0_IN                                 : IN   std_logic;
    RXN1_IN                                 : IN   std_logic;
    RXP0_IN                                 : IN   std_logic;
    RXP1_IN                                 : IN   std_logic;
    -------- Receive Ports - RX Elastic BUFFER AND Phase Alignment Ports -------
    RXBUFRESET0_IN                          : IN   std_logic;
    RXBUFRESET1_IN                          : IN   std_logic;
    RXBUFSTATUS0_OUT                        : OUT  std_logic_vector(2 DOWNTO 0);
    RXBUFSTATUS1_OUT                        : OUT  std_logic_vector(2 DOWNTO 0);
    RXSTATUS0_OUT                           : OUT  std_logic_vector(2 DOWNTO 0);
    RXSTATUS1_OUT                           : OUT  std_logic_vector(2 DOWNTO 0);
    --------------- Receive Ports - RX Loss-OF-sync State Machine --------------
    RXLOSSOFSYNC0_OUT                       : OUT  std_logic_vector(1 DOWNTO 0);
    RXLOSSOFSYNC1_OUT                       : OUT  std_logic_vector(1 DOWNTO 0);
    -------------- Receive Ports - RX Pipe Control FOR PCI Express -------------
    RXVALID0_OUT                            : OUT  std_logic;
    RXVALID1_OUT                            : OUT  std_logic;
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    RXPOLARITY0_IN                          : IN   std_logic;
    RXPOLARITY1_IN                          : IN   std_logic;
    ------------- SHARED Ports - Dynamic Reconfiguration PORT (DRP) ------------
    DADDR_IN                                : IN   std_logic_vector(6 DOWNTO 0);
    DCLK_IN                                 : IN   std_logic;
    DEN_IN                                  : IN   std_logic;
    DI_IN                                   : IN   std_logic_vector(15 DOWNTO 0);
    DO_OUT                                  : OUT  std_logic_vector(15 DOWNTO 0);
    DRDY_OUT                                : OUT  std_logic;
    DWE_IN                                  : IN   std_logic;
    --------------------- SHARED Ports - Tile AND PLL Ports --------------------
    CLKIN_IN                                : IN   std_logic;
    GTXRESET_IN                             : IN   std_logic;
    PLLLKDET_OUT                            : OUT  std_logic;
    PLLPOWERDOWN_IN                         : IN   std_logic;
    REFCLKOUT_OUT                           : OUT  std_logic;
    REFCLKPWRDNB_IN                         : IN   std_logic;
    RESETDONE0_OUT                          : OUT  std_logic;
    RESETDONE1_OUT                          : OUT  std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    TXCHARISK0_IN                           : IN   std_logic_vector(3 DOWNTO 0);
    TXCHARISK1_IN                           : IN   std_logic_vector(3 DOWNTO 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TXDATA0_IN                              : IN   std_logic_vector(31 DOWNTO 0);
    TXDATA1_IN                              : IN   std_logic_vector(31 DOWNTO 0);
    TXOUTCLK0_OUT                           : OUT  std_logic;
    TXOUTCLK1_OUT                           : OUT  std_logic;
    TXRESET0_IN                             : IN   std_logic;
    TXRESET1_IN                             : IN   std_logic;
    TXUSRCLK0_IN                            : IN   std_logic;
    TXUSRCLK1_IN                            : IN   std_logic;
    TXUSRCLK20_IN                           : IN   std_logic;
    TXUSRCLK21_IN                           : IN   std_logic;
    --------------- Transmit Ports - TX Driver AND OOB signalling --------------
    TXN0_OUT                                : OUT  std_logic;
    TXN1_OUT                                : OUT  std_logic;
    TXP0_OUT                                : OUT  std_logic;
    TXP1_OUT                                : OUT  std_logic;
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    TXENPRBSTST0_IN                         : IN   std_logic_vector(1 DOWNTO 0);
    TXENPRBSTST1_IN                         : IN   std_logic_vector(1 DOWNTO 0);
    -------------------- Transmit Ports - TX Polarity Control ------------------
    TXPOLARITY0_IN                          : IN   std_logic;
    TXPOLARITY1_IN                          : IN   std_logic);
END COMPONENT;


    ------------------------ Loopback AND Powerdown Ports ----------------------
   SIGNAL  loopback_ch0               : std_logic_vector(2 DOWNTO 0);
   SIGNAL  loopback_ch1               : std_logic_vector(2 DOWNTO 0);
   ----------------------- Receive Ports - 8b10b Decoder ----------------------
   SIGNAL  rxchariscomma_ch0          : std_logic_vector(3 DOWNTO 0);
   SIGNAL  rxchariscomma_ch1          : std_logic_vector(3 DOWNTO 0);
   SIGNAL  rxcharisk_ch0              : std_logic_vector(3 DOWNTO 0);
   SIGNAL  rxcharisk_ch1              : std_logic_vector(3 DOWNTO 0);
   SIGNAL  rxdisperr_ch0              : std_logic_vector(3 DOWNTO 0);
   SIGNAL  rxdisperr_ch1              : std_logic_vector(3 DOWNTO 0);
   SIGNAL  rxnotintable_ch0           : std_logic_vector(3 DOWNTO 0);
   SIGNAL  rxnotintable_ch1           : std_logic_vector(3 DOWNTO 0);
   ------------------- Receive Ports - Clock Correction Ports -----------------
   SIGNAL  rxclkcorcnt_ch0            : std_logic_vector(2 DOWNTO 0);
   SIGNAL  rxclkcorcnt_ch1            : std_logic_vector(2 DOWNTO 0);
   --------------- Receive Ports - Comma Detection AND Alignment --------------
   SIGNAL  rxbyteisaligned_ch0        : std_logic;
   SIGNAL  rxbyteisaligned_ch1        : std_logic;
   SIGNAL  rxenmcommaalign_ch0        : std_logic;
   SIGNAL  rxenmcommaalign_ch1        : std_logic;
   SIGNAL  rxenpcommaalign_ch0        : std_logic;
   SIGNAL  rxenpcommaalign_ch1        : std_logic;
   ------------------- Receive Ports - RX Data Path interface -----------------
   SIGNAL  rxdata_ch0                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL  rxdata_ch1                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL  rxrecclk_ch0               : std_logic;
   SIGNAL  rxrecclk_ch1               : std_logic;
   -------- Receive Ports - RX Elastic BUFFER AND Phase Alignment Ports -------
   SIGNAL  rxbufreset_ch0             : std_logic;
   SIGNAL  rxbufreset_ch1             : std_logic;
   SIGNAL  rxbufstatus_ch0            : std_logic_vector(2 DOWNTO 0);
   SIGNAL  rxbufstatus_ch1            : std_logic_vector(2 DOWNTO 0);
   --------------- Receive Ports - RX Loss-OF-sync State Machine --------------
   SIGNAL  rxlossofsync_ch0           : std_logic_vector(1 DOWNTO 0);
   SIGNAL  rxlossofsync_ch1           : std_logic_vector(1 DOWNTO 0);
   --------------------- Reset Ports --------------------
   SIGNAL  resetdone_ch0              : std_logic;
   SIGNAL  resetdone_ch1              : std_logic;
   ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
   SIGNAL  txcharisk_ch0              : std_logic_vector(3 DOWNTO 0);
   SIGNAL  txcharisk_ch1              : std_logic_vector(3 DOWNTO 0);
   ------------------ Transmit Ports - TX Data Path interface -----------------
   SIGNAL  txdata_ch0                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL  txdata_ch1                 : std_logic_vector(31 DOWNTO 0);
   --------------- Transmit Ports - TX Driver AND OOB signalling --------------
   SIGNAL  txdiffctrl_ch0             : std_logic_vector(2 DOWNTO 0);
   SIGNAL  txdiffctrl_ch1             : std_logic_vector(2 DOWNTO 0);
   SIGNAL  txpreemphasis_ch0          : std_logic_vector(2 DOWNTO 0);
   SIGNAL  txpreemphasis_ch1          : std_logic_vector(2 DOWNTO 0);
   ------------------------------- Global Signals -----------------------------
   SIGNAL  rxreset_ch0                : std_logic;
   SIGNAL  rxreset_ch1                : std_logic;
   SIGNAL  rxcdrreset_ch0             : std_logic;
   SIGNAL  rxcdrreset_ch1             : std_logic;
   SIGNAL  txreset_ch0                : std_logic;
   SIGNAL  txreset_ch1                : std_logic;
   SIGNAL  fullreset_ch0              : std_logic;
   SIGNAL  fullreset_ch1              : std_logic;
   SIGNAL  pllpowerdown_ch0           : std_logic;
   SIGNAL  pllpowerdown_ch1           : std_logic;
   SIGNAL  rxpowerdown_ch0            : std_logic;
   SIGNAL  rxpowerdown_ch1            : std_logic;
   SIGNAL  txpowerdown_ch0            : std_logic;
   SIGNAL  txpowerdown_ch1            : std_logic;
   --------------------- SHARED Ports - Tile AND PLL Ports --------------------
   SIGNAL  txoutclk               : std_logic;
   SIGNAL  gtxreset                : std_logic;
   SIGNAL  plllkdet                : std_logic;
   SIGNAL  pllpowerdown                : std_logic;
   SIGNAL  refclk                  : std_logic;
   -------------------- Transmit Ports - TX Polarity Control ------------------
   SIGNAL  txpolarity_ch0                  : std_logic := '0';
   SIGNAL  txpolarity_ch1                  : std_logic := '0';
   ----------------- Receive Ports - RX Polarity Control Ports ----------------
   SIGNAL  rxpolarity_ch0                  : std_logic := '0';
   SIGNAL  rxpolarity_ch1                  : std_logic := '0';

   SIGNAL sync_enable_ch0               : std_logic;
   SIGNAL sync_enable_ch1               : std_logic;

   -- Tx FOR GTP
   SIGNAL  txusrclk_x1              : std_logic;
   SIGNAL  txusrclk_x2               : std_logic;
   -- GTP dervied signals
   SIGNAL  rxdata_valid_ch0            : std_logic;
   SIGNAL  rxdata_valid_ch1            : std_logic;




  -- Tx signals AFTER adding CRC
  SIGNAL tx_data_plus_crc_ch0          : std_logic_vector(31 DOWNTO 0);
  SIGNAL tx_data_valid_plus_crc_ch0    : std_logic;
  -- Rx AFTER CRC stripped off.
  SIGNAL rx_data_minus_crc_ch0          : std_logic_vector(31 DOWNTO 0);
  SIGNAL rx_data_valid_minus_crc_ch0    : std_logic;
  -- Allows error counters, etc TO be reset
  SIGNAL reset_status_ch0: std_logic;



  -- Tx signals AFTER adding CRC
  SIGNAL tx_data_plus_crc_ch1          : std_logic_vector(31 DOWNTO 0);
  SIGNAL tx_data_valid_plus_crc_ch1    : std_logic;
  -- Rx AFTER CRC stripped off.
  SIGNAL rx_data_minus_crc_ch1          : std_logic_vector(31 DOWNTO 0);
  SIGNAL rx_data_valid_minus_crc_ch1    : std_logic;
  -- Allows error counters, etc TO be reset
  SIGNAL reset_status_ch1: std_logic;

   -- Rx
   SIGNAL  bc0_discrepancy_min_ch0               : std_logic_vector(12 DOWNTO 0) := (OTHERS => '0');
   SIGNAL  bc0_discrepancy_min_ch1               : std_logic_vector(12 DOWNTO 0) := (OTHERS => '0');
   SIGNAL  bc0_discrepancy_max_ch0               : std_logic_vector(12 DOWNTO 0) := (OTHERS => '0');
   SIGNAL  bc0_discrepancy_max_ch1               : std_logic_vector(12 DOWNTO 0) := (OTHERS => '0');
   SIGNAL  bc0_discrepancy_req_ch0               : std_logic_vector(12 DOWNTO 0) := (OTHERS => '0');
   SIGNAL  bc0_discrepancy_req_ch1               : std_logic_vector(12 DOWNTO 0) := (OTHERS => '0');

   SIGNAL  autoalign_lock_checks_ch0               : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
   SIGNAL  autoalign_lock_checks_ch1               : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
   SIGNAL  autoalign_once_ch0           : std_logic := '0';
   SIGNAL  autoalign_once_ch1           : std_logic := '0';
   SIGNAL  autoalign_auto_ch0           : std_logic := '0';
   SIGNAL  autoalign_auto_ch1           : std_logic := '0';   
   SIGNAL  autoalign_status_ch0               : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
   SIGNAL  autoalign_status_ch1               : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');

   SIGNAL  crc_error_cnt_ch0         : std_logic_vector(31 DOWNTO 0);
   SIGNAL  crc_error_cnt_ch1         : std_logic_vector(31 DOWNTO 0);
   SIGNAL  crc_checked_cnt_ch0         : std_logic_vector(31 DOWNTO 0);
   SIGNAL  crc_checked_cnt_ch1         : std_logic_vector(31 DOWNTO 0);

  SIGNAL rxdata_buf_ch0 : std_logic_vector(15 DOWNTO 0);
  SIGNAL rxdata_ordered_ch0 : std_logic_vector(31 DOWNTO 0);
  SIGNAL rxdata_swap_ch0 : std_logic;

  SIGNAL rxdata_buf_ch1 : std_logic_vector(15 DOWNTO 0);
  SIGNAL rxdata_ordered_ch1 : std_logic_vector(31 DOWNTO 0);
  SIGNAL rxdata_swap_ch1 : std_logic;

  SIGNAL refclkpwrdnb : std_logic;
  SIGNAL refclkpwrdnb_ch0 : std_logic;
  SIGNAL refclkpwrdnb_ch1 : std_logic;

  SIGNAL sync_slave_ch0: std_logic;
  SIGNAL sync_delay_ch0: std_logic_vector(4 DOWNTO 0);
  SIGNAL sync_delay_enable_ch0: std_logic;
  SIGNAL sync_error_ch0: std_logic;

  SIGNAL sync_slave_ch1: std_logic;
  SIGNAL sync_delay_ch1: std_logic_vector(4 DOWNTO 0);
  SIGNAL sync_delay_enable_ch1: std_logic;
  SIGNAL sync_error_ch1: std_logic;

  SIGNAL link_reset_b: std_logic;

  SIGNAL tx_data_plus_pat_ch0 : std_logic_vector(31 DOWNTO 0);
  SIGNAL tx_data_valid_plus_pat_ch0 : std_logic;
  SIGNAL rx_data_synced_ch0: std_logic_vector(31 DOWNTO 0);
  SIGNAL rx_data_valid_synced_ch0: std_logic;

  SIGNAL tx_data_plus_pat_ch1 : std_logic_vector(31 DOWNTO 0);
  SIGNAL tx_data_valid_plus_pat_ch1 : std_logic;
  SIGNAL rx_data_synced_ch1: std_logic_vector(31 DOWNTO 0);
  SIGNAL rx_data_valid_synced_ch1: std_logic;

  -- Pattern Injection/Capture
  SIGNAL pat_add: std_logic_vector(8 DOWNTO 0);


  SIGNAL pat_wen_ch0, pat_wen_ch1: std_logic;
  SIGNAL pat_stb_ch0, pat_stb_ch1: std_logic;
  SIGNAL pat_cntrl_ch0, pat_cntrl_ch1: std_logic_vector(1 DOWNTO 0);

  SIGNAL pat_rdata_ch0, pat_wdata_ch0: std_logic_vector(31 DOWNTO 0);
  SIGNAL pat_rdata_valid_ch0, pat_wdata_valid_ch0: std_logic;

  SIGNAL pat_rdata_ch1, pat_wdata_ch1: std_logic_vector(31 DOWNTO 0);
  SIGNAL pat_rdata_valid_ch1, pat_wdata_valid_ch1: std_logic;

BEGIN                       

  link_reset_b <= NOT link_reset_in;

---------------------------------------------------------------------------
-- Clocks/Resets 
---------------------------------------------------------------------------


  -- (a) refclk_100mhz(differential) (ibufds)-> refclk_100mhz
  -- (b) refclk_100mhz (gtp)-> txout_clk_200mhz
  -- (c) txout_clk_200mhz (dcm)-> txout_clk_100/200/400mhz
  
  refclk_ibufds_i : IBUFDS
  PORT MAP(
      O                               =>      refclk,
      I                               =>      refclkp_in,
      IB                              =>      refclkn_in);


  ---------------------------------------------------------------------------
  -- Tx Stage (1): Add CRC 
  ---------------------------------------------------------------------------

  

  links_crc_tx_ch0: links_crc_tx
  PORT MAP(
    reset           => link_reset_in,
    clk             => link_clk1x_in,
    data_in         => tx_data_plus_pat_ch0,
    data_valid_in   => tx_data_valid_plus_pat_ch0,
    data_out        => tx_data_plus_crc_ch0,
    data_valid_out  => tx_data_valid_plus_crc_ch0);

  links_crc_tx_ch1: links_crc_tx
  PORT MAP(
    reset           => link_reset_in,
    clk             => link_clk1x_in,
    data_in         => tx_data_plus_pat_ch1,
    data_valid_in   => tx_data_valid_plus_pat_ch1,
    data_out        => tx_data_plus_crc_ch1,
    data_valid_out  => tx_data_valid_plus_crc_ch1);

  ---------------------------------------------------------------------------
  -- Tx State (3): Insert K codes
  ---------------------------------------------------------------------------

  links_kcode_insert_ch0: links_kcode_insert
    PORT MAP(
      data_in             => tx_data_plus_crc_ch0,
      data_valid_in       => tx_data_valid_plus_crc_ch0,
      data_out            => txdata_ch0,
      charisk_out         => txcharisk_ch0);

  links_kcode_insert_ch1: links_kcode_insert
    PORT MAP(
      data_in             => tx_data_plus_crc_ch1,
      data_valid_in       => tx_data_valid_plus_crc_ch1,
      data_out            => txdata_ch1,
      charisk_out         => txcharisk_ch1);

---------------------------------------------------------------------------
-- GTX
---------------------------------------------------------------------------

  -- Reset sources...
  gtxreset <= fullreset_ch0 OR fullreset_ch1;
  pllpowerdown <= pllpowerdown_ch0 OR pllpowerdown_ch1;
  refclkpwrdnb <= refclkpwrdnb_ch0 OR refclkpwrdnb_ch1;

  -- Hold the TX IN reset till the TX user clocks are stable
  txreset_ch0 <= link_reset_in;
  txreset_ch1 <= link_reset_in;
  -- Hold the RX IN reset till the RX user clocks are stable
  rxreset_ch0 <= link_reset_in;
  rxreset_ch1 <= link_reset_in;
  -- Tx clk distribution
  txusrclk_x1 <= link_clk1x_in;
  txusrclk_x2 <= link_clk2x_in;
  -- Enable minus comma alignment
  rxenmcommaalign_ch0 <= '1';
  rxenmcommaalign_ch1 <= '1';
  -- Enable positive comma alignment
  rxenpcommaalign_ch0 <= '1';
  rxenpcommaalign_ch1 <= '1';
  -- Originally had DCMs, etc inside this module
  txoutclk_out <= txoutclk; 
  plllkdet_out <= plllkdet;


  minit_gtx_tile_inst : minit_gtx_tile
  GENERIC MAP(
    -- Simulation attributes
    TILE_SIM_MODE                => SIM_MODE,
    TILE_SIM_GTX_RESET_SPEEDUP   => SIM_GTX_RESET_SPEEDUP,
    TILE_SIM_PLL_PERDIV2         => SIM_PLL_PERDIV2)
  PORT MAP(
    ------------------------ Loopback AND Powerdown Ports ----------------------
    LOOPBACK0_IN              =>      loopback_ch0,
    LOOPBACK1_IN              =>      loopback_ch1,
    RXPOWERDOWN0_IN           =>      rxpowerdown_ch0,
    RXPOWERDOWN1_IN           =>      rxpowerdown_ch1,
    TXPOWERDOWN0_IN           =>      txpowerdown_ch0,
    TXPOWERDOWN1_IN           =>      txpowerdown_ch1,
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    RXCHARISCOMMA0_OUT        =>      rxchariscomma_ch0,
    RXCHARISCOMMA1_OUT        =>      rxchariscomma_ch1,
    RXCHARISK0_OUT            =>      rxcharisk_ch0,
    RXCHARISK1_OUT            =>      rxcharisk_ch1,
    RXDISPERR0_OUT            =>      rxdisperr_ch0,
    RXDISPERR1_OUT            =>      rxdisperr_ch1,
    RXNOTINTABLE0_OUT         =>      rxnotintable_ch0,
    RXNOTINTABLE1_OUT         =>      rxnotintable_ch1,
    ------------------- Receive Ports - Clock Correction Ports -----------------
    RXCLKCORCNT0_OUT          =>      rxclkcorcnt_ch0,
    RXCLKCORCNT1_OUT          =>      rxclkcorcnt_ch1,
    --------------- Receive Ports - Comma Detection AND Alignment --------------
    RXBYTEISALIGNED0_OUT      =>      rxbyteisaligned_ch0,
    RXBYTEISALIGNED1_OUT      =>      rxbyteisaligned_ch1,
    RXENMCOMMAALIGN0_IN       =>      rxenmcommaalign_ch0,
    RXENMCOMMAALIGN1_IN       =>      rxenmcommaalign_ch1,
    RXENPCOMMAALIGN0_IN       =>      rxenpcommaalign_ch0,
    RXENPCOMMAALIGN1_IN       =>      rxenpcommaalign_ch1,
    ------------------- Receive Ports - RX Data Path interface -----------------
    RXDATA0_OUT               =>      rxdata_ch0,
    RXDATA1_OUT               =>      rxdata_ch1,
    RXRESET0_IN               =>      rxreset_ch0,
    RXRESET1_IN               =>      rxreset_ch1,
    RXUSRCLK0_IN              =>      txusrclk_x2,
    RXUSRCLK1_IN              =>      txusrclk_x2,
    RXUSRCLK20_IN             =>      txusrclk_x1,
    RXUSRCLK21_IN             =>      txusrclk_x1,
    ------- Receive Ports - RX Driver,OOB signalling,Coupling AND Eq.,CDR ------
    RXCDRRESET0_IN            =>      rxcdrreset_ch0,
    RXCDRRESET1_IN            =>      rxcdrreset_ch1,
    RXN0_IN                   =>      rxn_ch0_in,
    RXN1_IN                   =>      rxn_ch1_in,
    RXP0_IN                   =>      rxp_ch0_in,
    RXP1_IN                   =>      rxp_ch1_in,
    -------- Receive Ports - RX Elastic BUFFER AND Phase Alignment Ports -------
    RXBUFRESET0_IN            =>      rxbufreset_ch0,
    RXBUFRESET1_IN            =>      rxbufreset_ch1,
    RXBUFSTATUS0_OUT          =>      rxbufstatus_ch0,
    RXBUFSTATUS1_OUT          =>      rxbufstatus_ch1,
    --------------- Receive Ports - RX Loss-OF-sync State Machine --------------
    RXLOSSOFSYNC0_OUT         =>      rxlossofsync_ch0,
    RXLOSSOFSYNC1_OUT         =>      rxlossofsync_ch1,
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    RXPOLARITY0_IN            =>      rxpolarity_ch0,
    RXPOLARITY1_IN            =>      rxpolarity_ch1,
    ------------- SHARED Ports - Dynamic Reconfiguration PORT (DRP) ------------
    DADDR_IN                  =>      drp_addr_in,
    DCLK_IN                   =>      drp_clk_in,
    DEN_IN                    =>      drp_en_in,
    DI_IN                     =>      drp_data_in,
    DO_OUT                    =>      drp_data_out,
    DRDY_OUT                  =>      drp_rdy_out,
    DWE_IN                    =>      drp_we_in,
    --------------------- SHARED Ports - Tile AND PLL Ports --------------------
    CLKIN_IN                  =>      refclk,
    GTXRESET_IN              =>       gtxreset,
    PLLLKDET_OUT              =>      plllkdet,
    PLLPOWERDOWN_IN           =>      pllpowerdown,
    REFCLKOUT_OUT             =>      refclk_out,
    REFCLKPWRDNB_IN           =>      refclkpwrdnb,
    RESETDONE0_OUT            =>      resetdone_ch0,
    RESETDONE1_OUT            =>      resetdone_ch1,
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    TXCHARISK0_IN             =>      txcharisk_ch0,
    TXCHARISK1_IN             =>      txcharisk_ch1,
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TXDATA0_IN                =>      txdata_ch0,
    TXDATA1_IN                =>      txdata_ch1,
    TXOUTCLK0_OUT             =>      txoutclk,
    TXOUTCLK1_OUT             =>      open,
    TXRESET0_IN               =>      txreset_ch0,
    TXRESET1_IN               =>      txreset_ch1,
    TXUSRCLK0_IN              =>      txusrclk_x2,
    TXUSRCLK1_IN              =>      txusrclk_x2,
    TXUSRCLK20_IN             =>      txusrclk_x1,
    TXUSRCLK21_IN             =>      txusrclk_x1,
    --------------- Transmit Ports - TX Driver AND OOB signalling --------------
    TXN0_OUT                  =>      txn_ch0_out,
    TXN1_OUT                  =>      txn_ch1_out,
    TXP0_OUT                  =>      txp_ch0_out,
    TXP1_OUT                  =>      txp_ch1_out,
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    TXENPRBSTST0_IN           =>      "00",
    TXENPRBSTST1_IN           =>      "00",
    -------------------- Transmit Ports - TX Polarity Control ------------------
    TXPOLARITY0_IN            =>      txpolarity_ch0,
    TXPOLARITY1_IN            =>      txpolarity_ch1);


  ---------------------------------------------------------------------------
  -- Rx Stage (2): CRC
  ---------------------------------------------------------------------------


  rxdata_swap_ch0_proc: PROCESS(link_reset_in, link_clk1x_in)
  BEGIN
    IF link_reset_in = '1' THEN
      rxdata_buf_ch0 <= rxdata_ch0(31 DOWNTO 16);
      rxdata_swap_ch0 <= '0'; 
    ELSIF rising_edge(link_clk1x_in) THEN
      rxdata_buf_ch0 <= rxdata_ch0(31 DOWNTO 16);
      CASE rxchariscomma_ch0 IS
      WHEN "0100" =>
        rxdata_swap_ch0 <= '1'; 
      WHEN "0001" =>
        rxdata_swap_ch0 <= '0'; 
      WHEN OTHERS =>
        NULL;
      END CASE;
    END IF;
  END PROCESS;

  rxdata_ordered_ch0 <= rxdata_ch0(15 DOWNTO 0) & rxdata_buf_ch0 WHEN rxdata_swap_ch0 = '1' ELSE rxdata_ch0;
  rxdata_valid_ch0 <= NOT rxcharisk_ch0(0);

  links_crc_rx_ch0: links_crc_rx
  PORT MAP(
    reset                   => link_reset_in,
    clk                     => link_clk1x_in,
    data_in                 => rxdata_ordered_ch0,
    data_valid_in           => rxdata_valid_ch0,
    data_out                => rx_data_minus_crc_ch0,
    data_valid_out          => rx_data_valid_minus_crc_ch0,
    data_start_out          => sync_slave_ch0,
    reset_counters_in       => reset_status_ch0,
    crc_checked_cnt_out     => crc_checked_cnt_ch0,
    crc_error_cnt_out       => crc_error_cnt_ch0,
    status_out              => OPEN);

  sync_slave_ch0_out <= sync_slave_ch0;

  -- Currently using frame start TO GENERATE sync SIGNAL 
  -- Should we be using something else?
  links_sync_ch0: links_sync
  PORT MAP(
    reset                      => link_reset_in,
    clk                        => link_clk1x_in,
    sync_master_in             => sync_master_in,
    sync_slave_in              => sync_slave_ch0, 
    data_in                    => rx_data_minus_crc_ch0,
    data_valid_in              => rx_data_valid_minus_crc_ch0,
    sync_enable_in             => sync_enable_ch0,
    sync_delay_out             => sync_delay_ch0,
    sync_delay_enable_out      => sync_delay_enable_ch0,
    sync_error_out             => sync_error_ch0,
    data_out                   => rx_data_synced_ch0,
    data_valid_out             => rx_data_valid_synced_ch0);


  rxdata_swap_ch1_proc: PROCESS(link_reset_in, link_clk1x_in)
  BEGIN
    IF link_reset_in = '1' THEN
      rxdata_buf_ch1 <= rxdata_ch1(31 DOWNTO 16);
      rxdata_swap_ch1 <= '0'; 
    ELSIF rising_edge(link_clk1x_in) THEN
      rxdata_buf_ch1 <= rxdata_ch1(31 DOWNTO 16);
      CASE rxchariscomma_ch1 IS
      WHEN "0100" =>
        rxdata_swap_ch1 <= '1'; 
      WHEN "0001" =>
        rxdata_swap_ch1 <= '0'; 
      WHEN OTHERS =>
        NULL;
      END CASE;
    END IF;
  END PROCESS;

  rxdata_ordered_ch1 <= rxdata_ch1(15 DOWNTO 0) & rxdata_buf_ch1 WHEN rxdata_swap_ch1 = '1' ELSE rxdata_ch1;
  rxdata_valid_ch1 <= NOT rxcharisk_ch1(0);

  links_crc_rx_ch1: links_crc_rx
  PORT MAP(
    reset                   => link_reset_in,
    clk                     => link_clk1x_in,
    data_in                 => rxdata_ordered_ch1,
    data_valid_in           => rxdata_valid_ch1,
    data_out                => rx_data_minus_crc_ch1,
    data_valid_out          => rx_data_valid_minus_crc_ch1,
    data_start_out          => sync_slave_ch1,
    reset_counters_in       => reset_status_ch1,
    crc_checked_cnt_out     => crc_checked_cnt_ch1,
    crc_error_cnt_out       => crc_error_cnt_ch1,
    status_out              => OPEN);

  sync_slave_ch1_out <= sync_slave_ch1;

  -- Currently using frame start TO GENERATE sync SIGNAL 
  -- Should we be using something else?
  links_sync_ch1: links_sync
  PORT MAP(
    reset                      => link_reset_in,
    clk                        => link_clk1x_in,
    sync_master_in             => sync_master_in,
    sync_slave_in              => sync_slave_ch1, 
    data_in                    => rx_data_minus_crc_ch1,
    data_valid_in              => rx_data_valid_minus_crc_ch1,
    sync_enable_in             => sync_enable_ch1,
    sync_delay_out             => sync_delay_ch1,
    sync_delay_enable_out      => sync_delay_enable_ch1,
    sync_error_out             => sync_error_ch1,
    data_out                   => rx_data_synced_ch1,
    data_valid_out             => rx_data_valid_synced_ch1);

  ---------------------------------------------------------------------------
  -- Pattern Injection
  ---------------------------------------------------------------------------

  -- 00: Off
  -- 01: Patern Capture
  -- 10: Pattern inject before GTX 
  -- 11: Pattern inject AFTER GTX

  pat_add <= ttc_time_in;

  ---------------------------------------------------------------------------

  -- Are we performing pattern capture?
  pat_wen_ch0 <= '1' WHEN ((pat_cntrl_ch0 = "01") AND (ttc_cntrl_in = "01")) ELSE '0';
  pat_stb_ch0 <= '1' WHEN pat_cntrl_ch0 /= "00" ELSE '0';

  -- Pattern input TO GTX transceiver
  tx_data_plus_pat_ch0 <= pat_rdata_ch0 WHEN pat_cntrl_ch0 = "10" ELSE tx_data_ch0_in;
  tx_data_valid_plus_pat_ch0 <= pat_rdata_valid_ch0 WHEN pat_cntrl_ch0 = "10" ELSE tx_data_valid_ch0_in;

  -- Pattern inject TO downstream code
  rx_data_ch0_out <= pat_rdata_ch0 WHEN pat_cntrl_ch0 = "11" ELSE rx_data_synced_ch0;
  rx_data_valid_ch0_out <= pat_rdata_valid_ch0 WHEN pat_cntrl_ch0 = "11" ELSE rx_data_valid_synced_ch0;

  -- SELECT SIGNAL TO write TO BUFFER
  pat_wdata_ch0 <= rx_data_synced_ch0;
  pat_wdata_valid_ch0 <= rx_data_valid_synced_ch0;

  dpram_ch0: pattern_ram_36x512_32x1024
    PORT MAP(
        pat_clk             => link_clk1x_in,
        pat_stb             => pat_stb_ch0,
        pat_wen             => pat_wen_ch0,
        pat_add             => pat_add,
        pat_rdata           => pat_rdata_ch0,
        pat_rdata_valid     => pat_rdata_valid_ch0,
        pat_wdata           => pat_wdata_ch0,
        pat_wdata_valid     => pat_wdata_valid_ch0,
        ram_clk             => link_clk1x_in,
        ram_stb             => ram_stb_ch0,
        ram_wen             => ram_wen_ch0,
        ram_add             => ram_add_ch0,
        ram_wdata           => ram_wdata_ch0,
        ram_ack             => ram_ack_ch0,
        ram_rdata           => ram_rdata_ch0);

  -- Are we performing pattern capture?
  pat_wen_ch1 <= '1' WHEN ((pat_cntrl_ch1 = "01") AND (ttc_cntrl_in = "01")) ELSE '0';
  pat_stb_ch1 <= '1' WHEN pat_cntrl_ch1 /= "00" ELSE '0';

  -- Pattern input TO GTX transceiver
  tx_data_plus_pat_ch1 <= pat_rdata_ch1 WHEN pat_cntrl_ch1 = "10" ELSE tx_data_ch1_in;
  tx_data_valid_plus_pat_ch1 <= pat_rdata_valid_ch1 WHEN pat_cntrl_ch1 = "10" ELSE tx_data_valid_ch1_in;

  -- Pattern inject TO downstream code
  rx_data_ch1_out <= pat_rdata_ch1 WHEN pat_cntrl_ch1 = "11" ELSE rx_data_synced_ch1;
  rx_data_valid_ch1_out <= pat_rdata_valid_ch1 WHEN pat_cntrl_ch1 = "11" ELSE rx_data_valid_synced_ch1;

  -- SELECT SIGNAL TO write TO BUFFER
  pat_wdata_ch1 <= rx_data_synced_ch1;
  pat_wdata_valid_ch1 <= rx_data_valid_synced_ch1;

  dpram_ch1: pattern_ram_36x512_32x1024
    PORT MAP(
        pat_clk             => link_clk1x_in,
        pat_stb             => pat_stb_ch1,
        pat_wen             => pat_wen_ch1,
        pat_add             => pat_add,
        pat_rdata           => pat_rdata_ch1,
        pat_rdata_valid     => pat_rdata_valid_ch1,
        pat_wdata           => pat_wdata_ch1,
        pat_wdata_valid     => pat_wdata_valid_ch1,
        ram_clk             => link_clk1x_in,
        ram_stb             => ram_stb_ch1,
        ram_wen             => ram_wen_ch1,
        ram_add             => ram_add_ch1,
        ram_wdata           => ram_wdata_ch1,
        ram_ack             => ram_ack_ch1,
        ram_rdata           => ram_rdata_ch1);

  ---------------------------------------------------------------------------
  -- REGISTER ACCESS: Ch0
  ---------------------------------------------------------------------------

   -- ReadOnly Regs: Ch0
   ro_regs_ch0(0) <= x"000000" & '0' & 
                     sync_error_ch0 &
                     sync_delay_ch0 &
                     sync_delay_enable_ch0;
   ro_regs_ch0(1) <= autoalign_lock_checks_ch0;
   ro_regs_ch0(2) <= "00000" &
                     rxchariscomma_ch0 & 
                     rxcharisk_ch0 & 
                     rxdisperr_ch0 & 
                     rxnotintable_ch0 & 
                     '0' &
                     rxclkcorcnt_ch0 & 
                     rxbyteisaligned_ch0 & 
                     '0' & 
                     rxbufstatus_ch0 & 
                     rxlossofsync_ch0;
   ro_regs_ch0(3) <= x"000000" & 
                    "0000" &
                     gtxreset &
                     plllkdet & 
                     resetdone_ch0 & 
                     '0';
   ro_regs_ch0(4) <= crc_checked_cnt_ch0;
   ro_regs_ch0(5) <= crc_error_cnt_ch0;
   ro_regs_ch0(6) <= autoalign_status_ch0;

   fill_spare_ro_regs_ch0: FOR i IN 7 TO 7 GENERATE
      ro_regs_ch0(i) <= x"00000000";
   END GENERATE;

   -- ReadWrite Regs: Ch0
   bc0_discrepancy_req_ch0 <= rw_regs_ch0(0)(12 DOWNTO 0);
   autoalign_once_ch0  <= rw_regs_ch0(0)(13);
   autoalign_auto_ch0  <= rw_regs_ch0(0)(14);
   reset_status_ch0  <= rw_regs_ch0(0)(15);
   -- spy_write_stop_ch0 <= rw_regs_ch0(0)(16);
   rxbufreset_ch0 <= rw_regs_ch0(0)(17);
   rxcdrreset_ch0 <= rw_regs_ch0(0)(18);
   fullreset_ch0 <= rw_regs_ch0(0)(19);
   pllpowerdown_ch0 <= rw_regs_ch0(0)(20);
   rxpowerdown_ch0 <= rw_regs_ch0(0)(21);
   txpowerdown_ch0 <= rw_regs_ch0(0)(22);
   refclkpwrdnb_ch0 <= rw_regs_ch0(0)(23);
   sync_enable_ch0 <= rw_regs_ch0(0)(24);
   pat_cntrl_ch0  <= rw_regs_ch0(0)(26 DOWNTO 25);

   loopback_ch0 <= rw_regs_ch0(1)(2 DOWNTO 0);
   txdiffctrl_ch0 <= rw_regs_ch0(1)(5 DOWNTO 3);
   txpreemphasis_ch0 <= rw_regs_ch0(1)(8 DOWNTO 6);
   txpolarity_ch0 <= rw_regs_ch0(1)(9);
   rxpolarity_ch0 <= rw_regs_ch0(1)(10);
   

   -- ReadWrite DefaultRegs: Ch0
   rw_regs_default_ch0(0) <= x"0070" & "000" & std_logic_vector(to_unsigned(20, 13));
   rw_regs_default_ch0(1) <= x"00000" & "000" & "000" & "100" & "000";
   
   fill_spare_rw_regs_default_ch0: FOR i IN 2 TO 7 GENERATE
      rw_regs_default_ch0(i) <= x"00000000";
   END GENERATE;
   
---------------------------------------------------------------------------
-- REGISTER ACCESS: Ch1
---------------------------------------------------------------------------

   -- ReadOnly Regs: ch1
   ro_regs_ch1(0) <= x"000000" & '0' & 
                     sync_error_ch1 &
                     sync_delay_ch1 &
                     sync_delay_enable_ch1;
   ro_regs_ch1(1) <= autoalign_lock_checks_ch1;
   ro_regs_ch1(2) <= "00000" &
                     rxchariscomma_ch1 &    -- 0x4000
                     rxcharisk_ch1 &        -- 0x2000
                     rxdisperr_ch1 &        -- 0x1000
                     rxnotintable_ch1 &     -- 0x0800
                     '0' &        -- 0x0400
                     rxclkcorcnt_ch1 &      -- 0x0200 DOWNTO 0x0080
                     rxbyteisaligned_ch1 &  -- 0x0040
                     '0' &       -- 0x0020
                     rxbufstatus_ch1 &      -- 0x0010 DOWNTO 0x0004
                     rxlossofsync_ch1;      -- 0x0002 DOWNTO 0x0001 
   ro_regs_ch1(3) <= x"000000" &
                     "0000" &
                     gtxreset &
                     plllkdet & 
                     resetdone_ch1 & 
                     '0';
   ro_regs_ch1(4) <= crc_checked_cnt_ch1;
   ro_regs_ch1(5) <= crc_error_cnt_ch1;
   ro_regs_ch1(6) <= autoalign_status_ch1;

   fill_spare_ro_regs_ch1: FOR i IN 7 TO 7 GENERATE
      ro_regs_ch1(i) <= x"00000000";
   END GENERATE;

   -- ReadWrite Regs: ch1
   bc0_discrepancy_req_ch1 <= rw_regs_ch1(0)(12 DOWNTO 0);
   autoalign_once_ch1  <= rw_regs_ch1(0)(13);
   autoalign_auto_ch1  <= rw_regs_ch1(0)(14);
   reset_status_ch1  <= rw_regs_ch1(0)(15);
   --spy_write_stop_ch1 <= rw_regs_ch1(0)(16);
   rxbufreset_ch1 <= rw_regs_ch1(0)(17);
   rxcdrreset_ch1 <= rw_regs_ch1(0)(18);
   fullreset_ch1 <= rw_regs_ch1(0)(19);
   pllpowerdown_ch1 <= rw_regs_ch1(0)(20);
   rxpowerdown_ch1 <= rw_regs_ch1(0)(21);
   txpowerdown_ch1 <= rw_regs_ch1(0)(22);
   refclkpwrdnb_ch1 <= rw_regs_ch1(0)(23);
   sync_enable_ch1 <= rw_regs_ch1(0)(24);
   pat_cntrl_ch1  <= rw_regs_ch1(0)(26 DOWNTO 25);

   loopback_ch1 <= rw_regs_ch1(1)(2 DOWNTO 0);
   txdiffctrl_ch1 <= rw_regs_ch1(1)(5 DOWNTO 3);
   txpreemphasis_ch1 <= rw_regs_ch1(1)(8 DOWNTO 6);
   txpolarity_ch1 <= rw_regs_ch1(1)(9);
   rxpolarity_ch1 <= rw_regs_ch1(1)(10);
   
   -- ReadWrite DefaultRegs: ch1
   rw_regs_default_ch1(0) <= x"0070" & "000" & std_logic_vector(to_unsigned(20, 13));
   rw_regs_default_ch1(1) <= x"00000" & "000" & "000" & "100" & "000";
   
   fill_spare_rw_regs_default_ch1: FOR i IN 2 TO 7 GENERATE
      rw_regs_default_ch1(i) <= x"00000000";
   END GENERATE;
      
---------------------------------------------------------------------------
-- Useful information
---------------------------------------------------------------------------


   -- Loopback mode (loopback)
   -- 000: Normal operation
   -- 001: Near-END PCS Loopback
   -- 010: Near-END PMA Loopback
   -- 011: Reserved
   -- 100: Far-END PMA Loopback
   -- 101: Reserved
   -- 110: Far-END PCS Loopback(1)
   -- 111: Reserved

   -- Magnitude OF differential swing (txdiffctrl)
   -- 000: 1100
   -- 001: 1050
   -- 010: 1000
   -- 011: 900
   -- 100: 800
   -- 101: 600
   -- 110: 400
   -- 111: 0

   -- Magnitude OF pre-emphasis (txpreemphasis)
   -- TxPreEmphasis (%) TX_DIFF_BOOST = FALSE(Default), TRUE
   -- 000: 2 3
   -- 001: 2 3
   -- 010: 2.5 4
   -- 011: 4.5 10.5
   -- 100: 9.5 18.5
   -- 101: 16 28
   -- 110: 23 39
   -- 111: 31 52
     
END behave;
