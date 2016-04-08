LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY unisim;
USE unisim.vcomponents.ALL;
LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;
USE work.package_reg.ALL;
USE work.package_utilities.ALL;


ENTITY minit_gtx_comm_interface IS
GENERIC(
   local_lhc_bunch_count:             integer := lhc_bunch_count;         -- USE 200 FOR sim ELSE lhc_bunch_count
   sim_mode:                          string := "fast";                   -- Set TO Fast Functional Simulation Model
   sim_gtx_reset_speedup:             integer:= 0;                        -- Set TO 1 TO speed up sim reset
   sim_pll_perdiv2:                   bit_vector:= x"0d0";                -- Set TO the VCO Unit Interval time
   module_gtx_ch0_reg:                type_mod_define;
   module_gtx_ch1_reg:                type_mod_define;
   module_gtx_ch0_ram:                type_mod_define;
   module_gtx_ch1_ram:                type_mod_define;
   module_gtx_drp:                    type_mod_define);
PORT(
   -- Fabric clk/rst
   fabric_clk1x_in              : IN   std_logic;
   fabric_reset_in              : IN   std_logic;  
   -- Link clk/rst
   link_clk1x_in                : IN   std_logic;
   link_clk2x_in                : IN   std_logic;
   link_reset_in                : IN   std_logic;
   -- GTP PLL clks
   txoutclk_out                 : OUT   std_logic;
   plllkdet_out                 : OUT   std_logic;
   -- Comm interface
   comm_cntrl                   : IN type_comm_cntrl;
   comm_reply                   : OUT type_comm_reply;
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
END minit_gtx_comm_interface;

ARCHITECTURE behave OF minit_gtx_comm_interface IS

  COMPONENT minit_gtx IS
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
    -- Spy memory interface
    spy_read_add_ch0             : IN std_logic_vector(10 DOWNTO 0);
    spy_read_add_ch1             : IN std_logic_vector(10 DOWNTO 0);
    spy_read_data_ch0            : OUT std_logic_vector(31 DOWNTO 0);
    spy_read_data_ch1            : OUT std_logic_vector(31 DOWNTO 0);
    spy_read_enable_ch0          : IN std_logic;
    spy_read_enable_ch1          : IN std_logic;
    spy_read_ack_ch0             : OUT std_logic;
    spy_read_ack_ch1             : OUT std_logic;
    -- Dynamic Reconfiguration PORT (DRP)
    drp_addr_in                  : IN std_logic_vector(6 DOWNTO 0);   
    drp_clk_in                   : IN std_logic;                      
    drp_en_in                    : IN std_logic;                      
    drp_data_in                  : IN std_logic_vector(15 DOWNTO 0);  
    drp_data_out                 : OUT std_logic_vector(15 DOWNTO 0); 
    drp_rdy_out                  : OUT std_ulogic;                    
    drp_we_in                    : IN std_logic;                      
    -- Rx parallel data OUT
    rx_data_ch0_out              : OUT std_logic_vector(31 DOWNTO 0);
    rx_data_ch1_out              : OUT std_logic_vector(31 DOWNTO 0);
    rx_data_valid_ch0_out        : OUT std_logic;
    rx_data_valid_ch1_out        : OUT std_logic;
    -- Rx serdes IN
    rxn_ch0_in                   : IN std_logic;
    rxn_ch1_in                   : IN std_logic;
    rxp_ch0_in                   : IN std_logic;
    rxp_ch1_in                   : IN std_logic;
    -- Ref clock
    refclkp_in                   : IN std_logic;
    refclkn_in                   : IN std_logic;
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

  -- Comm BUS moved into local clk domain
  SIGNAL comm_cntrl_slv:                     type_comm_cntrl;
  SIGNAL comm_reply_slv:                     type_comm_reply;

  CONSTANT comm_units:                   natural := 5;
  
  SIGNAL comm_cntrl_gtp:                     type_comm_bus_cntrl(comm_units-1 DOWNTO 0);
  SIGNAL comm_reply_gtp:                     type_comm_bus_reply(comm_units-1 DOWNTO 0);         
  
  -- Individual communication link TO rams
  SIGNAL comm_cntrl_ram_ch0:                     type_comm_cntrl;
  SIGNAL comm_reply_ram_ch0:                     type_comm_reply;
  SIGNAL comm_cntrl_ram_ch1:                     type_comm_cntrl;
  SIGNAL comm_reply_ram_ch1:                     type_comm_reply;
  
  -- Individual communication link TO dynamic reconfiguration PORT
  SIGNAL comm_cntrl_drp:                     type_comm_cntrl;
  SIGNAL comm_reply_drp:                     type_comm_reply;
  
  -- Individual communication link TO regs
  SIGNAL ro_regs_ch0                              : type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
  SIGNAL ro_regs_ch1                              : type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
  SIGNAL rw_regs_ch0                              : type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
  SIGNAL rw_regs_ch1                              : type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
  SIGNAL rw_regs_default_ch0                      : type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
  SIGNAL rw_regs_default_ch1                      : type_vector_of_stdlogicvec_x32(7 DOWNTO 0);
  
  SIGNAL link_reset_b:            std_logic;
  SIGNAL link_clk1x_phase180:     std_logic;
    
  SIGNAL fabric_reset_b:          std_logic;

  -- Strobe/ReadEnable FOR RAMs
  SIGNAL ram_ch0_stb :             std_logic;
  SIGNAL ram_ch1_stb :             std_logic;


begin

  fabric_reset_b <= NOT fabric_reset_in;
  link_reset_b <= NOT link_reset_in;
  
  --------------------------------------------------------------------------
  -- (1) Bridge comm BUS from fabric clock TO link clk
  --------------------------------------------------------------------------

  comm_clk_bridge_inst:  comm_clk_bridge
  GENERIC MAP(
    delay => 1)
  PORT MAP(
    rst_master_in           => fabric_reset_in,
    clk_master_in           => fabric_clk1x_in,
    rst_slave_in            => link_reset_in,
    clk_slave_in            => link_clk1x_in,
    comm_cntrl_master_in    => comm_cntrl,
    comm_cntrl_slave_out    => comm_cntrl_slv,
    comm_reply_master_out   => comm_reply,
    comm_reply_slave_in     => comm_reply_slv);

  --------------------------------------------------------------------------
  -- (2) The ENTITY comm_mini_hub fans OUT the control
  -- signals (e.g. read/write enable) as an ARRAY (comm_cntrl_gtp).  The 
  -- module replies are contained IN a similar ARRAY (comm_reply_gtp) 
  -- which are merged IN a large OR. Each module has a 'module' definition 
  -- which specifies the start AND END OF address space. 
  --------------------------------------------------------------------------

  comm_mini_hub_inst: comm_mini_hub
  GENERIC MAP(
    comm_units              => comm_units)
  PORT MAP(
    rst_in                     => link_reset_in, 
    clk_in                     => link_clk1x_in,
    comm_cntrl_in              => comm_cntrl_slv,
    comm_reply_out             => comm_reply_slv,      
    comm_bus_cntrl_out         => comm_cntrl_gtp,
    comm_bus_reply_in          => comm_reply_gtp);

  --------------------------------------------------------------------------
  -- Comm BUS: Ch0
  --------------------------------------------------------------------------

  reg_ch0: reg_array_inout
  GENERIC MAP(
    module                  => module_gtx_ch0_reg, -- Req. x"200" OF add space
    module_active           => '1',
    number_of_rw_words      => 8,
    number_of_ro_words      => 8)
  PORT MAP( 
    rstb_in                 => link_reset_b,
    clk_in                  => link_clk1x_in,
    comm_cntrl              => comm_cntrl_gtp(0),
    comm_reply              => comm_reply_gtp(0),
    rw_default_array_in     => rw_regs_default_ch0,
    rw_data_array_out       => rw_regs_ch0,
    ro_data_array_in        => ro_regs_ch0);

  ram_ch0: module_select
  GENERIC MAP(
    module                  => module_gtx_ch0_ram, -- Req. x"800" OF add space
    module_add_width_req    => x"00000800")
  PORT MAP(
    rst_in                  => link_reset_in, 
    clk_in                  => link_clk1x_in,
    comm_cntrl_in           => comm_cntrl_gtp(1),
    comm_reply_out          => comm_reply_gtp(1),
    comm_cntrl_out          => comm_cntrl_ram_ch0,
    comm_reply_in           => comm_reply_ram_ch0);

  ram_ch0_stb <= comm_cntrl_ram_ch0.stb AND (NOT comm_cntrl_ram_ch0.wen);
  comm_reply_ram_ch0.err <= '0';

  --------------------------------------------------------------------------
  -- Comm BUS: Ch1
  --------------------------------------------------------------------------

  reg_ch1: reg_array_inout
  GENERIC MAP(
    module                  => module_gtx_ch1_reg, -- Req. x"200" OF add space
    module_active           => '1',
    number_of_rw_words      => 8,
    number_of_ro_words      => 8)
  PORT MAP( 
    rstb_in                 => link_reset_b,
    clk_in                  => link_clk1x_in,
    comm_cntrl              => comm_cntrl_gtp(2),
    comm_reply              => comm_reply_gtp(2),
    rw_default_array_in     => rw_regs_default_ch1,
    rw_data_array_out       => rw_regs_ch1,
    ro_data_array_in        => ro_regs_ch1);

  ram_ch1: module_select
  GENERIC MAP(
    module                  => module_gtx_ch1_ram, -- Req. x"800" OF add space
    module_add_width_req    => x"00000800")
  PORT MAP(
    rst_in                  => link_reset_in, 
    clk_in                  => link_clk1x_in,
    comm_cntrl_in           => comm_cntrl_gtp(3),
    comm_reply_out          => comm_reply_gtp(3),
    comm_cntrl_out          => comm_cntrl_ram_ch1,
    comm_reply_in           => comm_reply_ram_ch1);

  ram_ch1_stb <= comm_cntrl_ram_ch1.stb AND (NOT comm_cntrl_ram_ch1.wen);
  comm_reply_ram_ch1.err <= '0';

 --------------------------------------------------------------------------
   -- MAP CommCntrl BUS TO Giga Bit Transceiver interface
   --------------------------------------------------------------------------

   -- How will XST handle this by using inverting inputs TO flipflops?
   link_clk1x_phase180 <= NOT link_clk1x_in;

   drp: module_select
   GENERIC MAP(
      module                  => module_gtx_drp, -- Req. x"200" OF add space
      module_add_width_req    => x"00000200")
   PORT MAP(
      rst_in                  => link_reset_in, 
      clk_in                  => link_clk1x_in,
      comm_cntrl_in           => comm_cntrl_gtp(4),
      comm_reply_out          => comm_reply_gtp(4),
      comm_cntrl_out          => comm_cntrl_drp,
      comm_reply_in           => comm_reply_drp);

   -- Unused. 16bit data
   comm_reply_drp.rdata(31 DOWNTO 16) <= (OTHERS => '0');
   comm_reply_drp.err <= '0';

   --------------------------------------------------------------------------
   -- Giga Bit Transceiver
   --------------------------------------------------------------------------

   minit_gtx_inst : minit_gtx
   GENERIC MAP(
      sim_mode                  => sim_mode,
      sim_gtx_reset_speedup     => sim_gtx_reset_speedup,
      sim_pll_perdiv2           => sim_pll_perdiv2,
      local_lhc_bunch_count     => local_lhc_bunch_count)
   PORT MAP(
      link_clk1x_in             => link_clk1x_in,
      link_clk2x_in             => link_clk2x_in,
      link_reset_in             => link_reset_in,
      txoutclk_out              => txoutclk_out,
      plllkdet_out              => plllkdet_out,
      ro_regs_ch0               => ro_regs_ch0,
      ro_regs_ch1               => ro_regs_ch1,
      rw_regs_ch0               => rw_regs_ch0,
      rw_regs_ch1               => rw_regs_ch1,
      rw_regs_default_ch0       => rw_regs_default_ch0,
      rw_regs_default_ch1       => rw_regs_default_ch1,
      spy_read_add_ch0          => comm_cntrl_ram_ch0.add(10 DOWNTO 0),
      spy_read_add_ch1          => comm_cntrl_ram_ch1.add(10 DOWNTO 0),
      spy_read_data_ch0         => comm_reply_ram_ch0.rdata,
      spy_read_data_ch1         => comm_reply_ram_ch1.rdata,
      spy_read_enable_ch0       => ram_ch0_stb,
      spy_read_enable_ch1       => ram_ch1_stb,
      spy_read_ack_ch0          => comm_reply_ram_ch0.ack,
      spy_read_ack_ch1          => comm_reply_ram_ch1.ack,
      drp_addr_in               => comm_cntrl_drp.add(8 DOWNTO 2),
      drp_clk_in                => link_clk1x_phase180,
      drp_en_in                 => comm_cntrl_drp.stb,
      drp_data_in               => comm_cntrl_drp.wdata(15 DOWNTO 0),
      drp_data_out              => comm_reply_drp.rdata(15 DOWNTO 0),
      drp_rdy_out               => comm_reply_drp.ack,
      drp_we_in                 => comm_cntrl_drp.wen,
      rx_data_ch0_out           => rx_data_ch0_out,
      rx_data_ch1_out           => rx_data_ch1_out,
      rx_data_valid_ch0_out     => rx_data_valid_ch0_out,
      rx_data_valid_ch1_out     => rx_data_valid_ch1_out,
      rxn_ch0_in                => rxn_ch0_in,
      rxn_ch1_in                => rxn_ch1_in,
      rxp_ch0_in                => rxp_ch0_in,
      rxp_ch1_in                => rxp_ch1_in,
      refclkp_in                => refclkp_in,
      refclkn_in                => refclkn_in,
      tx_data_ch0_in            => tx_data_ch0_in,
      tx_data_ch1_in            => tx_data_ch1_in,
      tx_data_valid_ch0_in      => tx_data_valid_ch0_in,
      tx_data_valid_ch1_in      => tx_data_valid_ch1_in,
      txn_ch0_out               => txn_ch0_out,
      txn_ch1_out               => txn_ch1_out,
      txp_ch0_out               => txp_ch0_out,
      txp_ch1_out               => txp_ch1_out);
      
END behave;