
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE package_cdc IS

   COMPONENT cdc_txdata IS
   PORT(
      rst:                       IN std_logic;
      clk1x:                     IN std_logic;
      clk4x:                     IN std_logic;
      data_in:                   IN std_logic_vector(16 DOWNTO 0);
      key_in:                    IN std_logic;
      data_out:                  OUT std_logic_vector(16 DOWNTO 0);
      pad_out:                   OUT std_logic);
   END COMPONENT;

   COMPONENT cdc_txdata_circular_buf IS
      PORT( 
         upstream_clk      : IN     std_logic;
         upstream_rst      : IN     std_logic;
         downstream_clk    : IN     std_logic;
         downstream_rst    : IN     std_logic;
         data_in           : IN     std_logic_vector(16 DOWNTO 0);
         data_out          : OUT    std_logic_vector(16 DOWNTO 0);
         pad_out           : OUT    std_logic);
   END COMPONENT;

   COMPONENT cdc_rxdata IS
   GENERIC(
      local_lhc_bunch_count:    integer);
   PORT (
      reset_in:               IN  std_logic;
      autoalign_once_in:     IN  std_logic;
      autoalign_auto_in:     IN  std_logic;
      link_clk_in:            IN std_logic;
      ttc_clk80_in:              IN  std_logic;
      ttc_clk160_in:            IN  std_logic;
      ttc_half_bunch_cnt_in: IN  std_logic_vector(12 DOWNTO 0);
      rx_data_in:          IN std_logic_vector(7 DOWNTO 0);
      rx_data_valid_in:    IN std_logic;
      rx_comma_valid_in:    IN std_logic;
      bc0_discrepancy_req_in:  IN  std_logic_vector(12 DOWNTO 0);
      decrease_delay_in:   IN  std_logic;
      increase_delay_in:      IN  std_logic;
      -- 8b/10b comma alignment
      rxbyteisaligned_in:      IN  std_logic;
      rxenpcommaalign_out:   OUT std_logic;
      rxenmcommaalign_out:   OUT std_logic;
      bc0_discrepancy_max_out:  OUT std_logic_vector(12 DOWNTO 0);
      bc0_discrepancy_min_out:  OUT std_logic_vector(12 DOWNTO 0);
      rx_data_out:    OUT std_logic_vector(15 DOWNTO 0);
      rx_data_valid_out:   OUT std_logic;
      autoalign_lock_checks_out: OUT std_logic_vector(31 DOWNTO 0);
      autoalign_status_out: OUT std_logic_vector(31 DOWNTO 0));
   END COMPONENT;

   COMPONENT kcode_word_insert IS
      PORT(
         data_in                         : IN   std_logic_vector(15 DOWNTO 0);
         comma_in                        : IN   std_logic;
         pad_in                          : IN   std_logic;
         data_out                        : OUT  std_logic_vector(15 DOWNTO 0);
         charisk_out                     : OUT  std_logic_vector(1 DOWNTO 0));
   END COMPONENT;

END PACKAGE;

---------------------------------------------------------------------------------------------------
-- Moves data between ttc clock AND link clock.  Link clk running faster than ttc clock 
-- so dummy words inserted into data stream.
---------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY cdc_txdata IS
PORT(
   rst:                       IN std_logic;
   clk1x:                     IN std_logic;
   clk4x:                     IN std_logic;
   data_in:                   IN std_logic_vector(16 DOWNTO 0);
   key_in:                    IN std_logic;
   data_out:                  OUT std_logic_vector(16 DOWNTO 0);
   pad_out:                   OUT std_logic);
END cdc_txdata;

ARCHITECTURE behave OF cdc_txdata IS
       
   TYPE type_vector_of_stdlogicvec_x17 is ARRAY(natural RANGE <>) OF std_logic_vector(16 DOWNTO 0);
   
   SIGNAL data_buf: type_vector_of_stdlogicvec_x17(3 DOWNTO 0);
   SIGNAL key_buf: std_logic_vector(3 DOWNTO 0);
   SIGNAL toggle_buf: std_logic_vector(3 DOWNTO 0);
   
   SIGNAL data_int: std_logic_vector(16 DOWNTO 0);
   SIGNAL pad_int: std_logic;
   SIGNAL toggle: std_logic;

begin

   PROCESS(clk4x)
   BEGIN
      IF rising_edge(clk4x) THEN
         data_buf <= (data_buf(2 DOWNTO 0) & data_in) AFTER 0.1 ns;
         key_buf <= (key_buf(2 DOWNTO 0) & key_in) AFTER 0.1 ns;
      END IF;
   END PROCESS;

   PROCESS(clk4x)
   BEGIN
      IF rising_edge(clk4x) THEN
         toggle_buf <= toggle_buf(2 DOWNTO 0) & toggle;
         IF (key_buf(2) XOR key_buf(3)) = '1' THEN
            -- Found transition edge
            data_int <= data_buf(1) AFTER 0.1 ns;
            pad_int <= '0' AFTER 0.1 ns;
         ELSE
            IF (toggle_buf = "0111") OR (toggle_buf = "1000") THEN
               pad_int <= '1' AFTER 0.1 ns;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS(clk1x, rst)
   BEGIN
      IF rst = '1' THEN
         toggle <= '0';
      ELSIF rising_edge(clk1x) THEN
         toggle <= NOT toggle AFTER 0.1 ns;
         data_out <= data_int;
         pad_out <= pad_int;
      END IF;
   END PROCESS;
      

