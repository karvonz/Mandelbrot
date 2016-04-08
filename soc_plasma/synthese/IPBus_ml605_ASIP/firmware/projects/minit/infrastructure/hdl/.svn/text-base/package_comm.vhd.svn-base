
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;

PACKAGE package_comm IS

  -- Place ALL BUS signals into a single RECORD FOR control
  TYPE type_comm_cntrl is RECORD
    stb: std_logic;
    wen: std_logic;
    add: std_logic_vector(31 DOWNTO 0);
    wdata: std_logic_vector(31 DOWNTO 0);
  END RECORD;

  -- Place ALL BUS signals into a single RECORD FOR reply
  TYPE type_comm_reply is RECORD
    ack : std_logic;
    err : std_logic;
    rdata: std_logic_vector(31 DOWNTO 0);
  END RECORD;

  -- Create arrays OF both the BUS records FOR control/reply
  TYPE type_comm_bus_cntrl is ARRAY(natural RANGE <>) OF type_comm_cntrl;
  TYPE type_comm_bus_reply is ARRAY(natural RANGE <>) OF type_comm_reply;

  -- NULL BUS reply.  Useful FOR initializing AFTER reet.
  CONSTANT comm_reply_null: type_comm_reply := (
    ack => '0',
    rdata => x"00000000",
    err => '0');

  CONSTANT comm_cntrl_null: type_comm_cntrl := (
    stb => '0',
    wen => '0',
    wdata => x"00000000",
    add => x"00000000");

  -- Takes a standard parallel BUS AND formats it IN a vhdl RECORD.
  -- The BUS is THEN distribued TO multiple (comm_units) slaves.
  COMPONENT comm_std_hub IS
  GENERIC(
    comm_units:    natural := 1);
  PORT(
    rst_in:                    IN std_logic;
    clk_in:                    IN std_logic;
    comm_bus_cntrl_out:     OUT type_comm_bus_cntrl(comm_units-1 DOWNTO 0);
    comm_bus_reply_in:      IN type_comm_bus_reply(comm_units-1 DOWNTO 0);
    stb_in:                 IN std_logic;
    wen_in:                 IN std_logic;
    add_in:                 IN std_logic_vector(31 DOWNTO 0);
    wdata_in:               IN std_logic_vector(31 DOWNTO 0);
    ack_out:                OUT std_logic;
    err_out:                OUT std_logic;
    rdata_out:              OUT std_logic_vector(31 DOWNTO 0));
  END COMPONENT;

  -- Distributes comm BUS TO many slaves.  Same as comm_std_hub, but
  -- without stanadrd parallel BUS interface.
  COMPONENT comm_mini_hub IS
  GENERIC(
    comm_units:    natural := 1);
  PORT(
    rst_in:                IN std_logic;
    clk_in:                 IN std_logic;
    comm_bus_cntrl_out:      OUT type_comm_bus_cntrl(comm_units-1 DOWNTO 0);
    comm_bus_reply_in:      IN type_comm_bus_reply(comm_units-1 DOWNTO 0);
    comm_cntrl_in:          IN type_comm_cntrl;
    comm_reply_out:          OUT type_comm_reply);
  END COMPONENT;

  COMPONENT comm_clk_bridge IS
  GENERIC(
    delay:    natural := 2);
  PORT(
    rst_master_in:              IN std_logic;
    clk_master_in:              IN std_logic;
    rst_slave_in:               IN std_logic;
    clk_slave_in:               IN std_logic;
    comm_cntrl_master_in:       IN type_comm_cntrl;
    comm_cntrl_slave_out:       OUT type_comm_cntrl;
    comm_reply_master_out:      OUT type_comm_reply;
    comm_reply_slave_in:        IN type_comm_reply);
  END COMPONENT;

END package_comm;

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.package_comm.ALL;

ENTITY comm_std_hub IS
GENERIC(
  comm_units:    natural := 1);
PORT(
  rst_in:                    IN std_logic;
  clk_in:                    IN std_logic;
  comm_bus_cntrl_out:     OUT type_comm_bus_cntrl(comm_units-1 DOWNTO 0);
  comm_bus_reply_in:      IN type_comm_bus_reply(comm_units-1 DOWNTO 0);
  stb_in:                 IN std_logic;
  wen_in:                 IN std_logic;
  add_in:                 IN std_logic_vector(31 DOWNTO 0);
  wdata_in:               IN std_logic_vector(31 DOWNTO 0);
  ack_out:                OUT std_logic;
  err_out:                OUT std_logic;
  rdata_out:              OUT std_logic_vector(31 DOWNTO 0));
END comm_std_hub;

