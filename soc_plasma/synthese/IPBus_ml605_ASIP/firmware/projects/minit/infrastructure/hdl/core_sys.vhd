
-- ToDo:: 
-- Remove subtract from within module_select
-- MasterSyncChan - programmable

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- USE ieee.std_logic_unsigned.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;
USE work.package_reg.ALL;
USE work.package_utilities.ALL;
USE work.package_i2c.ALL;
USE work.package_daq.ALL;
USE work.package_control.ALL;

LIBRARY TMCaloTrigger_lib;
USE TMCaloTrigger_lib.linkinterface.ALL;
USE TMCaloTrigger_lib.types.ALL;
USE TMCaloTrigger_lib.constants.ALL;

ENTITY core_sys IS
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
    debug_out        : OUT std_logic_vector(7 DOWNTO 0); 
    test_out         : OUT std_logic_vector(31 DOWNTO 0));
END core_sys;

ARCHITECTURE behave OF core_sys IS

  COMPONENT sys_info IS
    GENERIC(
      module:            type_mod_define;
      sys_id:            std_logic_vector(31 DOWNTO 0) := x"00000000";
      board_id:          std_logic_vector(31 DOWNTO 0) := x"00000000";
      slave_id:          std_logic_vector(31 DOWNTO 0) := x"00000000";
      firmware_id:       std_logic_vector(31 DOWNTO 0) := x"00000000");
    PORT(
      clk:               IN std_logic;
      rst:               IN std_logic;
      comm_cntrl:        IN type_comm_cntrl;
      comm_reply:        OUT type_comm_reply;
      test_out:          OUT std_logic_vector(31 DOWNTO 0));
  END COMPONENT;

  COMPONENT minit_gtx_comm_interface_basic IS
    GENERIC(
      local_lhc_bunch_count:             integer := lhc_bunch_count;         -- USE 200 FOR sim ELSE lhc_bunch_count
      sim_mode:                          string := "fast";                   -- Set TO Fast Functional Simulation Model
      sim_gtx_reset_speedup:             integer:= 0;                        -- Set TO 1 TO speed up sim reset
      sim_pll_perdiv2:                   bit_vector:= x"0d0");                -- Set TO the VCO Unit Interval time     
    PORT(
      -- Fabric clk/fabric_reset_in
      fabric_clk1x_in              : IN std_logic;
      fabric_reset_in              : IN std_logic;  
      -- Link clk/fabric_reset_in
      link_clk1x_in                : IN std_logic;
      link_clk2x_in                : IN std_logic;
      link_reset_in                : IN std_logic;
      -- GTP PLL clks
      txoutclk_out                 : OUT std_logic;
      plllkdet_out                 : OUT std_logic;
      -- Comm interface
      comm_enable                  : IN std_logic;
      comm_cntrl                   : IN type_comm_cntrl;
      comm_reply                   : OUT type_comm_reply;
      -- Sync channels together 
      sync_master_in               : IN std_logic;
      sync_slave_ch0_out           : OUT std_logic;
      sync_slave_ch1_out           : OUT std_logic;
      -- Pattern Inject/Capture control
      ttc_cntrl_in                 : IN std_logic_vector(1 DOWNTO 0);
      ttc_time_in                   : IN std_logic_vector(8 DOWNTO 0);
      -- Rx parallel data OUT
      rx_data_ch0_out              : OUT std_logic_vector(31 DOWNTO 0);
      rx_data_ch1_out              : OUT std_logic_vector(31 DOWNTO 0);
      rx_data_valid_ch0_out        : OUT  std_logic;
      rx_data_valid_ch1_out        : OUT  std_logic;   
      -- Rx serdes IN
      rxn_ch0_in                   : IN std_logic;
      rxn_ch1_in                   : IN std_logic;
      rxp_ch0_in                   : IN std_logic;
      rxp_ch1_in                   : IN std_logic;
      -- Ref clock
      refclkp_in                   : IN std_logic;
      refclkn_in                   : IN std_logic;
      refclk_out                   : OUT std_logic;
      -- Tx parallel data IN
      tx_data_ch0_in               : IN std_logic_vector(31 DOWNTO 0);
      tx_data_ch1_in               : IN std_logic_vector(31 DOWNTO 0);
      tx_data_valid_ch0_in         : IN std_logic;
      tx_data_valid_ch1_in         : IN std_logic;
      -- Tx serdes data OUT
      txn_ch0_out                  : OUT std_logic;
      txn_ch1_out                  : OUT std_logic;
      txp_ch0_out                  : OUT std_logic;
      txp_ch1_out                  : OUT std_logic);
  END COMPONENT;

  COMPONENT minit_gtx_txusrclk IS
  GENERIC (    
      performance_mode    : string   := "MAX_SPEED";
      clkfx_divide        : integer := 5;
      clkfx_multiply      : integer := 4;
      dfs_frequency_mode  : string := "LOW";
      dll_frequency_mode  : string := "LOW");
  PORT (
      clk_in                    : IN  std_logic;
      dcm_reset_in              : IN  std_logic;
      clk_d2_out                : OUT std_logic;
      clk_x1_out                : OUT std_logic;
      clk_x2_out                : OUT std_logic;
      clk_fx_out                : OUT std_logic;
      dcm_locked_out            : OUT std_logic);
  END COMPONENT;

  COMPONENT minit_dcm_reset IS
  PORT (
      clk_in                    : IN  std_logic;
      reset_in                  : IN  std_logic;
      dcm_lock_in               : IN std_logic;
      dcm_reset_out             : OUT std_logic);
  END COMPONENT;

  COMPONENT AlgorithmTop IS
  PORT(
    --TEMPORARY FOR TESTBENCH AND TO MAKE SYNTHESIS INCLUDE EVERYTHING  
    -- pragma translate_off
    OutLinearTowers        : OUT aLinearTowers;
    OutZeroedTowers         : OUT aLinearTowers;
    OutEHSum          : OUT aEHSums;
    OutPipe2x1SumA        : OUT a2x1Sums;
    OutPipe2x1SumB        : OUT a2x1Sums;
    OutPipe2x1ETSumA      : OUT a2x1ETSums;
    OutPipe2x1ETSumB      : OUT a2x1ETSums;
    OutPipe1x2ETSumA      : OUT a2x1ETSums;
    OutPipe1x2ETSumB      : OUT a2x1ETSums;
    OutPipe2x2SumA        : OUT a2x2Sums;
    OutPipe2x2SumB        : OUT a2x2Sums;
    OutPipe2x2ETSumA      : OUT a2x2ETSums;
    OutPipe2x2ETSumB      : OUT a2x2ETSums;
    OutPipeEPIMA        : OUT aEPIMs;
    OutPipeEPIMB        : OUT aEPIMs;
    OutPipeFilterMaskA      : OUT aFilterMask;
    OutPipeFilterMaskB      : OUT aFilterMask;
    OutPipeClusterPositionA    : OUT aClusterPosition;
    OutPipeClusterPositionB    : OUT aClusterPosition;
    OutPipeFilteredClusterA    : OUT aFilteredCluster;
    OutPipeFilteredClusterB    : OUT aFilteredCluster;
    -- pragma translate_on
    OutClusterSorting      : OUT aSortedCluster( (2*cNumberOfLinks)-1 DOWNTO 0 );
    -- -- OutSortedCluster      : OUT aSortedCluster( (2**cBitonicWidth)-1 DOWNTO 0 );
    OutPipeSortedCluster    : OUT aSortedCluster( cClustersPerPhi-1 DOWNTO 0 );
    -- OutPipeClusterFlag       : OUT aClusterFlag;
    -- OutPipeJF1D         : OUT aJet1D;
    epimlut_address:      IN  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
    epimlut_data:        IN  STD_LOGIC_VECTOR( 15 DOWNTO 0 );
    epimlut_cl0ck:        IN  std_logic;
    epimlut_enable:        IN  std_logic;
    ecallut_address:      IN  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
    ecallut_data:        IN  STD_LOGIC_VECTOR( 15 DOWNTO 0 );
    ecallut_cl0ck:        IN  std_logic;
    ecallut_enable:        IN  std_logic;
    hcallut_address:      IN  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
    hcallut_data:        IN  STD_LOGIC_VECTOR( 15 DOWNTO 0 );
    hcallut_cl0ck:        IN  std_logic;
    hcallut_enable:        IN  std_logic;
    -- jfradiuslut_address:    IN  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
    -- jfradiuslut_data:      IN  STD_LOGIC_VECTOR( 15 DOWNTO 0 );
    -- jfradiuslut_cl0ck:      IN  std_logic;
    -- jfradiuslut_enable:      IN  std_logic;
    clk_160    : IN STD_LOGIC;
    sync_reset_b  : IN STD_LOGIC := '0';
    --links_in  : IN aLinearTowers
    links_in  : IN all_links((cNumberOfLinks-1) DOWNTO 0));
  END COMPONENT;

  SIGNAL fabric_reset_b: std_logic;

  -- Internal communication BUS
  CONSTANT comm_units:                   natural := 9;
  SIGNAL comm_cntrl:                     type_comm_bus_cntrl(comm_units-1 DOWNTO 0);
  SIGNAL comm_reply:                     type_comm_bus_reply(comm_units-1 DOWNTO 0);

  -- Branch from Comm BUS TO load algo LUTs.  
  -- No readback.  Would be good FOR verification.
  SIGNAL algo_cntrl:                     type_comm_cntrl;
  SIGNAL algo_reply:                     type_comm_reply;
  SIGNAL epimlut_enable, ecallut_enable, hcallut_enable: std_logic;

  -- Tx Data
  SIGNAL tx_data_ch0                  : type_vector_of_stdlogicvec_x32(gtx_max DOWNTO gtx_min);
  SIGNAL tx_data_ch1                  : type_vector_of_stdlogicvec_x32(gtx_max DOWNTO gtx_min);
  SIGNAL tx_data_valid_ch0            : std_logic_vector(gtx_max DOWNTO gtx_min);
  SIGNAL tx_data_valid_ch1            : std_logic_vector(gtx_max DOWNTO gtx_min);
  SIGNAL tx_select                    : std_logic;
  -- Rx Data
  SIGNAL rx_data_ch0                  : type_vector_of_stdlogicvec_x32(gtx_max DOWNTO gtx_min);
  SIGNAL rx_data_ch1                  : type_vector_of_stdlogicvec_x32(gtx_max DOWNTO gtx_min);
  SIGNAL rx_data_valid_ch0            : std_logic_vector(gtx_max DOWNTO gtx_min);
  SIGNAL rx_data_valid_ch1            : std_logic_vector(gtx_max DOWNTO gtx_min);
  -- Txout clks from PLL IN gtx0
  SIGNAL txoutclk                : std_logic_vector(gtx_max DOWNTO gtx_min) := (OTHERS => '0');
  SIGNAL plllkdet                : std_logic_vector(gtx_max DOWNTO gtx_min) := (OTHERS => '0');
  SIGNAL refclk                  : std_logic_vector(gtx_max DOWNTO gtx_min) := (OTHERS => '0');
  SIGNAL clksys_lock            : std_logic;
  SIGNAL link_clk_rst      : std_logic;
  -- Global link clks (used TO drive txuser/rxuser clks) FOR ALL GTPs using gtx0 refclks 
  SIGNAL link_clk1x              : std_logic;
  SIGNAL link_clk2x              : std_logic;
  SIGNAL link_clk_lock           : std_logic;
  SIGNAL link_reset              : std_logic;
  SIGNAL link_reset_b            : std_logic;
  -- Test pattern generation
  SIGNAL counter                      : natural RANGE 0 TO 511;
  SIGNAL counter_word : std_logic_vector(8 DOWNTO 0);
  SIGNAL counter_data                 : std_logic_vector(31 DOWNTO 0);
  SIGNAL counter_data_valid           : std_logic;
  -- Incoming data from ConcElec/ConcJet
  SIGNAL trig_data_ch0               : type_vector_of_stdlogicvec_x32(gtx_max DOWNTO gtx_min) := (OTHERS => x"00000000");
  SIGNAL trig_data_ch1               : type_vector_of_stdlogicvec_x32(gtx_max DOWNTO gtx_min) := (OTHERS => x"00000000");
  SIGNAL trig_data_valid_ch0         : std_logic_vector(gtx_max DOWNTO gtx_min) := (OTHERS => '0');
  SIGNAL trig_data_valid_ch1         : std_logic_vector(gtx_max DOWNTO gtx_min) := (OTHERS => '0');
  
  CONSTANT gtx_units: natural RANGE 0 TO 31:= gtx_max-gtx_min+1;
  SIGNAL comm_gtx_cntrl: type_comm_bus_cntrl(gtx_units-1 DOWNTO 0);
  SIGNAL comm_gtx_reply: type_comm_bus_reply(gtx_units-1 DOWNTO 0);
  SIGNAL comm_gtx_port: integer RANGE 0 TO 31;
  SIGNAL comm_gtx_enable: std_logic_vector(gtx_max DOWNTO gtx_min);
  SIGNAL comm_gtx_add: std_logic_vector(31 DOWNTO 0);

  

  SIGNAL rw_reg, ro_reg: type_vector_of_stdlogicvec_x32(15 DOWNTO 0);

  SIGNAL sync_master: std_logic;
  SIGNAL sync_master_delay: std_logic_vector(4 DOWNTO 0);
  SIGNAL sync_master_delay_enable: std_logic;
  SIGNAL sync_slave_ch0: std_logic_vector(gtx_max DOWNTO gtx_min);
  SIGNAL sync_slave_ch1: std_logic_vector(gtx_max DOWNTO gtx_min);

  SIGNAL ttc_time: std_logic_vector(8 DOWNTO 0);
  SIGNAL ttc_cntrl: std_logic_vector(1 DOWNTO 0);

  -- Input TO algo
  SIGNAL rx_data_array, rx_data_array_d1: all_links(cNumberOfLinks-1 DOWNTO 0);
  SIGNAL rx_valid, rx_valid_d1: std_logic;
  -- Convert data into format FOR DAQ (i.e. very large std_logic_vector) 
  SIGNAL rx_data_d1: std_logic_vector(32*cNumberOfLinks-1 DOWNTO 0);
  SIGNAL rx_id_d1: std_logic_vector(11 DOWNTO 0);

  -- Output from algo
  SIGNAL result_data: aSortedCluster( (2*cNumberOfLinks)-1 DOWNTO 0 );
  SIGNAL result_array: type_vector_of_stdlogicvec_x32( (2*cNumberOfLinks)-1 DOWNTO 0 );
  SIGNAL result_vec: std_logic_vector(32*2*cNumberOfLinks-1 DOWNTO 0);
  SIGNAL result_id: std_logic_vector(11 DOWNTO 0);
  SIGNAL result_valid: std_logic;
  -- Delay UNITS always have 1 clk delay...  Hence FOR 10 clks program 9...
  CONSTANT result_delay: std_logic_vector(4 DOWNTO 0) := std_logic_vector(to_unsigned(8,5));

  -- Algo data valid.  Set TO '0' between events TO reset algo.
  SIGNAL algo_enable : std_logic;

  -- Used FOR master "packet_valid" AND "packet_id"
  CONSTANT algo_gtxd_master: natural RANGE 0 TO 31 := 6;

  SIGNAL trig: std_logic;

  CONSTANT daq_units: natural := 2;

  SIGNAL daq_chain: std_logic_vector(daq_units DOWNTO 0);
  SIGNAL daq_valid, daq_empty: std_logic_vector(daq_units-1 DOWNTO 0);
  SIGNAL daq_data: type_vector_of_stdlogicvec_x32(daq_units-1 DOWNTO 0);

  SIGNAL daqmerge_valid: std_logic;
  SIGNAL daqmerge_data: std_logic_vector(31 DOWNTO 0);

