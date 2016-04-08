

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

entity core_sys_test_r1 is
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
end core_sys_test_r1;

architecture behave of core_sys_test_r1 is

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


  debug_out(0) <= '0'; -- refclk(gtx_clk);
  debug_out(1) <= '0'; -- plllkdet(gtx_clk);
  debug_out(5 downto 2) <= (others => '0');
  debug_out(6) <= '0'; --link_reset;
  debug_out(7) <= '0';


end behave;