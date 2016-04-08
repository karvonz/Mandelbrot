
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.package_utilities.all;
use work.package_types.all;
--use work.ipbus_components.all;

--11021401  Reverted to osc (no SI5326 I2C support in redwood yet)
--11021402  Moved gtx_module base add from 0xA000 to 0xC0000
--11041550  Built Tmux

entity top_sys_r1 is
  generic (
    sim                   : boolean := false;
    board                 : std_logic_vector(31 downto 0):= x"00000001";
    firmware_version      : std_logic_vector(7 downto 0):= x"50"; 
    firmware_day          : std_logic_vector(7 downto 0):= x"15"; 
    firmware_month        : std_logic_vector(7 downto 0):= x"04"; 
    firmware_year         : std_logic_vector(7 downto 0):= x"11"; 
    gtx_min          	  : natural := 0;
    gtx_max          	  : natural := 11);
  port (
    -- Main clks and configuration
    clk1_p, clk1_n        : in  std_logic;
    clk2_p, clk2_n        : in  std_logic;
    osc1_p, osc1_n        : in  std_logic;
    osc2_p, osc2_n        : in  std_logic;
    -- Clk distribution
    clk_cntrl             : out  std_logic_vector (23 downto 0);
    -- Opto control
    ppod_tx0_cntrl      : inout std_logic_vector(6 downto 0);
    ppod_rx0_cntrl      : inout std_logic_vector(6 downto 0);
    ppod_rx2_cntrl      : inout std_logic_vector(6 downto 0);
    -- Clk synthesis
    si5326_cntrl          : inout std_logic_vector (4 downto 0);
    -- Required to instanstiate GTX to route refclk
    mgt116_rxn0         : in  std_logic;
    mgt116_rxp0         : in  std_logic;
    mgt116_rxn1         : in  std_logic;
    mgt116_rxp1         : in  std_logic;
    mgt116_txn0         : out  std_logic;
    mgt116_txp0         : out  std_logic;
    mgt116_txn1         : out  std_logic;
    mgt116_txp1         : out  std_logic;
    -- Required to instanstiate GTX to route refclk
    mgt112_rxn0         : in  std_logic;
    mgt112_rxp0         : in  std_logic;
    mgt112_rxn1         : in  std_logic;
    mgt112_rxp1         : in  std_logic;
    mgt112_txn0         : out  std_logic;
    mgt112_txp0         : out  std_logic;
    mgt112_txn1         : out  std_logic;
    mgt112_txp1         : out  std_logic;
    -- Ethernet Backplane/Fibre.  Check polarity and port in UCF/VHDL
    enet_clkp         : in  std_logic;
    enet_clkn         : in  std_logic;
    enet_txp          : out std_logic;
    enet_txn          : out std_logic;
    enet_rxp          : in  std_logic;
    enet_rxn          : in  std_logic;
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
    -- Misc
    cpld                  : in  std_logic_vector (9 downto 0);
    hdr_p                   : out  std_logic_vector(3 downto 0);
    hdr_n                   : out  std_logic_vector(3 downto 0);
    led                   : out  std_logic_vector (3 downto 0));
end top_sys_r1;

architecture behavioral of top_sys_r1 is

  signal clk1, clk2, osc1, osc2: std_logic;
  signal clk125, clk125_p, clk125_n: std_logic;
  signal clk125_refclk_after_gtx, hdr1_p, hdr1_n: std_logic;
  signal clk125_refclk_before_gtx, clk125_refclk_before_gtx_p, clk125_refclk_before_gtx_n: std_logic;
  signal rst_b, rst: std_logic;
  signal rst_powerup_b, rst_short: std_logic;
  signal link_clk1x, link_reset: std_logic;
  signal blink: std_logic;
  signal led_int: std_logic_vector(3 downto 0);

  signal pbus_strobe               : std_logic;
  signal pbus_wdata                : std_logic_vector(31 downto 0);
  signal pbus_addr                 : std_logic_vector(31 downto 0);
  signal pbus_rdata                : std_logic_vector(31 downto 0);
  signal pbus_ack                  : std_logic;
  signal pbus_write                : std_logic;
  signal pbus_berr                 : std_logic;

