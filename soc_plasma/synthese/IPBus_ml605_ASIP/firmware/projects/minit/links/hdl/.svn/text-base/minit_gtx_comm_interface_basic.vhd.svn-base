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


entity minit_gtx_comm_interface_basic is
generic(
   LOCAL_LHC_BUNCH_COUNT:             integer := LHC_BUNCH_COUNT;         -- Use 200 for sim else lhc_bunch_count
   SIM_MODE:                          string := "SLOW";                   -- Set to Fast Functional Simulation Model
   SIM_GTX_RESET_SPEEDUP:             integer:= 0;                        -- Set to 1 to speed up sim reset
   SIM_PLL_PERDIV2:                   bit_vector:= x"0d0");                -- Set to the VCO Unit Interval time
port(
   -- Fabric clk/rst
   fabric_clk1x_in              : in   std_logic;
   fabric_reset_in              : in   std_logic;  
   -- Link clk/rst
   link_clk1x_in                : in   std_logic;
   link_clk2x_in                : in   std_logic;
   link_reset_in                : in   std_logic;
   -- GTP PLL clks
   txoutclk_out                 : out   std_logic;
   plllkdet_out                 : out   std_logic;
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
   rx_data_ch0_out              : out  std_logic_vector(31 downto 0);
   rx_data_ch1_out              : out  std_logic_vector(31 downto 0);
   rx_data_valid_ch0_out        : out  std_logic;
   rx_data_valid_ch1_out        : out  std_logic;
   -- Rx serdes in
   rxn_ch0_in                   : in   std_logic;
   rxn_ch1_in                   : in   std_logic;
   rxp_ch0_in                   : in   std_logic;
   rxp_ch1_in                   : in   std_logic;
   -- Ref clock
   refclkp_in                   : in   std_logic;
   refclkn_in                   : in   std_logic;
   refclk_out                   : out  std_logic;
   -- Tx parallel data in
   tx_data_ch0_in               : in   std_logic_vector(31 downto 0);
   tx_data_ch1_in               : in   std_logic_vector(31 downto 0);
   tx_data_valid_ch0_in         : in   std_logic;
   tx_data_valid_ch1_in         : in   std_logic;
   -- Tx serdes data out
   txn_ch0_out                  : out  std_logic;
   txn_ch1_out                  : out  std_logic;
   txp_ch0_out                  : out  std_logic;
   txp_ch1_out                  : out  std_logic);
end minit_gtx_comm_interface_basic;