END behave;


--------------------------------------------------------------------------------------

-- Introduction:

-- The ENTITY "cdc_txdata_circular_buf" takes data from the 80Mhz domain 
-- AND moves it into the 100mhz domain as quickly as possible (25ns).  
-- It operates by sequentially placing the data into 4 differnt registers.  
-- These registers are THEN read into the 100mhz domain IF their asociated 
-- data valid SIGNAL = '1'.  Hence it is called the "dv_method" OR data_valid 
-- method.

-- The following is important IF you want TO verify timing, however the data 
-- path from 80mhz TO 100mhz domain must NOT take longer than 15ns AND it 
-- typically takes 5-6ns.  Hence you would be very unluckly TO run into a timing 
-- error even without the following constrains.  You can always do a back anotated 
-- timing sim as a check.

--------------------------------------------------------------------------------------

-- Constraints (UCF FILE):

-- TO verify the timing you should make two groups IN the UCF FILE (output
-- flipflops at 80Mhz AND input flipflops at 100Mhz).  This might be easiest 
-- TO do WITH constraits editor.  THEN make a timing constraint between them.
-- Note that "sync_dv_method_1a" is just the instance name OF this ENTITY IN 
-- my test design.  This name/names will vary depending ON where your instance 
-- is named/located.

-- # Output data reg at 80MHz.
-- INST "sync_dv_method_1a/buf0_0" TNM = "sync_dv_method_output_80mhz_ff";
-- # Do this FOR ALL 17bits OF ALL 4 registers (buf0, buf1, buf2, buf3).

-- # Input data reg at 100MHz.
-- INST "sync_dv_method_1a/data_out_0" TNM = "sync_dv_method_input_100mhz_ff";
-- # Do this FOR ALL 17bits OF data_out REGISTER.

-- # Data must be latched into 100mhz domain AFTER a maximum OF 15ns.  
-- # Data from 80mhz domain must be stable at this point.
-- TIMESPEC "TS_" = FROM "sync_dv_method_output_80mhz_ff" TO "sync_dv_method_input_100mhz_ff" 10 ns;

-- You might also want TO do the following so that WHEN the design is back 
-- annotated you don't get 'X' propogation IN the simulation.
-- # Mark as async reg TO stop 'X' propogation IN back annotation.
-- INST "sync_dv_method_1a/dv_array_clk0_3" ASYNC_REG;

-- I aggree that ALL this UCF FILE nonsense is NOT nice, but I don't think I can enter 
-- these constraints IN the vhdl (at least NOT easily).  Greg

--------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY cdc_txdata_circular_buf IS
   PORT( 
      upstream_clk      : IN     std_logic;
      upstream_rst      : IN     std_logic;
      downstream_clk    : IN     std_logic;
      downstream_rst    : IN     std_logic;
      data_in           : IN     std_logic_vector(16 DOWNTO 0);
      data_out          : OUT    std_logic_vector(16 DOWNTO 0);
      pad_out           : OUT    std_logic);
END cdc_txdata_circular_buf ;

ARCHITECTURE behave OF cdc_txdata_circular_buf IS

   SIGNAL buf0, buf1, buf2, buf3: std_logic_vector(16 DOWNTO 0);  
   SIGNAL w_add, r_add: std_logic_vector(1 DOWNTO 0);
   SIGNAL dv_array, dv_array_clk0, dv_array_clk1: std_logic_vector(3 DOWNTO 0);