--   signal pbus_bp_strobe               : std_logic;
--   signal pbus_bp_wdata                : std_logic_vector(31 downto 0);
--   signal pbus_bp_addr                 : std_logic_vector(31 downto 0);
--   signal pbus_bp_rdata                : std_logic_vector(31 downto 0);
--   signal pbus_bp_ack                  : std_logic;
--   signal pbus_bp_write                : std_logic;
--   signal pbus_bp_berr                 : std_logic;

--   signal enet_clk : std_logic;

  signal test                : std_logic_vector(31 downto 0);
  signal debug                : std_logic_vector(7 downto 0);

  signal enet_ok,enet_gtx_rst    : std_logic; 
  signal enet_clk, enet_mac_rst: std_logic;

  constant firmware: std_logic_vector(31 downto 0):= firmware_year & firmware_month & firmware_day & firmware_version;

  -- GTX ref clks
  --signal refclkp       :   std_logic_vector(gtx_max downto gtx_min);
  --signal refclkn       :   std_logic_vector(gtx_max downto gtx_min);


  component main_pbus is
    port(
      rst_async                  : in std_logic;
      clk                        : in std_logic;
      pbus_write_in              : in std_logic;
      pbus_en_in                 : in std_logic;
      pbus_wdata_in              : in std_logic_vector(31 downto 0);
      pbus_add_in                : in std_logic_vector(31 downto 0);
      pbus_rdata_out             : out std_logic_vector(31 downto 0);
      pbus_ack_out               : out std_logic;
      led_out                    : out std_logic_vector(3 downto 0));
  end component;

  component enet_gtx_ch0_top is
  port(
    reset_in:         in std_logic;
    clk125_in:        in std_logic;
    clk125_out:       out std_logic;
    gtx_powerdownpll_in: in std_logic;
    gtx_powerdownclk_in: in std_logic;
    enet_tx_p_out:    out std_logic;
    enet_tx_n_out:    out std_logic;
    enet_rx_p_in:     in std_logic;
    enet_rx_n_in:     in std_logic;
    enet_clk_in:      in std_logic;
    enet_ok_out:      out std_logic;
    pbus_rdata_in:    in std_logic_vector(31 downto 0);
    pbus_wdata_out:   out std_logic_vector(31 downto 0);
    pbus_strobe_out:  out std_logic;
    pbus_write_out:   out std_logic;
    pbus_ack_in:      in std_logic;
    pbus_berr_in:     in std_logic;
    pbus_addr_out:    out std_logic_vector(31 downto 0);
    pbus_test_out:    out std_logic_vector(7 downto 0));
  end component;

  component enet_gtx_ch1_top is
  port(
    reset_in:         in std_logic;
    clk125_in:        in std_logic;
    clk125_out:       out std_logic;
    clk125_refclk_after_gtx:    out std_logic;
    clk125_refclk_before_gtx:    out std_logic;
    gtx_powerdownpll_in: in std_logic;
    gtx_powerdownclk_in: in std_logic;
    enet_tx_p_out:    out std_logic;
    enet_tx_n_out:    out std_logic;
    enet_rx_p_in:     in std_logic;
    enet_rx_n_in:     in std_logic;
    enet_clk_in:      in std_logic;
    enet_ok_out:      out std_logic;
    pbus_rdata_in:    in std_logic_vector(31 downto 0);
    pbus_wdata_out:   out std_logic_vector(31 downto 0);
    pbus_strobe_out:  out std_logic;
    pbus_write_out:   out std_logic;
    pbus_ack_in:      in std_logic;
    pbus_berr_in:     in std_logic;
    pbus_addr_out:    out std_logic_vector(31 downto 0);
    pbus_test_out:    out std_logic_vector(7 downto 0));
  end component;

  -- component core_sys_algo_r1 is
  component core_sys_tmux_r1 is
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
    debug_out	     : out std_logic_vector(7 downto 0);
    test_out         : out std_logic_vector(31 downto 0));
  end component;

  component minit_gtx_refclk_route_only is
  port (
    clkin_in    : in std_logic;
    rxn0_in     : in std_logic;
    rxn1_in     : in std_logic;
    rxp0_in     : in std_logic;
    rxp1_in     : in std_logic;
    txn0_out    : out std_logic;
    txn1_out    : out std_logic;
    txp0_out    : out std_logic;
    txp1_out    : out std_logic);
  end component;

