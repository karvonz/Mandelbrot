
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE package_links IS

  COMPONENT links_kcode_insert IS
  PORT(
    data_in                         : IN   std_logic_vector(31 DOWNTO 0);
    data_valid_in                   : IN   std_logic;
    data_out                        : OUT  std_logic_vector(31 DOWNTO 0);
    charisk_out                     : OUT  std_logic_vector(3 DOWNTO 0));
  END COMPONENT;

  COMPONENT links_crc_rx IS
  PORT(
    reset:                  IN std_logic;
    clk:                    IN std_logic;
    data_in:                IN std_logic_vector(31 DOWNTO 0);
    data_valid_in:          IN std_logic;
    data_out:               OUT std_logic_vector(31 DOWNTO 0);
    data_valid_out:         OUT std_logic;
    data_start_out:         OUT std_logic;
    reset_counters_in:      IN std_logic;
    crc_checked_cnt_out:    OUT std_logic_vector(31 DOWNTO 0);
    crc_error_cnt_out:      OUT std_logic_vector(31 DOWNTO 0);
    status_out:             OUT std_logic_vector(3 DOWNTO 0));
  END COMPONENT;

  COMPONENT links_crc_tx IS
  PORT(
    reset:                  IN std_logic;
    clk:                    IN std_logic;
    data_in:                IN std_logic_vector(31 DOWNTO 0);
    data_valid_in:          IN std_logic;
    data_out:               OUT std_logic_vector(31 DOWNTO 0);
    data_valid_out:         OUT std_logic);
  END COMPONENT;

  COMPONENT links_sync IS
  PORT (
    reset:                      IN std_logic;
    clk:                        IN std_logic;
    sync_master_in:             IN std_logic;
    sync_slave_in:              IN std_logic;
    data_in:                    IN std_logic_vector(31 DOWNTO 0);
    data_valid_in:              IN std_logic;
    sync_enable_in:             IN std_logic;
    sync_delay_out:             OUT std_logic_vector(4 DOWNTO 0);
    sync_delay_enable_out:      OUT std_logic;
    sync_error_out:             OUT std_logic;
    data_out:                   OUT std_logic_vector(31 DOWNTO 0);
    data_valid_out:             OUT std_logic);
  END COMPONENT;

END PACKAGE;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY links_kcode_insert IS
  PORT(
    data_in                         : IN   std_logic_vector(31 DOWNTO 0);
    data_valid_in                   : IN   std_logic;
    data_out                        : OUT  std_logic_vector(31 DOWNTO 0);
    charisk_out                     : OUT  std_logic_vector(3 DOWNTO 0));
END links_kcode_insert;

ARCHITECTURE behave OF links_kcode_insert IS
begin

  -- FOR Xilinx Virtex 5
  -- TXCHARISK[1] corresponds TO TXDATA[15:8]
  -- TXCHARISK[0] corresponds TO TXDATA[7:0]

  data_out <= x"F7F7F7BC" WHEN data_valid_in /= '1' ELSE data_in;
  charisk_out <= "0000" WHEN data_valid_in = '1' ELSE "1111";

END behave;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY links_crc_rx IS
PORT (
  reset:                  IN std_logic;
  clk:                    IN std_logic;
  data_in:                IN std_logic_vector(31 DOWNTO 0);
  data_valid_in:          IN std_logic;
  data_out:               OUT std_logic_vector(31 DOWNTO 0);
  data_valid_out:         OUT std_logic;
  data_start_out:         OUT std_logic;
  reset_counters_in:      IN std_logic;
  crc_checked_cnt_out:    OUT std_logic_vector(31 DOWNTO 0);
  crc_error_cnt_out:      OUT std_logic_vector(31 DOWNTO 0);
  status_out:             OUT std_logic_vector(3 DOWNTO 0));
END links_crc_rx;

ARCHITECTURE behave OF links_crc_rx IS

  SIGNAL data_start : std_logic;
  SIGNAL data_valid_shreg : std_logic_vector(2 DOWNTO 0);
  
  SIGNAL crc_word : std_logic_vector(31 DOWNTO 0);
  SIGNAL crc_valid : std_logic;
  SIGNAL crc_error : std_logic;
  SIGNAL crc_error_cnt: unsigned(31 DOWNTO 0);   
  SIGNAL crc_checked : std_logic;
  SIGNAL crc_checked_cnt : unsigned(31 DOWNTO 0);
  
  CONSTANT max_cnt : unsigned := x"ffffffff";


