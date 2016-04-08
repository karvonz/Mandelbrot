LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;

PACKAGE package_control IS

  COMPONENT control_interface IS
  GENERIC(
    module:                            type_mod_define := module_control;
    LOCAL_LHC_BUNCH_COUNT:             integer := LHC_BUNCH_COUNT);
  PORT(
    -- Fabric clk/rst
    fabric_clk1x_in              : IN   std_logic;
    fabric_reset_in              : IN   std_logic;  
    -- Link clk/rst
    link_clk1x_in                : IN   std_logic;
    link_reset_in                : IN   std_logic;
    -- Comm interfaceic;
    comm_cntrl                   : IN type_comm_cntrl;
    comm_reply                   : OUT type_comm_reply;
    -- Pattern Inject/Capture control
    -- ttc_cntrl_in                 : OUT std_logic_vector(1 DOWNTO 0);
    ttc_time_in                  : IN std_logic_vector(8 DOWNTO 0);
    -- Bx req by Trigger (serial output)
    trig_out                     : OUT std_logic);
  END COMPONENT;

END  package_control;


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--LIBRARY unisim;
--USE unisim.vcomponents.ALL;
LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;
--USE work.package_reg.ALL;
--USE work.package_utilities.ALL;


ENTITY control_interface IS
GENERIC(
    module:                            type_mod_define := module_control;
    LOCAL_LHC_BUNCH_COUNT:             integer := LHC_BUNCH_COUNT);
PORT(
   -- Fabric clk/rst
   fabric_clk1x_in              : IN   std_logic;
   fabric_reset_in              : IN   std_logic;  
   -- Link clk/rst
   link_clk1x_in                : IN   std_logic;
   link_reset_in                : IN   std_logic;
   -- Comm interfaceic;
   comm_cntrl                   : IN type_comm_cntrl;
   comm_reply                   : OUT type_comm_reply;
   -- Pattern Inject/Capture control
   -- ttc_cntrl_in                 : OUT std_logic_vector(1 DOWNTO 0);
   ttc_time_in                  : IN std_logic_vector(8 DOWNTO 0);
   -- Bx req by Trigger (serial output)
    trig_out                     : OUT std_logic);
END control_interface;

ARCHITECTURE behave OF control_interface IS


  -- Comm BUS moved into local clk domain
  SIGNAL comm_cntrl_slv:                     type_comm_cntrl;
  SIGNAL comm_reply_slv:                     type_comm_reply;

  -- Ensures comm cycle only takes 1 clk period.
  SIGNAL write_once       : std_logic;
  SIGNAL read_once        : std_logic;
  -- Is base address correct - IF so enambe.
  SIGNAL module_en: std_logic;

  SIGNAL trig_bx: std_logic_vector(11 DOWNTO 0);
  SIGNAL trig_delay: std_logic_vector(11 DOWNTO 0);
  SIGNAL trig_enable: std_logic;
  
  SIGNAL ttc_time: std_logic_vector(11 DOWNTO 0);

  TYPE type_trig_sm IS (TRIG_IDLE, TRIG_ARMED, TRIG_PAUSE, TRIG_TX);
  SIGNAL trig_sm: type_trig_sm;