begin

---------------------------------------------------------------------
-- Fibre IP Start
---------------------------------------------------------------------

  --Ethernet interface
  ipbus_fibre: enet_gtx_ch0_top
  port map (
    reset_in => enet_mac_rst,
    clk125_in => osc1,
    clk125_out => clk125,
    gtx_powerdownpll_in => enet_gtx_rst, 
    gtx_powerdownclk_in => enet_gtx_rst,
    enet_tx_p_out => enet_txp,
    enet_tx_n_out => enet_txn,
    enet_rx_p_in => enet_rxp,
    enet_rx_n_in => enet_rxn,
    enet_clk_in => enet_clk,
    enet_ok_out => enet_ok, 
    pbus_rdata_in => pbus_rdata,
    pbus_wdata_out => pbus_wdata,
    pbus_strobe_out => pbus_strobe,
    pbus_write_out => pbus_write,
    pbus_ack_in => pbus_ack,
    pbus_berr_in => pbus_berr,
    pbus_addr_out => pbus_addr,
    pbus_test_out => open);

---------------------------------------------------------------------
-- Fibre IP End
---------------------------------------------------------------------

  mgt116_ibufds: ibufds
  port map (
    i => enet_clkp,
    ib => enet_clkn,
    o => enet_clk);

---------------------------------------------------------------------
-- Backplane IP Start
---------------------------------------------------------------------

--   mgt116_gtx: minit_gtx_refclk_route_only
--   port map(
--     clkin_in => enet_clk,
--     rxn0_in => mgt116_rxn0,
--     rxn1_in => mgt116_rxn1,
--     rxp0_in => mgt116_rxp0,
--     rxp1_in => mgt116_rxp1,
--     txn0_out => mgt116_txn0,
--     txn1_out => mgt116_txn1,
--     txp0_out => mgt116_txp0,
--     txp1_out => mgt116_txp1);
-- 
--   mgt112_gtx: minit_gtx_refclk_route_only
--   port map(
--     clkin_in => enet_clk,
--     rxn0_in => mgt112_rxn0,
--     rxn1_in => mgt112_rxn1,
--     rxp0_in => mgt112_rxp0,
--     rxp1_in => mgt112_rxp1,
--     txn0_out => mgt112_txn0,
--     txn1_out => mgt112_txn1,
--     txp0_out => mgt112_txp0,
--     txp1_out => mgt112_txp1);
-- 
--   -- Ethernet interface
--   ipbus_backplane: enet_gtx_ch1_top
--   port map (
--     reset_in => enet_mac_rst,
--     clk125_in => osc1,
--     clk125_out => clk125,
--     gtx_powerdownpll_in => enet_gtx_rst, 
--     gtx_powerdownclk_in => enet_gtx_rst,
--     enet_tx_p_out => enet_txp,
--     enet_tx_n_out => enet_txn,
--     enet_rx_p_in => enet_rxp,
--     enet_rx_n_in => enet_rxn,
--     enet_clk_in => enet_clk,
--     enet_ok_out => enet_ok, 
--     pbus_rdata_in => pbus_rdata,
--     pbus_wdata_out => pbus_wdata,
--     pbus_strobe_out => pbus_strobe,
--     pbus_write_out => pbus_write,
--     pbus_ack_in => pbus_ack,
--     pbus_berr_in => pbus_berr,
--     pbus_addr_out => pbus_addr,
--     pbus_test_out => open);

