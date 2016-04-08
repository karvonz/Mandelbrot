
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY work;
USE work.package_comm.ALL;
USE work.package_modules.ALL;

PACKAGE package_daq IS

  COMPONENT daq_buffer IS
  GENERIC(
    daq_width:       natural RANGE 0 TO 31:=1;
    buf_ident:       std_logic_vector(3 DOWNTO 0));
  PORT(
    clk:                  IN std_logic;
    rst:                  IN std_logic;
    trig_in:              IN std_logic;
    packet_data_in:       IN std_logic_vector(32*daq_width-1 DOWNTO 0);
    packet_id_in:         IN std_logic_vector(11 DOWNTO 0);
    packet_valid_in:      IN std_logic;
    daq_start_in:         IN std_logic;
    daq_stop_out:         OUT std_logic;
    daq_data_out:         OUT std_logic_vector(31 DOWNTO 0);
    daq_id_out:           OUT std_logic_vector(11 DOWNTO 0);
    daq_valid_out:        OUT std_logic;
    daq_empty_out:        OUT std_logic);
  END COMPONENT;

  COMPONENT daq_output IS
    GENERIC(
        module:                       type_mod_define := module_daq);
    PORT( 
      -- Fabric clk/fabric_reset_in
      fabric_clk1x_in              : IN std_logic;
      fabric_reset_in              : IN std_logic;   
      -- Link clk/fabric_reset_in
      link_clk1x_in                : IN std_logic;
      link_reset_in                : IN std_logic;
      -- Slow control TO regs
      comm_cntrl_in:                IN  type_comm_cntrl;
      comm_reply_out:               OUT type_comm_reply;
        -- Incoming DAQ stream.  BUFFER FOR subequent read OUT.
      daq_data_in:                  IN std_logic_vector (31 DOWNTO 0);
      daq_valid_in:                 IN std_logic;
      daq_start_in:                 IN std_logic;
      daq_stop_in:                  IN std_logic;
      overflow_out:                 OUT std_logic;
      backpressure_out:            OUT std_logic);
  END COMPONENT ;

END  package_daq;


-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.package_daq.ALL;

ENTITY tb_daq IS
END tb_daq;

ARCHITECTURE behave OF tb_daq IS
   
  SIGNAL clk, rst : std_logic := '1';

  -- ALL input data is 32 bits wide AND IN this insance it is 5 words long.
  TYPE type_event is ARRAY(natural RANGE <>) OF std_logic_vector(63 DOWNTO 0);
  CONSTANT event : type_event := (
      x"0000000000000000",
      x"0000000000000000",
      x"0000000000000000",
      x"0000000000000000");

  TYPE type_event_array is ARRAY(natural RANGE <>) OF type_event(0 TO 3);
  CONSTANT event_array : type_event_array := (
      
        -- Event 0
       (x"30000003ABCD0003",
        x"4000000300000003",
        x"5000000310000003",
        x"6000000320000003"),
        
        -- Event 1
       (x"30000006ABCD0006",
        x"4000000600000006",
        x"5000000610000006",
        x"6000000620000006")
    );

  TYPE type_event_seq_sm IS (IDLE, SEND_HEADER, SEND_PAYLOAD);
  SIGNAL event_seq_sm: type_event_seq_sm;

  SIGNAL packet_data: std_logic_vector(63 DOWNTO 0);
  SIGNAL packet_id: std_logic_vector(11 DOWNTO 0);
  SIGNAL packet_valid: std_logic;
  SIGNAL trig: std_logic;

  TYPE type_trig_sm IS (TRIG_IDLE, TRIG_TX_HEADER, TRIG_TX_IDENT, TRIG_END);
  SIGNAL trig_sm: type_trig_sm;
  
  SIGNAL daq_start, daq_empty: std_logic;

