library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

library work;
use work.package_types.all;
use work.package_comm.all;
use work.package_modules.all;
use work.package_i2c.all;
use work.package_txt_util.all;

entity tb_core_sys_tmux is
--generic(
--    gtx_min          : natural := 0;
--    gtx_max          : natural := 11);
end tb_core_sys_tmux;

architecture behave of tb_core_sys_tmux is

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
    debug_out        : out std_logic_vector(7 downto 0); 
    test_out         : out std_logic_vector(31 downto 0));
  end component;
  
  constant gtx_min          : natural := 0;
  constant gtx_max          : natural := 11;
  
  signal clk           : std_logic := '0';
  signal rst           : std_logic := '1';
  signal rstb          : std_logic := '0';
  
  signal gtx_clk : std_logic := '0';
  signal gtx_clk_p, gtx_clk_n : std_logic_vector(gtx_max downto gtx_min);
  signal tx_ch0_p, tx_ch0_n : std_logic_vector(gtx_max downto gtx_min);
  signal tx_ch1_p, tx_ch1_n : std_logic_vector(gtx_max downto gtx_min);
  signal rx_ch0_p, rx_ch0_n : std_logic_vector(gtx_max downto gtx_min);
  signal rx_ch1_p, rx_ch1_n : std_logic_vector(gtx_max downto gtx_min);
  
  signal pbus_addr     : std_logic_vector(31 downto 0) := (others => '0');
  signal pbus_wdata    : std_logic_vector(31 downto 0) := (others => '0');
  signal pbus_strobe   : std_logic := '0';
  signal pbus_write    : std_logic := '0';
  signal pbus_rdata    : std_logic_vector(31 downto 0) := (others => '0');
  signal pbus_ack      : std_logic := '0';
  signal pbus_ber      : std_logic := '0';
  
  signal si5326_cntrl  : std_logic_vector(4 downto 0);
  signal ppod_tx0_cntrl  : std_logic_vector(6 downto 0);
  signal ppod_rx0_cntrl  : std_logic_vector(6 downto 0);
  signal ppod_rx2_cntrl  : std_logic_vector(6 downto 0);