ARCHITECTURE behave OF comm_std_hub IS
begin

  comm_hub_process: PROCESS (clk_in, rst_in)

    VARIABLE ack_int: std_logic;
    VARIABLE err_int: std_logic;
    VARIABLE rdata_int: std_logic_vector(31 DOWNTO 0);

  BEGIN

    IF rst_in = '1' THEN
      -- Makes sim a little cleaner
      FOR i IN 0 TO comm_units-1 LOOP
        comm_bus_cntrl_out(i) <= comm_cntrl_null;
      END LOOP;
      ack_out <= '0';
      err_out <= '0';
      rdata_out <= (OTHERS => '0');
    ELSIF (clk_in'event AND clk_in = '1') THEN
      ack_int := '0';
      err_int := '0';
      rdata_int := (OTHERS => '0');
      FOR i IN 0 TO comm_units-1 LOOP
        -- Create registers FOR each comm slave. Will reduce REGISTER load.
        comm_bus_cntrl_out(i).stb <= stb_in;
        comm_bus_cntrl_out(i).wdata <= wdata_in;
        comm_bus_cntrl_out(i).wen <= wen_in;
        comm_bus_cntrl_out(i).add <= add_in;
        -- Merge incoming signals from comm slaves WITH large OR
        ack_int := comm_bus_reply_in(i).ack OR ack_int;
        err_int := comm_bus_reply_in(i).err OR err_int;
        rdata_int := comm_bus_reply_in(i).rdata OR rdata_int;
      END LOOP;
      ack_out <= ack_int;
      err_out <= err_int;
      rdata_out <= rdata_int;
    END IF;
  END PROCESS;

END behave;

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.package_comm.ALL;

ENTITY comm_mini_hub IS
GENERIC(
  comm_units:    natural := 1);
PORT(
  rst_in:                IN std_logic;
  clk_in:                 IN std_logic;
  comm_bus_cntrl_out:      OUT type_comm_bus_cntrl(comm_units-1 DOWNTO 0);
  comm_bus_reply_in:      IN type_comm_bus_reply(comm_units-1 DOWNTO 0);
  comm_cntrl_in:          IN type_comm_cntrl;
  comm_reply_out:          OUT type_comm_reply);
END comm_mini_hub;

ARCHITECTURE behave OF comm_mini_hub IS
begin

  comm_hub_process: PROCESS (clk_in, rst_in)
  VARIABLE ack_int: std_logic;
  VARIABLE err_int: std_logic;
  VARIABLE rdata_int: std_logic_vector(31 DOWNTO 0);
  BEGIN

    IF rst_in = '1' THEN
      -- Makes sim a little cleaner
      FOR i IN 0 TO comm_units-1 LOOP
        comm_bus_cntrl_out(i) <= comm_cntrl_null;
      END LOOP;
      comm_reply_out <= comm_reply_null;
    ELSIF (clk_in'event AND clk_in = '1') THEN
    ack_int := '0';
    err_int := '0';
    rdata_int := x"00000000";
    FOR i IN 0 TO comm_units-1 LOOP
      -- Create registers FOR each comm slave. Will reduce REGISTER load.
      comm_bus_cntrl_out(i) <= comm_cntrl_in;
      -- Merge incoming signals from comm slaves WITH large OR
      ack_int := comm_bus_reply_in(i).ack OR ack_int;
      err_int := comm_bus_reply_in(i).err OR err_int;
      rdata_int := comm_bus_reply_in(i).rdata OR rdata_int;
    END LOOP;
    comm_reply_out.ack <= ack_int;
    comm_reply_out.err <= err_int;
    comm_reply_out.rdata <= rdata_int;
    END IF;
  END PROCESS;

END behave;


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.package_comm.ALL;

ENTITY comm_clk_bridge IS
GENERIC(
  delay:    natural := 2);
PORT(
  rst_master_in:              IN std_logic;
  clk_master_in:              IN std_logic;
  rst_slave_in:               IN std_logic;
  clk_slave_in:               IN std_logic;
  comm_cntrl_master_in:       IN type_comm_cntrl;
  comm_cntrl_slave_out:       OUT type_comm_cntrl;
  comm_reply_master_out:      OUT type_comm_reply;
  comm_reply_slave_in:        IN type_comm_reply);
END comm_clk_bridge;

ARCHITECTURE behave OF comm_clk_bridge IS

  SIGNAL stb: std_logic_vector(delay DOWNTO 0);
  SIGNAL ack: std_logic_vector(delay DOWNTO 0);

begin

  move_to_slave_domain: PROCESS (clk_slave_in, rst_slave_in)
  BEGIN
    IF rst_slave_in = '1' THEN
      stb <= (OTHERS => '0');
    ELSIF rising_edge(clk_slave_in) THEN
      stb <= stb(delay-1 DOWNTO 0) & comm_cntrl_master_in.stb;
    END IF;
  END PROCESS;

  -- delay enables TO make sure add/data are valid.
  comm_cntrl_slave_out.wdata <= comm_cntrl_master_in.wdata;
  comm_cntrl_slave_out.add <= comm_cntrl_master_in.add;
  comm_cntrl_slave_out.wen <= comm_cntrl_master_in.wen;
  comm_cntrl_slave_out.stb <= stb(delay);

  move_to_master_domain: PROCESS (clk_master_in, rst_master_in)
  BEGIN
    IF rst_master_in = '1' THEN
      ack <= (OTHERS => '0');
    ELSIF rising_edge(clk_master_in) THEN
      ack <= ack(delay-1 DOWNTO 0) & comm_reply_slave_in.ack;
    END IF;
  END PROCESS;

  -- delay enables TO make sure data are valid.
  comm_reply_master_out.rdata <= comm_reply_slave_in.rdata;
  comm_reply_master_out.ack <= ack(delay);
  comm_reply_master_out.err <= comm_reply_slave_in.err;

END behave;
