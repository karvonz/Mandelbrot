
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

entity core_sys_tmux_r1 is
  generic(
    firmware         : std_logic_vector(31 downto 0);
    board            : std_logic_vector(31 downto 0);
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
end core_sys_tmux_r1;

architecture behave of core_sys_tmux_r1 is

  constant det_pp_links : integer := 10;
  constant pp_mp_links : integer := 12;
  constant bits_per_word: integer:= 32;
  constant words_per_bx : integer := 3;
  constant bx_per_orbit : integer := 32;

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

  component timemux_top is
    generic(
    det_pp_links : integer := 12;
    pp_mp_links : integer := 14;
    bits_per_word: integer:= 32;
    words_per_bx : integer := 3;
    bx_per_orbit : integer := 32);
  port(
    clk_in          : in std_logic;
    rst_in          : in std_logic := '0';
    link_start_in   : in std_logic;
    link_stop_in    : in std_logic;
    link_valid_in   : in std_logic;
    link_data_in    : in all_links((det_pp_links-1) downto 0);
    link_valid_out   : out std_logic_vector((pp_mp_links-1) downto 0);
    link_data_out    : out all_links((pp_mp_links-1) downto 0));
  end component;
  
  component detector_sim is
    generic(
		 det_pp_links : integer := 12;
		 bits_per_word: integer:= 32;
		 words_per_bx : integer := 3;
		 bx_per_orbit: integer := 3564);
    port(
      clk_in          : in std_logic;
      rst_in          : in std_logic := '0';
      link_start_out   : out std_logic;
      link_stop_out    : out std_logic;
      link_valid_out   : out std_logic;
      link_data_out    : out all_links((det_pp_links-1) downto 0));
  end component;

  signal fabric_reset_b: std_logic;

  -- Internal communication bus
  constant comm_units:                   natural := 7;
  signal comm_cntrl:                     type_comm_bus_cntrl(comm_units-1 downto 0);
  signal comm_reply:                     type_comm_bus_reply(comm_units-1 downto 0);

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
  signal rx_select                    : std_logic;  
  -- Txout clks from PLL in gtx0
  signal txoutclk                : std_logic_vector(gtx_max downto gtx_min) := (others => '0');
  signal plllkdet                : std_logic_vector(gtx_max downto gtx_min) := (others => '0');
  signal refclk                  : std_logic_vector(gtx_max downto gtx_min) := (others => '0');
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
  signal tx_data_ch0_int               : type_vector_of_stdlogicvec_x32(gtx_max downto gtx_min) := (others => x"00000000");
  signal tx_data_ch1_int               : type_vector_of_stdlogicvec_x32(gtx_max downto gtx_min) := (others => x"00000000");
  signal tx_valid_ch0_int         : std_logic_vector(gtx_max downto gtx_min) := (others => '0');
  signal tx_valid_ch1_int         : std_logic_vector(gtx_max downto gtx_min) := (others => '0');
  
  constant gtx_units: natural range 0 to 31:= gtx_max-gtx_min+1;
  signal comm_gtx_cntrl: type_comm_bus_cntrl(gtx_units-1 downto 0);
  signal comm_gtx_reply: type_comm_bus_reply(gtx_units-1 downto 0);
  signal comm_gtx_port: integer range 0 to 31;
  signal comm_gtx_enable: std_logic_vector(gtx_max downto gtx_min);

  signal rw_reg, ro_reg: type_vector_of_stdlogicvec_x32(15 downto 0);

  signal sync_master: std_logic;
  signal sync_master_delay: std_logic_vector(4 downto 0);
  signal sync_master_delay_enable: std_logic;
  signal sync_slave_ch0: std_logic_vector(gtx_max downto gtx_min);
  signal sync_slave_ch1: std_logic_vector(gtx_max downto gtx_min);

  signal ttc_time: std_logic_vector(8 downto 0);
  signal ttc_cntrl: std_logic_vector(1 downto 0);

  -- Input from detector (rx_data) or a simulation of the detector (sim_data).
  signal rx_data_array, sim_data_array: all_links(det_pp_links-1 downto 0);
  signal rx_valid, sim_valid: std_logic;
  
  -- Input to PP time_multiplexer after rx data selection.
  signal rx_tmux_data_array, rx_tmux_data_array_d1: all_links(det_pp_links-1 downto 0);
  signal rx_tmux_valid, rx_tmux_valid_d1: std_logic;
  

  -- Convert data into format for DAQ (i.e. very large std_logic_vector) 
  signal rx_tmux_data_d1: std_logic_vector(32*det_pp_links-1 downto 0);
  signal rx_tmux_stop: std_logic;
  signal rx_tmux_word_cnt: integer range words_per_bx-1 downto 0;
  
  -- Output from PP time_multiplexer to be transmitted to MP cards.
  signal tx_tmux_data_array: all_links(pp_mp_links-1 downto 0);
  signal tx_tmux_valid_array: std_logic_vector(pp_mp_links-1 downto 0);


  -- Delay units always have 1 clk delay...  Hence for 10 clks program 9...
  constant result_delay: std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(8,5));
  

  -- Used for master "packet_valid" and "packet_id"
  constant gtxd_master: natural range 0 to 31 := 6;

  signal trig: std_logic;

  
  -- TTC bunch crossing and fine crossing counters
  signal ttc_bx_cnt: integer range bx_per_orbit-1 downto 0;
  signal ttc_fx_cnt: integer range words_per_bx-1 downto 0;


  -- DAQ path
  constant daq_units: natural := 2;

  signal daq_chain: std_logic_vector(daq_units downto 0) := (others => '0');
  signal daq_valid, daq_empty: std_logic_vector(daq_units-1 downto 0) := (others => '0');
  signal daq_data: type_vector_of_stdlogicvec_x32(daq_units-1 downto 0) := (others => (others => '0'));

  signal daqmerge_valid: std_logic := '0';
  signal daqmerge_data: std_logic_vector(31 downto 0) := (others => '0');


  --for all : minit_gtx_txusrclk use entity links.minit_gtx_txusrclk(behave);

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
    board_id                => board,
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
    comm_cntrl                    => comm_cntrl(4),
    comm_reply                    => comm_reply(4),
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
  rx_select <= '0';
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
      comm_cntrl                => comm_cntrl(5),
      comm_reply                => comm_reply(5),
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
    comm_cntrl_in           => comm_cntrl(6),
    comm_reply_out          => comm_reply(6),
    comm_bus_cntrl_out      => comm_gtx_cntrl,
    comm_bus_reply_in       => comm_gtx_reply);

  -- Select which gtx unit to communicate with
  comm_gtx_port <= to_integer(unsigned(comm_gtx_cntrl(0).add(17 downto 14)));

  gtx_i: for i in gtx_min to gtx_max generate
  begin

    -- Which comm port are we communicating with.
    comm_gtx_enable(i) <= '1' when comm_gtx_port = i else '0';

    -- Select whether to use external or internal data for tx.
    tx_data_ch0(i) <= counter_data when tx_select = '0' else tx_data_ch0_int(i);
    tx_data_ch1(i) <= counter_data when tx_select = '0' else tx_data_ch1_int(i);
    tx_data_valid_ch0(i) <= counter_data_valid when tx_select = '0' else tx_valid_ch0_int(i);
    tx_data_valid_ch1(i) <= counter_data_valid when tx_select = '0' else tx_valid_ch1_int(i);

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
  -- PP: Map links
  --------------------------------------------------------------------------

  -- Use GTX transcsivers:
  -- 0-5 for pp cards
  -- rx using 0-4 (10 chans)
  -- tx using 0-5 (12 chans)

  -- 6-11 for mp cards
  -- hopefully capture data in daq buffer

  rx_data_array(0).data <= rx_data_ch0(0);
  rx_data_array(1).data <= rx_data_ch1(0); 
  rx_data_array(2).data <= rx_data_ch0(1); 
  rx_data_array(3).data <= rx_data_ch1(1); 
  rx_data_array(4).data <= rx_data_ch0(2); 
  rx_data_array(5).data <= rx_data_ch1(2); 
  rx_data_array(6).data <= rx_data_ch0(3); 
  rx_data_array(7).data <= rx_data_ch1(3); 
  rx_data_array(8).data <= rx_data_ch0(4); 
  rx_data_array(9).data <= rx_data_ch1(4); 
  -- rx_data_array(10).data <= rx_data_ch0(5); 
  -- rx_data_array(11).data <= rx_data_ch1(5);

  -- All rx data arriving in sync courtesy of GTX firmware
  rx_valid <= rx_data_valid_ch0(gtxd_master);

  -- Drive time multiplexer from rx inputs or simulated data 
  rx_tmux_data_array <= sim_data_array when rx_select = '0' else rx_data_array;
  rx_tmux_valid <= sim_valid when rx_select = '0' else rx_valid;

  --------------------------------------------------------------------------
  -- MP: Map links
  --------------------------------------------------------------------------

  -- All tx data channels post time multiplexing have different events 
  -- sent out at different times (i.e. data valid at different times).
  tx_data_ch0_int(0) <= tx_tmux_data_array(0).data; 
  tx_data_ch1_int(0) <= tx_tmux_data_array(1).data; 
  tx_data_ch0_int(1) <= tx_tmux_data_array(2).data; 
  tx_data_ch1_int(1) <= tx_tmux_data_array(3).data; 
  tx_data_ch0_int(2) <= tx_tmux_data_array(4).data; 
  tx_data_ch1_int(2) <= tx_tmux_data_array(5).data; 
  tx_data_ch0_int(3) <= tx_tmux_data_array(6).data; 
  tx_data_ch1_int(3) <= tx_tmux_data_array(7).data; 
  tx_data_ch0_int(4) <= tx_tmux_data_array(8).data; 
  tx_data_ch1_int(4) <= tx_tmux_data_array(9).data; 
  tx_data_ch0_int(5) <= tx_tmux_data_array(10).data; 
  tx_data_ch1_int(5) <= tx_tmux_data_array(11).data;

  -- All tx data channels post time multiplexing have different events 
  -- sent out at different times (i.e. data valid at different times).
  tx_valid_ch0_int(0) <= tx_tmux_valid_array(0);
  tx_valid_ch1_int(0) <= tx_tmux_valid_array(1);
  tx_valid_ch0_int(1) <= tx_tmux_valid_array(2);
  tx_valid_ch1_int(1) <= tx_tmux_valid_array(3);
  tx_valid_ch0_int(2) <= tx_tmux_valid_array(4);
  tx_valid_ch1_int(2) <= tx_tmux_valid_array(5);
  tx_valid_ch0_int(3) <= tx_tmux_valid_array(6);
  tx_valid_ch1_int(3) <= tx_tmux_valid_array(7);
  tx_valid_ch0_int(4) <= tx_tmux_valid_array(8);
  tx_valid_ch1_int(4) <= tx_tmux_valid_array(9);
  tx_valid_ch0_int(5) <= tx_tmux_valid_array(10);
  tx_valid_ch1_int(5) <= tx_tmux_valid_array(11);

  --------------------------------------------------------------------------
  -- MP: Map links
  --------------------------------------------------------------------------
  
  -- Only TimeMux in this core.  
  -- Keep GTX tranceivers fo debugging.
  -- Perhaps add MP algo later.

  tx_data_ch0_int(6) <= (others => '0');
  tx_data_ch1_int(6) <= (others => '0');
  tx_data_ch0_int(7) <= (others => '0');
  tx_data_ch1_int(7) <= (others => '0');
  tx_data_ch0_int(8) <= (others => '0');
  tx_data_ch1_int(8) <= (others => '0');
  tx_data_ch0_int(9) <= (others => '0');
  tx_data_ch1_int(9) <= (others => '0');
  tx_data_ch0_int(10) <= (others => '0');
  tx_data_ch1_int(10) <= (others => '0');
  tx_data_ch0_int(11) <= (others => '0');
  tx_data_ch1_int(11) <= (others => '0');

  tx_valid_ch0_int(6) <= '0';
  tx_valid_ch1_int(6) <= '0';
  tx_valid_ch0_int(7) <= '0';
  tx_valid_ch1_int(7) <= '0';
  tx_valid_ch0_int(8) <= '0';
  tx_valid_ch1_int(8) <= '0';
  tx_valid_ch0_int(9) <= '0';
  tx_valid_ch1_int(9) <= '0';
  tx_valid_ch0_int(10) <= '0';
  tx_valid_ch1_int(10) <= '0';
  tx_valid_ch0_int(11) <= '0';
  tx_valid_ch1_int(11) <= '0';
  
  --------------------------------------------------------------------------
  --  TTC signal generator
  --------------------------------------------------------------------------

  ttc_gen: process(link_clk1x, link_reset)
  begin
    if link_reset = '1' then
      ttc_bx_cnt <= 0;
    elsif (link_clk1x = '1') and link_clk1x'event then
      -- Clk is running faster than LHC bx clk.
      -- FX = FineCrossing
      if ttc_fx_cnt < (words_per_bx - 1) then
        ttc_fx_cnt <= ttc_fx_cnt + 1;
      else 
        ttc_fx_cnt <= 0; 
      end if;
      -- LHC bunch number
      -- BX = BunchCrossing
      if ttc_bx_cnt < (bx_per_orbit - 1)  then
        ttc_bx_cnt <= ttc_bx_cnt + 1;
      else
        ttc_bx_cnt <= 0;
      end if;
    end if;  
  end process;

  --------------------------------------------------------------------------
  -- No header on data from detector.  Multiple data words per bx.
  -- How do we know where one event starts and another stops?
  -- The RCT/GCT interface toggles the top bit in each word 
  -- to indicate which of the 2 words per bx is currently
  -- being transmitted.  Perhaps not available from HCAL/ECAL
  -- Assume detect correct bx from beginning of data packet and send 
  -- commas in gap.
  --------------------------------------------------------------------------

  proc_word_index: process(link_clk1x, link_reset)
    variable reset_finished : std_logic;
  begin
    if link_reset = '1' then
	   reset_finished := '0';
      rx_tmux_stop <= '0';
      rx_tmux_valid_d1 <= '0';
      reg_rx_data: for i in 0 to det_pp_links-1 loop
        rx_tmux_data_array_d1(i).data <=  x"00000000";
      end loop;
    elsif (link_clk1x = '1') and link_clk1x'event then
      if reset_finished = '0' then
		  -- Exit reset on next clock cycle.
		  reset_finished := '1';
		  -- Make sure that delayed signals have valid values.
		  rx_tmux_valid_d1 <= rx_tmux_valid;
		else
			-- Find beginning of new orbit
			if (rx_tmux_valid_d1 = '0') and (rx_tmux_valid = '1') then
			  rx_tmux_word_cnt <= 1;
			elsif (rx_tmux_valid = '1') and (rx_tmux_word_cnt < words_per_bx-1) then
			  rx_tmux_word_cnt <= rx_tmux_word_cnt+1;
			else
			  rx_tmux_word_cnt <= 0;
			end if;
			-- Find end of bx packet
			if rx_tmux_word_cnt = words_per_bx-2 then 
			  rx_tmux_stop <= '1';
			else
			  rx_tmux_stop <= '0';
			end if;
			-- Clk incoming data so that is presented to daq pipelines at the same time as rx_id.
			rx_tmux_data_array_d1 <= rx_tmux_data_array;
			rx_tmux_valid_d1 <= rx_tmux_valid;
	   end if;
    end if;
  end process;

  pass_data_into_format_for_daq: for i in 0 to det_pp_links-1 generate
    rx_tmux_data_d1(32*i+31 downto 32*i) <= rx_tmux_data_array_d1(i).data;
  end generate;

  --------------------------------------------------------------------------
  -- Time multiplexer
  --------------------------------------------------------------------------

  timemux_top_inst: timemux_top
    generic map(
      det_pp_links => det_pp_links,
      pp_mp_links => pp_mp_links,
      bits_per_word => bits_per_word,
      words_per_bx => words_per_bx)
    port map(
      clk_in            => link_clk1x,
      rst_in            => link_reset,
      link_start_in     => '0',
      link_stop_in      => rx_tmux_stop,
      link_valid_in     => rx_tmux_valid,
      link_data_in      => rx_tmux_data_array,
      link_valid_out    => tx_tmux_valid_array,
      link_data_out     => tx_tmux_data_array); 

  --------------------------------------------------------------------------
  -- Sim fake detector data
  --------------------------------------------------------------------------


  detector_sim_inst:  detector_sim
    generic map(	 
      det_pp_links => det_pp_links,
      bits_per_word => bits_per_word,
      words_per_bx => words_per_bx,
		bx_per_orbit => bx_per_orbit)
    port map(
      clk_in            => link_clk1x,
      rst_in            => link_reset,
      link_start_out    => open,
      link_stop_out     => open,
      link_valid_out    => sim_valid,
      link_data_out     => sim_data_array);

  -- Need Pipeline, but this will have to do for the moment.
  --result_id <= rx_tmux_id_d1;
  --result_valid <= rx_valid_d1;

