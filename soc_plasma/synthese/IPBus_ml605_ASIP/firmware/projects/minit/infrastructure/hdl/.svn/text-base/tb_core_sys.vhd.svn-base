LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY std;
USE std.textio.ALL;

LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;
USE work.package_i2c.ALL;
USE work.package_txt_util.ALL;

ENTITY tb_core_sys IS
END tb_core_sys;

ARCHITECTURE behave OF tb_core_sys IS

  COMPONENT core_sys IS
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
      pbus_addr_in     : IN std_logic_vector(31 DOWNTO 0);
      pbus_wdata_in    : IN std_logic_vector(31 DOWNTO 0);
      pbus_strobe_in   : IN std_logic;
      pbus_write_in    : IN std_logic;
      pbus_rdata_out   : OUT std_logic_vector(31 DOWNTO 0);
      pbus_ack_out     : OUT std_logic;
      pbus_berr_out    : OUT std_logic;
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
      test_out         : OUT std_logic_vector(31 DOWNTO 0));
  END COMPONENT;

  CONSTANT gtx_min          : natural := 0;
  CONSTANT gtx_max          : natural := 11;

  SIGNAL clk           : std_logic := '0';
  SIGNAL rst           : std_logic := '1';
  SIGNAL rstb          : std_logic := '0';
  
  SIGNAL gtx_clk : std_logic := '0';
  SIGNAL gtx_clk_p, gtx_clk_n : std_logic_vector(gtx_max DOWNTO gtx_min);
  SIGNAL tx_ch0_p, tx_ch0_n : std_logic_vector(gtx_max DOWNTO gtx_min);
  SIGNAL tx_ch1_p, tx_ch1_n : std_logic_vector(gtx_max DOWNTO gtx_min);
  SIGNAL rx_ch0_p, rx_ch0_n : std_logic_vector(gtx_max DOWNTO gtx_min);
  SIGNAL rx_ch1_p, rx_ch1_n : std_logic_vector(gtx_max DOWNTO gtx_min);
  
  SIGNAL pbus_addr     : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL pbus_wdata    : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL pbus_strobe   : std_logic := '0';
  SIGNAL pbus_write    : std_logic := '0';
  SIGNAL pbus_rdata    : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL pbus_ack      : std_logic := '0';
  SIGNAL pbus_ber      : std_logic := '0';
  
  SIGNAL si5326_cntrl  : std_logic_vector(4 DOWNTO 0);
  SIGNAL snap12_tx0_cntrl  : std_logic_vector(5 DOWNTO 0);
  SIGNAL snap12_rx0_cntrl  : std_logic_vector(5 DOWNTO 0);
  SIGNAL snap12_rx2_cntrl  : std_logic_vector(5 DOWNTO 0);

