
-- ToDo:: 
-- Remove subtract from within module_select
-- MasterSyncChan - programmable

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.package_types.all;
use work.package_comm.all;
use work.package_modules.all;
use work.package_reg.all;
use work.package_utilities.all;
use work.package_i2c.all;
use work.package_daq.all;
use work.package_control.all;

library TMCaloTrigger_lib;
use TMCaloTrigger_lib.linkinterface.all;
use TMCaloTrigger_lib.types.all;
use TMCaloTrigger_lib.constants.all;

entity core_sys_algo_r1 is
  generic(
    firmware         : std_logic_vector(31 downto 0);
    slave            : std_logic_vector(31 downto 0);
    i2c_clk_speed    : natural := 100000;
    gtx_min          : natural := 0;
    gtx_max          : natural := 0;
    gtx_clk          : natural := 0;
    local_lhc_bunch_count     : integer := lhc_bunch_count;   -- Use 200 for sim else lhc_bunch_count
    sim_mode                  : string     := "FAST";         -- Set to Fast Functional Simulation Model
    sim_gtx_reset_speedup     : integer    := 0;              -- Set to 1 to speed up sim reset
    sim_pll_perdiv2           : bit_vector := x"0d0");        -- Set to the VCO Unit Interval time);
  port (
    fabric_reset_in        : in std_logic;
    fabric_clk1x_in        : in std_logic;
    link_reset_in          : in std_logic;
    link_clk1x_in          : in std_logic;
    -- Parallel bus
    pbus_addr_in     : in std_logic_vector(31 downto 0);
    pbus_wdata_in    : in std_logic_vector(31 downto 0);
    pbus_strobe_in   : in std_logic;
    pbus_write_in    : in std_logic;
    pbus_rdata_out   : out std_logic_vector(31 downto 0);
    pbus_ack_out     : out std_logic;
    pbus_berr_out    : out std_logic;
    -- Rx Serial
    rxn_ch0_in       : in   std_logic_vector(gtx_max downto gtx_min);
    rxn_ch1_in       : in   std_logic_vector(gtx_max downto gtx_min);
    rxp_ch0_in       : in   std_logic_vector(gtx_max downto gtx_min);
    rxp_ch1_in       : in   std_logic_vector(gtx_max downto gtx_min);
    -- Ref clock
    refclkp_in       : in   std_logic_vector(gtx_max downto gtx_min);
    refclkn_in       : in   std_logic_vector(gtx_max downto gtx_min);
    -- Tx Serial
    txn_ch0_out      : out  std_logic_vector(gtx_max downto gtx_min);
    txn_ch1_out      : out  std_logic_vector(gtx_max downto gtx_min);
    txp_ch0_out      : out  std_logic_vector(gtx_max downto gtx_min);
    txp_ch1_out      : out  std_logic_vector(gtx_max downto gtx_min);
    -- Clock synthesis control
    si5326_cntrl     : inout std_logic_vector(4 downto 0);
    ppod_tx0_cntrl : inout std_logic_vector(6 downto 0);
    ppod_rx0_cntrl : inout std_logic_vector(6 downto 0);
    ppod_rx2_cntrl : inout std_logic_vector(6 downto 0);
    debug_out        : out std_logic_vector(7 downto 0); 
    test_out         : out std_logic_vector(31 downto 0));
end core_sys_algo_r1;