begin

   write_proc : PROCESS(upstream_clk, upstream_rst)
   BEGIN
      IF (upstream_rst = '1') THEN
         w_add <= "00";
         buf0 <= (OTHERS => '0');
         buf1 <= (OTHERS => '0');
         buf2 <= (OTHERS => '0');
         buf3 <= (OTHERS => '0');
      ELSIF (upstream_clk = '1' AND upstream_clk'event) THEN
         -- Increment write address IN grey code.
         -- Allows add TO be safely moved from the 
         -- 80MHz TO the 100mhz domain IF needed.
         CASE w_add IS
         WHEN "00" =>
            buf0 <= data_in;
            dv_array <= "1001";
            w_add <= "01";
         WHEN "01" =>
            buf1 <= data_in;
            dv_array <= "0011";
            w_add <= "11";
         WHEN "11" =>
            buf2 <= data_in;
            dv_array <= "0110";
            w_add <= "10";
         WHEN "10" =>
            buf3 <= data_in;
            dv_array <= "1100";
            w_add <= "00";
         WHEN OTHERS =>
            report "Invald address" SEVERITY failure;
         END CASE;
      END IF;
   END PROCESS write_proc;

   -- Originally clked dv_array (80MHz domain) first ON the rising 
   -- edge AND THEN ON falling edge OF downstream_clk.  OK IF "data_out" regs 
   -- were NOT IN IOBs.  Otherwise 5ns constraint ON "dv_array_clk1" 
   -- TO "data_out" regs too tight (only just).

   -- Swapped back TO original design.  Allows 100mhz signals TO be 
   -- sampled AND routed inside FPGA.  Useful FOR timing studies.
   
   -- First: clk data valid ON 100Mhz rising edge.
   dv_array_clk0_proc : PROCESS(downstream_clk, downstream_rst)
   BEGIN
      IF (downstream_rst = '1') THEN
         dv_array_clk0 <= "0000";
      ELSIF (downstream_clk = '1' AND downstream_clk'event) THEN
         dv_array_clk0 <= dv_array;
      END IF;
   END PROCESS dv_array_clk0_proc;

   -- Second: clk data valid ON 100Mhz falling edge.
   dv_array_clk1_proc : PROCESS(downstream_clk, downstream_rst)
   BEGIN
      IF (downstream_rst = '1') THEN
         dv_array_clk1 <= "0000";
      ELSIF (downstream_clk = '0' AND downstream_clk'event) THEN
         dv_array_clk1 <= dv_array_clk0;
      END IF;
   END PROCESS dv_array_clk1_proc;

   read_proc : PROCESS(downstream_clk, downstream_rst)
   BEGIN
      IF (downstream_rst = '1') THEN
         r_add <= "00";
         pad_out <= '0';
         data_out <= (OTHERS => '0');
      ELSIF (downstream_clk = '1' AND downstream_clk'event) THEN
         -- Watch OUT.. Using grey code FOR addressing.
         CASE r_add IS
         WHEN "00" =>
            IF dv_array_clk1(0) = '1' THEN
               data_out <= buf0;
               pad_out <= '0';
               r_add <= "01";
            ELSE
               pad_out <= '1';
            END IF;
         WHEN "01" =>
            IF dv_array_clk1(1) = '1' THEN
               data_out <= buf1;
               pad_out <= '0';
               r_add <= "11";
            ELSE
               pad_out <= '1';
            END IF;
         WHEN "11" =>
            IF dv_array_clk1(2) = '1' THEN
               data_out <= buf2;
               pad_out <= '0';
               r_add <= "10";
            ELSE
               pad_out <= '1';
            END IF;
         WHEN "10" =>
            IF dv_array_clk1(3) = '1' THEN
               data_out <= buf3;
               pad_out <= '0';
               r_add <= "00";
            ELSE
               pad_out <= '1';
            END IF;
         WHEN OTHERS =>
            report "Invald address" SEVERITY failure;
         END CASE;
      END IF;
   END PROCESS read_proc;


END behave;



---------------------------------------------------------------------------------------------------
-- Moves data between link clock AND ttc clock.  Link clk running faster than ttc clock 
-- so dummy words inserted into data stream.  This are removed before the data is written 
-- TO a dual PORT RAM.  Hence data the rate IN AND OUT OF the fifo is the same.  Code
-- automattically ensures byte order (byte TO word reassbly) AND bc0 discrepancy (difference
-- between ttc bc0 AND trig path bc0) are set correctly.
---------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY unisim;
USE unisim.vcomponents.ALL;
LIBRARY work;
USE work.package_types.ALL;

ENTITY cdc_rxdata IS
GENERIC(
   local_lhc_bunch_count:    integer);
PORT (
   reset_in:               IN  std_logic;
   autoalign_once_in:     IN  std_logic;
   autoalign_auto_in:     IN  std_logic;
   link_clk_in:            IN std_logic;
   ttc_clk80_in:              IN  std_logic;
   ttc_clk160_in:            IN  std_logic;
   ttc_half_bunch_cnt_in: IN  std_logic_vector(12 DOWNTO 0);
   rx_data_in:          IN std_logic_vector(7 DOWNTO 0);
   rx_data_valid_in:    IN std_logic;
   rx_comma_valid_in:    IN std_logic;
   bc0_discrepancy_req_in:  IN  std_logic_vector(12 DOWNTO 0);
   decrease_delay_in:   IN  std_logic;
   increase_delay_in:      IN  std_logic;
   -- 8b/10b comma alignment
   rxbyteisaligned_in:      IN  std_logic;
   rxenpcommaalign_out:   OUT std_logic;
   rxenmcommaalign_out:   OUT std_logic;
   bc0_discrepancy_max_out:  OUT std_logic_vector(12 DOWNTO 0);
   bc0_discrepancy_min_out:  OUT std_logic_vector(12 DOWNTO 0);
   rx_data_out:    OUT std_logic_vector(15 DOWNTO 0);
   rx_data_valid_out:   OUT std_logic;
   autoalign_lock_checks_out: OUT std_logic_vector(31 DOWNTO 0);
   autoalign_status_out: OUT std_logic_vector(31 DOWNTO 0));
END cdc_rxdata;

ARCHITECTURE behave OF cdc_rxdata IS
   

   SIGNAL fifoin_address_counter:  integer RANGE 0 TO 31;
   SIGNAL fifoout_address_counter:  integer RANGE 0 TO 31;
   SIGNAL fifoin_address_count:  std_logic_vector(10 DOWNTO 0);
   SIGNAL fifoout_address_count:  std_logic_vector(10 DOWNTO 0);
   SIGNAL fifoin_write_enable:  std_logic;
  
   SIGNAL input_flag: std_logic_vector(0 DOWNTO 0);
   SIGNAL output_flag: std_logic_vector(0 DOWNTO 0);


   SIGNAL rx_buf_data:  type_vector_of_stdlogicvec_x8(2 DOWNTO 0);
   SIGNAL rx_buf_flag: std_logic_vector(2 DOWNTO 0);

   SIGNAL rx_word_data:  std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
   SIGNAL rx_word_flag: std_logic_vector(1 DOWNTO 0) := (OTHERS => '0');
   SIGNAL rx_word_flag_latched: std_logic_vector(1 DOWNTO 0);  

   SIGNAL autoalign_operating: std_logic;
   SIGNAL autoalign_ok: std_logic;
   SIGNAL autoalign_increase_delay: std_logic;
   SIGNAL autoalign_byte_order: std_logic;
   SIGNAL autoalign_fifo_position: integer RANGE 0 TO 31;
   SIGNAL autoalign_lock_checks: unsigned(31 DOWNTO 0);
   SIGNAL autoalign_once: std_logic;
   SIGNAL autoalign_once_previous: std_logic;

   SIGNAL error_byte_align: std_logic;
   SIGNAL error_no_valid_fifo_location: std_logic;

   SIGNAL checklink_operating: std_logic;
   SIGNAL checklink_request: std_logic;
   SIGNAL checklink_finished: std_logic;

   SIGNAL bc0_discrepancy: std_logic_vector(12 DOWNTO 0);
   SIGNAL bc0_discrepancy_min: std_logic_vector(12 DOWNTO 0);
   SIGNAL bc0_discrepancy_max: std_logic_vector(12 DOWNTO 0);
   SIGNAL bc0_number_per_orbit: natural RANGE 0 TO 15;
   SIGNAL bc0_search: std_logic_vector(2 DOWNTO 0);  
   SIGNAL bc0_lock, bc0_lock_last, bc0_ok: std_logic;    

   SIGNAL byte_order: std_logic;
   SIGNAL byte_order_detected, byte_order_detected_last: std_logic;  
   SIGNAL byte_order_swapped, byte_order_swapped_last: std_logic;    

   SIGNAL increase_delay: std_logic;
   SIGNAL decrease_delay: std_logic;
   SIGNAL increase_delay_fast: std_logic := '0';
   SIGNAL decrease_delay_fast: std_logic := '0';
   SIGNAL increase_delay_buf: std_logic_vector(1 DOWNTO 0);
   SIGNAL decrease_delay_buf: std_logic_vector(1 DOWNTO 0);

   TYPE type_sm_autoalign IS (
      idle, 
      start_alignment,
      comma_align, 
      check_byte_order, 
      wait_for_byte_order_swap, 
      check_bc0_discrepancy, 
      check_stability, 
      fifo_increment, 
      wait_for_fifo_increment,
      end_alignment);
   SIGNAL autoalign_state: type_sm_autoalign;


   TYPE type_sm_checklink IS (
      wait_to_check_link, 
      checking_link,
      end_of_check_link);
   SIGNAL checklink_state: type_sm_checklink;

begin

-----------------------------------------------------------------------------
-- Stage 1: Write data into dual PORT RAM
-----------------------------------------------------------------------------

fifoin_sm: PROCESS (link_clk_in, reset_in) BEGIN
   IF reset_in = '1' THEN
      fifoin_address_counter <= 6;
   ELSIF rising_edge(link_clk_in) THEN
      IF rx_data_valid_in = '0' AND rx_comma_valid_in = '0' THEN  
        -- Padding word.  Do NOT place IN FIFO.
         fifoin_address_counter <= fifoin_address_counter;
    ELSE
         IF fifoin_address_counter < 31 THEN
            fifoin_address_counter <= fifoin_address_counter + 1;
         ELSE
            fifoin_address_counter <= 0;
         END IF;
      END IF;
   END IF;
END PROCESS fifoin_sm;

-- Makes simulation more realistic (less read/write conflicts)
fifoin_write_enable <= rx_data_valid_in OR rx_comma_valid_in;

-----------------------------------------------------------------------------
-- Stage 2: Dual PORT RAM
-----------------------------------------------------------------------------

fifoin_address_count <= conv_std_logic_vector(fifoin_address_counter,11);
fifoout_address_count <= conv_std_logic_vector(fifoout_address_counter,11);

-- Require std_logic_vector(0 DOWNTO 0) (i.e. size = 1) FOR blk ram
input_flag <= "1" WHEN rx_comma_valid_in = '1' ELSE "0";

Fifo_Ram : RAMB16_S9_S9
  GENERIC MAP (
   INIT_A => "000000000",                 --  Value OF output RAM registers ON PORT A at startup
   INIT_B => "000000000",                --  Value OF output RAM registers ON PORT B at startup
   SRVAL_A => "000000000",                   --  PORT A ouput value upon SSR assertion
   SRVAL_B => "000000000",               --  PORT B ouput value upon SSR assertion
   WRITE_MODE_A => "READ_FIRST",             --  WRITE_FIRST, READ_FIRST OR NO_CHANGE
   WRITE_MODE_B => "READ_FIRST",             --  WRITE_FIRST, READ_FIRST OR NO_CHANGE
   SIM_COLLISION_CHECK => "NONE")            -- Get rid OF errors WHEN read/write ptrs at same adress.
PORT MAP (
   ADDRA => fifoin_address_count,            -- PORT A 11-bit Address Input
   ADDRB => fifoout_address_count,           -- PORT B 10-bit Address Input
   DIA => rx_data_in,                           -- PORT A 8-bit Data Input
   DIB => (others=>'1'),                     -- PORT B 16-bit Data Input
   DIPA => input_flag,                      -- PORT A 1-bit parity Input
   DIPB => (others=>'1'),                    -- PORT-B 2-bit parity Input
   ClkA => link_clk_in,                         -- PORT A Clock
   ClkB => ttc_clk160_in,                          -- PORT B Clock
   ENA => fifoin_write_enable,                               -- PORT A RAM Enable Input
   ENB => '1',                               -- PortB RAM Enable Input
   SSRA => '0',                              -- PORT A Synchronous Set/reset_in Input
   SSRB => '0',                              -- PORT B Synchronous Set/reset_in Input
   WEB => '0',                               -- PORT B Write Enable Input
   WEA => '1',                               -- PORT A Write Enable Input         
   DOA => open,                              -- PORT A 8-bit Data Output
   DOB => rx_buf_data(0),             -- PORT B 16-bit Data Output
   DOPA => open,                             -- PORT A 1-bit Parity Output
   DOPB => output_flag);                   -- PORT B 2-bit Parity Output

   -- Require std_logic_vector(0 DOWNTO 0) (i.e. size = 1) FOR blk ram
   rx_buf_flag(0) <= '1' WHEN output_flag = "1" ELSE '0';

   rx_buf_proc: PROCESS (ttc_clk160_in) 
   BEGIN
      IF rising_edge(ttc_clk160_in) THEN
         rx_buf_data(2 DOWNTO 1) <= rx_buf_data(1 DOWNTO 0);
         rx_buf_flag(2 DOWNTO 1) <= rx_buf_flag(1 DOWNTO 0);
      END IF;
   END PROCESS;

   rx_word_proc: PROCESS (ttc_clk80_in) 
   BEGIN
      IF rising_edge(ttc_clk80_in) THEN
         IF byte_order = '0' THEN
            rx_word_data <= rx_buf_data(0) & rx_buf_data(1);
            rx_word_flag <= rx_buf_flag(0) & rx_buf_flag(1);
         ELSE
            rx_word_data <= rx_buf_data(1) & rx_buf_data(2);
            rx_word_flag <= rx_buf_flag(1) & rx_buf_flag(2); 
         END IF;       
      END IF;
   END PROCESS;

-----------------------------------------------------------------------------
-- Stage 3: Read data OUT OF dual PORT RAM
-----------------------------------------------------------------------------

-- Control read pointer.  Move read ptr by either skipping
fifoout_sm: PROCESS (ttc_clk160_in, reset_in) BEGIN
   IF reset_in = '1' THEN
      fifoout_address_counter <= 0;
   ELSIF rising_edge(ttc_clk160_in) THEN
      IF increase_delay_fast = '1' THEN
         fifoout_address_counter <= fifoout_address_counter;
      ELSIF decrease_delay_fast = '1' THEN
         IF fifoout_address_counter < 31 THEN
            fifoout_address_counter <= fifoout_address_counter + 1;
         ELSIF fifoout_address_counter = 31 THEN
            fifoout_address_counter <= 0;
         ELSE
            fifoout_address_counter <= 1;
         END IF;
      ELSE
         IF fifoout_address_counter < 31 THEN
            fifoout_address_counter <= fifoout_address_counter + 1;
         ELSE
            fifoout_address_counter <= 0;
         END IF;
      END IF;
   ELSE NULL;
   END IF;
END PROCESS fifoout_sm;

increase_delay <= autoalign_increase_delay;
decrease_delay <= '0';

fifo_delays: PROCESS (ttc_clk160_in) 
begin
   IF rising_edge(ttc_clk160_in) THEN
      increase_delay_buf <= increase_delay_buf(0) & increase_delay;
      decrease_delay_buf <= decrease_delay_buf(0) & decrease_delay;
      IF increase_delay_buf = "01" THEN
         increase_delay_fast <= '1';
      ELSE
         increase_delay_fast <= '0';
      END IF;
      IF decrease_delay_buf = "01" THEN
         decrease_delay_fast <= '1';
      ELSE
         decrease_delay_fast <= '0';
      END IF;
   END IF;
END PROCESS;


-----------------------------------------------------------------------------
-- Stage 4: Automatically set byte order / bc0 discrepancy
-----------------------------------------------------------------------------

-- Assume the read/write regs are NOT able TO make a pulsed SIGNAL
-- Hence need TO write '0' followed by '1' TO make pulse.
autoalign_once_pulse: PROCESS (ttc_clk80_in) 
begin
   IF reset_in = '1' THEN
      autoalign_once_previous <= '0';
      autoalign_once <= '0';
   ELSIF rising_edge(ttc_clk80_in) THEN
      autoalign_once_previous <= autoalign_once_in;
      IF (autoalign_once_previous = '0') AND (autoalign_once_in = '1') THEN
         autoalign_once <= '1';
      ELSE
         autoalign_once <= '0';
      END IF;
   END IF;
END PROCESS;

-- The state machine that automatically ensures: 
-- (a) the 16bits words are formed WITH the correct byte order
-- (b) the ttc versus trigger path bc0 discrepancy cotrectly set OR 
--     IF this cannot be achived the min/max bc0 discrepnacy is found.
input_alignment_sm: PROCESS (ttc_clk80_in, reset_in)
   VARIABLE delay_cnt : integer RANGE 0 TO 8191;
begin
   IF reset_in = '1' THEN
      checklink_request <= '0';
      autoalign_state <= idle;
      autoalign_fifo_position <= 0;
      autoalign_lock_checks <= (OTHERS =>'0');
      autoalign_increase_delay <= '0';
      autoalign_byte_order <= '1';
      error_byte_align <= '0';
      error_no_valid_fifo_location <= '0';
      bc0_discrepancy_min <= (OTHERS => '1');
      bc0_discrepancy_max <= (OTHERS => '0');
      rxenpcommaalign_out <= '1';
      rxenmcommaalign_out <= '1';
   ELSIF rising_edge(ttc_clk80_in) THEN
      CASE autoalign_state IS
      WHEN idle =>
         IF (autoalign_once = '1') OR (autoalign_auto_in = '1') THEN
            -- The SIGNAL "autoalign_fifo_position" just used TO track state machine.
            -- It does NOT affect address OF read/write pointers.
            autoalign_fifo_position <= 0;  
            autoalign_state <= start_alignment;
            autoalign_lock_checks <= (OTHERS =>'0');
         END IF;
      WHEN start_alignment =>
         autoalign_state <= comma_align;
         rxenpcommaalign_out <= '1';
         rxenmcommaalign_out <= '1';
         bc0_discrepancy_min <= (OTHERS => '1');
         bc0_discrepancy_max <= (OTHERS => '0');
         delay_cnt := 2 * local_lhc_bunch_count;
         error_byte_align <= '0';
         error_no_valid_fifo_location <= '0';
      WHEN comma_align => 
         -- Make sure we observe at least one comma by waiting entire orbit
         IF delay_cnt /= 0 THEN
            delay_cnt := delay_cnt - 1;
         ELSE
            rxenpcommaalign_out <= '0';
            rxenmcommaalign_out <= '0';
            IF rxbyteisaligned_in = '1' THEN
               autoalign_state <= check_byte_order;
               checklink_request <= '1';
            ELSE
               -- RECORD that links failed TO align TO commas.
               autoalign_state <= end_alignment;
               error_byte_align <= '1';
            END IF;
         END IF;
      WHEN check_byte_order =>
         checklink_request <= '0';
         -- IF (checklink_request = '1') OR (checklink_operating = '1') THEN
            -- WAIT FOR link check TO finish
            -- NULL;
         -- ELSE
         IF checklink_finished = '1' THEN
            IF byte_order_detected = '1' THEN
               IF byte_order_swapped = '0' THEN
                  autoalign_state <= check_bc0_discrepancy;
                  checklink_request <= '1';
               ELSE
                  autoalign_state <= wait_for_byte_order_swap;
                  autoalign_byte_order <= NOT autoalign_byte_order;
                  delay_cnt := 8;
               END IF;
            ELSE
               -- Data corruption?  Skip TO NEXT fifo location.
               autoalign_state <= fifo_increment;
            END IF;
         END IF;
      WHEN wait_for_byte_order_swap =>
         -- Make sure byte order swap has fully propogated through sys before rechecking link.
         IF delay_cnt /= 0 THEN
            delay_cnt := delay_cnt - 1;
         ELSE
            autoalign_state <= check_bc0_discrepancy;
            checklink_request <= '1';  
         END IF;
      WHEN check_bc0_discrepancy =>
         checklink_request <= '0';
         -- IF (checklink_request = '1') OR (checklink_operating = '1') THEN
            -- WAIT FOR link check TO finish
            -- NULL;
         IF checklink_finished = '1' THEN
            -- Check TO see whether valid BC0 SIGNAL detected ON trigger path.
            IF bc0_ok = '1' THEN
               IF bc0_discrepancy > bc0_discrepancy_max THEN
                  bc0_discrepancy_max <= bc0_discrepancy;
               END IF;
               IF bc0_discrepancy < bc0_discrepancy_min THEN
                  bc0_discrepancy_min <= bc0_discrepancy;
               END IF;
            END IF;
            -- Check TO see whether BC0 trigger/ttc path discrepancy matches that required.
            IF bc0_lock = '1' THEN
               autoalign_state <= check_stability;
               checklink_request <= '1';
               autoalign_lock_checks <= conv_unsigned(1,32);  
            ELSE
               autoalign_state <= fifo_increment;
            END IF;
         END IF;
      WHEN check_stability => 
         checklink_request <= '0';
         -- IF (checklink_request = '1') OR (checklink_operating = '1') THEN
            -- WAIT FOR link check TO finish
            -- NULL;
         -- ELSE
         IF checklink_finished = '1' THEN
            IF (byte_order_detected = '0') OR (byte_order_swapped = '1') OR (bc0_lock = '0') THEN
               -- Lost lock.  Do nowt FOR time being
               autoalign_state <= idle;
            ELSE
               autoalign_lock_checks <= autoalign_lock_checks + 1;
               checklink_request <= '1';
            END IF;
         END IF; 
      WHEN fifo_increment =>
         IF autoalign_fifo_position < 31 THEN
            autoalign_fifo_position <= autoalign_fifo_position + 1;
            autoalign_state <= wait_for_fifo_increment;
            autoalign_increase_delay <= '1';
            delay_cnt := 8;
         ELSE
            autoalign_state <= end_alignment;
            error_no_valid_fifo_location <= '1';
         END IF;
      WHEN wait_for_fifo_increment =>
         -- Make sure byte order swap has fully propogated through sys before rechecking link.
         autoalign_increase_delay  <= '0';
         IF delay_cnt /= 0 THEN
            delay_cnt := delay_cnt - 1;
         ELSE
            autoalign_state <= check_byte_order;
            checklink_request <= '1';  
         END IF;
      WHEN end_alignment =>
         NULL;
         autoalign_state <= idle;
      WHEN OTHERS =>
        autoalign_state <= idle;
      END CASE;
   END IF;
END PROCESS input_alignment_sm;

byte_order <= autoalign_byte_order;

-----------------------------------------------------------------------------
-- Stage 5: Check byte order / bc0 discrepancy
-----------------------------------------------------------------------------

check_link_sm: PROCESS (ttc_clk80_in, reset_in)
   VARIABLE bunch_counter : integer RANGE 0 TO 8191;
begin
   IF reset_in = '1' THEN

      bunch_counter := 0;
      rx_word_flag_latched <= "00";
      bc0_discrepancy <= (OTHERS => '1');
      bc0_number_per_orbit <= 0;
      bc0_search <= "000";
      bc0_lock <= '0';
      byte_order_detected <= '0';
      byte_order_swapped <= '0';
      bc0_ok <= '0';
      checklink_state <= wait_to_check_link;
      checklink_operating <= '0';
      checklink_finished <= '0';

   ELSIF rising_edge(ttc_clk80_in) THEN
      
      CASE checklink_state IS
      WHEN wait_to_check_link =>
         checklink_finished <= '0';
         IF checklink_request = '1' THEN
           checklink_state <= checking_link;
           checklink_operating <= '1';
           bunch_counter := 0;
           rx_word_flag_latched <= "00";
           bc0_discrepancy <= (OTHERS => '1');
           bc0_number_per_orbit <= 0;
           bc0_search <= "000";
           bc0_lock <= '0';
           byte_order_detected <= '0';
           byte_order_swapped <= '0';
           bc0_ok <= '0';
         END IF;
      
      WHEN checking_link =>
         IF bunch_counter < (local_lhc_bunch_count*2) + 3 THEN
            bunch_counter := bunch_counter + 1;
            -- Check byte order:
            -- RECORD IF comma detected IN either byte.
            rx_word_flag_latched <= rx_word_flag_latched OR rx_word_flag;
            -- Check BC0 discrepancy:
            -- First tried TO look FOR 3 sequential asserted bits ON MSB OF data word.
            -- But IF trig path has comma word NEXT TO it you only see 2 sequential asserted bits ON MSB
            -- Make sure data word is NOT a comma.  It may have MSB asserted.
            -- Cannot be confused by CRC.  CRC bounded either side by Comma.
            -- Hence IF CRC bit 15 = '1' set would get "010".
            -- Tried + 1.  NOT enough..
            IF (rx_word_data(15) = '1') AND (rx_word_flag = "00") THEN
              bc0_search <= bc0_search(1 DOWNTO 0) & '1';
            ELSE
              bc0_search <= bc0_search(1 DOWNTO 0) & '0';
            END IF;
            -- RECORD number OF BC0s per orbit.  Should just be 1!
            -- IF bc0_search = "011" THEN
            IF bc0_search = "110" THEN
               bc0_discrepancy <= ttc_half_bunch_cnt_in;
               IF bc0_number_per_orbit < 15 THEN
                  bc0_number_per_orbit <= bc0_number_per_orbit + 1;
               END IF;
            END IF;
         ELSE
           checklink_state <= end_of_check_link;
           checklink_operating <= '0';
         END IF;
      
      WHEN end_of_check_link =>
         checklink_state <= wait_to_check_link;
         checklink_finished <= '1';
         -- USE comma location TO determine byte order
         CASE rx_word_flag_latched IS
         WHEN "01" =>
            -- ALL OK.  Just detected commas IN top byte.
            byte_order_detected <= '1';
            byte_order_swapped <= '0';
         WHEN "10" =>
            -- Byte order wrong, but no evidence OF data corruption.
            byte_order_detected <= '1';
            byte_order_swapped <= '1';
         WHEN OTHERS =>
            -- Commas detected IN both/neither locations
            -- Data corruption?  Skip TO NEXT fifo location.
            byte_order_detected <= '0';
            byte_order_swapped <= '0';
         END CASE;
         IF bc0_number_per_orbit = 1 THEN
            bc0_ok <= '1';
            IF bc0_discrepancy = bc0_discrepancy_req_in THEN
               bc0_lock <= '1';
            ELSE
               bc0_lock <= '0';
            END IF;
         END IF;

      END CASE;

   END IF;
END PROCESS;


-----------------------------------------------------------------------------
-- Stage 6: Outputs
-----------------------------------------------------------------------------

rx_data_out <= rx_word_data;
rx_data_valid_out <= rx_word_flag(1) NOR rx_word_flag(0);
bc0_discrepancy_max_out <= bc0_discrepancy_max;
bc0_discrepancy_min_out <= bc0_discrepancy_min;
autoalign_lock_checks_out <= std_logic_vector(autoalign_lock_checks);

make_status: PROCESS (ttc_clk80_in, reset_in)
begin
   IF reset_in = '1' THEN
      autoalign_operating <= '0';
      autoalign_ok <= '0';
   ELSIF rising_edge(ttc_clk80_in) THEN
      IF autoalign_state = idle THEN
         autoalign_operating <= '0';
      ELSE 
         autoalign_operating <= '1';
      END IF;
      IF autoalign_state = check_stability THEN
         autoalign_ok <= '1';
      ELSE 
         autoalign_ok <= '0';
      END IF;
   END IF;
END PROCESS;

check_link_previous_data: PROCESS (ttc_clk80_in, reset_in)
begin
   IF reset_in = '1' THEN
      bc0_lock_last <= '0';
      byte_order_detected_last <= '0';
      byte_order_swapped_last <= '0';
   ELSIF rising_edge(ttc_clk80_in) THEN
      IF checklink_finished = '1' THEN
        bc0_lock_last <= bc0_lock;
        byte_order_detected_last <= byte_order_detected;
        byte_order_swapped_last <= byte_order_swapped;
      END IF;
   END IF;
END PROCESS;



autoalign_status_out <= 
   autoalign_operating &
   autoalign_ok &
   byte_order_detected_last &
   byte_order_swapped_last &
   bc0_lock_last &
   "000" &
   x"00000" &
   "00" &
   error_byte_align & 
   error_no_valid_fifo_location;

 END behave;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY kcode_word_insert IS
   PORT(
      data_in                         : IN   std_logic_vector(15 DOWNTO 0);
      comma_in                        : IN   std_logic;
      pad_in                          : IN   std_logic;
      data_out                        : OUT  std_logic_vector(15 DOWNTO 0);
      charisk_out                     : OUT  std_logic_vector(1 DOWNTO 0));
END kcode_word_insert;

ARCHITECTURE behave OF kcode_word_insert IS
begin

   -- FOR Xilinx Virtex 5
   -- TXCHARISK[1] corresponds TO TXDATA[15:8]
   -- TXCHARISK[0] corresponds TO TXDATA[7:0]

   PROCESS(comma_in, pad_in, data_in)
      VARIABLE txkcontrol: std_logic_vector(1 DOWNTO 0);
   BEGIN
      txkcontrol := comma_in & pad_in;
      CASE txkcontrol IS
      WHEN "00" =>
         data_out <= data_in;
         charisk_out <= "00";
      WHEN "10" =>
         -- data_out <= x"BC50";  -- From TLK2501 data sheet it seems comma IN top 8 bits (i.e = "BC50")
         -- charisk_out <= "10";
         data_out <= x"50BC";  -- Was working, but NOT WITH src cards.  looks like comma order wrong.
         charisk_out <= "01";
      WHEN "01" =>
         data_out <= x"F7F7";
         -- data_out <= x"FEFE";
         charisk_out <= "11";
      WHEN OTHERS =>
         data_out <= x"F7F7";
         -- data_out <= x"FEFE";
         charisk_out <= "11";
      END CASE;
   END PROCESS;

END behave;