begin

  data_valid_shreg(0) <= data_valid_in;
  
  PROCESS(clk)
  BEGIN
    IF rising_edge(clk) THEN
      data_valid_shreg(2 DOWNTO 1)  <= data_valid_shreg(1 DOWNTO 0) ;
    END IF;
  END PROCESS;

  data_start <= '1' WHEN data_valid_shreg = "001" ELSE '0';
  crc_valid <= '1' WHEN data_valid_shreg = "101" ELSE '0';

  crc32_inst: crc32
    GENERIC MAP (
      crc_init      => x"ffffffff")
    PORT MAP (
      crcout        => crc_word,
      crcclk        => clk,
      crcdatavalid  => data_valid_in,
      crcdatawidth  => "011",
      crcin         => data_in,
      crcreset      => data_start);

  data_out <= data_in WHEN crc_valid = '0' ELSE x"00000000";
  data_valid_out <= data_valid_in WHEN crc_valid = '0' ELSE '0';
  data_start_out <= data_start;

  -- Need TO delay data AND crc_valid SIGNAL UNTIL CRC bolck has computed CRC.

  PROCESS(reset, clk)
  BEGIN
    IF reset = '1' THEN
      crc_error <= '0';
    ELSIF rising_edge(clk) THEN
      IF crc_valid = '1' THEN
        -- Check CRC 
        IF crc_word /= data_in THEN
          crc_error <= '1';
        ELSE
          crc_error <= '0';
        END IF;
      ELSE
        -- NOT checking CRC
        crc_error <= '0';
      END IF;
    END IF;
  END PROCESS;


  status_counters: PROCESS(reset, clk)
  BEGIN
    IF reset = '1' THEN
        crc_error_cnt <= (OTHERS => '0');
        crc_checked_cnt <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
      IF reset_counters_in = '1' THEN
        crc_error_cnt <= (OTHERS => '0');
        crc_checked_cnt <= (OTHERS => '0');
      ELSE
        IF (crc_error = '1') AND (crc_error_cnt < max_cnt) THEN
          crc_error_cnt <= crc_error_cnt + 1;
        END IF;
        IF (crc_valid = '1') THEN
          crc_checked_cnt <= crc_checked_cnt + 1;
        END IF;
      END IF;
    END IF;
  END PROCESS;
  
  crc_error_cnt_out <= std_logic_vector(crc_error_cnt);
  crc_checked_cnt_out <= std_logic_vector(crc_checked_cnt);
  status_out <= (OTHERS => '0');

END behave;


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY links_crc_tx IS
PORT (
  reset:                  IN std_logic;
  clk:                    IN std_logic;
  data_in:                IN std_logic_vector(31 DOWNTO 0);
  data_valid_in:          IN std_logic;
  data_out:               OUT std_logic_vector(31 DOWNTO 0);
  data_valid_out:         OUT std_logic);
END links_crc_tx;

ARCHITECTURE behave OF links_crc_tx IS

  SIGNAL data_start : std_logic;
  SIGNAL data_valid_shreg : std_logic_vector(2 DOWNTO 0);
  
  SIGNAL crc_word : std_logic_vector(31 DOWNTO 0);
  SIGNAL crc_valid : std_logic;
  
  CONSTANT max_cnt : unsigned := x"ffffffff";


begin

  data_valid_shreg(0) <= data_valid_in;
  
  PROCESS(clk)
  BEGIN
    IF rising_edge(clk) THEN
      data_valid_shreg(2 DOWNTO 1)  <= data_valid_shreg(1 DOWNTO 0) ;
    END IF;
  END PROCESS;

  data_start <= '1' WHEN data_valid_shreg = "001" ELSE '0';
  crc_valid <= '1' WHEN data_valid_shreg = "100" ELSE '0';

  crc32_inst: crc32
    GENERIC MAP (
      crc_init      => x"ffffffff")
    PORT MAP (
      crcout        => crc_word,
      crcclk        => clk,
      crcdatavalid  => data_valid_in,
      crcdatawidth  => "011",
      crcin         => data_in,
      crcreset      => data_start);

  data_out <= crc_word WHEN crc_valid = '1' ELSE data_in;
  data_valid_out <=  data_valid_in OR crc_valid;
   