architecture behave of core_sys_algo_r1 is

  component sys_info is
    generic(
      module:            type_mod_define;
      sys_id:            std_logic_vector(31 downto 0) := x"00000000";
      board_id:          std_logic_vector(31 downto 0) := x"00000000";
      slave_id:          std_logic_vector(31 downto 0) := x"00000000";
      firmware_id:       std_logic_vector(31 downto 0) := x"00000000");
    port(
      clk:               in std_logic;
      rst:               in std_logic;
      comm_cntrl:        in type_comm_cntrl;
      comm_reply:        out type_comm_reply;
      test_out:          out std_logic_vector(31 downto 0));
  end component;

  component minit_gtx_comm_interface_basic is
    generic(
      local_lhc_bunch_count:             integer := lhc_bunch_count;         -- Use 200 for sim else lhc_bunch_count
      sim_mode:                          string := "fast";                   -- Set to Fast Functional Simulation Model
      sim_gtx_reset_speedup:             integer:= 0;                        -- Set to 1 to speed up sim reset
      sim_pll_perdiv2:                   bit_vector:= x"0d0");                -- Set to the VCO Unit Interval time     
    port(
      -- Fabric clk/fabric_reset_in
      fabric_clk1x_in              : in std_logic;
      fabric_reset_in              : in std_logic;  
      -- Link clk/fabric_reset_in
      link_clk1x_in                : in std_logic;
      link_clk2x_in                : in std_logic;
      link_reset_in                : in std_logic;
      -- GTP PLL clks
      txoutclk_out                 : out std_logic;
      plllkdet_out                 : out std_logic;
      -- Comm interface
      comm_enable                  : in std_logic;
      comm_cntrl                   : in type_comm_cntrl;
      comm_reply                   : out type_comm_reply;
      -- Sync channels together 
      sync_master_in               : in std_logic;
      sync_slave_ch0_out           : out std_logic;
      sync_slave_ch1_out           : out std_logic;
      -- Pattern Inject/Capture control
      ttc_cntrl_in                 : in std_logic_vector(1 downto 0);
      ttc_time_in                   : in std_logic_vector(8 downto 0);
      -- Rx parallel data out
      rx_data_ch0_out              : out std_logic_vector(31 downto 0);
      rx_data_ch1_out              : out std_logic_vector(31 downto 0);
      rx_data_valid_ch0_out        : out  std_logic;
      rx_data_valid_ch1_out        : out  std_logic;   
      -- Rx serdes in
      rxn_ch0_in                   : in std_logic;
      rxn_ch1_in                   : in std_logic;
      rxp_ch0_in                   : in std_logic;
      rxp_ch1_in                   : in std_logic;
      -- Ref clock
      refclkp_in                   : in std_logic;
      refclkn_in                   : in std_logic;
      refclk_out                   : out std_logic;
      -- Tx parallel data in
      tx_data_ch0_in               : in std_logic_vector(31 downto 0);
      tx_data_ch1_in               : in std_logic_vector(31 downto 0);
      tx_data_valid_ch0_in         : in std_logic;
      tx_data_valid_ch1_in         : in std_logic;
      -- Tx serdes data out
      txn_ch0_out                  : out std_logic;
      txn_ch1_out                  : out std_logic;
      txp_ch0_out                  : out std_logic;
      txp_ch1_out                  : out std_logic);
  end component;

  component minit_gtx_txusrclk is
  generic (    
      performance_mode    : string   := "MAX_SPEED";
      clkfx_divide        : integer := 5;
      clkfx_multiply      : integer := 4;
      dfs_frequency_mode  : string := "LOW";
      dll_frequency_mode  : string := "LOW");
  port (
      clk_in                    : in  std_logic;
      dcm_reset_in              : in  std_logic;
      clk_d2_out                : out std_logic;
      clk_x1_out                : out std_logic;
      clk_x2_out                : out std_logic;
      clk_fx_out                : out std_logic;
      dcm_locked_out            : out std_logic);
  end component;

  component minit_dcm_reset is
  port (
      clk_in                    : in  std_logic;
      reset_in                  : in  std_logic;
      dcm_lock_in               : in std_logic;
      dcm_reset_out             : out std_logic);
  end component;

  component AlgorithmTop IS
  port(
    --TEMPORARY FOR TESTBENCH AND TO MAKE SYNTHESIS INCLUDE EVERYTHING  
    -- pragma translate_off
    OutLinearTowers        : out aLinearTowers;
    OutZeroedTowers         : out aLinearTowers;
    OutEHSum          : out aEHSums;
    OutPipe2x1SumA        : out a2x1Sums;
    OutPipe2x1SumB        : out a2x1Sums;
    OutPipe2x1ETSumA      : out a2x1ETSums;
    OutPipe2x1ETSumB      : out a2x1ETSums;
    OutPipe1x2ETSumA      : out a2x1ETSums;
    OutPipe1x2ETSumB      : out a2x1ETSums;
    OutPipe2x2SumA        : out a2x2Sums;
    OutPipe2x2SumB        : out a2x2Sums;
    OutPipe2x2ETSumA      : out a2x2ETSums;
    OutPipe2x2ETSumB      : out a2x2ETSums;
    OutPipeEPIMA        : out aEPIMs;
    OutPipeEPIMB        : out aEPIMs;
    OutPipeFilterMaskA      : out aFilterMask;
    OutPipeFilterMaskB      : out aFilterMask;
    OutPipeClusterPositionA    : out aClusterPosition;
    OutPipeClusterPositionB    : out aClusterPosition;
    OutPipeFilteredClusterA    : out aFilteredCluster;
    OutPipeFilteredClusterB    : out aFilteredCluster;
    -- pragma translate_on
    OutClusterSorting      : out aSortedCluster( (2*cNumberOfLinks)-1 downto 0 );
    -- -- OutSortedCluster      : out aSortedCluster( (2**cBitonicWidth)-1 downto 0 );
    OutPipeSortedCluster    : out aSortedCluster( cClustersPerPhi-1 DOWNTO 0 );
    -- OutPipeClusterFlag       : out aClusterFlag;
    -- OutPipeJF1D         : out aJet1D;
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
    clk_160    : in STD_LOGIC;
    sync_reset_b  : in STD_LOGIC := '0';
    --links_in  : in aLinearTowers
    links_in  : in all_links((cNumberOfLinks-1) DOWNTO 0));
  end component;

  signal fabric_reset_b: std_logic;

  -- Internal communication bus
  constant comm_units:                   natural := 9;
  signal comm_cntrl:                     type_comm_bus_cntrl(comm_units-1 downto 0);
  signal comm_reply:                     type_comm_bus_reply(comm_units-1 downto 0);

  -- Branch from Comm Bus to load algo LUTs.  
  -- No readback.  Would be good for verification.
  signal algo_cntrl:                     type_comm_cntrl;
  signal algo_reply:                     type_comm_reply;
  signal epimlut_enable, ecallut_enable, hcallut_enable: std_logic;

  -- Tx Data
  signal tx_data_ch0                  : type_vector_of_stdlogicvec_x32(gtx_max downto gtx_min);
  signal tx_data_ch1                  : type_vector_of_stdlogicvec_x32(gtx_max downto gtx_min);
  signal tx_data_valid_ch0            : std_logic_vector(gtx_max downto gtx_min);
  signal tx_data_valid_ch1            : std_logic_vector(gtx_max downto gtx_min);
  signal tx_select                    : std_logic;
  -- Rx Data
  signal rx_data_ch0                  : type_vector_of_stdlogicvec_x32(gtx_max downto gtx_min);
  signal rx_data_ch1                  : type_vector_of_stdlogicvec_x32(gtx_max downto gtx_min);
  signal rx_data_valid_ch0            : std_logic_vector(gtx_max downto gtx_min);
  signal rx_data_valid_ch1            : std_logic_vector(gtx_max downto gtx_min);
  -- Txout clks from PLL in gtx0
  signal txoutclk                : std_logic_vector(gtx_max downto gtx_min) := (others => '0');
  signal plllkdet                : std_logic_vector(gtx_max downto gtx_min) := (others => '0');
  signal refclk                  : std_logic_vector(gtx_max downto gtx_min) := (others => '0');
  signal clksys_lock            : std_logic;
  signal link_clk_rst      : std_logic;
  -- Global link clks (used to drive txuser/rxuser clks) for all GTPs using gtx0 refclks 
  signal link_clk1x              : std_logic;
  signal link_clk2x              : std_logic;
  signal link_clk_lock           : std_logic;
  signal link_reset              : std_logic;
  signal link_reset_b            : std_logic;
  -- Test pattern generation
  signal counter                      : natural range 0 to 511;
  signal counter_word : std_logic_vector(8 downto 0);
  signal counter_data                 : std_logic_vector(31 downto 0);
  signal counter_data_valid           : std_logic;
  -- Incoming data from ConcElec/ConcJet
  signal trig_data_ch0               : type_vector_of_stdlogicvec_x32(gtx_max downto gtx_min) := (others => x"00000000");
  signal trig_data_ch1               : type_vector_of_stdlogicvec_x32(gtx_max downto gtx_min) := (others => x"00000000");
  signal trig_data_valid_ch0         : std_logic_vector(gtx_max downto gtx_min) := (others => '0');
  signal trig_data_valid_ch1         : std_logic_vector(gtx_max downto gtx_min) := (others => '0');
  
  constant gtx_units: natural range 0 to 31:= gtx_max-gtx_min+1;
  signal comm_gtx_cntrl: type_comm_bus_cntrl(gtx_units-1 downto 0);
  signal comm_gtx_reply: type_comm_bus_reply(gtx_units-1 downto 0);
  signal comm_gtx_port: integer range 0 to 31;
  signal comm_gtx_enable: std_logic_vector(gtx_max downto gtx_min);
  signal comm_gtx_add: std_logic_vector(31 downto 0);

  

  signal rw_reg, ro_reg: type_vector_of_stdlogicvec_x32(15 downto 0);

  signal sync_master: std_logic;
  signal sync_master_delay: std_logic_vector(4 downto 0);
  signal sync_master_delay_enable: std_logic;
  signal sync_slave_ch0: std_logic_vector(gtx_max downto gtx_min);
  signal sync_slave_ch1: std_logic_vector(gtx_max downto gtx_min);

  signal ttc_time: std_logic_vector(8 downto 0);
  signal ttc_cntrl: std_logic_vector(1 downto 0);

  -- Input to algo
  signal rx_data_array, rx_data_array_d1: all_links(cNumberOfLinks-1 downto 0);
  signal rx_valid, rx_valid_d1: std_logic;
  -- Convert data into format for DAQ (i.e. very large std_logic_vector) 
  signal rx_data_d1: std_logic_vector(32*cNumberOfLinks-1 downto 0);
  signal rx_id_d1: std_logic_vector(11 downto 0);

  -- Output from algo
  signal result_data: aSortedCluster( (2*cNumberOfLinks)-1 downto 0 );
  signal result_array: type_vector_of_stdlogicvec_x32( (2*cNumberOfLinks)-1 downto 0 );
  signal result_vec: std_logic_vector(32*2*cNumberOfLinks-1 downto 0);
  signal result_id: std_logic_vector(11 downto 0);
  signal result_valid: std_logic;
  -- Delay units always have 1 clk delay...  Hence for 10 clks program 9...
  constant result_delay: std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(8,5));

  -- Algo data valid.  Set to '0' between events to reset algo.
  signal algo_enable : std_logic;

  -- Used for master "packet_valid" and "packet_id"
  constant algo_gtxd_master: natural range 0 to 31 := 6;

  signal trig: std_logic;

  constant daq_units: natural := 2;

  signal daq_chain: std_logic_vector(daq_units downto 0);
  signal daq_valid, daq_empty: std_logic_vector(daq_units-1 downto 0);
  signal daq_data: type_vector_of_stdlogicvec_x32(daq_units-1 downto 0);

  signal daqmerge_valid: std_logic;
  signal daqmerge_data: std_logic_vector(31 downto 0);