begin
  
  --------------------------------------------------------------------------
  -- (1) Bridge fabric BUS from fabric clock TO link clk
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
  -- (2) Wisbone TYPE interface (i.e. registers IN CASE statement)
  --------------------------------------------------------------------------

  -- Does module base address match incoming address?
  module_en <= '1' WHEN (comm_cntrl_slv.add AND (NOT module.addr_mask)) = module.addr_base ELSE '0';

  wishbone: PROCESS(link_clk1x_in, link_reset_in)
  BEGIN
    IF (link_reset_in = '1') THEN
      -- Clear comm BUS
      write_once <= '0';
      read_once <= '0';
      comm_reply_slv <= comm_reply_null;
      -- Registers
      trig_enable <= '0';
      trig_bx <= (OTHERS => '0');
      trig_delay <= (OTHERS => '0');
    ELSIF (link_clk1x_in'event AND link_clk1x_in = '1') THEN
      -- Default FOR pulsed regs (i.e = '1' OR '0' only WHEN written TO)
      trig_enable <= '0';
      -- Detect BUS transaction.
      IF (comm_cntrl_slv.stb = '1') AND (module_en = '1') THEN
        -- BUS active AND module selected
        comm_reply_slv.ack <= '1';
        comm_reply_slv.err <= '0';
        IF comm_cntrl_slv.wen = '1' THEN          
          -- Write active
          IF (write_once ='0') THEN
            write_once <= '1';
            CASE comm_cntrl_slv.add(5 DOWNTO 2) IS
              WHEN "0000" =>
                trig_bx <= comm_cntrl_slv.wdata(11 DOWNTO 0);
                trig_delay <= comm_cntrl_slv.wdata(23 DOWNTO 12);
                trig_enable <= comm_cntrl_slv.wdata(24);
              WHEN OTHERS =>
                NULL;
              END CASE;
          ELSE
            -- Write still active, but NOT first fabric_clk1x_in cycle
            NULL;
          END IF;
        ELSE
          -- Read active
          IF (read_once ='0') THEN
            read_once <= '1';
            CASE comm_cntrl_slv.add(5 DOWNTO 2) IS
            WHEN "0000" =>
              -- EventLengthBuffer data AND status REGISTER
              comm_reply_slv.rdata <= x"00" &
                 trig_delay &       -- 12-23
                 trig_bx;           -- 0-11;
            WHEN OTHERS =>
              comm_reply_slv.rdata <= (OTHERS => '0');  -- spare registers
            END CASE;
          ELSE
            -- Read still active, but NOT first fabric_clk1x_in cycle
            NULL;
          END IF;
        END IF;
      ELSE
        -- No BUS ACCESS
        write_once <= '0';
        read_once <= '0';
        comm_reply_slv <= comm_reply_null;
      END IF;
    END IF;
  END PROCESS wishbone;

  --------------------------------------------------------------------------
  -- (3) Issues trig ON user request.  
  --------------------------------------------------------------------------

  ttc_time <= "000" & ttc_time_in;

  trig_proc: PROCESS(link_clk1x_in, link_reset_in)
    VARIABLE trig_bx_sreg: std_logic_vector(13 DOWNTO 0);
    VARIABLE trig_cnt: natural RANGE 0 TO 4095;
  BEGIN
    IF (link_reset_in = '1') THEN
      trig_bx_sreg := (OTHERS => '0');
      trig_cnt := 0;
      trig_sm <= TRIG_IDLE;
      trig_out <= '0';
    ELSIF (link_clk1x_in'event AND link_clk1x_in = '1') THEN
      CASE trig_sm IS
      WHEN TRIG_IDLE =>
        IF trig_enable = '1' THEN
          -- Add header AND trailer.
          trig_bx_sreg := '1' & trig_bx & '0';
          trig_out <= '0';
          trig_sm <= TRIG_ARMED;
        END IF;
      WHEN TRIG_ARMED =>
        -- Note: Wrong by 1 bx at the moment.
        -- Correct WHEN ttc time generation moved inside this arctitecture.
        IF ttc_time = trig_bx THEN
          trig_cnt := to_integer(unsigned(trig_delay));
          trig_sm <= TRIG_PAUSE;
        END IF;
      WHEN TRIG_PAUSE =>
        IF trig_cnt /= 0 THEN
          trig_cnt := trig_cnt - 1;
        ELSE
          trig_sm <= TRIG_TX;
          trig_cnt := trig_bx_sreg'length;
        END IF;
      WHEN TRIG_TX =>
        IF trig_cnt /= 0 THEN
          -- Derive SIGNAL from previous shift-reg
          trig_out <= trig_bx_sreg(trig_bx_sreg'length-1);
          -- Increment shift reg
          trig_bx_sreg := trig_bx_sreg(trig_bx_sreg'length-2 DOWNTO 0) & '0';
          trig_cnt := trig_cnt - 1;
        ELSE
          trig_out <= '0';
          trig_sm <= TRIG_IDLE;
        END IF;
      WHEN OTHERS =>
        report "State machine IN illegal state" SEVERITY failure;
        trig_sm <= TRIG_IDLE;
      END CASE;
    END IF;
  END PROCESS trig_proc;


END behave;