--  sync_bufd_ch0: delay_word
--  generic map (
--      width => 12)
--  port map (
--      reset_b	       => link_reset,
--      clk	       => link_clk1x,
--      delay_in         => result_delay,
--      delay_enable_in  => '1',
--      word_in          => rx_tmux_id_d1,
--      word_out         => result_id);
--
--  sync_bufdv_ch0: delay_bit
--  port map (
--      reset_b	       => link_reset,
--      clk	       => link_clk1x,
--      delay_in         => result_delay,
--      delay_enable_in  => '1',
--      bit_in           => algo_enable, --rx_valid_d1,
--      bit_out          => result_valid);

  --------------------------------------------------------------------------
  -- DAQ Capture
  --------------------------------------------------------------------------

--  daq_chain(0) <= not daq_empty(0);
--
--  daqbuf_input: daq_buffer
--    generic map(
--      daq_width             => (1*cNumberOfLinks),
--      buf_ident             => x"0")
--    port map(
--      clk                   => link_clk1x,
--      rst                   => link_reset,
--      trig_in               => trig,
--      packet_data_in        => rx_tmux_data_d1,
--      packet_id_in          => rx_tmux_id_d1,
--      packet_valid_in       => rx_tmux_valid_d1,
--      daq_start_in          => daq_chain(0),
--      daq_stop_out          => daq_chain(1),
--      daq_data_out          => daq_data(0),
--      daq_id_out            => open,
--      daq_valid_out         => daq_valid(0),
--      daq_empty_out         => daq_empty(0));
--
--
--
--
--  daqbuf_result: daq_buffer
--    generic map(
--      daq_width             => (2*cNumberOfLinks),
--      buf_ident             => x"1")
--    port map(
--      clk                   => link_clk1x,
--      rst                   => link_reset,
--      trig_in               => trig,
--      packet_data_in        => result_vec,
--      packet_id_in          => result_id,
--      packet_valid_in       => result_valid,
--      daq_start_in          => daq_chain(1),
--      daq_stop_out          => daq_chain(2),
--      daq_data_out          => daq_data(1),
--      daq_id_out            => open,
--      daq_valid_out         => daq_valid(1),
--      daq_empty_out         => daq_empty(1));
--
--  --------------------------------------------------------------------------
--  -- Merge data streams
--  -------------------------------------------------------------------------
--
--  daqmerge_proc: process(link_clk1x, link_reset)
--    variable daqmerge_valid_var: std_logic;
--    variable daqmerge_data_var: std_logic_vector(31 downto 0);
--  begin
--    if link_reset = '1' then
--      daqmerge_data <= (others => '0');
--      daqmerge_valid <= '0';
--    elsif (link_clk1x = '1') and link_clk1x'event then
--      daqmerge_data_var := (others => '0');
--      daqmerge_valid_var := '0';
--      daq_merge: for i in 0 to daq_units-1 loop
--        daqmerge_data_var := daqmerge_data_var or daq_data(i);
--        daqmerge_valid_var := daqmerge_valid_var or daq_valid(i);
--      end loop;
--      daqmerge_data <= daqmerge_data_var;
--      daqmerge_valid <= daqmerge_valid_var;
--    end if;
--  end process;
--
--  --------------------------------------------------------------------------
--  -- DAQ Buffer
--  -------------------------------------------------------------------------
--
--  daq_output_inst: daq_output
--    generic map(
--        module => module_daq)
--    port map( 
--      fabric_clk1x_in           => fabric_clk1x_in,
--      fabric_reset_in           => fabric_reset_in,
--      link_clk1x_in             => link_clk1x, 
--      link_reset_in             => link_reset, 
--      comm_cntrl_in             => comm_cntrl(6),
--      comm_reply_out            => comm_reply(6),
--      daq_data_in               => daqmerge_data,
--      daq_valid_in              => daqmerge_valid,
--      daq_start_in              => daq_chain(0),
--      daq_stop_in               => daq_chain(daq_units),
--      overflow_out              => open,
--      backpressure_out          => open);

  debug_out(0) <= sync_slave_ch0(6); -- refclk(gtx_clk);
  debug_out(1) <= sync_slave_ch0(7); -- plllkdet(gtx_clk);
  debug_out(5 downto 2) <= (others => '0');
  debug_out(6) <= sync_master; --link_reset;
  debug_out(7) <= '0';


end behave;