begin
  -- 125MHz clock
  clk <= NOT clk AFTER 4 ns;
  rst <= '0' AFTER 10 ns;

  event_seq_proc: PROCESS(clk, rst)
    VARIABLE event_index: natural RANGE 0 TO 255;
    VARIABLE data_index: natural RANGE 0 TO 255;
  BEGIN
    IF rst = '1' THEN
      packet_data <= (OTHERS => '0');
      packet_id <= (OTHERS => '0');
      packet_valid <= '0';
      event_seq_sm <= IDLE;
    ELSIF (clk'event AND clk = '1') THEN
      CASE event_seq_sm IS
      WHEN IDLE => 
        packet_data <= (OTHERS => '0');
        packet_valid <= '0';
        IF (event_index < event_array'length) THEN
          event_seq_sm <= SEND_HEADER;
        END IF;
      WHEN SEND_HEADER =>
        packet_data <= event_array(event_index)(0);
        packet_id <= event_array(event_index)(0)(11 DOWNTO 0);
        packet_valid <= '1';
        event_seq_sm <= SEND_PAYLOAD;
        data_index := 1;
      WHEN SEND_PAYLOAD =>
        IF (data_index < event_array(event_index)'length) THEN
          packet_data <= event_array(event_index)(data_index);
          packet_valid <= '1';
          data_index := data_index + 1;
        ELSE
          packet_data <= (OTHERS => '0');
          packet_id <= (OTHERS => '0');
          packet_valid <= '0';
          event_seq_sm <= IDLE;
          event_index := event_index + 1;
        END IF;
      WHEN OTHERS =>
        event_seq_sm <= IDLE;
      END CASE;
    END IF;
  END PROCESS;


  trig_encode: PROCESS(clk, rst)
    VARIABLE trig_cnt: integer RANGE 0 TO 15;
    CONSTANT trigid_req: std_logic_vector(11 DOWNTO 0):=x"006";
  BEGIN

    IF rst = '1' THEN
      trig_cnt := 12;
      trig <= '0';
    ELSIF (clk'event AND clk = '1') THEN
      CASE trig_sm IS
      WHEN TRIG_IDLE => 
        trig_sm <= TRIG_TX_HEADER;
      WHEN TRIG_TX_HEADER =>
        trig <= '1';
        trig_cnt := 12;
        trig_sm <= TRIG_TX_IDENT;
      WHEN TRIG_TX_IDENT =>
        IF trig_cnt /= 0 THEN
          trig_cnt := trig_cnt - 1;
          trig <= trigid_req(trig_cnt);
        ELSE
          trig_sm <= TRIG_END;
          trig <= '0';
        END IF;
      WHEN TRIG_END => 
        -- state machine opertaes once only...
        NULL;
      WHEN OTHERS =>
        trig_sm <= TRIG_IDLE;
      END CASE;
    END IF;
  END PROCESS;


  daq_buf_inst: daq_buffer
  GENERIC MAP(
    daq_width => 2,
    buf_ident => x"F")
  PORT MAP(
    clk                 => clk,
    rst                 => rst,
    trig_in             => trig,
    packet_data_in      => packet_data,
    packet_id_in        => packet_id,
    packet_valid_in     => packet_valid,
    daq_start_in        => daq_start,
    daq_stop_out        => open,
    daq_data_out        => open,
    daq_id_out          => open,
    daq_valid_out       => open,
    daq_empty_out       => daq_empty);

    daq_start <= NOT daq_empty;

END behave;


-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY unisim;
USE unisim.vcomponents.ALL;
LIBRARY work;
USE work.package_utilities.ALL;

ENTITY daq_buffer IS
  GENERIC(
    daq_width:       natural RANGE 0 TO 31:=1;
    buf_ident:       std_logic_vector(3 DOWNTO 0));
  PORT(
    clk:                  IN std_logic;
    rst:                  IN std_logic;
    trig_in:              IN std_logic;
    packet_data_in:       IN std_logic_vector(32*daq_width-1 DOWNTO 0);
    packet_id_in:         IN std_logic_vector(11 DOWNTO 0);
    packet_valid_in:      IN std_logic;
    daq_start_in:         IN std_logic;
    daq_stop_out:         OUT std_logic;
    daq_data_out:         OUT std_logic_vector(31 DOWNTO 0);
    daq_id_out:           OUT std_logic_vector(11 DOWNTO 0);
    daq_valid_out:        OUT std_logic;
    daq_empty_out:        OUT std_logic);
END daq_buffer;

ARCHITECTURE behave OF daq_buffer IS

  -- A pipeline (PacketPipe) FOR storing incoming packet data.  A 2nd BUFFER stores a
  -- unique identifier FOR the packet (PacketId = bunch crossing IN our CASE).

  -- IF a trigger is received a 3rd BUFFER (DaqData) stores the data extracted from the 
  -- PacketPipe BUFFER.  A 4th BUFFER (DaqId) keeps track OF the daqdata AND its id.

  -- Note that the PacketId AND DaqId are the same IN our case, although the code 
  -- could be modified so that they were NOT.  I have given them different names so I 
  -- can track the differebnt buffers.

  TYPE type_data_array is ARRAY(natural RANGE <>) OF std_logic_vector(35 DOWNTO 0);

  -- PacketData: Stores incoming trigger data AND is up TO 4k deep x 32bit wide
  -- Depth sufficient FOR ~ 1k bx.  Sufficient latency TO store data UNTIL trigger.
  SIGNAL packetpipe_wadd: std_logic_vector(10 DOWNTO 0);
  SIGNAL packetpipe_wadd_begin, packetpipe_wadd_end: std_logic_vector(10 DOWNTO 0);
  SIGNAL packetpipe_wen, packetpipe_wen_d1: std_logic;
  SIGNAL packetpipe_radd: std_logic_vector(10 DOWNTO 0);
  SIGNAL packetpipe_radd_valid: std_logic; 
  SIGNAL packetpipe_radd_end: std_logic_vector(10 DOWNTO 0);
  SIGNAL packetpipe_rdata: type_data_array(daq_width-1 DOWNTO 0);
  SIGNAL packetpipe_wdata: type_data_array(daq_width-1 DOWNTO 0);

  -- PacketId:  Store pointer TO trigger data.  Up TO 128 deep, although normally limited by 
  -- PACKETS_IN_PIPELINE CONSTANT.  It is used TO ensure that the number OF packets stored 
  -- is less than the number OF packets received per orbit.  IF this is NOT the CASE there 
  -- may be 2 packets WITH the same bx-id AND the  PacketId search may pick up the older 
  -- packet WITH the same bx-id. 
  -- Note that IF 10 cards operate IN round robin method THEN 128 deep PacketId should 
  -- be equivalent TO storing 1280 bx (i.e loads OF latency).
  SIGNAL packetid_wdata: std_logic_vector(35 DOWNTO 0);
  SIGNAL packetid_wadd: std_logic_vector(8 DOWNTO 0);
  SIGNAL packetid_rdata: std_logic_vector(35 DOWNTO 0);
  SIGNAL packetid_radd: std_logic_vector(8 DOWNTO 0);
  SIGNAL packetid_req: std_logic_vector(11 DOWNTO 0);
  SIGNAL packetid_req_valid: std_logic;
  SIGNAL packetid_wen: std_logic;
  SIGNAL packetid_extracted: std_logic_vector(11 DOWNTO 0);

  -- DaqData: Stores data AFTER receiving trigger. Decouples pipeline containing trigger data 
  -- AND BUFFER containing data waiting TO be sent TO DAQ.  Allows trigger data pipeline TO 
  -- receive adjacent triggers without a daq bottleneck.  512 deep.
  SIGNAL daqdata_wadd: std_logic_vector(8 DOWNTO 0);
  SIGNAL daqdata_wadd_begin, daqdata_wadd_end: std_logic_vector(8 DOWNTO 0);
  SIGNAL daqdata_wen, daqdata_wen_d1: std_logic;
  SIGNAL daqdata_radd: std_logic_vector(8 DOWNTO 0);
  SIGNAL daqdata_radd_valid: std_logic; 
  SIGNAL daqdata_radd_end: std_logic_vector(8 DOWNTO 0);
  SIGNAL daqdata_rdata: type_data_array(daq_width-1 DOWNTO 0);
  SIGNAL daqdata_wdata: type_data_array(daq_width-1 DOWNTO 0);
  SIGNAL daqdata_ram: natural RANGE 0 TO 31;

  -- DaqId:  Store pointer TO DaqData.
  SIGNAL daqid_wdata: std_logic_vector(35 DOWNTO 0);
  SIGNAL daqid_wadd: std_logic_vector(8 DOWNTO 0);
  SIGNAL daqid_rdata: std_logic_vector(35 DOWNTO 0);
  SIGNAL daqid_radd: std_logic_vector(8 DOWNTO 0);
  SIGNAL daqid_req: std_logic_vector(11 DOWNTO 0);
  SIGNAL daqid_req_valid: std_logic;
  SIGNAL daqid_wen: std_logic;
  SIGNAL daqid_extracted: std_logic_vector(11 DOWNTO 0);
  SIGNAL daqid_radd_valid: std_logic;
  
  
  SIGNAL daq_stop: std_logic;


  SIGNAL trig_id: std_logic_vector(11 DOWNTO 0);
  SIGNAL daqdata_id: std_logic_vector(11 DOWNTO 0);
  
  -- Statemachine used TO write the packetid AND a pointer TO the packetdata IN packetpipe.
  TYPE type_packetid_sm IS (WAIT_FOR_PACKET_BEGIN, WAIT_FOR_PACKET_END, WRITE_PACKET_ID, INC_WADD);
  SIGNAL packetid_sm: type_packetid_sm;

  -- State machine used TO extract trigger data from buffers. First searches PacketId buffer, 
  -- THEN extracts data from PacketData BUFFER.
  TYPE type_packetgrabber_sm IS (IDLE, PACKETID_SEARCH, PACKETDATA_EXTRACT);
  SIGNAL packetgrabber_sm: type_packetgrabber_sm;

  -- Statemachine used TO write the daqid AND a pointer TO the daqdata.
  TYPE type_daqid_sm IS (WAIT_FOR_PACKET_BEGIN, WAIT_FOR_PACKET_END, WRITE_PACKET_ID, INC_WADD);
  SIGNAL daqid_sm: type_daqid_sm;

  -- State machine used TO extract daq data from buffers.
  TYPE type_daqgrabber_sm IS (IDLE, DAQID_EXTRACT, DAQDATA_EXTRACT, DAQDATA_RAM_SELECT);
  SIGNAL daqgrabber_sm: type_daqgrabber_sm;

  -- Very important that the number OF packets per orbit is more that this number.  
  -- IF NOT two packets may have the bx-id.  It will THEN NOT be a unique number 
  -- IN the PacketId search RAM
  CONSTANT PACKETS_IN_PIPELINE: natural := 8;

   SIGNAL events:                         natural RANGE 0 TO 511;
   SIGNAL event_driver:                   std_logic_vector(1 DOWNTO 0);

begin


  packetpipe_wen <=  packet_valid_in;

  packetpipe_gen: FOR i IN 0 TO daq_width-1 GENERATE
    packetpipe_wdata(i) <= "0000" &  packet_data_in(32*i+31 DOWNTO 32*i);

    packetpipe_blockram: block_ram_36x2048_36x2048
    PORT MAP(
        clk_a               => clk,
        add_a               => packetpipe_wadd, 
        write_data_a        => packetpipe_wdata(i), 
        write_enable_a      => packetpipe_wen, 
        write_ack_a         => open, 
        read_data_a         => open, 
        read_enable_a       => '0', 
        read_ack_a          => open, 
        clk_b               => clk, 
        add_b               => packetpipe_radd, 
        write_data_b        => (OTHERS => '0'), 
        write_enable_b      => '0', 
        write_ack_b         => open, 
        read_data_b         => packetpipe_rdata(i), 
        read_enable_b       => '1', 
        read_ack_b          => OPEN);
    END GENERATE;
  
  packetpipe_buf_porta: PROCESS(clk, rst)
    VARIABLE packetpipe_wadd_int: integer RANGE 0 TO 511;
  BEGIN
    IF rst = '1' THEN
      packetpipe_wadd_int := 0;
       packetpipe_wen_d1 <= '0';
    ELSIF (clk'event AND clk = '1') THEN
      packetpipe_wen_d1 <= packetpipe_wen; 
      IF packetpipe_wen = '1' THEN
        IF packetpipe_wadd_int < 511 THEN
          packetpipe_wadd_int := packetpipe_wadd_int + 1;
        ELSE
          packetpipe_wadd_int := 0;
        END IF;
      END IF;
    END IF;
    packetpipe_wadd <= std_logic_vector(to_unsigned(packetpipe_wadd_int, packetpipe_wadd'length));
  END PROCESS;

  --------------------------------------------------------------------------
  --  BUFFER TO store packetid AND location IN packetpipe BUFFER
  --------------------------------------------------------------------------

  id_buffer: ramb16_s36_s36
  GENERIC MAP(
    write_mode_a => "read_first",
    write_mode_b => "read_first")
  PORT MAP(
    doa   => open,
    dob   => packetid_rdata(31 DOWNTO 0),
    dopa  => open,
    dopb  => packetid_rdata(35 DOWNTO 32),
    addra => packetid_wadd,
    addrb => packetid_radd,
    clka  => clk,
    clkb  => clk,
    dia   => packetid_wdata(31 DOWNTO 0),
    dib   => (OTHERS => '0'),
    dipa  => packetid_wdata(35 DOWNTO 32),
    dipb  => (OTHERS => '0'),
    ena   => '1',
    enb   => '1',
    ssra  => '0',
    ssrb  => '0',
    wea   => packetid_wen,
    web   => '0');

  ------------------------------------------------------------------------------
  -- PacketId Writer:
  ------------------------------------------------------------------------------

  -- Detects beginning AND END OF packet AND writes PacketId, PacketPipe RAM
  -- beginning AND END address TO PacketId RAM

  packetid_porta: PROCESS(clk, rst)
    VARIABLE packetid_wadd_int: integer RANGE 0 TO PACKETS_IN_PIPELINE-1;
  BEGIN

    IF rst = '1' THEN
      packetid_wadd_int := 0;
      packetid_sm <= WAIT_FOR_PACKET_BEGIN;
      trig_id <= (OTHERS => '0');
      packetpipe_wadd_begin <= (OTHERS => '0');
      packetpipe_wadd_end <= (OTHERS => '0');
      packetid_wdata <= (OTHERS => '0');
      packetid_wen <= '0';
    ELSIF (clk'event AND clk = '1') THEN
      CASE packetid_sm IS
      WHEN WAIT_FOR_PACKET_BEGIN => 
        packetid_wen <= '0';
        IF ( packetpipe_wen = '1') AND ( packetpipe_wen_d1='0') THEN
          trig_id <=  packet_id_in;
          packetpipe_wadd_begin <= packetpipe_wadd;
          packetid_sm <= WAIT_FOR_PACKET_END;
        END IF;
      WHEN WAIT_FOR_PACKET_END =>
        IF ( packetpipe_wen ='0') AND ( packetpipe_wen_d1='1') THEN
          packetpipe_wadd_end <= packetpipe_wadd;
          packetid_sm <= WRITE_PACKET_ID;
        END IF;
      WHEN WRITE_PACKET_ID =>
        packetid_wdata <= '0' & packetpipe_wadd_end & '0' & packetpipe_wadd_begin & trig_id;
        packetid_wen <= '1';
        packetid_sm <= WAIT_FOR_PACKET_BEGIN;
        IF packetid_wadd_int < PACKETS_IN_PIPELINE-1 THEN
          packetid_wadd_int := packetid_wadd_int + 1;
        ELSE
          packetid_wadd_int := 0;
        END IF;
      WHEN OTHERS =>
        packetid_sm <= WAIT_FOR_PACKET_BEGIN;
      END CASE;
    END IF;

    -- Assign counter defined as local VARIABLE TO SIGNAL
    packetid_wadd <= std_logic_vector(to_unsigned(packetid_wadd_int, packetid_wadd'length));

  END PROCESS;

  ------------------------------------------------------------------------------
  -- Decode PacketId (SimpleShiftReg)
  ------------------------------------------------------------------------------

  trig_decode: PROCESS(clk, rst)
    VARIABLE packetid_cnt: integer RANGE 0 TO 15;
  BEGIN

    IF rst = '1' THEN
      packetid_req_valid <= '0';
      packetid_req <= (OTHERS => '0');
      packetid_cnt := 0;
    ELSIF (clk'event AND clk = '1') THEN
      -- Essentially very simple state machine...
      IF packetid_cnt = 0 THEN
        -- Search FOR incoming events
        IF trig_in = '1' THEN 
          packetid_cnt := 12;
        END IF;
        packetid_req_valid <= '0';
      ELSE
        IF packetid_cnt = 1 THEN
          packetid_req_valid <= '1';
        ELSE
          packetid_req_valid <= '0';
        END IF;
        packetid_req <= packetid_req(10 DOWNTO 0) & trig_in;
        packetid_cnt := packetid_cnt - 1;
      END IF;
    END IF;
  END PROCESS;

  ------------------------------------------------------------------------------
  -- Packet Grabber:
  ------------------------------------------------------------------------------

  -- Searches PacketId RAM FOR PacketId AND thus also PacketPipe address
  -- Extracts data from PacketPipe RAM AND sends data TO DAQ

  packetgrabber_proc: PROCESS(clk, rst)
    VARIABLE packetid_radd_int: natural RANGE 0 TO PACKETS_IN_PIPELINE-1;
  BEGIN
    IF rst = '1' THEN
      packetgrabber_sm <= IDLE;
      packetid_radd_int := 0;
      packetpipe_radd <= (OTHERS => '0');
      packetpipe_radd_valid <= '0';
      packetpipe_radd_end <= (OTHERS => '0');
      packetid_extracted <= (OTHERS => '0');
    ELSIF (clk'event AND clk = '1') THEN
      CASE packetgrabber_sm IS
      WHEN IDLE => 
        IF packetid_req_valid = '1' THEN
          -- Initiate search FOR packetid IN packetid blockram
           packetgrabber_sm <= PACKETID_SEARCH;
          -- Start search at address 0.
           packetid_radd_int := 1;
        END IF;
      WHEN PACKETID_SEARCH =>
        IF packetid_rdata(11 DOWNTO 0) = packetid_req THEN
          -- Found packetid.  Now have pointer TO packetdata pipeline
          packetid_extracted <= packetid_req;
          packetpipe_radd <= packetid_rdata(22 DOWNTO 12);
          packetpipe_radd_end <= packetid_rdata(34 DOWNTO 24);
          packetgrabber_sm <= PACKETDATA_EXTRACT;
        ELSE
          IF packetid_radd_int /= PACKETS_IN_PIPELINE-1 THEN
            packetid_radd_int := packetid_radd_int + 1;
          ELSE
            -- Failed TO to find event.  GENERATE empty DAQ packet.
             packetgrabber_sm <= IDLE;
          END IF;
        END IF;
      WHEN PACKETDATA_EXTRACT =>
        IF (packetpipe_radd /= packetpipe_radd_end) THEN
          packetpipe_radd <= packetpipe_radd + std_logic_vector(to_unsigned(1, packetpipe_radd'length));
          packetpipe_radd_valid <= '1';
        ELSE
          packetgrabber_sm <= IDLE;
          packetpipe_radd_valid <= '0';
        END IF;
      WHEN OTHERS =>
        packetgrabber_sm <= IDLE;
      END CASE;
    END IF;
    -- Assign counter defined as local VARIABLE TO SIGNAL
    packetid_radd <= std_logic_vector(to_unsigned(packetid_radd_int, packetid_radd'length));
  END PROCESS;

  --------------------------------------------------------------------------
  --  DAQ BUFFER TO hold events WHILE waiting FOR readout
  --------------------------------------------------------------------------


  -- Re-assign signals here TO make simulation simpler TO understand.
  daqdata_wen <= packetpipe_radd_valid;

  daqdata_gen: FOR i IN 0 TO daq_width-1 GENERATE
    daqdata_wdata(i) <= packetpipe_rdata(i);

    daqdata_buffer: ramb16_s36_s36
    GENERIC MAP(
      write_mode_a => "read_first",
      write_mode_b => "read_first")
    PORT MAP(
      doa   => open,
      dob   => daqdata_rdata(i)(31 DOWNTO 0),
      dopa  => open,
      dopb  => daqdata_rdata(i)(35 DOWNTO 32),
      addra => daqdata_wadd,
      addrb => daqdata_radd,
      clka  => clk,
      clkb  => clk,
      dia   => daqdata_wdata(i)(31 DOWNTO 0),
      dib   => (OTHERS => '0'),
      dipa  => daqdata_wdata(i)(35 DOWNTO 32),
      dipb  => (OTHERS => '0'),
      ena   => '1',
      enb   => '1',
      ssra  => '0',
      ssrb  => '0',
      wea   => daqdata_wen,
      web   => '0');
  END GENERATE;

  daqid_buffer: ramb16_s36_s36
  GENERIC MAP(
    write_mode_a => "read_first",
    write_mode_b => "read_first")
  PORT MAP(
    doa   => open,
    dob   => daqid_rdata(31 DOWNTO 0),
    dopa  => open,
    dopb  => daqid_rdata(35 DOWNTO 32),
    addra => daqid_wadd,
    addrb => daqid_radd,
    clka  => clk,
    clkb  => clk,
    dia   => daqid_wdata(31 DOWNTO 0),
    dib   => (OTHERS => '0'),
    dipa  => daqid_wdata(35 DOWNTO 32),
    dipb  => (OTHERS => '0'),
    ena   => '1',
    enb   => '1',
    ssra  => '0',
    ssrb  => '0',
    wea   => daqid_wen,
    web   => '0');

  ------------------------------------------------------------------------------
  -- DaqDataBuf(Write): Simply increment address counter.
  ------------------------------------------------------------------------------

  daqdata_buf: PROCESS(clk, rst)
    VARIABLE daqdata_wadd_int: integer RANGE 0 TO 511;
  BEGIN
    IF rst = '1' THEN
      daqdata_wadd_int := 0;
      daqdata_wen_d1 <= '0';
    ELSIF (clk'event AND clk = '1') THEN
      daqdata_wen_d1 <= daqdata_wen; 
      IF daqdata_wen = '1' THEN
        IF daqdata_wadd_int < 511 THEN
          daqdata_wadd_int := daqdata_wadd_int + 1;
        ELSE
          daqdata_wadd_int := 0;
        END IF;
      END IF;
    END IF;
    daqdata_wadd <= std_logic_vector(to_unsigned(daqdata_wadd_int, daqdata_wadd'length));
  END PROCESS;

  ------------------------------------------------------------------------------
  -- DaqIdBuf(Write): Store PacketId, Begin/End Address
  ------------------------------------------------------------------------------

  daqdatagrabber_porta: PROCESS(clk, rst)
    VARIABLE daqid_wadd_int: integer RANGE 0 TO 511;
  BEGIN

    IF rst = '1' THEN
      daqid_wadd_int := 0;
      daqid_sm <= WAIT_FOR_PACKET_BEGIN;
      daqdata_id <= (OTHERS => '0');
      daqdata_wadd_begin <= (OTHERS => '0');
      daqdata_wadd_end <= (OTHERS => '0');
      daqid_wdata <= (OTHERS => '0');
      daqid_wen <= '0';
    ELSIF (clk'event AND clk = '1') THEN
      CASE daqid_sm IS
      WHEN WAIT_FOR_PACKET_BEGIN => 
        daqid_wen <= '0';
        IF (daqdata_wen = '1') AND (daqdata_wen_d1='0') THEN
          daqdata_id <=  packetid_extracted;
          daqdata_wadd_begin <= daqdata_wadd;
          daqid_sm <= WAIT_FOR_PACKET_END;
        END IF;
      WHEN WAIT_FOR_PACKET_END =>
        IF (daqdata_wen ='0') AND (daqdata_wen_d1='1') THEN
          daqdata_wadd_end <= daqdata_wadd;
          daqid_sm <= WRITE_PACKET_ID;
        END IF;
      WHEN WRITE_PACKET_ID =>
        daqid_wdata <= "000" & daqdata_wadd_end & "000" & daqdata_wadd_begin & daqdata_id;
        daqid_wen <= '1';
        IF daqid_wadd_int < 511 THEN
          daqid_wadd_int := daqid_wadd_int + 1;
        ELSE
          daqid_wadd_int := 0;
        END IF;
        daqid_sm <= WAIT_FOR_PACKET_BEGIN;
      WHEN OTHERS =>
        daqid_sm <= WAIT_FOR_PACKET_BEGIN;
      END CASE;
    END IF;

    -- Assign counter defined as local VARIABLE TO SIGNAL
    daqid_wadd <= std_logic_vector(to_unsigned(daqid_wadd_int, daqid_wadd'length));

  END PROCESS;

  ------------------------------------------------------------------------------
  -- DaqDataBuf(Read) & DaqId(Read): Extraxt packets ON daq start SIGNAL. 
  ------------------------------------------------------------------------------

  daqgrabber_proc: PROCESS(clk, rst)
    VARIABLE daqid_radd_int: natural RANGE 0 TO PACKETS_IN_PIPELINE-1;
  BEGIN
    IF rst = '1' THEN
      daqgrabber_sm <= IDLE;
      daqid_radd_int := 1;
      daqid_radd_valid <= '0';
      daqdata_radd <= (OTHERS => '0');
      daqdata_radd_valid <= '0';
      daqdata_radd_end <= (OTHERS => '0');
      daqid_extracted <= (OTHERS => '0');
      daq_stop <= '0';
    ELSIF (clk'event AND clk = '1') THEN
      CASE daqgrabber_sm IS
      WHEN IDLE => 
        daq_stop <= '0';
        IF daq_start_in = '1' THEN
           daqgrabber_sm <= DAQID_EXTRACT;
        END IF;
      WHEN DAQID_EXTRACT =>
        daqid_extracted <= daqid_rdata(11 DOWNTO 0);
        daqid_radd_valid <= '1';
        daqdata_radd <= daqid_rdata(20 DOWNTO 12);
        daqdata_radd_end <= daqid_rdata(32 DOWNTO 24);
        daqgrabber_sm <= DAQDATA_EXTRACT;
        daqdata_ram <= 0;
      WHEN DAQDATA_EXTRACT =>
        daqid_radd_valid <= '0';
        IF (daqdata_radd /= daqdata_radd_end) THEN
          daqdata_radd <= daqdata_radd + std_logic_vector(to_unsigned(1, daqdata_radd'length));
          daqdata_radd_valid <= '1';
        ELSE
          daqgrabber_sm <= DAQDATA_RAM_SELECT;
          daqdata_radd_valid <= '0';
          daqdata_ram <= daqdata_ram+1;
        END IF;
      WHEN DAQDATA_RAM_SELECT =>
        IF daqdata_ram < daq_width THEN 
          daqgrabber_sm <= DAQDATA_EXTRACT;
          -- Reset add TO beginning FOR NEXT RAM
          daqdata_radd <= daqid_rdata(20 DOWNTO 12);
        ELSE
          daqgrabber_sm <= IDLE;
          daq_stop <= '1';
          -- Increment read add so that sm ready TO extract NEXT DaqId.;
          IF daqid_radd_int < 511 THEN
            daqid_radd_int := daqid_radd_int + 1;
          ELSE
            daqid_radd_int := 0;
          END IF;
        END IF;
      WHEN OTHERS =>
        daqgrabber_sm <= IDLE;
      END CASE;
    END IF;
    -- Assign counter defined as local VARIABLE TO SIGNAL
    daqid_radd <= std_logic_vector(to_unsigned(daqid_radd_int, daqid_radd'length));
  END PROCESS;

   -- The event driver counts events stored IN the SlinkLengthFifo
   event_driver <= daqid_wen & daqid_radd_valid;

   events_stored : PROCESS(rst, clk)
   BEGIN
      IF (rst = '1') THEN
         events <= 0;
         daq_empty_out <= '1';
      ELSIF (clk = '1' AND clk'event) THEN    
        CASE event_driver IS
        WHEN "01" =>
            events <= events - 1;
        WHEN "10" =>
            events <= events + 1;
        WHEN OTHERS =>
            NULL;
        END CASE;
        IF events = 0 THEN
          daq_empty_out <= '1';
        ELSE
          daq_empty_out <= '0';
        END IF;
      END IF;
   END PROCESS events_stored;

   clk_output : PROCESS(rst, clk)
   BEGIN
      IF (rst = '1') THEN
        daq_stop_out <= '0';
        daq_valid_out <= '0';
        daq_data_out <= (OTHERS => '0');
        daq_id_out  <= (OTHERS => '0');
      ELSIF (clk = '1' AND clk'event) THEN    
        daq_valid_out <= daqdata_radd_valid OR daqid_radd_valid;
        daq_stop_out <= daq_stop;
        IF daqid_radd_valid = '1' THEN
          daq_data_out <= buf_ident & x"0BC0" & daqid_rdata(11 DOWNTO 0);
          daq_id_out <= daqid_extracted;
        ELSIF daqdata_radd_valid = '1' THEN
          daq_data_out <= daqdata_rdata(daqdata_ram)(31 DOWNTO 0);
          daq_id_out <= daqid_extracted;
        ELSE
          daq_data_out <= (OTHERS => '0');
          daq_id_out <= (OTHERS => '0');
        END IF;
      END IF;
   END PROCESS clk_output;

END behave;


-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;
USE work.package_reg.ALL;
USE work.package_utilities.ALL;

ENTITY daq_output IS
   GENERIC(
      module:              type_mod_define := module_daq);
   PORT( 
      -- Fabric clk/fabric_reset_in
      fabric_clk1x_in              : IN std_logic;
      fabric_reset_in              : IN std_logic;  
      -- Link clk/fabric_reset_in
      link_clk1x_in                : IN std_logic;
      link_reset_in                : IN std_logic;
      -- Slow control TO regs
      comm_cntrl_in:                   IN  type_comm_cntrl;
      comm_reply_out:                   OUT type_comm_reply;
        -- Incoming DAQ stream.  BUFFER FOR subequent read OUT.
      daq_data_in:                  IN std_logic_vector (31 DOWNTO 0);
      daq_valid_in:                 IN std_logic;
      daq_start_in:                 IN std_logic;
      daq_stop_in:                  IN std_logic;
      overflow_out:                 OUT std_logic;
      backpressure_out:            OUT std_logic);
END daq_output ;


ARCHITECTURE behave OF daq_output IS

   SIGNAL clear:                     std_logic;
   SIGNAL enable:                    std_logic;

   -- EventDataBuffer
   SIGNAL read_data:                 std_logic_vector (31 DOWNTO 0);
   SIGNAL overflow:                  std_logic;
   SIGNAL full:                      std_logic;
   SIGNAL empty:                     std_logic;
   SIGNAL full_thresh_assert:        std_logic_vector (7 DOWNTO 0);
   SIGNAL full_thresh_negate:        std_logic_vector (7 DOWNTO 0);
   SIGNAL read_increment:            std_logic;
   SIGNAL write_enable:              std_logic;
   SIGNAL write_data:                std_logic_vector(31 DOWNTO 0);

   SIGNAL reg_cntrl, reg_cntrl_linkclk: std_logic_vector(17 DOWNTO 0);
   
   TYPE event_sm_type IS (
      IDLE,
      SLINK_ACTIVE);
   SIGNAL state:    event_sm_type;
   
   SIGNAL events:                         natural RANGE 0 TO 1023;
   SIGNAL event_begin:                    std_logic;
   SIGNAL event_end:                      std_logic;
   SIGNAL event_driver:                   std_logic_vector(1 DOWNTO 0);

   -- EventLengthBuffer
   SIGNAL event_length:                   unsigned(15 DOWNTO 0);
   SIGNAL event_length_empty:             std_logic;
   SIGNAL event_length_read_data:         std_logic_vector(15 DOWNTO 0);
   SIGNAL event_length_read_increment:    std_logic;
   SIGNAL event_length_write_enable:      std_logic;

   -- Ensures comm cycle only takes 1 clk period.
   SIGNAL write_once       : std_logic;
   SIGNAL read_once        : std_logic;
   -- Is base address correct - IF so enambe.
   SIGNAL module_en: std_logic;

begin

   -------------------------------------------------------------------------------
   -- Need TO be a little careful.  Daq data enters IN LinkClk domain AND IS 
   -- read IN the FabricClk domain.  Should be OK.  There are a few signals that 
   -- cross clk domains, but they are things link overflow that are insensitive.
   -------------------------------------------------------------------------------

  -- Does module base address match incoming address?
  module_en <= '1' WHEN (comm_cntrl_in.add AND (NOT module.addr_mask)) = module.addr_base ELSE '0';

  wishbone: PROCESS(fabric_clk1x_in, fabric_reset_in)
  BEGIN
    IF (fabric_reset_in = '1') THEN
      -- Clear comm BUS
      write_once <= '0';
      read_once <= '0';
      -- By default enable BUFFER system AND set full assert/negate thresholds at midpoint.
      reg_cntrl <= "01" & x"80" & x"80";
      comm_reply_out <= comm_reply_null;
    ELSIF (fabric_clk1x_in'event AND fabric_clk1x_in = '1') THEN
      -- Pulsed regs that increment fifos.  By default set TO '1'.
      event_length_read_increment <= '0';
      read_increment <= '0';
      -- Detect BUS transaction.
      IF (comm_cntrl_in.stb = '1') AND (module_en = '1') THEN
        -- BUS active AND module selected
        comm_reply_out.ack <= '1';
        comm_reply_out.err <= '0';
        IF comm_cntrl_in.wen = '1' THEN          
          -- Write active
          IF (write_once ='0') THEN
            write_once <= '1';
            CASE comm_cntrl_in.add(5 DOWNTO 2) IS
              WHEN "0000" =>
                -- Increment event length BUFFER
                event_length_read_increment <= '1';
              WHEN "0011" =>
                reg_cntrl <= comm_cntrl_in.wdata(17 DOWNTO 0);
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
            CASE comm_cntrl_in.add(5 DOWNTO 2) IS
            WHEN "0000" =>
              -- EventLengthBuffer data AND status REGISTER
              comm_reply_out.rdata <= x"000" & "000" &
                 event_length_empty &        -- 16
                 event_length_read_data;    -- 0-15
            WHEN "0001" =>
              -- EventDataBuffer status REGISTER
              comm_reply_out.rdata <= x"0000000" & '0' & 
                 overflow &                 -- 2
                 full &                     -- 1
                 empty;                     -- 0
            WHEN "0010" =>
              -- EventDataBuffer data REGISTER
              comm_reply_out.rdata <= read_data;
              -- Auto increment data BUFFER
              read_increment <= '1';
            WHEN OTHERS =>
              comm_reply_out.rdata <= (OTHERS => '0');  -- spare registers
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
        comm_reply_out <= comm_reply_null;
      END IF;
    END IF;
  END PROCESS wishbone;

  clk_bridge : PROCESS(link_reset_in, link_clk1x_in)
  BEGIN
    IF link_reset_in = '1' THEN
      reg_cntrl_linkclk <= (OTHERS => '0');
      full_thresh_assert <= (OTHERS => '0');
      full_thresh_negate <= (OTHERS => '0');
      enable <= '0';
      clear <= '1';
    ELSIF (link_clk1x_in = '1') AND (link_clk1x_in'event) THEN
      -- Clk signals again TO remove metastability 
      full_thresh_assert <= reg_cntrl_linkclk(7 DOWNTO 0);
      full_thresh_negate <= reg_cntrl_linkclk(15 DOWNTO 8);
      enable <= reg_cntrl_linkclk(16);
      clear <= reg_cntrl_linkclk(17);
      -- Clk from fabric TO link clock domain.
      reg_cntrl_linkclk <= reg_cntrl;
    END IF;
  END PROCESS clk_bridge;

  -------------------------------------------------------------------------------
  -- Slink Fifo FOR VME acess
  -------------------------------------------------------------------------------
  
  daq_fifo_inst: fifo32_dual_clk
  PORT MAP(
    clear                      => clear,
    write_clk                  => link_clk1x_in,
    write_enable               => write_enable,
    write_data                 => write_data,
    read_clk                   => fabric_clk1x_in,
    read_data                  => read_data,
    read_enable                => read_increment,
    read_valid                 => open,
    full                       => full,
    full_thresh_assert         => full_thresh_assert,
    full_thresh_negate         => full_thresh_negate,
    overflow                   => overflow,
    empty                      => empty);

  overflow_out <= overflow;
  backpressure_out <= full;

  -------------------------------------------------------------------------------
  -- Fifo FOR event size
  -------------------------------------------------------------------------------
  
  event_length_fifo: fifo16_dual_clk
  PORT MAP(
    clear                      => clear,
    write_clk                  => link_clk1x_in,
    write_enable               => event_length_write_enable,
    write_data                 => std_logic_vector(event_length),
    read_clk                   => fabric_clk1x_in,
    read_data                  => event_length_read_data,
    read_enable                => event_length_read_increment,
    read_valid                 => OPEN);

   -------------------------------------------------------------------------------
   -- Link Clk domain
   -------------------------------------------------------------------------------

   event_length_write_enable <=  event_end AND enable;

   event_sm : PROCESS(link_reset_in, link_clk1x_in)
   BEGIN
      IF (link_reset_in = '1') THEN
        state <= IDLE;
        event_begin <= '0'; -- default
        event_end <= '0';  -- default
        event_length <= x"0000";
        write_enable <= '0';
        write_data <= (OTHERS => '0');
      ELSIF (link_clk1x_in = '1' AND link_clk1x_in'event) THEN    
         IF clear = '1' THEN
            state <= IDLE;
            event_begin <= '0'; -- default
            event_end <= '0';  -- default
            event_length <= x"0000";
         ELSE
            event_begin <= '0'; -- default
            event_end <= '0';  -- default
            CASE state IS
            WHEN IDLE =>
               -- Check FOR beginning OF event..
               IF (daq_start_in = '1') AND (enable = '1') THEN
                  event_length <= to_unsigned(0,16);
                  state <= SLINK_ACTIVE;
                  event_begin <= '1';
               END IF; 
            WHEN SLINK_ACTIVE =>
              -- Check FOR END OF event..
              IF (daq_stop_in = '1') THEN
                state <= IDLE;
                event_end <= '1';
              END IF;
              -- Place data IN BUFFER AND increment event length counter
              IF (daq_valid_in = '1') THEN
                event_length <= event_length + 1;
                write_enable <= '1';
                write_data <= daq_data_in;
              ELSE
                write_enable <= '0';
                write_data <= (OTHERS => '0');
              END IF; 
            WHEN OTHERS =>
               NULL;
               ASSERT false
                  report "State machine entered illegal state."
                  SEVERITY failure;
            END CASE;
         END IF;
      END IF;
   END PROCESS event_sm;

   -- The event driver counts events stored IN the SlinkLengthFifo
   event_driver <= event_length_write_enable & event_length_read_increment;

   events_stored : PROCESS(link_reset_in, link_clk1x_in)
   BEGIN
      IF (link_reset_in = '1') THEN
         events <= 0;
         event_length_empty <= '1';
      ELSIF (link_clk1x_in = '1' AND link_clk1x_in'event) THEN    
         IF clear = '1' THEN
            events <= 0;
            event_length_empty <= '1';
         ELSE
            CASE event_driver IS
            WHEN "01" =>
               events <= events - 1;
            WHEN "10" =>
               events <= events + 1;
            WHEN OTHERS =>
               NULL;
            END CASE;
         END IF;
         IF events = 0 THEN
            event_length_empty <= '1';
         ELSE
            event_length_empty <= '0';
         END IF;
      END IF;
   END PROCESS events_stored;

END behave;