END behave;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.package_utilities.ALL;

ENTITY links_sync IS
PORT (
  reset:                      IN std_logic;
  clk:                        IN std_logic;
  sync_master_in:             IN std_logic;
  sync_slave_in:              IN std_logic;
  data_in:                    IN std_logic_vector(31 DOWNTO 0);
  data_valid_in:              IN std_logic;
  sync_enable_in:             IN std_logic;
  sync_delay_out:             OUT std_logic_vector(4 DOWNTO 0);
  sync_delay_enable_out:      OUT std_logic;
  sync_error_out:             OUT std_logic;
  data_out:                   OUT std_logic_vector(31 DOWNTO 0);
  data_valid_out:             OUT std_logic);
END links_sync;

ARCHITECTURE behave OF links_sync IS

   TYPE type_sync_state IS (
      idle,
      wait_for_sync_slave
   );

  SIGNAL delay : natural RANGE 0 TO 31;
  SIGNAL sync_delay : std_logic_vector(4 DOWNTO 0);
  SIGNAL sync_delay_enable: std_logic;
  SIGNAL sync_measured : std_logic;
  SIGNAL sync_state : type_sync_state;
  SIGNAL reset_b: std_logic;

  SIGNAL data_sync: std_logic_vector(31 DOWNTO 0);
  SIGNAL data_valid_sync: std_logic;

begin


  data_out <= data_sync WHEN sync_enable_in = '1' ELSE data_in;
  data_valid_out <= data_valid_sync WHEN sync_enable_in = '1' ELSE data_valid_in; 

  reset_b <= NOT reset;

  sync_bufd_ch0: delay_word
  GENERIC MAP (
      width => 32)
  PORT MAP (
      reset_b	       => reset_b,
      clk	       => clk,
      delay_in         => sync_delay,
      delay_enable_in  => sync_delay_enable,
      word_in          => data_in,
      word_out         => data_sync);

  sync_bufdv_ch0: delay_bit
  PORT MAP (
      reset_b	       => reset_b,
      clk	       => clk,
      delay_in         => sync_delay,
      delay_enable_in  => sync_delay_enable,
      bit_in           => data_valid_in,
      bit_out          => data_valid_sync);

  sync_cntrl: PROCESS(reset, clk)
    VARIABLE sync_input: std_logic_vector(1 DOWNTO 0);
  BEGIN
    IF reset = '1' THEN
      sync_state <= idle;
      sync_delay <= "00000";
      sync_delay_enable <= '0';
      sync_measured <= '0';
      sync_error_out <= '0';
      sync_error_out <= '0';
    ELSIF rising_edge(clk) THEN
      -- Default parames
      sync_measured <= '0';
      -- Sync measurement state machine
      sync_input := sync_slave_in & sync_master_in;
      CASE sync_state IS
      WHEN idle =>
        CASE sync_input IS
        WHEN "11" =>
          sync_delay <= "00000";
          sync_delay_enable <= '0';
          sync_measured <= '1';
          sync_error_out <= '0';
        WHEN "10" =>
          sync_state <= wait_for_sync_slave;
          delay <= 0;
        WHEN "01" =>
          -- Error sync_master_in should arive before sync_slave_in.
          sync_error_out <= '1';
        WHEN OTHERS =>
          NULL;
        END CASE;
      WHEN wait_for_sync_slave =>
        IF sync_master_in = '1' THEN
          -- Adjust delay paramemter
          sync_delay <= std_logic_vector(to_unsigned(delay,5));
          sync_delay_enable <= '1';
          sync_measured <= '1';
          sync_error_out <= '0';
          sync_state <= idle;
        ELSIF delay /= 31 THEN
          delay <= delay+1;
        ELSE
          -- Could also be that sync_master_in is missing
          sync_error_out <= '1';
          sync_state <= idle;
        END IF;
      END CASE;
    END IF;
  END PROCESS;

  sync_delay_out <= sync_delay;
  sync_delay_enable_out <= sync_delay_enable;

END behave;
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------