architecture behave of minit_gtx_comm_interface_basic is

  component minit_gtx is
  generic(
    -- Simulation attributes
    SIM_MODE                : string     := "SLOW"; -- Set to Fast Functional Simulation Model
    SIM_GTX_RESET_SPEEDUP   : integer    := 0;      -- Set to 1 to speed up sim reset
    SIM_PLL_PERDIV2         : bit_vector := x"0d0"; -- Set to the VCO Unit Interval time 
    LOCAL_LHC_BUNCH_COUNT   : integer    := LHC_BUNCH_COUNT);
  port(
    -- Link clk
    link_clk1x_in                : in   std_logic;
    link_clk2x_in                : in   std_logic;
    link_reset_in                : in   std_logic;
    -- GTP PLL clks
    txoutclk_out                 : out   std_logic;
    plllkdet_out                 : out   std_logic;
    -- Register interface
    ro_regs_ch0                  : out type_vector_of_stdlogicvec_x32(7 downto 0);
    ro_regs_ch1                  : out type_vector_of_stdlogicvec_x32(7 downto 0);
    rw_regs_ch0                  : in type_vector_of_stdlogicvec_x32(7 downto 0);
    rw_regs_ch1                  : in type_vector_of_stdlogicvec_x32(7 downto 0);
    rw_regs_default_ch0          : out type_vector_of_stdlogicvec_x32(7 downto 0);
    rw_regs_default_ch1          : out type_vector_of_stdlogicvec_x32(7 downto 0);
    -- Access to Pattern Inject/Capture RAM
    ram_stb_ch0                  : in std_logic;
    ram_stb_ch1                  : in std_logic;
    ram_wen_ch0                  : in std_logic;
    ram_wen_ch1                  : in std_logic;
    ram_add_ch0                  : in std_logic_vector(9 downto 0);
    ram_add_ch1                  : in std_logic_vector(9 downto 0);
    ram_wdata_ch0                : in std_logic_vector(31 downto 0);
    ram_wdata_ch1                : in std_logic_vector(31 downto 0);
    ram_ack_ch0                  : out std_logic;
    ram_ack_ch1                  : out std_logic;
    ram_rdata_ch0                : out std_logic_vector(31 downto 0);
    ram_rdata_ch1                : out std_logic_vector(31 downto 0);
    -- Pattern Inject/Capture control
    ttc_cntrl_in                 : in std_logic_vector(1 downto 0);
    ttc_time_in                   : in std_logic_vector(8 downto 0);
    -- Dynamic Reconfiguration Port (DRP)
    drp_addr_in                  : in std_logic_vector(6 downto 0);   
    drp_clk_in                   : in std_logic;                      
    drp_en_in                    : in std_logic;                      
    drp_data_in                  : in std_logic_vector(15 downto 0);  
    drp_data_out                 : out std_logic_vector(15 downto 0); 
    drp_rdy_out                  : out std_ulogic;                    
    drp_we_in                    : in std_logic;                      
    -- Sync channels together 
    sync_master_in               : in std_logic;
    sync_slave_ch0_out           : out std_logic;
    sync_slave_ch1_out           : out std_logic;
    -- Rx parallel data out
    rx_data_ch0_out              : out std_logic_vector(31 downto 0);
    rx_data_ch1_out              : out std_logic_vector(31 downto 0);
    rx_data_valid_ch0_out        : out std_logic;
    rx_data_valid_ch1_out        : out std_logic;
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

  -- Comm bus moved into local clk domain
  signal comm_cntrl_slv:                     type_comm_cntrl;
  signal comm_reply_slv:                     type_comm_reply;

  -- Individual communication link to regs
  signal comm_cntrl_reg_ch0:                     type_comm_cntrl;
  signal comm_reply_reg_ch0:                     type_comm_reply;
  signal comm_cntrl_reg_ch1:                     type_comm_cntrl;
  signal comm_reply_reg_ch1:                     type_comm_reply;

  -- Individual communication link to rams
  signal comm_cntrl_ram_ch0:                     type_comm_cntrl;
  signal comm_reply_ram_ch0:                     type_comm_reply;
  signal comm_cntrl_ram_ch1:                     type_comm_cntrl;
  signal comm_reply_ram_ch1:                     type_comm_reply;
  
  -- Individual communication link to dynamic reconfiguration port
  signal comm_cntrl_drp:                     type_comm_cntrl;
  signal comm_reply_drp:                     type_comm_reply;
  
  -- Individual communication link to regs
  signal ro_regs_ch0                              : type_vector_of_stdlogicvec_x32(7 downto 0);
  signal ro_regs_ch1                              : type_vector_of_stdlogicvec_x32(7 downto 0);
  signal rw_regs_ch0                              : type_vector_of_stdlogicvec_x32(7 downto 0);
  signal rw_regs_ch1                              : type_vector_of_stdlogicvec_x32(7 downto 0);
  signal rw_regs_default_ch0                      : type_vector_of_stdlogicvec_x32(7 downto 0);
  signal rw_regs_default_ch1                      : type_vector_of_stdlogicvec_x32(7 downto 0);
  
  signal link_reset_b:            std_logic;
    
  signal fabric_reset_b:          std_logic;

  signal comm_strobe :             std_logic;

begin

  fabric_reset_b <= not fabric_reset_in;
  link_reset_b <= not link_reset_in;
  
  --------------------------------------------------------------------------
  -- (1) Bridge comm bus from fabric clock to link clk
  --------------------------------------------------------------------------

  comm_clk_bridge_inst:  comm_clk_bridge
  generic map(
    delay => 1)
  port map(
    rst_master_in           => fabric_reset_in,
    clk_master_in           => fabric_clk1x_in,
    rst_slave_in            => link_reset_in,
    clk_slave_in            => link_clk1x_in,
    comm_cntrl_master_in    => comm_cntrl,
    comm_cntrl_slave_out    => comm_cntrl_slv,
    comm_reply_master_out   => comm_reply,
    comm_reply_slave_in     => comm_reply_slv);

  --------------------------------------------------------------------------
  -- (2) Fan out / fan in comm bus signals
  --------------------------------------------------------------------------
  
  -- Require 2x 0x800 of add space for RAMs
  -- Require 2x 0x200 for regs
  -- Require 1x 0x200 for DRP


  comm_strobe <= comm_cntrl_slv.stb when comm_enable = '1' else '0';

  -- Struggling to meet timing.  Clk everything.

  -- comm_bus_dist: process(comm_strobe, comm_cntrl_slv, comm_reply_reg_ch0, comm_reply_reg_ch1,
  --  comm_reply_ram_ch0, comm_reply_ram_ch1, comm_reply_drp)

  comm_bus_dist: process(link_clk1x_in)
  begin

    if (link_clk1x_in = '1' and link_clk1x_in'event) then

      -- By default send all cntrl signals 
      comm_cntrl_reg_ch0 <= comm_cntrl_slv;
      comm_cntrl_ram_ch0 <= comm_cntrl_slv;
      comm_cntrl_reg_ch1 <= comm_cntrl_slv;
      comm_cntrl_ram_ch1 <= comm_cntrl_slv;
      comm_cntrl_drp <= comm_cntrl_slv;
  
      -- By default disable strobe
      comm_cntrl_reg_ch0.stb <= '0';
      comm_cntrl_ram_ch0.stb <= '0';
      comm_cntrl_reg_ch1.stb <= '0';
      comm_cntrl_ram_ch1.stb <= '0';
      comm_cntrl_drp.stb <= '0';
  
      -- By default reply with nothing.
      comm_reply_slv <= COMM_REPLY_NULL;
  
      if comm_enable = '1' then
        -- Enable strobe depending on addr
        case comm_cntrl_slv.add(13 downto 12) is
        when "00" =>
          -- x0000 to x0FFF
          case comm_cntrl_slv.add(11 downto 9) is
          when "000" =>
            -- x0000 to x01FF
            comm_cntrl_reg_ch0.stb <= comm_strobe;
            comm_reply_slv <= comm_reply_reg_ch0;
          when "011" =>
            -- x0600 to x07FF
            comm_cntrl_drp.stb <= comm_strobe;
            comm_reply_slv <= comm_reply_drp;
          when others =>
            null;
          end case;
        when "01" =>
          -- Ch0-RAM: x1000 to x1FFF,
          comm_cntrl_ram_ch0.stb <= comm_strobe;
          comm_reply_slv <= comm_reply_ram_ch0;
        when "10" =>
          -- Ch1-Regs: x2000 to x2FFF
          case comm_cntrl_slv.add(11 downto 9) is
          when "000" =>
            -- Ch1-Regs (only use small part): x2000 to x21FF 
            comm_cntrl_reg_ch1.stb <= comm_strobe;
            comm_reply_slv <= comm_reply_reg_ch1;
          when others =>
            null;
          end case;
        when "11" =>
          -- Ch1-RAM: x3000 to x3FFF,
          comm_cntrl_ram_ch1.stb <= comm_strobe;
          comm_reply_slv <= comm_reply_ram_ch1;
        when others =>
          null;
        end case;
      else
        -- Read bus brought together with large OR
        -- Must send zeros if not addresed. 
        comm_reply_slv <= COMM_REPLY_NULL;
      end if;
    end if;

  end process;

  --------------------------------------------------------------------------
  -- Comm bus: Ch0
  --------------------------------------------------------------------------

  reg_ch0: reg_array_inout
  generic map(
    module                  => module_null, -- Internal addres space check unused.
    module_active           => '0',         -- Disable internal add space matching
    number_of_rw_words      => 8,
    number_of_ro_words      => 8)
  port map( 
    rstb_in                 => link_reset_b,
    clk_in                  => link_clk1x_in,
    comm_cntrl              => comm_cntrl_reg_ch0,
    comm_reply              => comm_reply_reg_ch0,
    rw_default_array_in     => rw_regs_default_ch0,
    rw_data_array_out       => rw_regs_ch0,
    ro_data_array_in        => ro_regs_ch0);

  -- Ne err
  comm_reply_ram_ch0.err <= '0';

  --------------------------------------------------------------------------
  -- Comm bus: Ch1
  --------------------------------------------------------------------------

  reg_ch1: reg_array_inout
  generic map(
    module                  => module_null, -- Internal addres space check unused.
    module_active           => '0',         -- Disable internal add space matching
    number_of_rw_words      => 8,
    number_of_ro_words      => 8)
  port map( 
    rstb_in                 => link_reset_b,
    clk_in                  => link_clk1x_in,
    comm_cntrl              => comm_cntrl_reg_ch1,
    comm_reply              => comm_reply_reg_ch1,
    rw_default_array_in     => rw_regs_default_ch1,
    rw_data_array_out       => rw_regs_ch1,
    ro_data_array_in        => ro_regs_ch1);

  comm_reply_ram_ch1.err <= '0';

 --------------------------------------------------------------------------
   -- Map CommCntrl bus to Giga Bit Transceiver interface
   --------------------------------------------------------------------------

   -- How will XST handle this by using inverting inputs to flipflops?
   -- link_clk1x_phase180 <= not link_clk1x_in;

   -- Unused. 16bit data
   comm_reply_drp.rdata(31 downto 16) <= (others => '0');
   comm_reply_drp.err <= '0';

   --------------------------------------------------------------------------
   -- Giga Bit Transceiver
   --------------------------------------------------------------------------

   minit_gtx_inst : minit_gtx
   generic map(
      sim_mode                  => sim_mode,
      sim_gtx_reset_speedup     => sim_gtx_reset_speedup,
      sim_pll_perdiv2           => sim_pll_perdiv2,
      local_lhc_bunch_count     => local_lhc_bunch_count)
   port map(
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
      ram_stb_ch0               => comm_cntrl_ram_ch0.stb,
      ram_stb_ch1               => comm_cntrl_ram_ch1.stb,
      ram_wen_ch0               => comm_cntrl_ram_ch0.wen,
      ram_wen_ch1               => comm_cntrl_ram_ch1.wen,
      ram_add_ch0               => comm_cntrl_ram_ch0.add(9 downto 0),   --add(11 downto 2),
      ram_add_ch1               => comm_cntrl_ram_ch1.add(9 downto 0),   --add(11 downto 2),
      ram_wdata_ch0             => comm_cntrl_ram_ch0.wdata,
      ram_wdata_ch1             => comm_cntrl_ram_ch1.wdata,
      ram_ack_ch0               => comm_reply_ram_ch0.ack,
      ram_ack_ch1               => comm_reply_ram_ch1.ack,
      ram_rdata_ch0             => comm_reply_ram_ch0.rdata,
      ram_rdata_ch1             => comm_reply_ram_ch1.rdata,
      ttc_cntrl_in              => ttc_cntrl_in,
      ttc_time_in               => ttc_time_in,
      drp_addr_in               => comm_cntrl_drp.add(8 downto 2),
      drp_clk_in                => link_clk1x_in,
      drp_en_in                 => comm_cntrl_drp.stb,
      drp_data_in               => comm_cntrl_drp.wdata(15 downto 0),
      drp_data_out              => comm_reply_drp.rdata(15 downto 0),
      drp_rdy_out               => comm_reply_drp.ack,
      drp_we_in                 => comm_cntrl_drp.wen,
      sync_master_in            => sync_master_in,
      sync_slave_ch0_out        => sync_slave_ch0_out,
      sync_slave_ch1_out        => sync_slave_ch1_out,
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
      refclk_out                => refclk_out,
      tx_data_ch0_in            => tx_data_ch0_in,
      tx_data_ch1_in            => tx_data_ch1_in,
      tx_data_valid_ch0_in      => tx_data_valid_ch0_in,
      tx_data_valid_ch1_in      => tx_data_valid_ch1_in,
      txn_ch0_out               => txn_ch0_out,
      txn_ch1_out               => txn_ch1_out,
      txp_ch0_out               => txp_ch0_out,
      txp_ch1_out               => txp_ch1_out);
      
end behave;