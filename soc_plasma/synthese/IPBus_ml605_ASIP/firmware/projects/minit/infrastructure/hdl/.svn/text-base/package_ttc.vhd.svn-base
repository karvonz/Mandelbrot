
---------------------------------------------------------------
-- TTC : L1a Timing & Control, Version 2.0
---------------------------------------------------------------   


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.package_comm.ALL;
USE work.package_utilities.ALL;

PACKAGE package_ttc IS

  -- IF you add extra TTC commands here please also add them TO the functions
  -- "ttc_cmd_enum2vec" AND "ttc_cmd_vec2enum" that allow conversion to/from
  -- vectors IN the PACKAGE BODY.
  TYPE type_ttc_cmd IS 
  (
    BUNCH_CROSS_ZERO,  
    RESET_EVENT_CNT,   
    RESET_ORBIT_CNT,   
    RESYNC,            
    LAUNCH_REALIGNMENT,
    LAUNCH_PATT_INJ,   
    BIST,
    TEST_B_CHAN,
    CAPTURE_GT_DATA,
    NO_COMMAND);

  FUNCTION ttc_cmd_enum2vec(ttc_cmd_enum: type_ttc_cmd) RETURN std_logic_vector;
  FUNCTION ttc_cmd_vec2enum(ttc_cmd_vec: std_logic_vector(7 DOWNTO 0)) RETURN type_ttc_cmd;

  TYPE sync_comm_type is RECORD
    bc0: std_logic;
    reset_event_cnt: std_logic;
    reset_orbit_cnt: std_logic;
    resynch: std_logic;
    launch_realignment: std_logic;
    launch_patt_inj: std_logic;
    bist: std_logic;
    test_b_chan: std_logic;
    capture_gt_data: std_logic;
    trigger: std_logic;
  END RECORD;

  CONSTANT sync_comm_null: sync_comm_type := (
    bc0 => '0',
    reset_event_cnt => '0',
    reset_orbit_cnt => '0',
    resynch => '0',
    launch_realignment => '0',
    launch_patt_inj => '0',
    bist => '0',
    test_b_chan => '0',
    capture_gt_data => '0',
    trigger => '0');

END package_ttc;

-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   

-- TTCrx manual specifies 
-- bit 0 TO indicate BUNCH_CROSS_ZERO
-- bit 1 TO indicate RESET_EVENT_CNT
-- bits 5:2 FOR system messages
-- bits 7:6 FOR user messages

PACKAGE BODY package_ttc IS

   FUNCTION ttc_cmd_enum2vec(ttc_cmd_enum: type_ttc_cmd) RETURN std_logic_vector IS
      VARIABLE ttc_cmd_vec : std_logic_vector(7 DOWNTO 0);
   BEGIN
      CASE ttc_cmd_enum IS
         WHEN BUNCH_CROSS_ZERO   => ttc_cmd_vec := "00000001";
         WHEN RESET_EVENT_CNT    => ttc_cmd_vec := "00000010";
         WHEN RESET_ORBIT_CNT    => ttc_cmd_vec := "00000100";
         WHEN RESYNC             => ttc_cmd_vec := "00001000";
         WHEN LAUNCH_REALIGNMENT => ttc_cmd_vec := "00001100";
         WHEN LAUNCH_PATT_INJ    => ttc_cmd_vec := "00010000";
         WHEN BIST               => ttc_cmd_vec := "00010100";
         WHEN TEST_B_CHAN        => ttc_cmd_vec := "00011000";
         WHEN CAPTURE_GT_DATA    => ttc_cmd_vec := "00011001";
         WHEN NO_COMMAND         => ttc_cmd_vec := "00000000";
         WHEN OTHERS             => ttc_cmd_vec := "00000000";
      END CASE;
      RETURN ttc_cmd_vec;
   END ttc_cmd_enum2vec;
   --
   FUNCTION ttc_cmd_vec2enum(ttc_cmd_vec: std_logic_vector(7 DOWNTO 0)) RETURN type_ttc_cmd IS
      VARIABLE ttc_cmd_enum : type_ttc_cmd;
   BEGIN
      CASE ttc_cmd_vec IS
         WHEN "00000001" => ttc_cmd_enum := BUNCH_CROSS_ZERO; 
         WHEN "00000010" => ttc_cmd_enum := RESET_EVENT_CNT;  
         WHEN "00000100" => ttc_cmd_enum := RESET_ORBIT_CNT;  
         WHEN "00001000" => ttc_cmd_enum := RESYNC; 
         WHEN "00001100" => ttc_cmd_enum := LAUNCH_REALIGNMENT; 
         WHEN "00010000" => ttc_cmd_enum := LAUNCH_PATT_INJ; 
         WHEN "00010100" => ttc_cmd_enum := BIST; 
         WHEN "00011000" => ttc_cmd_enum := TEST_B_CHAN;
         WHEN "00011001" => ttc_cmd_enum := CAPTURE_GT_DATA;         
         WHEN OTHERS     => ttc_cmd_enum := NO_COMMAND;
      END CASE;
      RETURN ttc_cmd_enum;
   END ttc_cmd_vec2enum;

END package_ttc;

-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_ttc.ALL;
USE work.package_types.ALL;

ENTITY ttc_check IS
   GENERIC(
      -- Pass GENERIC TO make orbit smaller IN simulation
      local_lhc_bunch_count:  integer);
   PORT( 
      reset_b:                IN std_logic;
      clk40:                  IN std_logic;
      l1a:                    IN std_logic;
      bc0:                    IN std_logic;
      ttc_cmd:                IN type_ttc_cmd;
      -- Counters that can be read back TO ensure ALL TTC info sent OK.
      l1a_cnt:                OUT std_logic_vector(31 DOWNTO 0);
      ttc_cmd_cnt:            OUT std_logic_vector(31 DOWNTO 0);
      -- The bunch & orbit counter provide "LHC time".
      -- Both default TO ALL '1's WHEN "LHC" time is meaningless (e.g. bc0 sync loss)
      bunch_cnt:              OUT std_logic_vector(11 DOWNTO 0);
      orbit_cnt:              OUT std_logic_vector(31 DOWNTO 0);
      -- Note that AFTER TTC "RESYNC" system will NOT be OutOfSync, however UNTIL 
      -- the first BCO is received bc0 checking will NOT be operating. 
      bc0_check_operating:    OUT std_logic;
      bc0_check_outofsync:    OUT std_logic);