---------------------------------------------------------------------
-- Backplane IP End
---------------------------------------------------------------------

--   bp_reg: process(enet_clk, rst)
--   begin
--     if rst = '1' then 
--       pbus_bp_rdata <= (others => '0');
--     elsif enet_clk = '1' and enet_clk'event then
--       pbus_bp_ack <= pbus_bp_strobe;
--       if pbus_bp_strobe = '1' and pbus_bp_write = '1' then
--         if  pbus_bp_addr = x"10000000" then
--           pbus_bp_rdata <=pbus_bp_wdata;
--         end if;
--       end if;
--     end if;
--   end process;
--   pbus_bp_berr <= '0';


  -- Core system seprated from control sys to make simulation easier
  -- Switched to clk1, 120MHz generate
  core_sys_inst: core_sys_tmux_r1
  generic map(
    firmware                => firmware,
    board                   => board,
    i2c_clk_speed           => 100000,
    gtx_min                 => gtx_min,
    gtx_max                 => gtx_max,
    gtx_clk                 => 4,               -- GTX_DUAL_X0Y6 (MGT115)
    local_lhc_bunch_count   => lhc_bunch_count,
    sim_mode                => "SLOW",          -- Set to Fast Functional Simulation Model
    sim_gtx_reset_speedup   => 0,               -- Set to 1 to speed up sim reset
    sim_pll_perdiv2         => x"0d0")          -- Set to the VCO Unit Interval time);
  port map(
    fabric_reset_in         => rst,
    fabric_clk1x_in         => clk125,
    link_reset_in           => link_reset,
    link_clk1x_in           => link_clk1x,
    -- Parallel bus
    pbus_addr_in            => pbus_addr,
    pbus_wdata_in           => pbus_wdata,
    pbus_strobe_in          => pbus_strobe,
    pbus_write_in           => pbus_write,
    pbus_rdata_out          => pbus_rdata,
    pbus_ack_out            => pbus_ack, 
    pbus_berr_out           => pbus_berr,
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
    ppod_tx0_cntrl          => ppod_tx0_cntrl,
    ppod_rx0_cntrl          => ppod_rx0_cntrl,
    ppod_rx2_cntrl          => ppod_rx2_cntrl,
    debug_out               => debug,
    test_out                => test);



  -- The following refers comments refer to the output 
  -- destination from the crosspoint switch

  --  For the refclks: clk_cntrl(0-15)
  --------------------------------------------------
  -- sx0  sx1  input chan
  --------------------------------------------------
  --  0    0     1: CLK1
  --  0    1     2: CLK2
  --  1    0     3: OSC1
  --  1    1     4: OSC2

  --  For the clk1 and clk2 select: clk_cntrl(16-23)
  --------------------------------------------------
  -- sx0  sx1  input chan
  --------------------------------------------------
  --  0    0     1: FCLKA   
  --  0    1     2: TCLKA
  --  1    0     3: TCLKC
  --  1    1     4: SI5326-CLK1

  -- For running with 125Mhz Osc1
  -- Don't forget to change "link_clk1x <= osc1;"
  clk_cntrl(0) <= '1';  -- refclk3: u15, port s10
  clk_cntrl(1) <= '0';  -- refclk3: u15, port s11
  clk_cntrl(2) <= '1';  -- refclk2: u15, port s20
  clk_cntrl(3) <= '0';  -- refclk2: u15, port s21
  clk_cntrl(4) <= '1';  -- refclk1: u15, port s30
  clk_cntrl(5) <= '0';  -- refclk1: u15, port s31
  clk_cntrl(6) <= '1';  -- refclk0: u15, port s40
  clk_cntrl(7) <= '0';  -- refclk0: u15, port s41
  clk_cntrl(8) <= '1';  -- refclk7: u20, port s10
  clk_cntrl(9) <= '0';  -- refclk7: u20, port s11
  clk_cntrl(10) <= '1';  -- refclk6: u20, port s20
  clk_cntrl(11) <= '0';  -- refclk6: u20, port s21
  clk_cntrl(12) <= '1';  -- refclk6: u20, port s30
  clk_cntrl(13) <= '0';  -- refclk6: u20, port s31
  clk_cntrl(14) <= '1';  -- refclk6: u20, port s40
  clk_cntrl(15) <= '0';  -- refclk6: u20, port s41