begin

  fabric_reset_b <= not fabric_reset_in;
  link_reset_b <= not link_reset;

  -- Hub for communication to all the "comm" slave untits.
  comm_std_hub_inst: comm_std_hub
  generic map(
    comm_units              => comm_units)
  port map(
    rst_in                    => fabric_reset_in,
    clk_in                    => fabric_clk1x_in,
    comm_bus_cntrl_out        => comm_cntrl,
    comm_bus_reply_in         => comm_reply,
    stb_in                    => pbus_strobe_in,
    wen_in                    => pbus_write_in,
    add_in                    => pbus_addr_in,
    wdata_in                  => pbus_wdata_in,
    ack_out                   => pbus_ack_out,
    err_out                   => pbus_berr_out,
    rdata_out                 => pbus_rdata_out);

  -- SlaveId, FirmwareVersion, etc..
  sys_info_inst: sys_info
  generic map(
    module                  => module_sys_info,
    firmware_id             => firmware)
  port map(
    rst                     => fabric_reset_in,
    clk                     => fabric_clk1x_in,
    comm_cntrl              => comm_cntrl(0),
    comm_reply              => comm_reply(0),
    test_out                => test_out);

  ---------------------------------------------------------------
  ---------------------------------------------------------------

  -- Array of regs for generic write capability
  reg_array_out_inst: reg_array_out
  generic map(
    module              => module_reg_array_out,
    number_of_words     => 16)
  port map( 
    rstb_in             => fabric_reset_b,
    clk_in              => fabric_clk1x_in,
    comm_cntrl          => comm_cntrl(1),
    comm_reply          => comm_reply(1),
    data_array_out      => rw_reg);

  -- Array of regs for generic read capability
  reg_array_in_inst: reg_array_in
  generic map(
    module              => module_reg_array_in,
    number_of_words     => 16)
  port map( 
    rstb_in             => fabric_reset_b,
    clk_in              => fabric_clk1x_in,
    comm_cntrl          => comm_cntrl(2),
    comm_reply          => comm_reply(2),
    data_array_in       => ro_reg);

  ---------------------------------------------------------------
  ---------------------------------------------------------------

  -- Note that control bus labelled si5325 rather than si5326
  si5326_cntrl(0) <= rw_reg(0)(0);  -- rst_b
  ro_reg(0)(0) <= si5326_cntrl(1);  -- int_c1b
  ro_reg(0)(1) <= si5326_cntrl(2);  -- lol

  si5326_i2c: i2c_master_top
  generic map(
    module                        => module_si5326_i2c,
    base_board_clk                => 125000000,
    i2c_clk_speed                 => i2c_clk_speed)
  port map( 
    reset_b                       => fabric_reset_b,
    clk                           => fabric_clk1x_in,
    comm_cntrl                    => comm_cntrl(3),
    comm_reply                    => comm_reply(3),
    scl                           => si5326_cntrl(3),
    sda                           => si5326_cntrl(4));

  ---------------------------------------------------------------
  ---------------------------------------------------------------

  ppod_tx0_cntrl(2 downto 0) <= "000";  -- addr(2:0)
  ppod_tx0_cntrl(3) <= rw_reg(1)(0);   -- reset_b

  ro_reg(1)(0) <= ppod_tx0_cntrl(6);  -- int

  ppod_rx0_cntrl(2 downto 0) <= "000";  -- addr(2:0)
  ppod_rx0_cntrl(3) <= rw_reg(1)(8);   -- reset_b
  ppod_rx0_cntrl(4) <= 'Z';
  ppod_rx0_cntrl(5) <= 'Z';

  ro_reg(1)(8) <= ppod_rx0_cntrl(6);  -- int

  ppod_rx2_cntrl(2 downto 0) <= "000";  -- addr(2:0)
  ppod_rx2_cntrl(3) <= rw_reg(1)(16);   -- reset_b
  ppod_rx2_cntrl(4) <= 'Z';
  ppod_rx2_cntrl(5) <= 'Z';

  ro_reg(1)(16) <= ppod_rx2_cntrl(6);  -- int


  ppod_tx0_i2c: i2c_master_top
  generic map(
    module                        => module_snap12_tx0_i2c,
    base_board_clk                => 125000000,
    i2c_clk_speed                 => i2c_clk_speed)
  port map( 
    reset_b                       => fabric_reset_b,
    clk                           => fabric_clk1x_in,
    comm_cntrl                    => comm_cntrl(5),
    comm_reply                    => comm_reply(5),
    scl                           => ppod_tx0_cntrl(4),
    sda                           => ppod_tx0_cntrl(5));

  ---------------------------------------------------------------
  ---------------------------------------------------------------

  counter_proc: process(link_reset, link_clk1x)
  begin
    if link_reset = '1' then
      counter <= 0;
    elsif link_clk1x'event and link_clk1x='1' then
      if counter < 511 then
        counter <= counter+1;
      else
        counter <= 0;
      end if;
    end if;
  end process;

  counter_word <= std_logic_vector(to_unsigned(counter, 9));

  counter_data_proc: process(link_reset, link_clk1x)
  begin
    if link_reset = '1' then
        counter_data_valid <= '0';
        counter_data <= x"00000000";
    elsif rising_edge(link_clk1x) then
      -- Reg data valid
      -- Max length of event is 64 words
      -- Set by requiremnet that must have >= 8 in the DAQ buffer and  
      -- transceiver pattern RAM is 512 deep. 
      if (counter rem 64) < 30 then
        counter_data <= x"ABCD" & "0000000" & counter_word;
        counter_data_valid <= '1';
      else
        counter_data <= x"00000000";
        counter_data_valid <= '0';
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- Generate TxUser and RxUser Clks (external)
  --------------------------------------------------------------------------

    dcm : minit_gtx_txusrclk
    generic map(
      performance_mode              => "MAX_SPEED",
      clkfx_divide                  => 5,
      clkfx_multiply                => 4,
      dfs_frequency_mode            => "LOW",
      dll_frequency_mode            => "LOW")
    port map(
      clk_in                          =>      link_clk1x_in,
      dcm_reset_in                    =>      link_clk_rst,
      clk_d2_out                      =>      open,          -- Unused
      clk_x1_out                      =>      link_clk1x,    -- 125MHz
      clk_x2_out                      =>      link_clk2x,    -- 250MHz
      clk_fx_out                      =>      open, -- link_clkfx,    -- 100Mhz
      dcm_locked_out                  =>      link_clk_lock);

    dcm_rst: minit_dcm_reset 
    port map (
      clk_in              => fabric_clk1x_in,
      reset_in            => fabric_reset_in,
      dcm_lock_in         => '1',
      dcm_reset_out       => link_clk_rst);

  --------------------------------------------------------------------------
  -- Reset
  --------------------------------------------------------------------------

  link_reset <= (not link_clk_lock) or link_clk_rst;

  --------------------------------------------------------------------------
  -- Delay master sync signal to allow all channels to align
  --------------------------------------------------------------------------

  sync_master_delay_inst: delay_bit
  port map (
      reset_b        => link_reset_b,
      clk        => link_clk1x,
      delay_in        => sync_master_delay,
      delay_enable_in => sync_master_delay_enable,
      bit_in          => sync_slave_ch0(6),
      bit_out         => sync_master);

  sync_master_delay_enable <= rw_reg(2)(0); 
  sync_master_delay <= rw_reg(2)(5 downto 1); 

  --------------------------------------------------------------------------
  -- Select input data
  --------------------------------------------------------------------------


  tx_select <= '0';
  ttc_time <= counter_word;
  -- Be careful.   rw-reg clked from fabric....
  -- Not sure this is wise....
  ttc_cntrl <= rw_reg(3)(1 downto 0);

  control_interface_inst: control_interface 
    generic map(
      module                    => module_control,
      local_lhc_bunch_count     => local_lhc_bunch_count)
    port map(
      fabric_clk1x_in           => fabric_clk1x_in,
      fabric_reset_in           => fabric_reset_in,
      link_clk1x_in             => link_clk1x,
      link_reset_in             => link_reset,
      comm_cntrl                => comm_cntrl(7),
      comm_reply                => comm_reply(7),
      ttc_time_in               => ttc_time,
      trig_out                  => trig);


  --- Rip out part of the comm bus with add space = 16 x 0x2000
  -- (i.e. up to 32 channels)
  sub_modules_gtx: sub_modules
  generic map(
    module                  => module_gtx,
    module_add_width_req    => x"00040000",
    comm_units              => gtx_units)
  port map(
    rst_in                  => fabric_reset_in, 
    clk_in                  => fabric_clk1x_in,
    comm_cntrl_in           => comm_cntrl(4),
    comm_reply_out          => comm_reply(4),
    comm_bus_cntrl_out      => comm_gtx_cntrl,
    comm_bus_reply_in       => comm_gtx_reply);

  -- Select which gtx unit to communicate with
  comm_gtx_port <= to_integer(unsigned(comm_gtx_cntrl(0).add(17 downto 14)));

  gtx_i: for i in gtx_min to gtx_max generate
  begin

    -- Which comm port are we communicating with.
    comm_gtx_enable(i) <= '1' when comm_gtx_port = i else '0';

    -- Select whether to use external or internal data for tx.
    tx_data_ch0(i) <= counter_data when tx_select = '0' else trig_data_ch0(i);
    tx_data_ch1(i) <= counter_data when tx_select = '0' else trig_data_ch1(i);
    tx_data_valid_ch0(i) <= counter_data_valid when tx_select = '0' else trig_data_valid_ch0(i);
    tx_data_valid_ch1(i) <= counter_data_valid when tx_select = '0' else trig_data_valid_ch1(i);

    minit_gtx_comm_inst : minit_gtx_comm_interface_basic
    generic map(
      local_lhc_bunch_count  => local_lhc_bunch_count,    
      sim_mode               => sim_mode,
      sim_gtx_reset_speedup  => sim_gtx_reset_speedup,
      sim_pll_perdiv2        => sim_pll_perdiv2)
    port map(
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

  end generate;


  --------------------------------------------------------------------------
  -- Data processing
  --------------------------------------------------------------------------

  algo_select: module_select
    generic map(
      module                => module_algo,
      module_add_width_req  => x"00020000")
    port map(
      rst_in                => fabric_reset_in,
      clk_in                => fabric_clk1x_in,
      comm_cntrl_in         => comm_cntrl(8),
      comm_reply_out        => comm_reply(8),
      comm_cntrl_out        => algo_cntrl,
      comm_reply_in         => algo_reply);
  
  -- Enables to acess different LUTs
  epimlut_enable <= '1' when ((algo_cntrl.wen and algo_cntrl.stb) = '1') and (algo_cntrl.add(12 downto 11) = "00") else '0';
  ecallut_enable <= '1' when ((algo_cntrl.wen and algo_cntrl.stb) = '1') and (algo_cntrl.add(12 downto 11) = "01") else '0';
  hcallut_enable <= '1' when ((algo_cntrl.wen and algo_cntrl.stb) = '1') and (algo_cntrl.add(12 downto 11) = "10") else '0';

  -- No ack or read possibility from LUTs.  Might be nice to have read access for verfication.
  algo_reply.ack <= algo_cntrl.stb;
  algo_reply.err <= '0';
  algo_reply.rdata <= x"00000000";

  --------------------------------------------------------------------------
  -- Map links onto rx data for algo
  --------------------------------------------------------------------------

  -- Map links onto algo block 
  -- Use GTX transcsivers 0-5 to Tx data and 6-11 to Rx data.
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

  -- Ought to have error checking to ensure all packets have same id.
  proc_get_packet_id: process(link_clk1x, link_reset)
  begin
    if link_reset = '1' then
      rx_valid_d1 <= '0';
      rx_id_d1 <= x"000";
      reg_rx_data: for i in 0 to cNumberOfLinks-1 loop
        rx_data_array_d1(i).data <=  x"00000000";
      end loop;
    elsif (link_clk1x = '1') and link_clk1x'event then
      -- Extract the bunch id from beginning of the packet.
      if (rx_valid_d1 = '0') and (rx_valid = '1') then
        -- Start of new packet.  Store the Packet Ident
        rx_id_d1 <= rx_data_ch0(algo_gtxd_master)(11 downto 0);
      elsif (rx_valid_d1 = '1') and (rx_valid = '0') then
        rx_id_d1 <= (others => '0');
      end if;
      -- Clk incoming data so that is presented to daq pipelines at the same time as rx_id.
      rx_data_array_d1 <= rx_data_array;
      rx_valid_d1 <= rx_valid;
      -- Only enable ago after packet header has passed by.
      algo_enable <= rx_valid and rx_valid_d1;
    end if;
  end process;

  pass_data_into_format_for_daq: for i in 0 to cNumberOfLinks-1 generate
    rx_data_d1(32*i+31 downto 32*i) <= rx_data_array_d1(i).data;
  end generate;

  --------------------------------------------------------------------------
  -- Obtain PacketId
  --------------------------------------------------------------------------

  algo_inst: AlgorithmTop
  port map(
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
    -- -- OutSortedCluster   : out aSortedCluster( (2**cBitonicWidth)-1 downto 0 );
    OutPipeSortedCluster     => open,
    -- OutPipeClusterFlag    : out aClusterFlag;
    -- OutPipeJF1D           : out aJet1D;
    epimlut_address          => algo_cntrl.add(10 downto 1),
    epimlut_data             => algo_cntrl.wdata(15 downto 0),
    epimlut_cl0ck            => fabric_clk1x_in,
    epimlut_enable           => epimlut_enable,
    ecallut_address          => algo_cntrl.add(10 downto 1),
    ecallut_data             => algo_cntrl.wdata(15 downto 0),
    ecallut_cl0ck            => fabric_clk1x_in,
    ecallut_enable           => ecallut_enable,
    hcallut_address          => algo_cntrl.add(10 downto 1),
    hcallut_data             => algo_cntrl.wdata(15 downto 0),
    hcallut_cl0ck            => fabric_clk1x_in,
    hcallut_enable           => hcallut_enable,
    -- jfradiuslut_address:    IN  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
    -- jfradiuslut_data:      IN  STD_LOGIC_VECTOR( 15 DOWNTO 0 );
    -- jfradiuslut_cl0ck:      IN  std_logic;
    -- jfradiuslut_enable:      IN  std_logic;
    clk_160                  => link_clk1x,
    sync_reset_b             => algo_enable,
    --links_in  : in aLinearTowers
    links_in                 => rx_data_array_d1);


  -- Simulate some data processing
  -- Simply OR all channels together

  -- result_data <= rx_data_ch0(0) or (x"0000E" & rx_data_ch0(0)(11 downto 0));
  -- result_valid <=rx_data_valid_ch0(0);

  conv_result_data_to_array_std_logic_vector : for i in 0 to 2*cNumberOfLinks-1 generate
    result_array(i)(0) <= result_data(i).info.maxima;                   -- STD_LOGIC;
    result_array(i)(13 downto 1) <= result_data(i).info.cluster;        -- STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );  cLinearizedWidth= 10
    result_array(i)(14 downto 14) <= result_data(i).info.count;                   -- STD_LOGIC_VECTOR( 0 DOWNTO 0 );
    result_array(i)(16 downto 15) <= result_data(i).fineposition.h;     -- STD_LOGIC_VECTOR( 1 DOWNTO 0 );
    result_array(i)(18 downto 17) <= result_data(i).fineposition.v;     -- STD_LOGIC_VECTOR( 1 DOWNTO 0 );
    result_array(i)(24 downto 19) <= result_data(i).coarseposition;     -- STD_LOGIC_VECTOR( 5 DOWNTO 0 ) ;
    result_array(i)(25 downto 25) <= result_data(i).epims;                        -- STD_LOGIC_VECTOR( 0 DOWNTO 0 )
    result_array(i)(31 downto 26) <= "000000";
  end generate;

  conv_result_array_to_result_vec: for i in 0 to 2*cNumberOfLinks-1 generate
    result_vec(32*i+31 downto 32*i) <= result_array(i);            -- STD_LOGIC;
  end generate;

  -- Need Pipeline, but this will have to do for the moment.
  --result_id <= rx_id_d1;
  --result_valid <= rx_valid_d1;

  sync_bufd_ch0: delay_word
  generic map (
      width => 12)
  port map (
      reset_b	       => link_reset,
      clk	       => link_clk1x,
      delay_in         => result_delay,
      delay_enable_in  => '1',
      word_in          => rx_id_d1,
      word_out         => result_id);

  sync_bufdv_ch0: delay_bit
  port map (
      reset_b	       => link_reset,
      clk	       => link_clk1x,
      delay_in         => result_delay,
      delay_enable_in  => '1',
      bit_in           => algo_enable, --rx_valid_d1,
      bit_out          => result_valid);

  --------------------------------------------------------------------------
  -- DAQ Capture
  --------------------------------------------------------------------------

  daq_chain(0) <= not daq_empty(0);

  daqbuf_input: daq_buffer
    generic map(
      daq_width             => (1*cNumberOfLinks),
      buf_ident             => x"0")
    port map(
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
    generic map(
      daq_width             => (2*cNumberOfLinks),
      buf_ident             => x"1")
    port map(
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

  daqmerge_proc: process(link_clk1x, link_reset)
    variable daqmerge_valid_var: std_logic;
    variable daqmerge_data_var: std_logic_vector(31 downto 0);
  begin
    if link_reset = '1' then
      daqmerge_data <= (others => '0');
      daqmerge_valid <= '0';
    elsif (link_clk1x = '1') and link_clk1x'event then
      daqmerge_data_var := (others => '0');
      daqmerge_valid_var := '0';
      daq_merge: for i in 0 to daq_units-1 loop
        daqmerge_data_var := daqmerge_data_var or daq_data(i);
        daqmerge_valid_var := daqmerge_valid_var or daq_valid(i);
      end loop;
      daqmerge_data <= daqmerge_data_var;
      daqmerge_valid <= daqmerge_valid_var;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- DAQ Buffer
  -------------------------------------------------------------------------

  daq_output_inst: daq_output
    generic map(
        module => module_daq)
    port map( 
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
      backpressure_out          => open);

  debug_out(0) <= sync_slave_ch0(6); -- refclk(gtx_clk);
  debug_out(1) <= sync_slave_ch0(7); -- plllkdet(gtx_clk);
  debug_out(5 downto 2) <= (others => '0');
  debug_out(6) <= sync_master; --link_reset;
  debug_out(7) <= '0';


end behave;