begin

  ppod_tx0_cntrl <= (others => 'Z');
  ppod_rx0_cntrl <= (others => 'Z');
  ppod_rx2_cntrl <= (others => 'Z');

  -- 125MHz clock
  clk <= not clk after 4 ns;
  rstb <= not rst;

  -- 240MHz Link clk (used for trigger links)
  gtx_clk <= not gtx_clk after 4.2 ns; --2.1 ns;

  gtx_loop: for i in gtx_min to gtx_max generate 
    gtx_clk_p(i) <= gtx_clk;  
    gtx_clk_n(i) <= not gtx_clk;
  end generate;

  core_sys_tmux_r1_inst: core_sys_tmux_r1
  generic map(
    firmware                => x"DEADBEEF",
    slave                   => x"01234567",
    i2c_clk_speed           => 1000000,
    gtx_min                 => gtx_min,
    gtx_max                 => gtx_max,
    gtx_clk                 => 0,
    local_lhc_bunch_count   => 200,             -- Use 200 for sim else lhc_bunch_count
    sim_mode                => "FAST",          -- Set to Fast Functional Simulation Model
    sim_gtx_reset_speedup   => 1,               -- Set to 1 to speed up sim reset
    sim_pll_perdiv2         => x"0d0")          -- Set to the VCO Unit Interval time);
  port map(
    fabric_reset_in         => rst, 
    fabric_clk1x_in         => clk,
    link_clk1x_in           => gtx_clk,
    link_reset_in           => rst,
    -- Parallel bus
    pbus_addr_in            => pbus_addr,
    pbus_wdata_in           => pbus_wdata,
    pbus_strobe_in          => pbus_strobe,
    pbus_write_in           => pbus_write,
    pbus_rdata_out          => pbus_rdata,
    pbus_ack_out            => pbus_ack, 
    pbus_berr_out           => open,
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
    -- Clock synthesis control
    si5326_cntrl            => si5326_cntrl,
    ppod_tx0_cntrl          => ppod_tx0_cntrl,
    ppod_rx0_cntrl          => ppod_rx0_cntrl,
    ppod_rx2_cntrl          => ppod_rx2_cntrl,
    test_out                => open);

  --rx_ch1_p <= tx_ch1_p;
  --rx_ch1_n <= tx_ch1_n;

  --rx_ch0_p <= transport tx_ch0_p after 30 ns;
  --rx_ch0_n <= transport tx_ch0_n after 30 ns;

  rx_ch1_p <= transport tx_ch1_p after 30 ns;
  rx_ch1_n <= transport tx_ch1_n after 30 ns;

  rx_ch0_p <= tx_ch0_p;
  rx_ch0_n <= tx_ch0_n;

  -- si5326_cntrl(0) is driven by fpga (rst_b)
  si5326_cntrl(1) <= '0';  -- int_c1b
  si5326_cntrl(2) <= '0';  -- lol
  si5326_cntrl(3) <= 'H';  -- i2c scl
  si5326_cntrl(4) <= 'H';  -- i2c sda

  -- Clk frequency synthesis block
  i2c_slave_top_inst: i2c_slave_top
  port map( 
    clk       => clk,
    reset_b   => rstb,
    slave_add => "1101000",
    scl       => si5326_cntrl(3),
    sda       => si5326_cntrl(4));

  sim: process

    -- Variables used in procedures write_a32d32 & read_a32d32
    -- Could be inside procedures, however more difficult to
    -- view in simulator.  If inside procedure then variables only 
    -- visible after procedure called and variables created for each 
    -- procedure call.

    constant u32allone : unsigned(31 downto 0) := x"FFFFFFFF";
    variable addr : std_logic_vector(31 downto 0) := x"00000000";
    variable masklow : std_logic_vector(31 downto 0) := x"00000000";
    variable maskhigh : std_logic_vector(31 downto 0) := x"00000000";
    variable mask : std_logic_vector(31 downto 0) := x"00000000";
    variable wdata : std_logic_vector(31 downto 0) := x"00000000";
    variable rdata : std_logic_vector(31 downto 0) := x"00000000";

    -- Problem.  Int'High = x7FFF. Hence cannot have positive values for 32 bit nums.
    variable rdata_int : integer := 0;

    variable timeout_ack: natural := 30;
    variable timeout_rdy: natural := 30;

    -- I2C Transaction buffer
    variable i2c_r_nw :  std_logic := '1';
    variable i2c_add :  std_logic_vector(6 downto 0) := "0000000"; 
    variable i2c_addr_ndata :  std_logic := '0'; 
    variable i2c_ack_check :  std_logic := '0'; 
    variable i2c_ack_inv : std_logic := '0';
    variable i2c_data_w :  std_logic_vector(7 downto 0) := "11000011";
    variable i2c_stop :  std_logic := '1';

    -- I2C Status
    variable i2c_data_r :  std_logic_vector(7 downto 0) := "00000000";
    variable i2c_mid_trans :  std_logic := '0';
    variable i2c_idle :  std_logic := '0';
    variable i2c_start_data :  std_logic := '0';
    variable i2c_start_add :  std_logic := '0';
    variable i2c_ack_failed :  std_logic := '0';
    variable i2c_error_bus_not_free :  std_logic := '0';
    variable i2c_transaction_active :  std_logic := '0';
    variable i2c_transaction_enable :  std_logic := '0';

    variable daq_event_length: natural range 0 to 65535;
    variable daq_event: boolean;

    constant gtx: natural range 0 to 15 := 6;
    constant gtx_space: std_logic_vector(31 downto 0) := x"00004000";
    
    variable gtx_offset: std_logic_vector(31 downto 0);
    variable module_gtx_ch0_reg, module_gtx_ch1_reg: type_mod_define;
    variable module_gtx_ch0_ram, module_gtx_ch1_ram: type_mod_define;

    --------------------------------------------------------------------------------------------
    -- Procedures that would mimic function bus calls in C++
    --------------------------------------------------------------------------------------------

    procedure pbus_wait_for_ack(clks_to_wait: in natural) is 
      variable continue: boolean := true;
      variable timer: natural;
    begin
        continue := true;
        timer := clks_to_wait;        
        while continue loop
          wait until (clk'event and clk = '1');    
            if pbus_ack = '1' then
              continue := false;
              rdata := pbus_rdata;
              pbus_strobe <= '0';
            else 
              timer := timer - 1;
              if timer = 0 then
                report "Failed to get acknowledge from pbus.  Aborting" severity failure;
              end if;
            end if;
        end loop;
    end pbus_wait_for_ack;

    procedure pbus_wait_till_rdy(clks_to_wait: in natural) is 
      variable continue: boolean := true;
      variable timer: natural;
    begin
        continue := true;
        timer := clks_to_wait;        
        while continue loop
          wait until (clk'event and clk = '1');    
            if pbus_ack = '0' then
              continue := false;
            else 
              timer := timer - 1;
              if timer = 0 then
                report "Bus not free.  Aborting" severity failure;
              end if;
            end if;
        end loop;
    end pbus_wait_till_rdy;

    procedure pbus_reg_write(module: in type_mod_define; reg: in std_logic_vector(31 downto 0); 
        high_bit: in natural; low_bit: in natural; data: unsigned(31 downto 0); verify: in boolean)is
    begin
      -- Following includes at least one "wait" so signals are assigned.
      pbus_wait_till_rdy(timeout_rdy);
        -- Build address to access
        addr := module.addr_base + reg;
        pbus_addr <= addr;
        pbus_wdata <= x"00000000";
        pbus_strobe <= '1';
        pbus_write <= '0';
      -- Following includes at least one "wait" so signals are assigned.
      pbus_wait_for_ack(timeout_ack);
        -- Build mask
        masklow :=  std_logic_vector(SHIFT_LEFT(u32allone, low_bit));
        maskhigh := std_logic_vector(SHIFT_RIGHT(u32allone, 31 - high_bit));
        mask := maskhigh and masklow;
        -- Bitshift data into correct part of reg.
        wdata := std_logic_vector(SHIFT_LEFT(unsigned(data), low_bit)) and mask;
        -- Add parts of reg that shouldn't be changed.
        rdata := rdata and (not mask);
      -- Following includes at least one "wait" so signals are assigned.
      pbus_wait_till_rdy(timeout_rdy);
        -- Place on bus
        pbus_addr <= addr;
        pbus_wdata <= wdata or rdata;
        pbus_strobe <= '1';
        pbus_write <= '1';
      -- Following includes at least one "wait" so signals are assigned.
      pbus_wait_for_ack(timeout_ack);
        if verify = TRUE then
          -- Following includes at least one "wait" so signals are assigned.
          pbus_wait_till_rdy(timeout_rdy);
          pbus_addr <= addr;
          pbus_wdata <= x"00000000";
          pbus_strobe <= '1';
          pbus_write <= '0';
          -- Following includes at least one "wait" so signals are assigned.
          pbus_wait_for_ack(timeout_ack);
          assert (wdata and mask) = (rdata and mask) report "Write verify failed" severity failure;
        end if;

    end pbus_reg_write;


    procedure pbus_reg_read(module: in type_mod_define; reg: in std_logic_vector(31 downto 0); 
        high_bit: in natural; low_bit: in natural)is
    begin
      -- Following includes at least one "wait" so signals are assigned.
      pbus_wait_till_rdy(timeout_rdy);
        -- Build address to access
        addr := module.addr_base + reg;
        pbus_addr <= addr;
        pbus_wdata <= x"00000000";
        pbus_strobe <= '1';
        pbus_write <= '0';
      -- Following includes at least one "wait" so signals are assigned.
      pbus_wait_for_ack(timeout_ack);
        -- Build mask
        masklow :=  std_logic_vector(SHIFT_LEFT(u32allone, low_bit));
        maskhigh := std_logic_vector(SHIFT_RIGHT(u32allone, 31 - high_bit));
        mask := maskhigh and masklow;
        rdata := rdata and mask;
        rdata := std_logic_vector(SHIFT_RIGHT(unsigned(rdata), low_bit));
        -- Forced to have signed output because range of int x8000 to x7FFF (two's complement)
        rdata_int := TO_INTEGER(signed(rdata));
        -- report "Data read back (integer) = " & str(rdata_int) severity note;
    end pbus_reg_read;

    --------------------------------------------------------------------------------------------
    -- Procedures that would mimic i2c function calls in C++
    --------------------------------------------------------------------------------------------


    procedure i2c_wait_until_finished is
    --  Note i2c acknowledge should only be checked on i2c address/data transmission (i.e not read!)
    begin
      report "Waiting for I2C transaction to finish";
      pbus_reg_read(module_si5326_i2c, x"0000000C", 31, 0);
      i2c_data_r :=  rdata(7 downto 0);
      i2c_mid_trans :=  rdata(8);
      i2c_idle :=  rdata(9);
      i2c_start_data :=  rdata(10);
      i2c_start_add :=  rdata(11);
      i2c_ack_failed :=  rdata(12);
      i2c_error_bus_not_free :=  rdata(13);
      i2c_transaction_active :=  rdata(14);
      i2c_transaction_enable :=  rdata(15);
      assert i2c_error_bus_not_free = '0'
      report "User should wait for I2C bus to be free before attemting another slave address/write/read"
      severity failure;
      while (i2c_transaction_active = '1') loop
        -- while ((i2c_idle = '0') and (i2c_mid_trans = '0')) or (i2c_start_add = '1') or (i2c_start_data = '1') loop
        pbus_reg_read(module_si5326_i2c, x"0000000C", 31, 0);
        i2c_data_r :=  rdata(7 downto 0);
        i2c_mid_trans :=  rdata(8);
        i2c_idle :=  rdata(9);
        i2c_start_data :=  rdata(10);
        i2c_start_add :=  rdata(11);
        i2c_ack_failed :=  rdata(12);
        i2c_error_bus_not_free :=  rdata(13);
        i2c_transaction_active :=  rdata(14);
        i2c_transaction_enable :=  rdata(15);
        assert i2c_error_bus_not_free = '0'
        report "User should wait for I2C bus to be free before attemting another slave address/write/read"
        severity failure;
      end loop;
      assert i2c_ack_failed = '0'
      report "No acknowledge from I2C slave."
      severity failure;
      -- Following wait not needed, but added so that i2c transactions are
      -- separated, making the wave window esier to understand.
      wait for 10 us;
    end i2c_wait_until_finished;

    procedure i2c_write(add: in std_logic_vector(6 downto 0); data_w: in std_logic_vector(7 downto 0)) is
      variable wdata_local : unsigned(31 downto 0);
    begin
      report "Resets ptr to transaction buffer";
      pbus_reg_write(module_si5326_i2c, x"00000000", 31, 0, x"00000000", false);
      report "Writing slave address for I2C WRITE";
      i2c_r_nw := '0';
      i2c_add := add;
      i2c_stop := '0';
      i2c_addr_ndata := '1';
      i2c_ack_check := '1';
      i2c_ack_inv := '0';
      wdata_local := x"00000" & i2c_ack_inv & i2c_ack_check & i2c_addr_ndata & i2c_stop & unsigned(i2c_add) & i2c_r_nw;
      pbus_reg_write(module_si5326_i2c, x"00000004", 31, 0, wdata_local, false);
      report "Writing data for i2c WRITE";
      i2c_data_w := data_w;
      i2c_stop := '1';
      i2c_addr_ndata := '0';
      i2c_ack_check := '1';
      i2c_ack_inv := '0';
      wdata_local := x"00000" & i2c_ack_inv & i2c_ack_check & i2c_addr_ndata & i2c_stop & unsigned(i2c_add) & i2c_r_nw;
      pbus_reg_write(module_si5326_i2c, x"00000004", 31, 0, wdata_local, false);
      report "Init transaction";
      pbus_reg_write(module_si5326_i2c, x"00000008", 31, 0, x"00000000", false);
      report "Wait for I2C to finish";
      i2c_wait_until_finished;
    end i2c_write;


    procedure i2c_read(add: in std_logic_vector(6 downto 0)) is
      variable wdata_local : unsigned(31 downto 0);
    begin
      report "Resets ptr to transaction buffer";
      pbus_reg_write(module_si5326_i2c, x"00000000", 31, 0, x"00000000", false);
      report "Writing slave address for I2C READ";
      i2c_r_nw := '1';
      i2c_add := add;
      i2c_stop := '0';
      i2c_addr_ndata := '1';
      i2c_ack_check := '1';
      i2c_ack_inv := '0';
      wdata_local := x"00000" & i2c_ack_inv & i2c_ack_check & i2c_addr_ndata & i2c_stop & unsigned(i2c_add) & i2c_r_nw;
      pbus_reg_write(module_si5326_i2c, x"00000004", 31, 0, wdata_local, false);
      report "Writing transaction info for 1st I2C READ";
      i2c_data_w := x"00";  -- (i.e. we don't care);
      i2c_stop := '0';
      i2c_addr_ndata := '0';
      i2c_ack_check := '0';
      i2c_ack_inv := '0';
      wdata_local := x"00000" & i2c_ack_inv & i2c_ack_check & i2c_addr_ndata & i2c_stop & unsigned(i2c_add) & i2c_r_nw;
      pbus_reg_write(module_si5326_i2c, x"00000004", 31, 0, wdata_local, false);
      report "Writing transaction info for 2nd I2C READ";
      i2c_data_w := x"00";  -- (i.e. we don't care);
      i2c_stop := '1';
      i2c_addr_ndata := '0';
      i2c_ack_check := '0';
      i2c_ack_inv := '1';
      wdata_local := x"00000" & i2c_ack_inv & i2c_ack_check & i2c_addr_ndata & i2c_stop & unsigned(i2c_add) & i2c_r_nw;
      pbus_reg_write(module_si5326_i2c, x"00000004", 31, 0, wdata_local, false);
      report "Init transaction";
      pbus_reg_write(module_si5326_i2c, x"00000008", 31, 0, x"00000000", false);
      report "Wait for I2C to finish";
      i2c_wait_until_finished;
    end i2c_read;

    procedure i2c_test is 
    begin
      report "Test I2C:  Requires visual check in wave window";
      i2c_write("1101000", x"A5");
      i2c_read("1101000");   
    end i2c_test;

    procedure ram_test is 
    begin
      wait until clk'event and clk='1';
        report "GTX0Ch0: Set RAM mode to pattern capture";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020" + x"00000000", 26, 25, x"00000001", true);
      wait until clk'event and clk='1';
        report "TTC Control (Global Control): Enable pattern capture";
        pbus_reg_write(module_reg_array_out, x"0000000C", 1, 0, x"00000001", true);
      -- Pattern RAM is 512 deep.  At 125MHz RAM will fill in just over 4us.
      wait for 5 us;
      wait until clk'event and clk='1';
        report "TTC Control (Global Control): Disable pattern capture";
        pbus_reg_write(module_reg_array_out, x"0000000C", 1, 0, x"00000000", true);
      for i in 0 to 10 loop
        wait until clk'event and clk='1';
          report "GTX: Read back RAM";
          pbus_reg_read(  module_gtx_ch0_ram, std_logic_vector(to_unsigned(i*8,32)), 31, 0);
          report "GTX: RAM = " &  hstr(rdata);
      end loop;
    end ram_test;



    begin

      -- Must be a better way of multiplying x4000 by 6....
      gtx_offset := std_logic_vector(to_unsigned((gtx * to_integer(unsigned(gtx_space))),32));

      report "gtx_offset = " & hstr(gtx_offset);

      module_gtx_ch0_reg.addr_base := module_gtx.addr_base + gtx_offset + x"0000";
      module_gtx_ch0_reg.addr_end  := module_gtx.addr_base + gtx_offset + x"0000" + x"01FF";
      module_gtx_ch0_reg.addr_mask := x"000001FF";

      module_gtx_ch0_ram.addr_base := module_gtx.addr_base + gtx_offset + x"1000";
      module_gtx_ch0_ram.addr_end  := module_gtx.addr_base + gtx_offset + x"1000" + x"0FFF";
      module_gtx_ch0_ram.addr_mask := x"00000FFF";

      module_gtx_ch1_reg.addr_base := module_gtx.addr_base + gtx_offset + x"2000";
      module_gtx_ch1_reg.addr_end  := module_gtx.addr_base + gtx_offset + x"2000" + x"01FF";
      module_gtx_ch1_reg.addr_mask := x"000001FF";

      module_gtx_ch1_ram.addr_base := module_gtx.addr_base + gtx_offset + x"3000";
      module_gtx_ch1_ram.addr_end  := module_gtx.addr_base + gtx_offset + x"3000" + x"0FFF";
      module_gtx_ch1_ram.addr_mask := x"00000FFF";

      wait for 100 ns;
        rst <= '0';
      -- wait for 1 us;

      wait until clk'event and clk='1';
        report "Test reg access";
        pbus_reg_write(module_sys_info, x"00000004", 31, 0, x"DEADBEEF", true);

        report "Waiting 10us to come out of reset";
      wait for 10 us;

      --wait until clk'event and clk='1';
      --  i2c_test;

      wait until clk'event and clk='1';
        report "GTX: PowerOn Transceiver";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020" + x"0", 23, 20, x"00000008", true);
      wait until clk'event and clk='1';
        report "GTX: PowerOn Transceiver";
        pbus_reg_write(  module_gtx_ch1_reg, x"00000020" + x"0", 23, 20, x"00000008", true);
      wait until clk'event and clk='1';
        report "Waiting 1us after power up";
      wait for 1 us;
        report "GTX: Reset On";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020" + x"0", 19, 19, x"00000001", true);
      wait until clk'event and clk='1';
        report "GTX: Reset Off";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020" + x"0", 19, 19, x"00000000", true);

        report "Waiting 10us for links to come up";
      wait for 10 us;

      wait until clk'event and clk='1';
        report "GTX: Read CRC checked counter";
        pbus_reg_read(  module_gtx_ch0_reg, x"00000010", 31, 0);
        report "GTX: CRC checked counter = " &  str(rdata_int);
      wait until clk'event and clk='1';
        report "GTX: Read CRC error counter";
        pbus_reg_read(  module_gtx_ch0_reg, x"00000014", 31, 0);
        report "GTX: CRC error counter = " &  str(rdata_int);

      wait until clk'event and clk='1';
        report "GTX: Reset status.  Adding x20 to access W/R regs";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020", 15, 15, x"00000001", false);
      wait until clk'event and clk='1';
        report "GTX: Reset status.  Adding x20 to access W/R regs";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020", 15, 15, x"00000000", false);
      
      wait for 5 us;
      wait until clk'event and clk='1';
        report "GTX: Read CRC checked counter";
        pbus_reg_read(  module_gtx_ch0_reg, x"00000010", 31, 0);
        report "GTX: CRC checked counter = " &  str(rdata_int);
      wait until clk'event and clk='1';
        report "GTX: Read CRC error counter";
        pbus_reg_read(  module_gtx_ch0_reg, x"00000014", 31, 0);
        report "GTX: CRC error counter = " &  str(rdata_int);

      wait until clk'event and clk='1';
        report "Set SyncMaster delay to mid-value (16)";
        pbus_reg_write(module_reg_array_out, x"00000008", 4, 0, x"00000010", true);
      wait until clk'event and clk='1';
        report "Set SyncMasterEnable delay to one";
        pbus_reg_write(module_reg_array_out, x"00000008", 0, 0, x"00000001", true);

      wait until clk'event and clk='1';
        report "GTX: Enable SyncAuto on both chans";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020", 24, 24, x"00000001", false);
        pbus_reg_write(  module_gtx_ch1_reg, x"00000020", 24, 24, x"00000001", false);
      wait for 1 us;

      wait until clk'event and clk='1';
        pbus_reg_read(  module_gtx_ch1_reg, x"00000000", 0, 0);
        report "Gtx0Ch1: SyncDelayEnable (should be 1) = " &  str(rdata_int);
      wait until clk'event and clk='1';
        pbus_reg_read(  module_gtx_ch1_reg, x"00000000", 5, 1);
        report "Gtx0Ch1: SyncDelay (should be 4) = " &  str(rdata_int);

      wait until clk'event and clk='1';
        report "Set SyncMaster delay to opt-value (16-12-1=3)";
        pbus_reg_write(module_reg_array_out, x"00000008", 5, 1, x"00000003", true);
      wait until clk'event and clk='1';
        report "Set SyncMasterEnable delay to one";
        pbus_reg_write(module_reg_array_out, x"00000008", 0, 0, x"00000001", true);
      wait for 1 us;

      wait until clk'event and clk='1';
        pbus_reg_read(  module_gtx_ch1_reg, x"00000000", 6, 6);
        assert rdata_int=0 report "Gtx0Ch1: SyncError" severity failure;
      wait until clk'event and clk='1';
        pbus_reg_read(  module_gtx_ch1_reg, x"00000000", 0, 0);
        assert rdata_int=0 report "Gtx0Ch1: SyncDelayEnable should be 0" severity failure;
      wait until clk'event and clk='1';
        pbus_reg_read(  module_gtx_ch1_reg, x"00000000", 5, 1);
        assert rdata_int=0 report "Gtx0Ch1: SyncDelay should be 0" severity failure;


      wait until clk'event and clk='1';
        report "Trig: Set bx to trigger on (i.e. 64 decimal)";
        pbus_reg_write(module_control, x"00000000", 11, 0, x"00000040", true);
      wait until clk'event and clk='1';
        report "Trig: Set trig delay (i.e. 100 decimal)";
        pbus_reg_write(module_control, x"00000000", 23, 12, x"00000064", true);
      wait until clk'event and clk='1';
        report "Trig: Arm trigger";
        pbus_reg_write(module_control, x"00000000", 24, 24, x"00000001", false);
      wait for 1 us;

      daq_event := false;
      report "DAQ: Check to see if fifo containing event length is empty";
      while daq_event=false loop
        pbus_reg_read(module_daq, x"00000000", 16, 16);
        -- Check to see if daq output buf empty
        if rdata_int = 0 then
          daq_event:=true;
          report "DAQ: Event found, Increment EventLength fifo by write";
          pbus_reg_write(module_daq, x"00000000", 0, 0, x"00000000", false);
          pbus_reg_read(module_daq, x"00000000", 15, 0);
          daq_event_length := to_integer(unsigned(rdata(15 downto 0)));
          report "DAQ: EventLength = " & str(daq_event_length);
        else
          report "DAQ: No event";
        end if;
      end loop;
  
      daq_read_event: for idata in 0 to daq_event_length loop
        pbus_reg_read(module_daq, x"00000008", 31, 0);
        report "DAQ: EventData at index " & str(idata) & " = " &  hstr(rdata);
      end loop daq_read_event;



      wait until clk'event and clk='1';
        report "Sim finished" severity note;

      -- ram_test;

      --  wait until clk'event and clk='1';
      --  i2c_test;
      --  report "Sim finished" severity note;

      wait for 2 ms;

   end process;

end behave;