begin

  fabric_reset_b <= NOT fabric_reset_in;
  link_reset_b <= NOT link_reset;

  -- Hub FOR communication TO ALL the "comm" slave untits.
  comm_std_hub_inst: comm_std_hub
  GENERIC MAP(
    comm_units              => comm_units)
  PORT MAP(
    rst_in                    => fabric_reset_in,
    clk_in                    => fabric_clk1x_in,
    comm_bus_cntrl_out        => comm_cntrl,
    comm_bus_reply_in         => comm_reply,
    stb_in                    => ipbus_strobe_in,
    wen_in                    => ipbus_write_in,
    add_in                    => ipbus_addr_in,
    wdata_in                  => ipbus_wdata_in,
    ack_out                   => ipbus_ack_out,
    err_out                   => ipbus_berr_out,
    rdata_out                 => ipbus_rdata_out);

  -- SlaveId, FirmwareVersion, etc..
  sys_info_inst: sys_info
  GENERIC MAP(
    module                  => module_sys_info,
    firmware_id             => firmware)
  PORT MAP(
    rst                     => fabric_reset_in,
    clk                     => fabric_clk1x_in,
    comm_cntrl              => comm_cntrl(0),
    comm_reply              => comm_reply(0),
    test_out                => test_out);

  ---------------------------------------------------------------
  ---------------------------------------------------------------

  -- ARRAY OF regs FOR GENERIC write capability
  reg_array_out_inst: reg_array_out
  GENERIC MAP(
    module              => module_reg_array_out,
    number_of_words     => 16)
  PORT MAP( 
    rstb_in             => fabric_reset_b,
    clk_in              => fabric_clk1x_in,
    comm_cntrl          => comm_cntrl(1),
    comm_reply          => comm_reply(1),
    data_array_out      => rw_reg);

  -- ARRAY OF regs FOR GENERIC read capability
  reg_array_in_inst: reg_array_in
  GENERIC MAP(
    module              => module_reg_array_in,
    number_of_words     => 16)
  PORT MAP( 
    rstb_in             => fabric_reset_b,
    clk_in              => fabric_clk1x_in,
    comm_cntrl          => comm_cntrl(2),
    comm_reply          => comm_reply(2),
    data_array_in       => ro_reg);

  ---------------------------------------------------------------
  ---------------------------------------------------------------

  -- Note that control BUS labelled si5325 rather than si5326
  si5326_cntrl(0) <= rw_reg(0)(0);  -- rst_b
  ro_reg(0)(0) <= si5326_cntrl(1);  -- int_c1b
  ro_reg(0)(1) <= si5326_cntrl(2);  -- lol

  si5326_i2c: i2c_master_top
  GENERIC MAP(
    module                        => module_si5326_i2c,
    base_board_clk                => 125000000,
    i2c_clk_speed                 => i2c_clk_speed)
  PORT MAP( 
    reset_b                       => fabric_reset_b,
    clk                           => fabric_clk1x_in,
    comm_cntrl                    => comm_cntrl(3),
    comm_reply                    => comm_reply(3),
    scl                           => si5326_cntrl(3),
    sda                           => si5326_cntrl(4));

  ---------------------------------------------------------------
  ---------------------------------------------------------------

  snap12_tx0_cntrl(0) <= rw_reg(1)(0);  -- reset_b
  snap12_tx0_cntrl(1) <= rw_reg(1)(1);      -- txdis
  snap12_tx0_cntrl(2) <= rw_reg(1)(2);      -- txen
  ro_reg(1)(0) <= snap12_tx0_cntrl(5);  -- fault_b

  snap12_rx0_cntrl(0) <= rw_reg(1)(8);   -- EnableSignalDetect
  snap12_rx0_cntrl(1) <= rw_reg(1)(9);   -- RxEnable
  snap12_rx0_cntrl(2) <= rw_reg(1)(10);  -- SquelchEnable
  ro_reg(1)(8) <= snap12_rx0_cntrl(5);   -- SignalDetect

  snap12_rx0_cntrl(3) <= 'Z';
  snap12_rx0_cntrl(4) <= 'Z';

  snap12_rx2_cntrl(0) <= rw_reg(1)(16);  -- EnableSignalDetect
  snap12_rx2_cntrl(1) <= rw_reg(1)(17);  -- RxEnable
  snap12_rx2_cntrl(2) <= rw_reg(1)(18);  -- SquelchEnable
  ro_reg(1)(16) <= snap12_rx2_cntrl(5);  -- SignalDetect

  snap12_rx2_cntrl(3) <= 'Z';
  snap12_rx2_cntrl(4) <= 'Z';

  snap12_tx0_i2c: i2c_master_top
  GENERIC MAP(
    module                        => module_snap12_tx0_i2c,
    base_board_clk                => 125000000,
    i2c_clk_speed                 => i2c_clk_speed)
  PORT MAP( 
    reset_b                       => fabric_reset_b,
    clk                           => fabric_clk1x_in,
    comm_cntrl                    => comm_cntrl(5),
    comm_reply                    => comm_reply(5),
    scl                           => snap12_tx0_cntrl(3),
    sda                           => snap12_tx0_cntrl(4));

  ---------------------------------------------------------------
  ---------------------------------------------------------------

  counter_proc: PROCESS(link_reset, link_clk1x)
  BEGIN
    IF link_reset = '1' THEN
      counter <= 0;
    ELSIF link_clk1x'event AND link_clk1x='1' THEN
      IF counter < 511 THEN
        counter <= counter+1;
      ELSE
        counter <= 0;
      END IF;
    END IF;
  END PROCESS;

  counter_word <= std_logic_vector(to_unsigned(counter, 9));

  counter_data_proc: PROCESS(link_reset, link_clk1x)
  BEGIN
    IF link_reset = '1' THEN
        counter_data_valid <= '0';
        counter_data <= x"00000000";
    ELSIF rising_edge(link_clk1x) THEN
      -- Reg data valid
      -- Max length OF event is 64 words
      -- Set by requiremnet that must have >= 8 IN the DAQ BUFFER AND  
      -- transceiver pattern RAM is 512 deep. 
      IF (counter rem 64) < 30 THEN
        counter_data <= x"ABCD" & "0000000" & counter_word;
        counter_data_valid <= '1';
      ELSE
        counter_data <= x"00000000";
        counter_data_valid <= '0';
      END IF;
    END IF;
  END PROCESS;

  --------------------------------------------------------------------------
  -- GENERATE TxUser AND RxUser Clks (external)
  --------------------------------------------------------------------------

    dcm : minit_gtx_txusrclk
    GENERIC MAP(
      performance_mode              => "MAX_SPEED",
      clkfx_divide                  => 5,
      clkfx_multiply                => 4,
      dfs_frequency_mode            => "LOW",
      dll_frequency_mode            => "LOW")
    PORT MAP(
      clk_in                          =>      link_clk1x_in,
      dcm_reset_in                    =>      link_clk_rst,
      clk_d2_out                      =>      open,          -- Unused
      clk_x1_out                      =>      link_clk1x,    -- 125MHz
      clk_x2_out                      =>      link_clk2x,    -- 250MHz
      clk_fx_out                      =>      open, -- link_clkfx,    -- 100Mhz
      dcm_locked_out                  =>      link_clk_lock);

    dcm_rst: minit_dcm_reset 
    PORT MAP (
      clk_in              => fabric_clk1x_in,
      reset_in            => fabric_reset_in,
      dcm_lock_in         => '1',
      dcm_reset_out       => link_clk_rst);

  --------------------------------------------------------------------------
  -- Reset
  --------------------------------------------------------------------------

  link_reset <= (NOT link_clk_lock) OR link_clk_rst;

  --------------------------------------------------------------------------
  -- Delay master sync SIGNAL TO allow ALL channels TO align
  --------------------------------------------------------------------------

  sync_master_delay_inst: delay_bit
  PORT MAP (
      reset_b        => link_reset_b,
      clk        => link_clk1x,
      delay_in        => sync_master_delay,
      delay_enable_in => sync_master_delay_enable,
      bit_in          => sync_slave_ch0(6),
      bit_out         => sync_master);

  sync_master_delay_enable <= rw_reg(2)(0); 
  sync_master_delay <= rw_reg(2)(5 DOWNTO 1); 

  --------------------------------------------------------------------------
  -- SELECT input data
  --------------------------------------------------------------------------


  tx_select <= '0';
  ttc_time <= counter_word;
  -- Be careful.   rw-reg clked from fabric....
  -- NOT sure this is wise....
  ttc_cntrl <= rw_reg(3)(1 DOWNTO 0);

  control_interface_inst: control_interface 
    GENERIC MAP(
      module                    => module_control,
      local_lhc_bunch_count     => local_lhc_bunch_count)
    PORT MAP(
      fabric_clk1x_in           => fabric_clk1x_in,
      fabric_reset_in           => fabric_reset_in,
      link_clk1x_in             => link_clk1x,
      link_reset_in             => link_reset,
      comm_cntrl                => comm_cntrl(7),
      comm_reply                => comm_reply(7),
      ttc_time_in               => ttc_time,
      trig_out                  => trig);


  --- Rip OUT part OF the comm BUS WITH add space = 16 x 0x2000
  -- (i.e. up TO 32 channels)
  sub_modules_gtx: sub_modules
  GENERIC MAP(
    module                  => module_gtx,
    module_add_width_req    => x"00040000",
    comm_units              => gtx_units)
  PORT MAP(
    rst_in                  => fabric_reset_in, 
    clk_in                  => fabric_clk1x_in,
    comm_cntrl_in           => comm_cntrl(4),
    comm_reply_out          => comm_reply(4),
    comm_bus_cntrl_out      => comm_gtx_cntrl,
    comm_bus_reply_in       => comm_gtx_reply);

  -- SELECT which gtx unit TO communicate WITH
  comm_gtx_port <= to_integer(unsigned(comm_gtx_cntrl(0).add(17 DOWNTO 14)));

  gtx_i: FOR i IN gtx_min TO gtx_max GENERATE
  BEGIN

    -- Which comm PORT are we communicating WITH.
    comm_gtx_enable(i) <= '1' WHEN comm_gtx_port = i ELSE '0';

    -- SELECT whether TO USE external OR internal data FOR tx.
    tx_data_ch0(i) <= counter_data WHEN tx_select = '0' ELSE trig_data_ch0(i);
    tx_data_ch1(i) <= counter_data WHEN tx_select = '0' ELSE trig_data_ch1(i);
    tx_data_valid_ch0(i) <= counter_data_valid WHEN tx_select = '0' ELSE trig_data_valid_ch0(i);
    tx_data_valid_ch1(i) <= counter_data_valid WHEN tx_select = '0' ELSE trig_data_valid_ch1(i);

    minit_gtx_comm_inst : minit_gtx_comm_interface_basic
    GENERIC MAP(
      local_lhc_bunch_count  => local_lhc_bunch_count,    
      sim_mode               => sim_mode,
      sim_gtx_reset_speedup  => sim_gtx_reset_speedup,
      sim_pll_perdiv2        => sim_pll_perdiv2)
    PORT MAP(
      fabric_clk1x_in           => fabric_clk1x_in,
      fabric_reset_in           => fabric_reset_in,
      link_clk1x_in             => link_clk1x, 
      link_clk2x_in             => link_clk2x, 
      link_reset_in             => link_reset, 
      txoutclk_out              => txoutclk(i),
      plllkdet_out              => plllkdet(i),
      comm_enable               => comm_gtx_enable(i),
      comm_cntrl                => comm_gtx_cntrl(i),
      comm_reply                => comm_gtx_reply(i),
      sync_master_in            => sync_master,
      sync_slave_ch0_out        => sync_slave_ch0(i),
      sync_slave_ch1_out        => sync_slave_ch1(i),
      ttc_cntrl_in              => ttc_cntrl,
      ttc_time_in               => ttc_time,
      rx_data_ch0_out           => rx_data_ch0(i),
      rx_data_ch1_out           => rx_data_ch1(i),
      rx_data_valid_ch0_out     => rx_data_valid_ch0(i),
      rx_data_valid_ch1_out     => rx_data_valid_ch1(i),
      rxn_ch0_in                => rxn_ch0_in(i),
      rxn_ch1_in                => rxn_ch1_in(i),
      rxp_ch0_in                => rxp_ch0_in(i),
      rxp_ch1_in                => rxp_ch1_in(i),
      refclkp_in                => refclkp_in(i),
      refclkn_in                => refclkn_in(i),
      refclk_out                => refclk(i),
      tx_data_ch0_in            => tx_data_ch0(i),
      tx_data_ch1_in            => tx_data_ch1(i),
      tx_data_valid_ch0_in      => tx_data_valid_ch0(i),
      tx_data_valid_ch1_in      => tx_data_valid_ch1(i),
      txn_ch0_out               => txn_ch0_out(i),
      txn_ch1_out               => txn_ch1_out(i),
      txp_ch0_out               => txp_ch0_out(i),
      txp_ch1_out               => txp_ch1_out(i));

  END GENERATE;


  --------------------------------------------------------------------------
  -- Data processing
  --------------------------------------------------------------------------

  algo_select: module_select
    GENERIC MAP(
      module                => module_algo,
      module_add_width_req  => x"00020000")
    PORT MAP(
      rst_in                => fabric_reset_in,
      clk_in                => fabric_clk1x_in,
      comm_cntrl_in         => comm_cntrl(8),
      comm_reply_out        => comm_reply(8),
      comm_cntrl_out        => algo_cntrl,
      comm_reply_in         => algo_reply);
  
  -- Enables TO acess different LUTs
  epimlut_enable <= '1' WHEN ((algo_cntrl.wen AND algo_cntrl.stb) = '1') AND (algo_cntrl.add(12 DOWNTO 11) = "00") ELSE '0';
  ecallut_enable <= '1' WHEN ((algo_cntrl.wen AND algo_cntrl.stb) = '1') AND (algo_cntrl.add(12 DOWNTO 11) = "01") ELSE '0';
  hcallut_enable <= '1' WHEN ((algo_cntrl.wen AND algo_cntrl.stb) = '1') AND (algo_cntrl.add(12 DOWNTO 11) = "10") ELSE '0';

  -- No ack OR read possibility from LUTs.  Might be nice TO have read ACCESS FOR verfication.
  algo_reply.ack <= algo_cntrl.stb;
  algo_reply.err <= '0';
  algo_reply.rdata <= x"00000000";

  --------------------------------------------------------------------------
  -- MAP links onto rx data FOR algo
  --------------------------------------------------------------------------

  -- MAP links onto algo BLOCK 
  -- USE GTX transcsivers 0-5 TO Tx data AND 6-11 TO Rx data.
  rx_data_array(0).data <= rx_data_ch0(6);
  rx_data_array(1).data <= rx_data_ch1(6); 
  rx_data_array(2).data <= rx_data_ch0(7); 
  rx_data_array(3).data <= rx_data_ch1(7); 
  rx_data_array(4).data <= rx_data_ch0(8); 
  rx_data_array(5).data <= rx_data_ch1(8); 
  rx_data_array(6).data <= rx_data_ch0(9); 
  rx_data_array(7).data <= rx_data_ch1(9); 
  rx_data_array(8).data <= rx_data_ch0(10); 
  rx_data_array(9).data <= rx_data_ch1(10); 
  rx_data_array(10).data <= rx_data_ch0(11); 
  rx_data_array(11).data <= rx_data_ch1(11);  

  rx_valid <= rx_data_valid_ch0(algo_gtxd_master);

  --------------------------------------------------------------------------
  -- Obtain PacketId
  --------------------------------------------------------------------------

  -- Ought TO have error checking TO ensure ALL packets have same id.
  proc_get_packet_id: PROCESS(link_clk1x, link_reset)
  BEGIN
    IF link_reset = '1' THEN
      rx_valid_d1 <= '0';
      rx_id_d1 <= x"000";
      reg_rx_data: FOR i IN 0 TO cNumberOfLinks-1 LOOP
        rx_data_array_d1(i).data <=  x"00000000";
      END LOOP;
    ELSIF (link_clk1x = '1') AND link_clk1x'event THEN
      -- Extract the bunch id from beginning OF the packet.
      IF (rx_valid_d1 = '0') AND (rx_valid = '1') THEN
        -- Start OF NEW packet.  Store the Packet Ident
        rx_id_d1 <= rx_data_ch0(algo_gtxd_master)(11 DOWNTO 0);
      ELSIF (rx_valid_d1 = '1') AND (rx_valid = '0') THEN
        rx_id_d1 <= (OTHERS => '0');
      END IF;
      -- Clk incoming data so that is presented TO daq pipelines at the same time as rx_id.
      rx_data_array_d1 <= rx_data_array;
      rx_valid_d1 <= rx_valid;
      -- Only enable ago AFTER packet header has passed by.
      algo_enable <= rx_valid AND rx_valid_d1;
    END IF;
  END PROCESS;

  pass_data_into_format_for_daq: FOR i IN 0 TO cNumberOfLinks-1 GENERATE
    rx_data_d1(32*i+31 DOWNTO 32*i) <= rx_data_array_d1(i).data;
  END GENERATE;

  --------------------------------------------------------------------------
  -- Obtain PacketId
  --------------------------------------------------------------------------

  algo_inst: AlgorithmTop
  PORT MAP(
    --TEMPORARY FOR TESTBENCH AND TO MAKE SYNTHESIS INCLUDE EVERYTHING  
    -- pragma translate_off
    OutLinearTowers          => open,
    OutZeroedTowers          => open,
    OutEHSum                 => open,
    OutPipe2x1SumA           => open,
    OutPipe2x1SumB           => open,
    OutPipe2x1ETSumA         => open,
    OutPipe2x1ETSumB         => open,
    OutPipe1x2ETSumA         => open,
    OutPipe1x2ETSumB         => open,
    OutPipe2x2SumA           => open,
    OutPipe2x2SumB           => open,
    OutPipe2x2ETSumA         => open,
    OutPipe2x2ETSumB         => open,
    OutPipeEPIMA             => open,
    OutPipeEPIMB             => open,
    OutPipeFilterMaskA       => open,
    OutPipeFilterMaskB       => open,
    OutPipeClusterPositionA  => open,
    OutPipeClusterPositionB  => open,
    OutPipeFilteredClusterA  => open,
    OutPipeFilteredClusterB  => open,
    -- pragma translate_on
    OutClusterSorting        => result_data,
    -- -- OutSortedCluster   : OUT aSortedCluster( (2**cBitonicWidth)-1 DOWNTO 0 );
    OutPipeSortedCluster     => open,
    -- OutPipeClusterFlag    : OUT aClusterFlag;
    -- OutPipeJF1D           : OUT aJet1D;
    epimlut_address          => algo_cntrl.add(10 DOWNTO 1),
    epimlut_data             => algo_cntrl.wdata(15 DOWNTO 0),
    epimlut_cl0ck            => fabric_clk1x_in,
    epimlut_enable           => epimlut_enable,
    ecallut_address          => algo_cntrl.add(10 DOWNTO 1),
    ecallut_data             => algo_cntrl.wdata(15 DOWNTO 0),
    ecallut_cl0ck            => fabric_clk1x_in,
    ecallut_enable           => ecallut_enable,
    hcallut_address          => algo_cntrl.add(10 DOWNTO 1),
    hcallut_data             => algo_cntrl.wdata(15 DOWNTO 0),
    hcallut_cl0ck            => fabric_clk1x_in,
    hcallut_enable           => hcallut_enable,
    -- jfradiuslut_address:    IN  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
    -- jfradiuslut_data:      IN  STD_LOGIC_VECTOR( 15 DOWNTO 0 );
    -- jfradiuslut_cl0ck:      IN  std_logic;
    -- jfradiuslut_enable:      IN  std_logic;
    clk_160                  => link_clk1x,
    sync_reset_b             => algo_enable,
    --links_in  : IN aLinearTowers
    links_in                 => rx_data_array_d1);


  -- Simulate some data processing
  -- Simply OR ALL channels together

  -- result_data <= rx_data_ch0(0) OR (x"0000E" & rx_data_ch0(0)(11 DOWNTO 0));
  -- result_valid <=rx_data_valid_ch0(0);

  conv_result_data_to_array_std_logic_vector : FOR i IN 0 TO 2*cNumberOfLinks-1 GENERATE
    result_array(i)(0) <= result_data(i).info.maxima;                   -- STD_LOGIC;
    result_array(i)(13 DOWNTO 1) <= result_data(i).info.cluster;        -- STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );  cLinearizedWidth= 10
    result_array(i)(14 DOWNTO 14) <= result_data(i).info.count;                   -- STD_LOGIC_VECTOR( 0 DOWNTO 0 );
    result_array(i)(16 DOWNTO 15) <= result_data(i).fineposition.h;     -- STD_LOGIC_VECTOR( 1 DOWNTO 0 );
    result_array(i)(18 DOWNTO 17) <= result_data(i).fineposition.v;     -- STD_LOGIC_VECTOR( 1 DOWNTO 0 );
    result_array(i)(24 DOWNTO 19) <= result_data(i).coarseposition;     -- STD_LOGIC_VECTOR( 5 DOWNTO 0 ) ;
    result_array(i)(25 DOWNTO 25) <= result_data(i).epims;                        -- STD_LOGIC_VECTOR( 0 DOWNTO 0 )
    result_array(i)(31 DOWNTO 26) <= "000000";
  END GENERATE;

  conv_result_array_to_result_vec: FOR i IN 0 TO 2*cNumberOfLinks-1 GENERATE
    result_vec(32*i+31 DOWNTO 32*i) <= result_array(i);            -- STD_LOGIC;
  END GENERATE;

  -- Need Pipeline, but this will have TO do FOR the moment.
  --result_id <= rx_id_d1;
  --result_valid <= rx_valid_d1;

  sync_bufd_ch0: delay_word
  GENERIC MAP (
      width => 12)
  PORT MAP (
      reset_b	       => link_reset,
      clk	       => link_clk1x,
      delay_in         => result_delay,
      delay_enable_in  => '1',
      word_in          => rx_id_d1,
      word_out         => result_id);

  sync_bufdv_ch0: delay_bit
  PORT MAP (
      reset_b	       => link_reset,
      clk	       => link_clk1x,
      delay_in         => result_delay,
      delay_enable_in  => '1',
      bit_in           => algo_enable, --rx_valid_d1,
      bit_out          => result_valid);

  --------------------------------------------------------------------------
  -- DAQ Capture
  --------------------------------------------------------------------------

  daq_chain(0) <= NOT daq_empty(0);

  daqbuf_input: daq_buffer
    GENERIC MAP(
      daq_width             => (1*cNumberOfLinks),
      buf_ident             => x"0")
    PORT MAP(
      clk                   => link_clk1x,
      rst                   => link_reset,
      trig_in               => trig,
      packet_data_in        => rx_data_d1,
      packet_id_in          => rx_id_d1,
      packet_valid_in       => rx_valid_d1,
      daq_start_in          => daq_chain(0),
      daq_stop_out          => daq_chain(1),
      daq_data_out          => daq_data(0),
      daq_id_out            => open,
      daq_valid_out         => daq_valid(0),
      daq_empty_out         => daq_empty(0));




  daqbuf_result: daq_buffer
    GENERIC MAP(
      daq_width             => (2*cNumberOfLinks),
      buf_ident             => x"1")
    PORT MAP(
      clk                   => link_clk1x,
      rst                   => link_reset,
      trig_in               => trig,
      packet_data_in        => result_vec,
      packet_id_in          => result_id,
      packet_valid_in       => result_valid,
      daq_start_in          => daq_chain(1),
      daq_stop_out          => daq_chain(2),
      daq_data_out          => daq_data(1),
      daq_id_out            => open,
      daq_valid_out         => daq_valid(1),
      daq_empty_out         => daq_empty(1));

  --------------------------------------------------------------------------
  -- Merge data streams
  -------------------------------------------------------------------------

  daqmerge_proc: PROCESS(link_clk1x, link_reset)
    VARIABLE daqmerge_valid_var: std_logic;
    VARIABLE daqmerge_data_var: std_logic_vector(31 DOWNTO 0);
  BEGIN
    IF link_reset = '1' THEN
      daqmerge_data <= (OTHERS => '0');
      daqmerge_valid <= '0';
    ELSIF (link_clk1x = '1') AND link_clk1x'event THEN
      daqmerge_data_var := (OTHERS => '0');
      daqmerge_valid_var := '0';
      daq_merge: FOR i IN 0 TO daq_units-1 LOOP
        daqmerge_data_var := daqmerge_data_var OR daq_data(i);
        daqmerge_valid_var := daqmerge_valid_var OR daq_valid(i);
      END LOOP;
      daqmerge_data <= daqmerge_data_var;
      daqmerge_valid <= daqmerge_valid_var;
    END IF;
  END PROCESS;

  --------------------------------------------------------------------------
  -- DAQ BUFFER
  -------------------------------------------------------------------------

  daq_output_inst: daq_output
    GENERIC MAP(
        module => module_daq)
    PORT MAP( 
      fabric_clk1x_in           => fabric_clk1x_in,
      fabric_reset_in           => fabric_reset_in,
      link_clk1x_in             => link_clk1x, 
      link_reset_in             => link_reset, 
      comm_cntrl_in             => comm_cntrl(6),
      comm_reply_out            => comm_reply(6),
      daq_data_in               => daqmerge_data,
      daq_valid_in              => daqmerge_valid,
      daq_start_in              => daq_chain(0),
      daq_stop_in               => daq_chain(daq_units),
      overflow_out              => open,
      backpressure_out          => OPEN);

  debug_out(0) <= '0'; -- refclk(gtx_clk);
  debug_out(1) <= '0'; -- plllkdet(gtx_clk);
  debug_out(5 DOWNTO 2) <= (OTHERS => '0');
  debug_out(6) <= '0'; --link_reset;
  debug_out(7) <= '0';


END behave;