--   -- For running with 120Mhz Clk1
--   -- Requires SI5326 and NAT correctly programmed
--   -- Don't forget to change "link_clk1x <= clk1;"
--   clk_cntrl(0) <= '0';  -- refclk3: u15, port s10
--   clk_cntrl(1) <= '0';  -- refclk3: u15, port s11
--   clk_cntrl(2) <= '0';  -- refclk2: u15, port s20
--   clk_cntrl(3) <= '0';  -- refclk2: u15, port s21
--   clk_cntrl(4) <= '0';  -- refclk1: u15, port s30
--   clk_cntrl(5) <= '0';  -- refclk1: u15, port s31
--   clk_cntrl(6) <= '0';  -- refclk0: u15, port s40
--   clk_cntrl(7) <= '0';  -- refclk0: u15, port s41
--   clk_cntrl(8) <= '1';  -- refclk7: u20, port s10
--   clk_cntrl(9) <= '0';  -- refclk7: u20, port s11
--   clk_cntrl(10) <= '0';  -- refclk6: u20, port s20
--   clk_cntrl(11) <= '0';  -- refclk6: u20, port s21
--   clk_cntrl(12) <= '0';  -- refclk6: u20, port s30
--   clk_cntrl(13) <= '0';  -- refclk6: u20, port s31
--   clk_cntrl(14) <= '0';  -- refclk6: u20, port s40
--   clk_cntrl(15) <= '0';  -- refclk6: u20, port s41

  clk_cntrl(16) <= '1';  -- clk1 to bufs: u24, port s10
  clk_cntrl(17) <= '1';  -- clk1 to bufs: u24, port s11
  clk_cntrl(18) <= '0';  -- clk2 to bufs: u24, port s20
  clk_cntrl(19) <= '0';  -- clk2 to bufs: u24, port s21
  clk_cntrl(20) <= '0';  -- not used: u24, port s30
  clk_cntrl(21) <= '0';  -- not used: u24, port s31
  clk_cntrl(22) <= '0';  -- si5326 input: u24, port s40
  clk_cntrl(23) <= '1';  -- si5326 input: u24, port s41

  -- Reset generation
  reset_gen : component srl16
  port map (
    a0 => '1',
    a1 => '1',
    a2 => '1',
    a3 => '1',
    clk => osc1,
    d => '1',
    q => rst_powerup_b);

  rst_short <= not (rst_powerup_b); -- and cpld(0); 

  -- In Xilinx ethernet simulation reset is 15us.
  enet_gtx_rst_legthen : process(osc1)
    variable enet_rst_cnt : natural;
  begin
    if (osc1 = '1' and osc1'event) then
      if (rst_short = '1') then
        if sim = TRUE then
          enet_rst_cnt := 2000;    -- 16us
        else
          enet_rst_cnt := 20000;  -- 160us  
        end if;
        enet_gtx_rst <= '1';
      elsif (enet_rst_cnt > 0) then
        enet_rst_cnt := enet_rst_cnt - 1;
        enet_gtx_rst <= '1';
      else
        enet_gtx_rst <= '0';
      end if;
    end if;
  end process enet_gtx_rst_legthen;

  -- In Xilinx ethernet simulation reset is 15us.
  enet_mac_rst_legthen : process(osc1)
    variable enet_rst_cnt : natural;
  begin
    if (osc1 = '1' and osc1'event) then
      if (rst_short = '1') then
        if sim = TRUE then
          enet_rst_cnt := 4000;    -- 32us
        else
          enet_rst_cnt := 40000;  -- 320us
        end if;
        enet_mac_rst <= '1';
      elsif (enet_rst_cnt > 0) then
        enet_rst_cnt := enet_rst_cnt - 1;
        enet_mac_rst <= '1';
      else
        enet_mac_rst <= '0';
      end if;
    end if;
  end process enet_mac_rst_legthen;


  -- In Xilinx TEMAC simulation reset is 15us.
  rst_legthen : process(clk125, enet_ok, enet_gtx_rst)
    variable rst_cnt : natural;
    variable init: std_logic;
  begin
    if (enet_ok /= '1') or (enet_gtx_rst = '1') then
      rst <= '1';
      init := '1';
    elsif (clk125 = '1' and clk125'event) then
      if (init = '1') then
        init := '0';
        rst_cnt := 2500;   -- 20us
        rst <= '1';
      elsif (rst_cnt > 0) then
        rst_cnt := rst_cnt - 1;
        rst <= '1';
      else
        rst <= '0';
      end if;
    end if;
  end process rst_legthen;

  rst_b <= not rst;

  -- Setup clk and rst for links and algo
  -- link_clk1x <= clk1;
  link_clk1x <= osc1;
  -- Move rst into link domain 
  link_rst_proc : process(clk1)
    variable link_reset_int : std_logic;
  begin
    if (clk1 = '1' and clk1'event) then
      link_reset_int := rst;
      link_reset <= link_reset_int;
    end if;
  end process link_rst_proc;

  osc1_buf : component ibufgds
  generic map(
    diff_term => true,
    iostandard => "LVDS_25")
  port map(
    o  => osc1,
    i => osc1_p,
    ib => osc1_n);

  osc2_buf : component ibufgds
  generic map(
    diff_term => true,
    iostandard => "LVDS_25")
  port map(
    o  => osc2,
    i => osc2_p,
    ib => osc2_n);

  clk1_buf : component ibufgds
  generic map(
    diff_term => true,
    iostandard => "LVDS_25")
  port map(
    o  => clk1,
    i => clk1_p,
    ib => clk1_n);

  clk2_buf : component ibufgds
  generic map(
    diff_term => true,
    iostandard => "LVDS_25")
  port map(
    o  => clk2,
    i => clk2_p,
    ib => clk2_n);


  lengthen_led_pulses : for i in 3 to 3 generate
    leds_inst: pulse_lengthen
    generic map( 
        pulse_length => 4000000,
        pulse_init   => '1')
    port map( 
        clk         => osc1,
        reset_b     => rst_powerup_b,
        pulse_short => led_int(i),
        pulse_long  => led(i));
  end generate;  

  led_int(0) <= rst;
  led_int(1) <= enet_gtx_rst;
  led_int(2) <= test(3);
  led_int(3) <= blink;

  led(0) <= enet_gtx_rst;
  led(1) <= enet_mac_rst;
  led(2) <= rst;
  -- led(3) <= test(3);


  hdr_p(0) <= debug(0);
  hdr_n(0) <= debug(1);
  hdr_p(1) <= clk125_p;
  hdr_n(1) <= clk125_n;
  hdr_p(2) <= hdr1_p;
  hdr_n(2) <= hdr1_n;
  hdr_p(3) <= debug(6);
  hdr_n(3) <= debug(7); 

  clk125_lvds : component obufds
  generic map(
      IOSTANDARD => "LVDS_25")
  port map(
      I => clk125,
      O  => clk125_p,
      OB => clk125_n);

  clk125_refclk_after_gtx_lvds : component obufds
  generic map(
      IOSTANDARD => "LVDS_25")
  port map(
      I => clk1,
      O  => hdr1_p,
      OB => hdr1_n);

--   clk125_refclk_before_gtx_lvds : component obufds
--   generic map(
--       IOSTANDARD => "LVDS_25")
--   port map(
--       I => clk125_refclk_before_gtx,
--       O  => clk125_refclk_before_gtx_p,
--       OB => clk125_refclk_before_gtx_n);

  blink_inst: blinker
  generic map( 
    blink_period => 125000000)
  port map( 
    clk         => osc1,
    reset_b     => rst_powerup_b,
    blink_out   => blink);

end behavioral;