END ttc_check;

ARCHITECTURE behave OF ttc_check IS

   SIGNAL bc0_check: std_logic_vector(1 DOWNTO 0);
   SIGNAL bc0_local: std_logic;
   SIGNAL bc0_check_outofsync_int: std_logic;
   SIGNAL bc0_check_operating_int: std_logic;
   SIGNAL bunch_cnt_int: unsigned (11 DOWNTO 0);
   SIGNAL orbit_cnt_int: unsigned (31 DOWNTO 0);
   SIGNAL l1a_cnt_int: unsigned(31 DOWNTO 0);
   SIGNAL ttc_cmd_cnt_int: unsigned(31 DOWNTO 0);

begin

   bc0_sync_check: PROCESS(reset_b, clk40)
   BEGIN
      IF (reset_b = '0') THEN
         -- Invalid bunch crossing (i.e. will be obvious that "LHC time" invalid WHEN read back) 
         orbit_cnt_int <= (OTHERS => '1');
         bunch_cnt_int <= (OTHERS => '1');
         bc0_check_outofsync_int <= '1';
         bc0_check_operating_int <= '0';
      ELSIF (clk40 = '1' AND clk40'event) THEN
         -- Only reset TTC IF OutOfSync
         IF (ttc_cmd = RESYNC) AND (bc0_check_outofsync_int = '1') THEN
            bc0_check_outofsync_int <= '0';
            -- Invalid bunch crossing (i.e. will be obvious that "LHC time" invalid WHEN read back) 
            bunch_cnt_int <= (OTHERS => '1');     
            bc0_check_operating_int <= '0';
         ELSIF (bc0_check_outofsync_int = '0') THEN
            IF (bc0_check_operating_int = '0') THEN
               -- Awaiting first bc0
               IF (bc0 = '1') THEN
                  bc0_check_operating_int <= '1';
                  bunch_cnt_int <= to_unsigned(1,12);
                  orbit_cnt_int <= (OTHERS => '0');
               END IF;
            ELSE
               -- Time system running normally (i.e. bc0_check_operating_int = '1')
               -- Check FOR sync
               CASE bc0_check IS
                  WHEN "10"  =>
                     --Lost sync (bc0 from TCS, but no local bc0)
                     bc0_check_outofsync_int <= '1';
                     bc0_check_operating_int <= '0';
                     bunch_cnt_int <= (OTHERS => '1');
                     -- orbit_cnt_int <= (OTHERS => '1');
                  WHEN "01"  =>
                     --Lost sync (No bc0 from TCS, but local bc0)
                     bc0_check_outofsync_int <= '1';
                     bc0_check_operating_int <= '0';
                     bunch_cnt_int <= (OTHERS => '1');
                     -- orbit_cnt_int <= (OTHERS => '1');
                  WHEN OTHERS  =>
                     -- System running normally.  Increment orbit + bunch counters
                     IF bunch_cnt_int = (local_lhc_bunch_count - 1) THEN
                        bunch_cnt_int <= (OTHERS => '0');
                        orbit_cnt_int <= orbit_cnt_int + 1;
                     ELSE
                        bunch_cnt_int <= bunch_cnt_int + 1;
                     END IF;
               END CASE;
            END IF;
         END IF;
         IF (ttc_cmd = RESET_ORBIT_CNT) THEN
            orbit_cnt_int <= (OTHERS => '0');
         END IF;
      END IF;
   END PROCESS;

   -- GENERATE local bc0.
   bc0_local <= '1' WHEN (bunch_cnt_int = 0) ELSE '0';
   -- Create SIGNAL from both TTC BC0 AND local BC0 TO evaluate IF system IN sync.
   bc0_check <=  bc0 & bc0_local;

   bc0_check_outofsync <= bc0_check_outofsync_int;
   bc0_check_operating <= bc0_check_operating_int;
   bunch_cnt <= std_logic_vector(bunch_cnt_int);
   orbit_cnt <= std_logic_vector(orbit_cnt_int);

   ttc_counters: PROCESS (reset_b, clk40) 
   BEGIN
      IF reset_b = '0' THEN
         l1a_cnt_int <= (OTHERS => '0');
         ttc_cmd_cnt_int <= (OTHERS => '0');
      ELSIF (clk40'event AND clk40 = '1') THEN
         IF ttc_cmd = RESET_EVENT_CNT THEN
            l1a_cnt_int <= (OTHERS => '0');
         ELSIF l1a = '1' THEN
            l1a_cnt_int <= l1a_cnt_int + 1;
         END IF;
         IF ttc_cmd /= NO_COMMAND THEN
            -- Can only reset ttc_cmd counter by async reset od system.
            ttc_cmd_cnt_int <= ttc_cmd_cnt_int + 1;
         END IF;
      END IF;
   END PROCESS;

   l1a_cnt <= std_logic_vector(l1a_cnt_int);
   ttc_cmd_cnt <= std_logic_vector(ttc_cmd_cnt_int);

END behave;

-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_ttc.ALL;
USE work.package_types.ALL;

ENTITY ttc_sync_comm IS
   PORT (
      reset_b:                   IN std_logic;
      clk40:                     IN std_logic;
      -- TTC l1a & cmd as enum TYPE. 
      ttc_cmd:                   IN type_ttc_cmd;
      l1a:                       IN std_logic;
      -- TTC output
      sync_comm:                 OUT sync_comm_type);
END ttc_sync_comm;

ARCHITECTURE behave OF ttc_sync_comm IS
begin

   assign_sync_comm: PROCESS (reset_b, ttc_cmd, l1a) BEGIN
      IF reset_b = '0' THEN
         sync_comm <= sync_comm_null;
      ELSE
         --  Set default..
         sync_comm <= sync_comm_null;
         -- Assign B channel commands..
         CASE ttc_cmd IS
            WHEN BUNCH_CROSS_ZERO => 
               sync_comm.bc0 <= '1';
            WHEN RESET_EVENT_CNT => 
               sync_comm.reset_event_cnt <= '1';
            WHEN RESET_ORBIT_CNT => 
               sync_comm.reset_orbit_cnt <= '1';
            WHEN RESYNC => 
               sync_comm.resynch <= '1';
            WHEN LAUNCH_REALIGNMENT => 
               sync_comm.launch_realignment <= '1';
            WHEN LAUNCH_PATT_INJ => 
               sync_comm.launch_patt_inj <= '1';
            WHEN BIST => 
               sync_comm.bist <= '1';
            WHEN TEST_B_CHAN => 
               sync_comm.test_b_chan <= '1';
            WHEN CAPTURE_GT_DATA => 
               sync_comm.capture_gt_data <= '1';
            WHEN OTHERS =>
               NULL;
         END CASE;
         -- Assign A channel commands..
         sync_comm.trigger <= l1a;
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
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_ttc.ALL;
USE work.package_types.ALL;
USE work.package_serial.ALL;

ENTITY ttc_serialise IS
   PORT (
      reset_b:                      IN std_logic;
      clk40:                        IN std_logic;
      ttc_en_in:                    IN std_logic;
      ttc_l1a_in:                   IN std_logic;
      ttc_cmd_vector_in:            IN std_logic_vector(7 DOWNTO 0);
      ttc_cmd_strobe_in:            IN std_logic;
      ttc_chan_a_out:               OUT std_logic;
      ttc_chan_b_out:               OUT std_logic);
END ttc_serialise;

ARCHITECTURE behave OF ttc_serialise IS

   SIGNAL ttc_chan_a_pipeline: std_logic_vector(1 DOWNTO 0);
   SIGNAL ttc_l1a: std_logic;
   SIGNAL ttc_cmd_strobe: std_logic;
   SIGNAL ttc_cmd_vector: std_logic_vector(7 DOWNTO 0);

begin

   --------------------------------------------------------------------------
   -- (1) Enable external B channel
   --------------------------------------------------------------------------

   ttc_en_proc: PROCESS (reset_b, clk40) BEGIN
      IF reset_b = '0' THEN
         ttc_cmd_strobe <= '0';
         ttc_cmd_vector <= x"00";
         ttc_l1a <= '0';
      ELSIF (clk40'event AND clk40 = '1') THEN
         IF ttc_en_in = '1' THEN
            ttc_cmd_strobe <= ttc_cmd_strobe_in;
            ttc_cmd_vector <= ttc_cmd_vector_in;
            ttc_l1a <= ttc_l1a_in;
         ELSE
            ttc_cmd_strobe <= '0';
            ttc_cmd_vector <= x"00";
            ttc_l1a <= '0';
         END IF;
      END IF;
   END PROCESS ttc_en_proc;

   --------------------------------------------------------------------------
   -- (2) Serialise external B channel
   --------------------------------------------------------------------------

   -- The danger OF using an external serialisation COMPONENT 
   -- is that the latency changes AND thus the l1a AND BC0
   -- become OUT OF sync.  TBD WITH Magnus.
   ttc_cmd_serialise: nrztrigxmt
   GENERIC MAP (
      size => 8)
   PORT MAP (
      clk => clk40, 
      rst => reset_b, 
      xmt => ttc_cmd_strobe, 
      clen => 7,
      idat => ttc_cmd_vector, 
      serout => ttc_chan_b_out,
      done => OPEN);

   -- Must delay L1A TO maintain timing between BCo AND L1A
   select_ttc_source: PROCESS (reset_b, clk40) BEGIN
      IF reset_b = '0' THEN
         ttc_chan_a_pipeline <= (OTHERS => '0');
      ELSIF (clk40'event AND clk40 = '1') THEN
         ttc_chan_a_pipeline(0) <= ttc_l1a;
         FOR i IN 0 TO (ttc_chan_a_pipeline'high - 1) LOOP
            ttc_chan_a_pipeline(i+1) <= ttc_chan_a_pipeline(i);
         END LOOP;
      END IF;
   END PROCESS;

   ttc_chan_a_out <= ttc_chan_a_pipeline(ttc_chan_a_pipeline'high);

END behave;


-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_ttc.ALL;
USE work.package_types.ALL;
USE work.package_serial.ALL;

ENTITY ttc_deserialise IS
   PORT (
      reset_b:                    IN std_logic;
      clk40:                      IN std_logic;
      ttc_chan_a_in:              IN std_logic;
      ttc_chan_b_in:              IN std_logic;
      ttc_l1a_out:                OUT std_logic;
      ttc_cmd_vector_out:         OUT std_logic_vector(7 DOWNTO 0);
      ttc_cmd_strobe_out:         OUT std_logic;
      ttc_cmd_error_out:          OUT std_logic);
END ttc_deserialise;

ARCHITECTURE behave OF ttc_deserialise IS

   SIGNAL ttc_chan_a_pipeline: std_logic_vector(34 DOWNTO 0);

begin

   --------------------------------------------------------------------------
   -- (1) Deserialise external B channel
   --------------------------------------------------------------------------

   -- The danger OF using an external serialisation COMPONENT 
   -- is that the latency changes AND thus the l1a AND BC0
   -- become OUT OF sync.  TBD WITH Magnus.

   ttc_deserialise: nrztrigrec
   GENERIC MAP (
      size => 8)
   PORT MAP (
      clk => clk40, 
      rst => reset_b, 
      indat => ttc_chan_b_in, 
      done => ttc_cmd_strobe_out,
      err => ttc_cmd_error_out, 
      bcount => open, 
      odat => ttc_cmd_vector_out);

   -- Must delay L1A TO maintain timing between BCo AND L1A
   select_ttc_source: PROCESS (reset_b, clk40) BEGIN
      IF reset_b = '0' THEN
         ttc_chan_a_pipeline <= (OTHERS => '0');
      ELSIF (clk40'event AND clk40 = '1') THEN
         ttc_chan_a_pipeline(0) <= ttc_chan_a_in;
         FOR i IN 0 TO (ttc_chan_a_pipeline'high - 1) LOOP
            ttc_chan_a_pipeline(i+1) <= ttc_chan_a_pipeline(i);
         END LOOP;
      END IF;
   END PROCESS;

   ttc_l1a_out <= ttc_chan_a_pipeline(ttc_chan_a_pipeline'high);

END behave;


-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
        
        
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_ttc.ALL;
USE work.package_types.ALL;
USE work.package_serial.ALL;

ENTITY ttc_control IS
   GENERIC (
      -- Pass GENERIC TO make orbit smaller IN simulation
      local_lhc_bunch_count:     integer;
      -- Number OF additional TTC slaves
      links:                     natural := 1);
   PORT (
      reset_b:                   IN std_logic;
      clk40:                     IN std_logic;
      -- TTC Source
      ttc_source_in:             IN std_logic;
      -- TTC External (TTCrx OR Upstream)
      ttcext_chan_a_in:          IN std_logic;
      ttcext_chan_b_in:          IN std_logic;
      -- TTC Local (VME)
      ttcvme_l1a_in:             IN std_logic;
      ttcvme_l1a_time_in:        IN std_logic_vector(11 DOWNTO 0);
      ttcvme_l1a_pending_out:    OUT std_logic;
      ttcvme_cmd_vector_in:      IN std_logic_vector(7 DOWNTO 0);
      ttcvme_cmd_strobe_in:      IN std_logic;
      ttcvme_cmd_time_in:        IN std_logic_vector(11 DOWNTO 0);
      ttcvme_cmd_pending_out:    OUT std_logic;
      ttcvme_bc0_en_in:          IN std_logic;
      -- TTC output
      ttc_sync_comm_out:         OUT sync_comm_type;
      ttc_cmd_out:               OUT type_ttc_cmd;
      l1a_out:                   OUT std_logic;
      -- Counters that can be read back TO ensure ALL TTC info sent OK.
      l1a_cnt_out:               OUT std_logic_vector(31 DOWNTO 0);
      ttc_cmd_cnt_out:           OUT std_logic_vector(31 DOWNTO 0);
      -- Provide LHC time AND bc0 check status.
      bunch_cnt_out:             OUT std_logic_vector(11 DOWNTO 0);
      orbit_cnt_out:             OUT std_logic_vector(31 DOWNTO 0);
      -- Note that AFTER TTC "RESYNC" system will be NOT be OutOfSync, however UNTIL 
      -- the first BCO is received bc0 checking will NOT be operating. 
      bc0_check_operating_out:   OUT std_logic;
      bc0_check_outofsync_out:   OUT std_logic;
      -- The TTC commands are distributed serially.  
      -- Hence possibility OF commands overlapping.
      ttc_cmd_collission_out:    OUT std_logic;
      ttc_cmd_corrupt_out:       OUT std_logic;
      -- Allow possibility TO clear TTC errors from VME
     ttc_clear_errors_in:        IN std_logic; 
      -- FOR distribution
      ttc_chan_a_array_out:      OUT std_logic_vector(links -1 DOWNTO 0);
      ttc_chan_b_array_out:      OUT std_logic_vector(links -1 DOWNTO 0));
END ttc_control;

ARCHITECTURE behave OF ttc_control IS

   SIGNAL ttc_chan_a: std_logic;
   SIGNAL ttc_chan_b: std_logic;
   SIGNAL cnt: natural RANGE 31 DOWNTO 0;
   SIGNAL ttc_cmd_strobe: std_logic;
   SIGNAL ttc_cmd_error: std_logic;
   SIGNAL ttc_cmd_vector: std_logic_vector(7 DOWNTO 0);
   SIGNAL ttc_cmd: type_ttc_cmd;
   SIGNAL l1a, l1a_int, bc0: std_logic;

   SIGNAL bunch_cnt: std_logic_vector(11 DOWNTO 0);
   SIGNAL orbit_cnt: std_logic_vector(31 DOWNTO 0);

   SIGNAL ttcvme_bc0_chan_a: std_logic;
   SIGNAL ttcvme_bc0_chan_b: std_logic;

   SIGNAL ttcvme_chan_a: std_logic;
   SIGNAL ttcvme_chan_b: std_logic;
   SIGNAL ttcvme_cmd_strobe: std_logic;
   SIGNAL ttcvme_cmd_vector: std_logic_vector(7 DOWNTO 0);
   SIGNAL ttcvme_cmd_time: std_logic_vector(11 DOWNTO 0);
   SIGNAL ttcvme_cmd_pending: std_logic;
   SIGNAL ttcvme_l1a: std_logic;
   SIGNAL ttcvme_l1a_pending: std_logic;
   SIGNAL ttcvme_l1a_time: std_logic_vector(11 DOWNTO 0);
   SIGNAL ttcvme_bunch_cnt: natural RANGE 4095 DOWNTO 0;
   SIGNAL ttcvme_bc0: std_logic;
   
   SIGNAL ttc_chan_a_pipeline: std_logic_vector(41 DOWNTO 0);
   SIGNAL ttc_chan_a_delayed: std_logic;
   SIGNAL ttc_chan_b_pipeline: std_logic_vector(41 DOWNTO 0);
   SIGNAL ttc_chan_b_delayed: std_logic;
   SIGNAL ttc_chan_b_pipeline_empty: std_logic;
   SIGNAL ttc_chan_b_pipeline_cnt: natural RANGE 0 TO 63;
   
   CONSTANT ttc_cmd_bc0: std_logic_vector(7 DOWNTO 0) := ttc_cmd_enum2vec(BUNCH_CROSS_ZERO);
   CONSTANT delay_to_out: std_logic_vector (11 DOWNTO 0) := std_logic_vector(to_unsigned(41,12)); 
   
   SIGNAL ttc_sync_comm: sync_comm_type;
   SIGNAL bunch_cnt_to_launch: std_logic_vector(11 DOWNTO 0);

   SIGNAL safe_to_exit_reset: std_logic;

begin

   --------------------------------------------------------------------------
   -- (1) BC0 WHEN external TTC system NOT used.
   --------------------------------------------------------------------------

   ttcvme_bc0_proc: PROCESS (reset_b, clk40) 
   BEGIN
      IF reset_b = '0' THEN
         ttcvme_bunch_cnt <= 0;
         ttcvme_bc0 <= '0';
      ELSIF (clk40'event AND clk40 = '1') THEN
         IF ttcvme_bunch_cnt /= 0 THEN
            ttcvme_bunch_cnt <= ttcvme_bunch_cnt - 1;
            ttcvme_bc0 <= '0';
         ELSE
            ttcvme_bunch_cnt <= natural(local_lhc_bunch_count)-1;
            ttcvme_bc0 <= ttcvme_bc0_en_in;
         END IF;
      END IF;
   END PROCESS;

   bc0_ser_inst: ENTITY work.ttc_serialise(behave)
   PORT MAP(
      reset_b => reset_b,        
      clk40 => clk40,       
      ttc_en_in => '1',           
      ttc_l1a_in => '0',          
      ttc_cmd_vector_in => ttc_cmd_bc0,    
      ttc_cmd_strobe_in => ttcvme_bc0,  
      ttc_chan_a_out => ttcvme_bc0_chan_a,       
      ttc_chan_b_out => ttcvme_bc0_chan_b);  

   --------------------------------------------------------------------------
   -- (2) Pipeline sync commands TO allow merging WITH TTC local (VME)
   --------------------------------------------------------------------------

   -- Store B chan commands IN pipeline so that we can guarantee 
   -- B-chann is free before sending commandm from VME.
   select_ttc_source: PROCESS (reset_b, clk40) BEGIN
      IF reset_b = '0' THEN
         safe_to_exit_reset <= '0';
         ttc_chan_a_pipeline <= (OTHERS => '0');
         ttc_chan_b_pipeline <= (OTHERS => '0');
         ttc_chan_b_pipeline_cnt <= 63;
         ttc_chan_b_pipeline_empty <= '0';
      ELSIF (clk40'event AND clk40 = '1') THEN
         -- Place TTC Command AND L1a IN pipelines
         IF ttc_source_in = '1' THEN
            ttc_chan_a_pipeline(0) <= ttcext_chan_a_in;
            ttc_chan_b_pipeline(0) <= ttcext_chan_b_in;
         ELSE
            ttc_chan_a_pipeline(0) <= ttcvme_bc0_chan_a;
            ttc_chan_b_pipeline(0) <= ttcvme_bc0_chan_b;
         END IF;
         -- Chan A Pipeline.
         FOR i IN 0 TO (ttc_chan_a_pipeline'high - 1) LOOP
            ttc_chan_a_pipeline(i+1) <= ttc_chan_a_pipeline(i);
         END LOOP;
         -- Chan B Pipeline.
         FOR i IN 0 TO (ttc_chan_b_pipeline'high - 1) LOOP
            ttc_chan_b_pipeline(i+1) <= ttc_chan_b_pipeline(i);
         END LOOP;
         -- USE counter TO determine activity IN TTCrx Command pipeline.
         IF ttc_chan_b_pipeline(0) = '1' THEN
            ttc_chan_b_pipeline_empty <= '0';
            ttc_chan_b_pipeline_cnt <= ttc_chan_b_pipeline'high;
         ELSIF ttc_chan_b_pipeline_cnt > 0 THEN
            ttc_chan_b_pipeline_empty <= '0';
            ttc_chan_b_pipeline_cnt <= ttc_chan_b_pipeline_cnt - 1;
         ELSE
            ttc_chan_b_pipeline_empty <= '1';
         END IF;
         -- Make sure that there are no command fragments IN pipeline WHEN reset removed.
         IF ttc_chan_b_pipeline_empty = '1' THEN
            safe_to_exit_reset <= '1';
         END IF;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------------------
   -- (3) Make sure serial stream empty before coming OUT OF reset.
   --------------------------------------------------------------------------

   ttc_chan_b_delayed <= ttc_chan_b_pipeline(ttc_chan_b_pipeline'high) 
      WHEN  safe_to_exit_reset = '1' ELSE '0';
   
   ttc_chan_a_delayed <= ttc_chan_a_pipeline(ttc_chan_b_pipeline'high) 
      WHEN  safe_to_exit_reset = '1' ELSE '0';

   --------------------------------------------------------------------------
   -- (4) Serialise local B Channel (VME)
   --------------------------------------------------------------------------

   -- Locally generated L1A AND channel-B commands will be serialised AND THEN merged
   -- WITH external channels A AND B before being deserialised.  Must launch locally
   -- generated commands earlier TO allow FOR serialisation
   bunch_cnt_to_launch_local: PROCESS (reset_b, clk40) 
      VARIABLE bunch_cnt_to_launch_int : std_logic_vector(11 DOWNTO 0); 
   BEGIN
      IF reset_b = '0' THEN
         bunch_cnt_to_launch <= x"FFF";         
      ELSIF (clk40'event AND clk40 = '1') THEN      
         bunch_cnt_to_launch_int := bunch_cnt + delay_to_out;
         IF (bunch_cnt_to_launch_int < local_lhc_bunch_count) THEN
            bunch_cnt_to_launch <= bunch_cnt_to_launch_int;
         ELSE
            bunch_cnt_to_launch <= bunch_cnt_to_launch_int - local_lhc_bunch_count;
         END IF;
      END IF;
   END PROCESS;

   ttcvme_cmd_schedule: PROCESS (reset_b, clk40) 
   BEGIN
      IF reset_b = '0' THEN
         ttcvme_cmd_strobe <= '0';
         ttcvme_cmd_vector <= (OTHERS => '0');
         ttcvme_cmd_time <= (OTHERS => '0');
         ttcvme_cmd_pending <= '0';
      ELSIF (clk40'event AND clk40 = '1') THEN
         -- By default do NOT transmit any command.
         ttcvme_cmd_strobe <= '0';
         -- Transmit VME generated commands IF serial line free.
         IF ttcvme_cmd_pending = '1' THEN      
            IF (bunch_cnt_to_launch = ttcvme_cmd_time) OR (bunch_cnt = x"FFF") THEN
               IF (ttc_chan_b_pipeline_empty = '1') THEN              
                  ttcvme_cmd_strobe <= '1';
                  ttcvme_cmd_pending <= '0';
               END IF;
            END IF;
         ELSE
            -- No commands pending.  Allow NEW commands TO be scheduled.
            IF (ttcvme_cmd_strobe_in = '1') THEN
               ttcvme_cmd_pending <= '1';
               -- REGISTER TTC command vector & time just IN CASE the user 
               -- changes the REGISTER AFTER sending the strobe SIGNAL.  FOR 
               -- example he/she may write TO the reg FOR a subsequent command.
               ttcvme_cmd_vector <= ttcvme_cmd_vector_in;
               ttcvme_cmd_time <= ttcvme_cmd_time_in;
            END IF;
         END IF;
      END IF;
   END PROCESS;


   ttcvme_l1a_schedule: PROCESS (reset_b, clk40) 
   BEGIN
      IF reset_b = '0' THEN
         ttcvme_l1a_time <= (OTHERS => '0');
         ttcvme_l1a_pending <= '0';
         ttcvme_l1a <= '0';
      ELSIF (clk40'event AND clk40 = '1') THEN
         -- By default do NOT transmit l1a
         ttcvme_l1a <= '0';
         -- Unlike  TTC Commands (B chan): No check TO see IF L1a line free.
         IF ttcvme_l1a_pending = '1' THEN      
            IF (bunch_cnt_to_launch = ttcvme_l1a_time)  OR (bunch_cnt = x"FFF") THEN
               ttcvme_l1a <= '1';
               ttcvme_l1a_pending <= '0';
            END IF;
         ELSE
            -- No commands pending.  Allow NEW commands TO be scheduled.
            IF (ttcvme_l1a_in = '1') THEN
               ttcvme_l1a_pending <= '1';
               ttcvme_l1a_time <= ttcvme_l1a_time_in;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   ttcvme_ser_inst: ENTITY work.ttc_serialise(behave)
   PORT MAP(
      reset_b => reset_b,        
      clk40 => clk40,       
      ttc_en_in => '1',           
      ttc_l1a_in => ttcvme_l1a,          
      ttc_cmd_vector_in => ttcvme_cmd_vector,    
      ttc_cmd_strobe_in => ttcvme_cmd_strobe,  
      ttc_chan_a_out => ttcvme_chan_a,       
      ttc_chan_b_out => ttcvme_chan_b);  

   --------------------------------------------------------------------------
   -- (5) Merge TTCrx AND TTCvme
   --------------------------------------------------------------------------

   ttc_chan_a <= ttc_chan_a_delayed OR ttcvme_chan_a;
   ttc_chan_b <= ttc_chan_b_delayed OR ttcvme_chan_b;

   -- No check FOR collission between VME/TTCrx yet.
   ttc_cmd_collission_out <= '0';

   --------------------------------------------------------------------------
   -- (6) Deserialise
   --------------------------------------------------------------------------

   ttc_deserialise: ENTITY work.ttc_deserialise(behave)
   PORT MAP(
      clk40 => clk40, 
      reset_b => reset_b, 
      ttc_chan_a_in => ttc_chan_a,
      ttc_chan_b_in => ttc_chan_b,
      ttc_l1a_out => l1a_int,
      ttc_cmd_vector_out => ttc_cmd_vector,
      ttc_cmd_strobe_out => ttc_cmd_strobe,
      ttc_cmd_error_out => ttc_cmd_error);

   reg_ttc_cmd: PROCESS (reset_b, clk40) BEGIN
      IF reset_b = '0' THEN
         ttc_cmd <= NO_COMMAND;
         ttc_cmd_corrupt_out <= '0';
         l1a <= '0';
      ELSIF (clk40'event AND clk40 = '1') THEN
         -- delay l1a 1 clk TO keep IN sunc WITH ttc_cmd
         l1a <= l1a_int;
         IF ttc_cmd_error = '1' THEN
            ttc_cmd_corrupt_out <= '1';
            ttc_cmd <= NO_COMMAND;
         ELSE
            IF ttc_clear_errors_in = '1' THEN
              ttc_cmd_corrupt_out <= '0';
            END IF;
            IF ttc_cmd_strobe = '1' THEN
               ttc_cmd <= ttc_cmd_vec2enum(ttc_cmd_vector);
            ELSE
               ttc_cmd <= NO_COMMAND;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   --------------------------------------------------------------------------
   -- (7) Output
   --------------------------------------------------------------------------


   ttcvme_cmd_pending_out <= ttcvme_cmd_pending;
   ttcvme_l1a_pending_out <= ttcvme_l1a_pending;

   
   -- Following RECORD used TO distribute sync SIGNAL 
   -- everywhere except core TTC code
   create_ttc_vhdl_record: ENTITY work.ttc_sync_comm(behave)
   PORT MAP(
      reset_b => reset_b,
      clk40 => clk40,
      ttc_cmd => ttc_cmd,
      l1a => l1a,
      sync_comm => ttc_sync_comm);

   out_proc: PROCESS (reset_b, clk40) BEGIN
      IF reset_b = '0' THEN
         ttc_sync_comm_out <= sync_comm_null;
         ttc_cmd_out <= NO_COMMAND; 
         l1a_out <= '0';
         bunch_cnt_out <= (OTHERS => '0');
         orbit_cnt_out <= (OTHERS => '0');
         ttc_chan_a_array_out <= (OTHERS => '0');
         ttc_chan_b_array_out <= (OTHERS => '0');
      ELSIF (clk40'event AND clk40 = '1') THEN
         -- Must delay ALL these signals by 1 clk TO allow FOR delay 
         -- IN trigger counter
         ttc_sync_comm_out <= ttc_sync_comm;
         ttc_cmd_out <= ttc_cmd; 
         l1a_out <= l1a;
         bunch_cnt_out <= bunch_cnt;
         orbit_cnt_out <= orbit_cnt;
        -- Create TTC word FOR distribution TO slaves.
         -- Place IN clked PROCESS TO create registers IN IOBs
         ttc_chan_a_array_out <= (OTHERS => ttc_chan_a);
         ttc_chan_b_array_out <= (OTHERS => ttc_chan_b);
      END IF;
   END PROCESS;

   --------------------------------------------------------------------------
   -- (8) Checks
   --------------------------------------------------------------------------

   bc0 <= '1' WHEN ttc_cmd = BUNCH_CROSS_ZERO ELSE '0';

   ttc_check_inst: ENTITY work.ttc_check(behave)
      GENERIC MAP(
         local_lhc_bunch_count   => local_lhc_bunch_count)
      PORT MAP( 
         reset_b                 => reset_b,
         clk40                   => clk40,
         l1a                     => l1a,
         bc0                     => bc0,
         ttc_cmd                 => ttc_cmd,
         l1a_cnt                 => l1a_cnt_out,
         ttc_cmd_cnt             => ttc_cmd_cnt_out,
         bunch_cnt               => bunch_cnt,                    
         orbit_cnt               => orbit_cnt,         
         bc0_check_operating     => bc0_check_operating_out,
         bc0_check_outofsync     => bc0_check_outofsync_out);

END behave;

-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_ttc.ALL;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_utilities.ALL;
USE work.package_modules.ALL;


ENTITY ttc_control_with_comm_interface IS
   GENERIC (
      module:                       type_mod_define := module_ttc;
      -- Pass GENERIC TO make orbit smaller IN simulation
      local_lhc_bunch_count:        integer;
      -- Number OF TTC slaves TO drive from this TTC master
      links:                        integer := 1);
   PORT (
      reset_b:                      IN std_logic;
      clk40:                        IN std_logic;
      -- Comm interface used FOR slow control REGISTER ACCESS
      comm_cntrl:                   IN type_comm_cntrl;
      comm_reply:                   OUT type_comm_reply;
      -- TTC External
      ttcext_chan_a_in:             IN std_logic;
      ttcext_chan_b_in:             IN std_logic;
      ttcext_ready_in:              IN std_logic;
      ttcext_reset_b_out:           OUT std_logic;
      ttcext_cmd_strobe_gap_min_in: IN std_logic_vector(11 DOWNTO 0);
      ttcext_cmd_vector_last_in:    IN std_logic_vector(7 DOWNTO 0);
      -- TTC output
      ttc_sync_comm_out:            OUT sync_comm_type;
      ttc_cmd_out:                  OUT type_ttc_cmd;
      l1a_out:                      OUT std_logic;
      l1a_cnt_out:                  OUT std_logic_vector(31 DOWNTO 0);
      -- No BUNCH_CROSS_ZERO coun   ter.  Instead provide LHC time AND bc0 check status.
      bunch_cnt_out:                OUT std_logic_vector(11 DOWNTO 0);
      orbit_cnt_out:                OUT std_logic_vector(31 DOWNTO 0);
      -- TTC distribution network   .
      ttc_chan_a_array_out:         OUT std_logic_vector(links-1 DOWNTO 0);
      ttc_chan_b_array_out:         OUT std_logic_vector(links-1 DOWNTO 0);
      ttc_ok_out:                   OUT std_logic;
      ttc_reset_b_out:              OUT std_logic;
		ttc_selfdestruct_out:         OUT std_logic);

END ttc_control_with_comm_interface;

ARCHITECTURE behave OF ttc_control_with_comm_interface IS

   
   SIGNAL ttcvme_l1a: std_logic;
   SIGNAL ttcvme_l1a_time: std_logic_vector(11 DOWNTO 0);
   SIGNAL ttcvme_l1a_pending: std_logic;
   SIGNAL ttcvme_bc0_en: std_logic;
   SIGNAL ttcvme_cmd_vector: std_logic_vector(7 DOWNTO 0);   
   SIGNAL ttcvme_cmd_time: std_logic_vector(11 DOWNTO 0);
   SIGNAL ttcvme_cmd_strobe: std_logic;
   SIGNAL ttcvme_cmd_pending: std_logic;
   
   SIGNAL l1a_cnt: std_logic_vector(31 DOWNTO 0);
   SIGNAL ttc_cmd_cnt: std_logic_vector(31 DOWNTO 0);
   SIGNAL bunch_cnt: std_logic_vector(11 DOWNTO 0);
   SIGNAL orbit_cnt: std_logic_vector(31 DOWNTO 0);
   
   SIGNAL bc0_check_operating: std_logic;
   SIGNAL bc0_check_outofsync: std_logic;
   
   SIGNAL ttc_cmd_collission: std_logic;
   SIGNAL ttc_cmd_corrupt: std_logic;
   
   SIGNAL ttc_source, ttc_clear_errors: std_logic;
   SIGNAL ttcext_reset, ttcext_reset_long: std_logic;

   -- Ensures comm cycle only takes 1 clk40 period.
   SIGNAL write_once       : std_logic;
   SIGNAL read_once        : std_logic;

   SIGNAL module_en: std_logic;

   SIGNAL ttc_selfdestruct, ttc_reset_b: std_logic;

begin

   ttc_control_inst: ENTITY work.ttc_control(behave)
   GENERIC MAP(
      local_lhc_bunch_count       => local_lhc_bunch_count,
      links                       => links)
   PORT MAP(
      reset_b                     => reset_b, 
      clk40                       => clk40,
      ttc_source_in               => ttc_source,
      ttcext_chan_a_in            => ttcext_chan_a_in,
      ttcext_chan_b_in            => ttcext_chan_b_in,
      ttcvme_l1a_in               => ttcvme_l1a,
      ttcvme_l1a_time_in          => ttcvme_l1a_time,
      ttcvme_l1a_pending_out      => ttcvme_l1a_pending, 
      ttcvme_bc0_en_in            => ttcvme_bc0_en, 
      ttcvme_cmd_vector_in        => ttcvme_cmd_vector, 
      ttcvme_cmd_time_in          => ttcvme_cmd_time,
      ttcvme_cmd_strobe_in        => ttcvme_cmd_strobe,
      ttcvme_cmd_pending_out      => ttcvme_cmd_pending,
      ttc_sync_comm_out           => ttc_sync_comm_out,
      ttc_cmd_out                 => ttc_cmd_out,
      l1a_out                     => l1a_out,
      l1a_cnt_out                 => l1a_cnt, 
      ttc_cmd_cnt_out             => ttc_cmd_cnt,
      bunch_cnt_out               => bunch_cnt,
      orbit_cnt_out               => orbit_cnt, 
      bc0_check_operating_out     => bc0_check_operating,
      bc0_check_outofsync_out     => bc0_check_outofsync,
      ttc_cmd_collission_out      => ttc_cmd_collission,
      ttc_cmd_corrupt_out         => ttc_cmd_corrupt,
      ttc_clear_errors_in         => ttc_clear_errors,     
      ttc_chan_a_array_out        => ttc_chan_a_array_out,
      ttc_chan_b_array_out        => ttc_chan_b_array_out);


  -- Does module base address match incoming address?
  module_en <= '1' WHEN (comm_cntrl.add AND (NOT module.addr_mask)) = module.addr_base ELSE '0';

  wishbone: PROCESS(clk40, reset_b)
  BEGIN

    IF (reset_b = '0') THEN

      -- Clear comm BUS
      write_once <= '0';
      read_once <= '0';
      comm_reply <= comm_reply_null;
      -- WriteRead regs
      ttc_source <= '0';
      ttcvme_bc0_en <= '0';
      ttc_reset_b <= '0';
      ttcvme_l1a_time <= x"100";
      ttcvme_cmd_vector <= x"00";
      ttcvme_cmd_time <= x"100";
      -- WrtieOnly regs
      ttcvme_l1a <= '0';
      ttcext_reset <= '0';
      ttcvme_cmd_strobe <= '0';
      ttc_clear_errors <= '0';
      ttc_selfdestruct <= '0';

    ELSIF (clk40'event AND clk40 = '1') THEN

      -- WrtieOnly regs default state
      ttcvme_l1a <= '0';
      ttcext_reset <= '0';
      ttcvme_cmd_strobe <= '0';
      ttc_clear_errors <= '0';
      ttc_selfdestruct <= '0';

      IF (comm_cntrl.stb = '1') AND (module_en = '1') THEN
        -- BUS active AND module selected
        comm_reply.ack <= '1';
        comm_reply.err <= '0';
        IF comm_cntrl.wen = '1' THEN          
          -- Write active
          IF (write_once ='0') THEN
            write_once <= '1';
            CASE comm_cntrl.add(7 DOWNTO 0) IS
            WHEN x"34" =>
              ttc_source <= comm_cntrl.wdata(0);
              ttcvme_bc0_en <= comm_cntrl.wdata(1);
              ttc_reset_b <= comm_cntrl.wdata(2);
            WHEN x"38" =>
              ttcvme_l1a_time <= comm_cntrl.wdata(11 DOWNTO 0);
              ttcvme_cmd_vector <= comm_cntrl.wdata(19 DOWNTO 12);
              ttcvme_cmd_time <= comm_cntrl.wdata(31 DOWNTO 20);
            WHEN x"3C" =>
              ttcvme_l1a <= comm_cntrl.wdata(0);
              ttcext_reset <= comm_cntrl.wdata(1);
              ttcvme_cmd_strobe <= comm_cntrl.wdata(2);
              ttc_clear_errors <= comm_cntrl.wdata(3);
              ttc_selfdestruct <= comm_cntrl.wdata(4);
            WHEN OTHERS =>
              NULL;
            END CASE;
          END IF;
        ELSE
          -- Read active
          IF (read_once ='0') THEN
            read_once <= '1';
            CASE comm_cntrl.add(7 DOWNTO 0) IS
            WHEN x"1C" =>
              comm_reply.rdata(11 DOWNTO 0) <= ttcext_cmd_strobe_gap_min_in;
              comm_reply.rdata(19 DOWNTO 12) <= ttcext_cmd_vector_last_in;
              comm_reply.rdata(31 DOWNTO 20) <= (OTHERS => '0');
            WHEN x"20" =>
              comm_reply.rdata(0) <= ttcvme_cmd_pending;
              comm_reply.rdata(1) <= ttcvme_l1a_pending;
              comm_reply.rdata(6 DOWNTO 2) <= (OTHERS => '0');
              comm_reply.rdata(7) <= ttc_cmd_corrupt;
              comm_reply.rdata(8) <= ttc_cmd_collission;
              comm_reply.rdata(9) <= '0';
              comm_reply.rdata(10) <= bc0_check_operating;
              comm_reply.rdata(11) <= bc0_check_outofsync;
              comm_reply.rdata(12) <= ttcext_ready_in;
              comm_reply.rdata(31 DOWNTO 13) <= (OTHERS => '0');
            WHEN x"24" =>
              comm_reply.rdata <= l1a_cnt;
            WHEN x"28" =>
              comm_reply.rdata <= ttc_cmd_cnt;
            WHEN x"2C" =>
              comm_reply.rdata <= orbit_cnt;
            WHEN x"30" =>
              comm_reply.rdata(11 DOWNTO 0) <= bunch_cnt;
              comm_reply.rdata(31 DOWNTO 12) <= (OTHERS => '0');
            WHEN x"34" =>
              comm_reply.rdata(0) <= ttc_source;
              comm_reply.rdata(1) <= ttcvme_bc0_en;
              comm_reply.rdata(2) <= ttc_reset_b;
              comm_reply.rdata(31 DOWNTO 3) <= (OTHERS => '0');
            WHEN x"38" =>
              comm_reply.rdata(11 DOWNTO 0) <= ttcvme_l1a_time;
              comm_reply.rdata(19 DOWNTO 12) <= ttcvme_cmd_vector;
              comm_reply.rdata(31 DOWNTO 20) <= ttcvme_cmd_time;
            WHEN x"3C" =>
              -- write only regs
              comm_reply.rdata <= (OTHERS => '0');
            WHEN OTHERS =>
              comm_reply.rdata <= (OTHERS => '0');  -- spare registers
            END CASE;
          END IF;
        END IF;
      ELSE
        -- No BUS ACCESS
        write_once <= '0';
        read_once <= '0';
        comm_reply <= comm_reply_null;
      END IF;

    END IF;
  END PROCESS wishbone;




   -- Need TO widen pulse because it will be sampled by async clk.
   ttc_selfdestruct_proc : PROCESS(clk40, reset_b)
     VARIABLE widen_pulse: std_logic_vector(2 DOWNTO 0);
   BEGIN
      IF reset_b = '0' THEN
         ttc_selfdestruct_out <= '0';
         widen_pulse := "000";
      ELSIF rising_edge(clk40) THEN
         IF ttc_selfdestruct = '1' THEN
            widen_pulse := "111";
         ELSE
            widen_pulse := widen_pulse(1 DOWNTO 0) & '0'; 
         END IF;
         ttc_selfdestruct_out <= widen_pulse(2);
      END IF;
   END PROCESS;


   -- TTCrx seems TO need a reset pulse OF 400ms TO lock TO become ready.
   -- Tracked TO missing connection ON first Concentrator.

   ttcext_inst: pulse_lengthen
   GENERIC MAP(
      pulse_length => 40000000, -- Used TO 1 second (40000000) because PromEn line NOT tied TO gnd ON TTCrx.  Set TO 10 FOR sim.
      pulse_init  => '1')
   PORT MAP( 
      clk         => clk40,
      reset_b     => reset_b,
      pulse_short => ttcext_reset,
      pulse_long  => ttcext_reset_long);

   ttcext_reset_b_out <= (NOT ttcext_reset_long) AND reset_b;

   bunch_cnt_out <= bunch_cnt;
   orbit_cnt_out <= orbit_cnt;
   l1a_cnt_out <= l1a_cnt;
   ttc_reset_b_out <= ttc_reset_b;

   output : PROCESS(clk40, reset_b)
   BEGIN
      IF reset_b = '0' THEN
         ttc_ok_out <= '0';
      ELSIF rising_edge(clk40) THEN
         ttc_ok_out <= bc0_check_operating AND (NOT bc0_check_outofsync);
      END IF;
   END PROCESS;

END behave;