begin

  snap12_tx0_cntrl <= (OTHERS => 'Z');
  snap12_rx0_cntrl <= (OTHERS => 'Z');
  snap12_rx2_cntrl <= (OTHERS => 'Z');

  -- 125MHz clock
  clk <= NOT clk AFTER 4 ns;
  rstb <= NOT rst;

  -- 240MHz Link clk (used FOR trigger links)
  gtx_clk <= NOT gtx_clk AFTER 4.2 ns; --2.1 ns;

  gtx_loop: FOR i IN gtx_min TO gtx_max GENERATE 
    gtx_clk_p(i) <= gtx_clk;  
    gtx_clk_n(i) <= NOT gtx_clk;
  END GENERATE;

  core_sys_inst: core_sys
  GENERIC MAP(
    firmware                => x"DEADBEEF",
    slave                   => x"01234567",
    i2c_clk_speed           => 1000000,
    gtx_min                 => gtx_min,
    gtx_max                 => gtx_max,
    gtx_clk                 => 0,
    local_lhc_bunch_count   => 200,             -- USE 200 FOR sim ELSE lhc_bunch_count
    sim_mode                => "FAST",          -- Set TO Fast Functional Simulation Model
    sim_gtx_reset_speedup   => 1,               -- Set TO 1 TO speed up sim reset
    sim_pll_perdiv2         => x"0d0")          -- Set TO the VCO Unit Interval time);
  PORT MAP(
    fabric_reset_in         => rst, 
    fabric_clk1x_in         => clk,
    link_clk1x_in           => gtx_clk,
    link_reset_in           => rst,
    -- Parallel BUS
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
    snap12_tx0_cntrl        => snap12_tx0_cntrl,
    snap12_rx0_cntrl        => snap12_rx0_cntrl,
    snap12_rx2_cntrl        => snap12_rx2_cntrl,
    test_out                => OPEN);

  --rx_ch1_p <= tx_ch1_p;
  --rx_ch1_n <= tx_ch1_n;

  --rx_ch0_p <= TRANSPORT tx_ch0_p AFTER 30 ns;
  --rx_ch0_n <= TRANSPORT tx_ch0_n AFTER 30 ns;

  rx_ch1_p <= TRANSPORT tx_ch1_p AFTER 30 ns;
  rx_ch1_n <= TRANSPORT tx_ch1_n AFTER 30 ns;

  rx_ch0_p <= tx_ch0_p;
  rx_ch0_n <= tx_ch0_n;

  -- si5326_cntrl(0) is driven by fpga (rst_b)
  si5326_cntrl(1) <= '0';  -- int_c1b
  si5326_cntrl(2) <= '0';  -- lol
  si5326_cntrl(3) <= 'H';  -- i2c scl
  si5326_cntrl(4) <= 'H';  -- i2c sda

  -- Clk frequency synthesis BLOCK
  i2c_slave_top_inst: i2c_slave_top
  PORT MAP( 
    clk       => clk,
    reset_b   => rstb,
    slave_add => "1101000",
    scl       => si5326_cntrl(3),
    sda       => si5326_cntrl(4));

  sim: PROCESS

    -- Variables used IN procedures write_a32d32 & read_a32d32
    -- Could be inside procedures, however more difficult TO
    -- view IN simulator.  IF inside PROCEDURE THEN variables only 
    -- visible AFTER PROCEDURE called AND variables created FOR each 
    -- PROCEDURE call.

    CONSTANT u32allone : unsigned(31 DOWNTO 0) := x"FFFFFFFF";
    VARIABLE addr : std_logic_vector(31 DOWNTO 0) := x"00000000";
    VARIABLE masklow : std_logic_vector(31 DOWNTO 0) := x"00000000";
    VARIABLE maskhigh : std_logic_vector(31 DOWNTO 0) := x"00000000";
    VARIABLE mask : std_logic_vector(31 DOWNTO 0) := x"00000000";
    VARIABLE wdata : std_logic_vector(31 DOWNTO 0) := x"00000000";
    VARIABLE rdata : std_logic_vector(31 DOWNTO 0) := x"00000000";

    -- Problem.  Int'High = x7FFF. Hence cannot have positive values FOR 32 bit nums.
    VARIABLE rdata_int : integer := 0;

    VARIABLE timeout_ack: natural := 30;
    VARIABLE timeout_rdy: natural := 30;

    -- I2C Transaction BUFFER
    VARIABLE i2c_r_nw :  std_logic := '1';
    VARIABLE i2c_add :  std_logic_vector(6 DOWNTO 0) := "0000000"; 
    VARIABLE i2c_addr_ndata :  std_logic := '0'; 
    VARIABLE i2c_ack_check :  std_logic := '0'; 
    VARIABLE i2c_ack_inv : std_logic := '0';
    VARIABLE i2c_data_w :  std_logic_vector(7 DOWNTO 0) := "11000011";
    VARIABLE i2c_stop :  std_logic := '1';

    -- I2C Status
    VARIABLE i2c_data_r :  std_logic_vector(7 DOWNTO 0) := "00000000";
    VARIABLE i2c_mid_trans :  std_logic := '0';
    VARIABLE i2c_idle :  std_logic := '0';
    VARIABLE i2c_start_data :  std_logic := '0';
    VARIABLE i2c_start_add :  std_logic := '0';
    VARIABLE i2c_ack_failed :  std_logic := '0';
    VARIABLE i2c_error_bus_not_free :  std_logic := '0';
    VARIABLE i2c_transaction_active :  std_logic := '0';
    VARIABLE i2c_transaction_enable :  std_logic := '0';

    VARIABLE daq_event_length: natural RANGE 0 TO 65535;
    VARIABLE daq_event: boolean;

    CONSTANT gtx: natural RANGE 0 TO 15 := 6;
    CONSTANT gtx_space: std_logic_vector(31 DOWNTO 0) := x"00004000";
    
    VARIABLE gtx_offset: std_logic_vector(31 DOWNTO 0);
    VARIABLE module_gtx_ch0_reg, module_gtx_ch1_reg: type_mod_define;
    VARIABLE module_gtx_ch0_ram, module_gtx_ch1_ram: type_mod_define;

    --------------------------------------------------------------------------------------------
    -- Procedures that would mimic FUNCTION BUS calls IN C++
    --------------------------------------------------------------------------------------------

    PROCEDURE pbus_wait_for_ack(clks_to_wait: IN natural) IS 
      VARIABLE continue: boolean := true;
      VARIABLE timer: natural;
    BEGIN
        continue := true;
        timer := clks_to_wait;        
        WHILE continue LOOP
          WAIT UNTIL (clk'event AND clk = '1');    
            IF pbus_ack = '1' THEN
              continue := false;
              rdata := pbus_rdata;
              pbus_strobe <= '0';
            ELSE 
              timer := timer - 1;
              IF timer = 0 THEN
                report "Failed TO get acknowledge from pbus.  Aborting" SEVERITY failure;
              END IF;
            END IF;
        END LOOP;
    END pbus_wait_for_ack;

    PROCEDURE pbus_wait_till_rdy(clks_to_wait: IN natural) IS 
      VARIABLE continue: boolean := true;
      VARIABLE timer: natural;
    BEGIN
        continue := true;
        timer := clks_to_wait;        
        WHILE continue LOOP
          WAIT UNTIL (clk'event AND clk = '1');    
            IF pbus_ack = '0' THEN
              continue := false;
            ELSE 
              timer := timer - 1;
              IF timer = 0 THEN
                report "Bus NOT free.  Aborting" SEVERITY failure;
              END IF;
            END IF;
        END LOOP;
    END pbus_wait_till_rdy;

    PROCEDURE pbus_reg_write(module: IN type_mod_define; reg: IN std_logic_vector(31 DOWNTO 0); 
        high_bit: IN natural; low_bit: IN natural; data: unsigned(31 DOWNTO 0); verify: IN boolean)IS
    BEGIN
      -- Following includes at least one "wait" so signals are assigned.
      pbus_wait_till_rdy(timeout_rdy);
        -- Build address TO ACCESS
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
        mask := maskhigh AND masklow;
        -- Bitshift data into correct part OF reg.
        wdata := std_logic_vector(SHIFT_LEFT(unsigned(data), low_bit)) AND mask;
        -- Add parts OF reg that shouldn't be changed.
        rdata := rdata AND (NOT mask);
      -- Following includes at least one "wait" so signals are assigned.
      pbus_wait_till_rdy(timeout_rdy);
        -- Place ON BUS
        pbus_addr <= addr;
        pbus_wdata <= wdata OR rdata;
        pbus_strobe <= '1';
        pbus_write <= '1';
      -- Following includes at least one "wait" so signals are assigned.
      pbus_wait_for_ack(timeout_ack);
        IF verify = TRUE THEN
          -- Following includes at least one "wait" so signals are assigned.
          pbus_wait_till_rdy(timeout_rdy);
          pbus_addr <= addr;
          pbus_wdata <= x"00000000";
          pbus_strobe <= '1';
          pbus_write <= '0';
          -- Following includes at least one "wait" so signals are assigned.
          pbus_wait_for_ack(timeout_ack);
          ASSERT (wdata AND mask) = (rdata AND mask) report "Write verify failed" SEVERITY failure;
        END IF;

    END pbus_reg_write;


    PROCEDURE pbus_reg_read(module: IN type_mod_define; reg: IN std_logic_vector(31 DOWNTO 0); 
        high_bit: IN natural; low_bit: IN natural)IS
    BEGIN
      -- Following includes at least one "wait" so signals are assigned.
      pbus_wait_till_rdy(timeout_rdy);
        -- Build address TO ACCESS
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
        mask := maskhigh AND masklow;
        rdata := rdata AND mask;
        rdata := std_logic_vector(SHIFT_RIGHT(unsigned(rdata), low_bit));
        -- Forced TO have signed output because RANGE OF int x8000 TO x7FFF (two's complement)
        rdata_int := TO_INTEGER(signed(rdata));
        -- report "Data read back (integer) = " & str(rdata_int) SEVERITY note;
    END pbus_reg_read;

    --------------------------------------------------------------------------------------------
    -- Procedures that would mimic i2c FUNCTION calls IN C++
    --------------------------------------------------------------------------------------------


    PROCEDURE i2c_wait_until_finished IS
    --  Note i2c acknowledge should only be checked ON i2c address/data transmission (i.e NOT read!)
    BEGIN
      report "Waiting FOR I2C transaction TO finish";
      pbus_reg_read(module_si5326_i2c, x"0000000C", 31, 0);
      i2c_data_r :=  rdata(7 DOWNTO 0);
      i2c_mid_trans :=  rdata(8);
      i2c_idle :=  rdata(9);
      i2c_start_data :=  rdata(10);
      i2c_start_add :=  rdata(11);
      i2c_ack_failed :=  rdata(12);
      i2c_error_bus_not_free :=  rdata(13);
      i2c_transaction_active :=  rdata(14);
      i2c_transaction_enable :=  rdata(15);
      ASSERT i2c_error_bus_not_free = '0'
      report "User should WAIT FOR I2C BUS TO be free before attemting another slave address/write/read"
      SEVERITY failure;
      WHILE (i2c_transaction_active = '1') LOOP
        -- WHILE ((i2c_idle = '0') AND (i2c_mid_trans = '0')) OR (i2c_start_add = '1') OR (i2c_start_data = '1') LOOP
        pbus_reg_read(module_si5326_i2c, x"0000000C", 31, 0);
        i2c_data_r :=  rdata(7 DOWNTO 0);
        i2c_mid_trans :=  rdata(8);
        i2c_idle :=  rdata(9);
        i2c_start_data :=  rdata(10);
        i2c_start_add :=  rdata(11);
        i2c_ack_failed :=  rdata(12);
        i2c_error_bus_not_free :=  rdata(13);
        i2c_transaction_active :=  rdata(14);
        i2c_transaction_enable :=  rdata(15);
        ASSERT i2c_error_bus_not_free = '0'
        report "User should WAIT FOR I2C BUS TO be free before attemting another slave address/write/read"
        SEVERITY failure;
      END LOOP;
      ASSERT i2c_ack_failed = '0'
      report "No acknowledge from I2C slave."
      SEVERITY failure;
      -- Following WAIT NOT needed, but added so that i2c transactions are
      -- separated, making the wave window esier TO understand.
      WAIT FOR 10 us;
    END i2c_wait_until_finished;

    PROCEDURE i2c_write(add: IN std_logic_vector(6 DOWNTO 0); data_w: IN std_logic_vector(7 DOWNTO 0)) IS
      VARIABLE wdata_local : unsigned(31 DOWNTO 0);
    BEGIN
      report "Resets ptr TO transaction buffer";
      pbus_reg_write(module_si5326_i2c, x"00000000", 31, 0, x"00000000", false);
      report "Writing slave address FOR I2C WRITE";
      i2c_r_nw := '0';
      i2c_add := add;
      i2c_stop := '0';
      i2c_addr_ndata := '1';
      i2c_ack_check := '1';
      i2c_ack_inv := '0';
      wdata_local := x"00000" & i2c_ack_inv & i2c_ack_check & i2c_addr_ndata & i2c_stop & unsigned(i2c_add) & i2c_r_nw;
      pbus_reg_write(module_si5326_i2c, x"00000004", 31, 0, wdata_local, false);
      report "Writing data FOR i2c WRITE";
      i2c_data_w := data_w;
      i2c_stop := '1';
      i2c_addr_ndata := '0';
      i2c_ack_check := '1';
      i2c_ack_inv := '0';
      wdata_local := x"00000" & i2c_ack_inv & i2c_ack_check & i2c_addr_ndata & i2c_stop & unsigned(i2c_add) & i2c_r_nw;
      pbus_reg_write(module_si5326_i2c, x"00000004", 31, 0, wdata_local, false);
      report "Init transaction";
      pbus_reg_write(module_si5326_i2c, x"00000008", 31, 0, x"00000000", false);
      report "Wait FOR I2C TO finish";
      i2c_wait_until_finished;
    END i2c_write;


    PROCEDURE i2c_read(add: IN std_logic_vector(6 DOWNTO 0)) IS
      VARIABLE wdata_local : unsigned(31 DOWNTO 0);
    BEGIN
      report "Resets ptr TO transaction buffer";
      pbus_reg_write(module_si5326_i2c, x"00000000", 31, 0, x"00000000", false);
      report "Writing slave address FOR I2C READ";
      i2c_r_nw := '1';
      i2c_add := add;
      i2c_stop := '0';
      i2c_addr_ndata := '1';
      i2c_ack_check := '1';
      i2c_ack_inv := '0';
      wdata_local := x"00000" & i2c_ack_inv & i2c_ack_check & i2c_addr_ndata & i2c_stop & unsigned(i2c_add) & i2c_r_nw;
      pbus_reg_write(module_si5326_i2c, x"00000004", 31, 0, wdata_local, false);
      report "Writing transaction info FOR 1st I2C READ";
      i2c_data_w := x"00";  -- (i.e. we don't care);
      i2c_stop := '0';
      i2c_addr_ndata := '0';
      i2c_ack_check := '0';
      i2c_ack_inv := '0';
      wdata_local := x"00000" & i2c_ack_inv & i2c_ack_check & i2c_addr_ndata & i2c_stop & unsigned(i2c_add) & i2c_r_nw;
      pbus_reg_write(module_si5326_i2c, x"00000004", 31, 0, wdata_local, false);
      report "Writing transaction info FOR 2nd I2C READ";
      i2c_data_w := x"00";  -- (i.e. we don't care);
      i2c_stop := '1';
      i2c_addr_ndata := '0';
      i2c_ack_check := '0';
      i2c_ack_inv := '1';
      wdata_local := x"00000" & i2c_ack_inv & i2c_ack_check & i2c_addr_ndata & i2c_stop & unsigned(i2c_add) & i2c_r_nw;
      pbus_reg_write(module_si5326_i2c, x"00000004", 31, 0, wdata_local, false);
      report "Init transaction";
      pbus_reg_write(module_si5326_i2c, x"00000008", 31, 0, x"00000000", false);
      report "Wait FOR I2C TO finish";
      i2c_wait_until_finished;
    END i2c_read;

    PROCEDURE i2c_test IS 
    BEGIN
      report "Test I2C:  Requires visual check IN wave window";
      i2c_write("1101000", x"A5");
      i2c_read("1101000");   
    END i2c_test;

    PROCEDURE ram_test IS 
    BEGIN
      WAIT UNTIL clk'event AND clk='1';
        report "GTX0Ch0: Set RAM mode TO pattern capture";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020" + x"00000000", 26, 25, x"00000001", true);
      WAIT UNTIL clk'event AND clk='1';
        report "TTC Control (Global Control): Enable pattern capture";
        pbus_reg_write(module_reg_array_out, x"0000000C", 1, 0, x"00000001", true);
      -- Pattern RAM is 512 deep.  At 125MHz RAM will fill IN just over 4us.
      WAIT FOR 5 us;
      WAIT UNTIL clk'event AND clk='1';
        report "TTC Control (Global Control): Disable pattern capture";
        pbus_reg_write(module_reg_array_out, x"0000000C", 1, 0, x"00000000", true);
      FOR i IN 0 TO 10 LOOP
        WAIT UNTIL clk'event AND clk='1';
          report "GTX: Read back RAM";
          pbus_reg_read(  module_gtx_ch0_ram, std_logic_vector(to_unsigned(i*8,32)), 31, 0);
          report "GTX: RAM = " &  hstr(rdata);
      END LOOP;
    END ram_test;



    BEGIN

      -- Must be a better way OF multiplying x4000 by 6....
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

      WAIT FOR 100 ns;
        rst <= '0';
      -- WAIT FOR 1 us;

      WAIT UNTIL clk'event AND clk='1';
        report "Test reg access";
        pbus_reg_write(module_sys_info, x"00000004", 31, 0, x"DEADBEEF", true);

        report "Waiting 10us TO come OUT OF reset";
      WAIT FOR 10 us;

      report "Load LUTs WITH 0xFFFFFFFF";
      algolut: FOR i IN 0 TO 3 LOOP
        report "AlgoLut: Load at index " & str(i);
        -- epimlu
        WAIT UNTIL clk'event AND clk='1';
          pbus_reg_write(module_algo, x"00000800" + std_logic_vector(to_unsigned(4*i,31)), 31, 0, x"FFFFFFFF", false);
        -- ecallut
        WAIT UNTIL clk'event AND clk='1';
          pbus_reg_write(module_algo, x"00001000" + std_logic_vector(to_unsigned(4*i,31)), 31, 0, x"FFFFFFFF", false);
        -- hcallut
        WAIT UNTIL clk'event AND clk='1';
          pbus_reg_write(module_algo, x"00001800" + std_logic_vector(to_unsigned(4*i,31)), 31, 0, x"FFFFFFFF", false);
      END LOOP;


      --WAIT UNTIL clk'event AND clk='1';
      --  i2c_test;

      WAIT UNTIL clk'event AND clk='1';
        report "GTX: PowerOn Transceiver";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020" + x"0", 23, 20, x"00000008", true);
      WAIT UNTIL clk'event AND clk='1';
        report "GTX: PowerOn Transceiver";
        pbus_reg_write(  module_gtx_ch1_reg, x"00000020" + x"0", 23, 20, x"00000008", true);
      WAIT UNTIL clk'event AND clk='1';
        report "Waiting 1us AFTER power up";
      WAIT FOR 1 us;
        report "GTX: Reset On";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020" + x"0", 19, 19, x"00000001", true);
      WAIT UNTIL clk'event AND clk='1';
        report "GTX: Reset Off";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020" + x"0", 19, 19, x"00000000", true);

        report "Waiting 10us FOR links TO come up";
      WAIT FOR 10 us;

      WAIT UNTIL clk'event AND clk='1';
        report "GTX: Read CRC checked counter";
        pbus_reg_read(  module_gtx_ch0_reg, x"00000010", 31, 0);
        report "GTX: CRC checked counter = " &  str(rdata_int);
      WAIT UNTIL clk'event AND clk='1';
        report "GTX: Read CRC error counter";
        pbus_reg_read(  module_gtx_ch0_reg, x"00000014", 31, 0);
        report "GTX: CRC error counter = " &  str(rdata_int);

      WAIT UNTIL clk'event AND clk='1';
        report "GTX: Reset status.  Adding x20 TO ACCESS W/R regs";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020", 15, 15, x"00000001", false);
      WAIT UNTIL clk'event AND clk='1';
        report "GTX: Reset status.  Adding x20 TO ACCESS W/R regs";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020", 15, 15, x"00000000", false);
      
      WAIT FOR 5 us;
      WAIT UNTIL clk'event AND clk='1';
        report "GTX: Read CRC checked counter";
        pbus_reg_read(  module_gtx_ch0_reg, x"00000010", 31, 0);
        report "GTX: CRC checked counter = " &  str(rdata_int);
      WAIT UNTIL clk'event AND clk='1';
        report "GTX: Read CRC error counter";
        pbus_reg_read(  module_gtx_ch0_reg, x"00000014", 31, 0);
        report "GTX: CRC error counter = " &  str(rdata_int);

      WAIT UNTIL clk'event AND clk='1';
        report "Set SyncMaster delay TO mid-value (16)";
        pbus_reg_write(module_reg_array_out, x"00000008", 4, 0, x"00000010", true);
      WAIT UNTIL clk'event AND clk='1';
        report "Set SyncMasterEnable delay TO one";
        pbus_reg_write(module_reg_array_out, x"00000008", 0, 0, x"00000001", true);

      WAIT UNTIL clk'event AND clk='1';
        report "GTX: Enable SyncAuto ON both chans";
        pbus_reg_write(  module_gtx_ch0_reg, x"00000020", 24, 24, x"00000001", false);
        pbus_reg_write(  module_gtx_ch1_reg, x"00000020", 24, 24, x"00000001", false);
      WAIT FOR 1 us;

      WAIT UNTIL clk'event AND clk='1';
        pbus_reg_read(  module_gtx_ch1_reg, x"00000000", 0, 0);
        report "Gtx0Ch1: SyncDelayEnable (should be 1) = " &  str(rdata_int);
      WAIT UNTIL clk'event AND clk='1';
        pbus_reg_read(  module_gtx_ch1_reg, x"00000000", 5, 1);
        report "Gtx0Ch1: SyncDelay (should be 4) = " &  str(rdata_int);

      WAIT UNTIL clk'event AND clk='1';
        report "Set SyncMaster delay TO opt-value (16-12-1=3)";
        pbus_reg_write(module_reg_array_out, x"00000008", 5, 1, x"00000003", true);
      WAIT UNTIL clk'event AND clk='1';
        report "Set SyncMasterEnable delay TO one";
        pbus_reg_write(module_reg_array_out, x"00000008", 0, 0, x"00000001", true);
      WAIT FOR 1 us;

      WAIT UNTIL clk'event AND clk='1';
        pbus_reg_read(  module_gtx_ch1_reg, x"00000000", 6, 6);
        ASSERT rdata_int=0 report "Gtx0Ch1: SyncError" SEVERITY failure;
      WAIT UNTIL clk'event AND clk='1';
        pbus_reg_read(  module_gtx_ch1_reg, x"00000000", 0, 0);
        ASSERT rdata_int=0 report "Gtx0Ch1: SyncDelayEnable should be 0" SEVERITY failure;
      WAIT UNTIL clk'event AND clk='1';
        pbus_reg_read(  module_gtx_ch1_reg, x"00000000", 5, 1);
        ASSERT rdata_int=0 report "Gtx0Ch1: SyncDelay should be 0" SEVERITY failure;


      WAIT UNTIL clk'event AND clk='1';
        report "Trig: Set bx TO trigger ON (i.e. 64 decimal)";
        pbus_reg_write(module_control, x"00000000", 11, 0, x"00000040", true);
      WAIT UNTIL clk'event AND clk='1';
        report "Trig: Set trig delay (i.e. 100 decimal)";
        pbus_reg_write(module_control, x"00000000", 23, 12, x"00000064", true);
      WAIT UNTIL clk'event AND clk='1';
        report "Trig: Arm trigger";
        pbus_reg_write(module_control, x"00000000", 24, 24, x"00000001", false);
      WAIT FOR 1 us;

      daq_event := false;
      report "DAQ: Check TO see IF fifo containing event length is empty";
      WHILE daq_event=false LOOP
        pbus_reg_read(module_daq, x"00000000", 16, 16);
        -- Check TO see IF daq output buf empty
        IF rdata_int = 0 THEN
          daq_event:=true;
          report "DAQ: Event found, Increment EventLength fifo by write";
          pbus_reg_write(module_daq, x"00000000", 0, 0, x"00000000", false);
          pbus_reg_read(module_daq, x"00000000", 15, 0);
          daq_event_length := to_integer(unsigned(rdata(15 DOWNTO 0)));
          report "DAQ: EventLength = " & str(daq_event_length);
        ELSE
          report "DAQ: No event";
        END IF;
      END LOOP;
  
      daq_read_event: FOR idata IN 0 TO daq_event_length LOOP
        pbus_reg_read(module_daq, x"00000008", 31, 0);
        report "DAQ: EventData at index " & str(idata) & " = " &  hstr(rdata);
      END LOOP daq_read_event;



      WAIT UNTIL clk'event AND clk='1';
        report "Sim finished" SEVERITY note;

      -- ram_test;

      --  WAIT UNTIL clk'event AND clk='1';
      --  i2c_test;
      --  report "Sim finished" SEVERITY note;

      WAIT FOR 2 ms;

   END PROCESS;

END behave;