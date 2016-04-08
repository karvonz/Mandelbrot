
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.package_comm.ALL;
USE work.package_modules.ALL;

PACKAGE package_i2c IS

  -- i2c interface configured TO sim cms analogue opto hybrid
  -- rw registers :(3 DOWNTO 0) AND (29 DOWNTO 16)
  -- r registers : none (although some bits IN a rw reg are read only)

  CONSTANT i2c_rw_add_min : integer := 0;
  CONSTANT i2c_rw_add_max : integer := 3;
  CONSTANT i2c_r_add_min  : integer := 0;
  CONSTANT i2c_r_add_max  : integer := 0;

   TYPE i2c_data_r_type is ARRAY (natural RANGE <>) OF std_logic_vector(7 DOWNTO 0);
   TYPE i2c_data_rw_type is ARRAY (natural RANGE <>) OF std_logic_vector(7 DOWNTO 0);

   COMPONENT i2c_slave_top IS
   PORT( 
      clk       : IN     std_logic;
      reset_b   : IN     std_logic;
      scl       : IN     std_logic;
      slave_add : IN     std_logic_vector (6 DOWNTO 0);
      sda       : INOUT  std_logic);
   END COMPONENT;

   COMPONENT i2c_slave_decode IS
   PORT(
      clk        : IN         std_logic;
      sync_reset : IN         std_logic;
      sda        : INOUT        std_logic;
      scl       : IN      std_logic;
      rx         : OUT     std_logic;
      tx         : OUT     std_logic;
      start      : OUT     std_logic;
      stop       : OUT     std_logic;
      data_rx    : OUT     std_logic;
      data_tx   : IN std_logic);
   END COMPONENT ;

   COMPONENT i2c_slave_control IS
   PORT( 
      clk        : IN     std_logic;
      slave_add  : IN     std_logic_vector (6 DOWNTO 0);
      sync_reset : IN     std_logic;
      start      : IN     std_logic;
      stop       : IN     std_logic;
      tx         : IN     std_logic;
      rx         : IN     std_logic;
      data_rx    : IN     std_logic;
      data_tx    : OUT    std_logic;
      data_rw    : OUT    i2c_data_rw_type (i2c_rw_add_max DOWNTO i2c_rw_add_min));
   END COMPONENT ;

   COMPONENT i2c_master_wbone_interface IS
  GENERIC(
      base_board_clk     : natural := 40000000;
      i2c_clk_speed     : natural := 100000;
      i2c_buffer_depth  : natural := 4;
      wish_addr_width   : natural := 8;
      wish_data_width   : natural := 16);
  PORT(
    clk           : IN     std_logic;
    async_reset      : IN     std_logic;
    adr_i             : IN     std_logic_vector (wish_addr_width-1 DOWNTO 0); -- address bits
    dat_i             : IN     std_logic_vector (wish_data_width-1 DOWNTO 0); -- databus input
    dat_o             : OUT    std_logic_vector (wish_data_width-1 DOWNTO 0); -- databus output
    we_i              : IN     std_logic; -- write enable input
    stb_i             : IN     std_logic; -- strobe signals / core SELECT SIGNAL
    cyc_i             : IN     std_logic; -- valid BUS cycle input
    ack_o             : OUT    std_logic; -- BUS cycle acknowledge output
    start_add      : OUT  std_logic := '0';
    start_data       : OUT  std_logic := '0';
    stop            : OUT std_logic := '0';
    r_nw            : OUT std_logic := '0';
    add           : OUT std_logic_vector(6 DOWNTO 0) := (OTHERS => '0');
    data_w         : OUT  std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    data_r         : IN std_logic_vector(7 DOWNTO 0);
    ack           : IN  std_logic;
    idle            : IN  std_logic;
    mid_trans      : IN std_logic;
    en_i2c_sm      : OUT  std_logic := '0');
   END COMPONENT;

   COMPONENT i2c_master_top IS
   GENERIC( 
      module:           type_mod_define;
      base_board_clk:   natural := 40000000;
      i2c_clk_speed:    natural := 100000);
   PORT( 
      clk:            IN std_logic;
      reset_b:          IN std_logic;
      comm_cntrl:       IN type_comm_cntrl;
      comm_reply:       OUT type_comm_reply;
      scl:              INOUT  std_logic;
      sda:              INOUT  std_logic);
   END COMPONENT ;

   COMPONENT i2c_master_output IS
   PORT( 
      scl   : OUT    std_logic;
      sda   : OUT    std_logic;
      scl_o : IN     std_logic;
      sda_o : IN     std_logic);
   END COMPONENT;

   COMPONENT i2c_master_control IS
   PORT( 
      add         : IN     std_logic_vector (6 DOWNTO 0);
      async_reset : IN     std_logic;
      clk         : IN     std_logic;
      data_w      : IN     std_logic_vector (7 DOWNTO 0);
      enable      : IN     std_logic;
      r_nw        : IN     std_logic;
      ack_inv     : IN     std_logic;
      scl_i       : IN     std_logic;
      sda_i       : IN     std_logic;
      start_add   : IN     std_logic;
      start_data  : IN     std_logic;
      stop        : IN     std_logic;
      ack         : OUT    std_logic;
      data_r      : OUT    std_logic_vector (7 DOWNTO 0);
      idle        : OUT    std_logic;
      mid_trans   : OUT    std_logic;
      scl_o       : OUT    std_logic;
      sda_o       : OUT    std_logic);
   END COMPONENT ;

   COMPONENT i2c_master_comm_interface IS
   GENERIC(
      module:            type_mod_define;
      base_board_clk:    natural := 40000000;
      i2c_clk_speed:     natural := 100000;
      i2c_buffer_depth:  natural := 4);
   PORT(
      clk:            IN std_logic;
      reset_b:          IN std_logic;
      comm_cntrl:       IN type_comm_cntrl;
      comm_reply:       OUT type_comm_reply;
      start_add:        OUT std_logic := '0';
      start_data:       OUT std_logic := '0';
      stop:             OUT std_logic := '0';
      r_nw:             OUT std_logic := '0';
      ack_inv:          OUT std_logic := '0';
      add:              OUT std_logic_vector(6 DOWNTO 0) := (OTHERS => '0');
      data_w:           OUT std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
      data_r:           IN std_logic_vector(7 DOWNTO 0);
      ack :             IN std_logic;
      idle:             IN std_logic;
      mid_trans:        IN std_logic;
      en_i2c_sm:        OUT std_logic := '0');
   END COMPONENT;

END  package_i2c;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
LIBRARY work;
USE work.package_i2c.ALL;

ENTITY i2c_slave_top IS
   PORT( 
      clk       : IN     std_logic;
      reset_b   : IN     std_logic;
      scl       : IN     std_logic;
      slave_add : IN     std_logic_vector (6 DOWNTO 0);
      sda       : INOUT  std_logic);
END i2c_slave_top ;

ARCHITECTURE behave OF i2c_slave_top IS

   SIGNAL data_rx : std_logic;
   SIGNAL data_tx : std_logic;
   SIGNAL reset   : std_logic;
   SIGNAL rx      : std_logic;
   SIGNAL start   : std_logic;
   SIGNAL stop    : std_logic;
   SIGNAL tx      : std_logic;

begin

   reset <= NOT(reset_b);

   i0 : i2c_slave_control
      PORT MAP (
         clk        => clk,
         slave_add  => slave_add,
         sync_reset => reset,
         start      => start,
         stop       => stop,
         tx         => tx,
         rx         => rx,
         data_rx    => data_rx,
         data_tx    => data_tx,
         data_rw    => OPEN
      );
   i1 : i2c_slave_decode
      PORT MAP (
         clk        => clk,
         sync_reset => reset,
         sda        => sda,
         scl        => scl,
         rx         => rx,
         tx         => tx,
         start      => start,
         stop       => stop,
         data_rx    => data_rx,
         data_tx    => data_tx
      );

END behave;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY i2c_slave_decode IS
   PORT(
      clk        : IN         std_logic;
      sync_reset : IN         std_logic;
      sda        : INOUT        std_logic;
      scl       : IN      std_logic;
      rx         : OUT     std_logic;
      tx         : OUT     std_logic;
      start      : OUT     std_logic;
      stop       : OUT     std_logic;
      data_rx    : OUT     std_logic;
      data_tx   : IN std_logic);
END i2c_slave_decode ;

ARCHITECTURE behave OF i2c_slave_decode IS

   SIGNAL sync_sda0 : std_logic;
   SIGNAL sync_sda1 : std_logic;
   SIGNAL sync_sda2 : std_logic;
   SIGNAL sync_scl0 : std_logic;
   SIGNAL sync_scl1 : std_logic;
   SIGNAL sync_scl2 : std_logic;
   SIGNAL i2c_history : std_logic_vector(3 DOWNTO 0);
   SIGNAL scl_history : std_logic_vector(1 DOWNTO 0);

begin

  gen_control_sig: PROCESS(clk) 
  BEGIN 
    IF (clk = '1' AND clk'event) THEN
      IF sync_reset = '1' THEN
           
           rx <= '0';
           tx <= '0';
           start <= '0';
           stop <= '0';
           data_rx <= '0';
  
           sync_sda0 <= '1';
           sync_sda1 <=  '1';
           sync_sda2 <=  '1';
           sync_scl0 <=  '1';
           sync_scl1 <=  '1';
           sync_scl2 <=  '1';
  
           i2c_history <=  "1111";
           scl_history <=  "11";
  
        ELSE
           
            -- Don't USE sync_0 as a precaution against sync errors
         sync_sda0 <= to_ux01(sda);
           sync_sda1 <= sync_sda0;
           sync_sda2 <= sync_sda1;
           sync_scl0 <= to_ux01(scl);
           sync_scl1 <= sync_scl0;
           sync_scl2 <= sync_scl1;
  
           i2c_history <= sync_sda1 & sync_sda2 & sync_scl1 & sync_scl2;
           scl_history <= sync_scl1 & sync_scl2;
        
           CASE i2c_history IS
           WHEN "0111" =>
              start <= '1';
              stop <= '0';
           WHEN "1011" =>
              start <= '0';
              stop <= '1';
           WHEN OTHERS =>
              start <= '0';
              stop <= '0';
           END CASE;
     
           CASE scl_history IS
           WHEN "01" =>
              tx <= '1';  
              rx <= '0';
           WHEN "10" =>
              tx <= '0';
              rx <= '1';
        data_rx<= sync_sda1;
           WHEN OTHERS =>
              tx <= '0';
              rx <= '0';
           END CASE;
  
        END IF;
     END IF;
  END PROCESS gen_control_sig;
  
   sda <= '0' WHEN data_tx = '0' ELSE 'Z';

END behave;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_signed.ALL;
LIBRARY work;
USE work.package_i2c.ALL;

ENTITY i2c_slave_control IS
   PORT( 
      clk        : IN     std_logic;
      slave_add  : IN     std_logic_vector (6 DOWNTO 0);
      sync_reset : IN     std_logic;
      start      : IN     std_logic;
      stop       : IN     std_logic;
      tx         : IN     std_logic;
      rx         : IN     std_logic;
      data_rx    : IN     std_logic;
      data_tx    : OUT    std_logic;
      data_rw    : OUT    i2c_data_rw_type (i2c_rw_add_max DOWNTO i2c_rw_add_min));
END i2c_slave_control ;

ARCHITECTURE behave OF i2c_slave_control IS

   SIGNAL buffer_in: std_logic_vector (7 DOWNTO 0);
   SIGNAL buffer_out: std_logic_vector (7 DOWNTO 0);
   SIGNAL command: unsigned(6 DOWNTO 0);
   SIGNAL add: unsigned (6 DOWNTO 0);
   SIGNAL ack: std_logic;
   SIGNAL add_read_bit: std_logic;
   SIGNAL command_read_bit: std_logic;
   SIGNAL cnt: integer;

   TYPE state_type IS (
      idle,
      chip_add,
      ack_1,
      add_read_or_write,
      read_data,
      write_data,
      ack_3
   );

   ATTRIBUTE state_vector : string;
   ATTRIBUTE state_vector OF behave : ARCHITECTURE is "current_state" ;

   SIGNAL current_state : state_type ;
   SIGNAL next_state : state_type ;

   SIGNAL data_rw_cld : i2c_data_rw_type (i2c_rw_add_max DOWNTO i2c_rw_add_min) ;
   SIGNAL data_tx_cld : std_logic  ;

begin

   clocked_proc : PROCESS(clk)
   BEGIN
      IF (clk'event AND clk = '1') THEN
         IF (sync_reset = '1') THEN
            current_state <= idle;
            -- reset values
            data_rw_cld <= (OTHERS => x"00");
            data_tx_cld <= '1';
            ack <= '0';
            add <= "0000000";
            add_read_bit <= '0';
            buffer_in <= "00000000";
            buffer_out <= "00000000";
            cnt <= 0;
            command <= "0000000";
            command_read_bit <= '0';
         ELSE
            current_state <= next_state;

            CASE current_state IS
            WHEN idle =>
               IF (start = '1') THEN
                  cnt <= 7;
               END IF;
            WHEN chip_add =>
               IF (rx = '1' AND cnt > 0) THEN
                  add <= add(5 DOWNTO 0) & data_rx;
                  cnt <= cnt - 1;
               ELSIF (rx = '1' AND cnt = 0) THEN
                  add_read_bit <= data_rx;
               END IF;
            WHEN ack_1 =>
               IF (tx = '1' AND add_read_bit = '1') THEN
                  data_tx_cld <= buffer_out (cnt-1);
                  cnt <= cnt - 1;
               ELSIF (tx = '1' AND add_read_bit  = '0') THEN
                  data_tx_cld<= '1';
                  cnt <= 8;
               END IF;
            WHEN add_read_or_write =>
               IF (tx = '1' AND unsigned(slave_add)=add AND add_read_bit = '0') THEN
                  data_tx_cld <= '0';
               ELSIF (tx = '1' AND unsigned(slave_add) = add AND add_read_bit = '1') THEN
                  data_tx_cld <= '0';                  
                  cnt <= 8;
                  IF (conv_integer(add(1 DOWNTO 0)) >= i2c_rw_add_min) AND (conv_integer(add(1 DOWNTO 0)) <= i2c_rw_add_max) THEN
                        buffer_out <= data_rw_cld(conv_integer(add(1 DOWNTO 0)));
                  ELSE
                        buffer_out <= x"00";
                  END IF;
                  cnt <= 8;
               END IF;
            WHEN read_data =>
               IF (tx = '1' AND cnt > 0) THEN
                  data_tx_cld <= buffer_out (cnt-1);
                  cnt <= cnt - 1;
               ELSIF (tx = '1' AND cnt = 0) THEN
                  data_tx_cld <= '1';
               END IF;
            WHEN write_data =>
               IF (rx = '1' AND cnt > 0) THEN
                  buffer_in <= buffer_in (6 DOWNTO 0) & data_rx;
                  cnt <= cnt - 1;
               ELSIF (tx = '1' AND cnt = 0) THEN
                  IF (add(1 DOWNTO 0) >= i2c_rw_add_min) AND (add(1 DOWNTO 0) <= i2c_rw_add_max) THEN
                     data_rw_cld(conv_integer(add(1 DOWNTO 0))) <= buffer_in;
                     data_tx_cld <= '0';
                  ELSE
                     data_tx_cld <='1';
                  END IF;
               END IF;
            WHEN ack_3 =>
               IF (tx = '1') THEN
                  data_tx_cld <= '1';
               END IF;
            WHEN OTHERS =>
               NULL;
            END CASE;


         END IF;
      END IF;

   END PROCESS clocked_proc;

   nextstate_proc : PROCESS (
      add,
      add_read_bit,
      cnt,
      current_state,
      rx,
      slave_add,
      start,
      tx)
   BEGIN

      CASE current_state IS
      WHEN idle =>
         IF (start = '1') THEN
            next_state <= chip_add;
         ELSE
            next_state <= idle;
         END IF;
      WHEN chip_add =>
         IF (rx = '1' AND cnt > 0) THEN
            next_state <= chip_add;
         ELSIF (rx = '1' AND cnt = 0) THEN
            next_state <= add_read_or_write;
         ELSE
            next_state <= chip_add;
         END IF;
      WHEN ack_1 =>
         IF (tx = '1' AND add_read_bit = '1') THEN
            next_state <= read_data;
         ELSIF (tx = '1' AND add_read_bit  = '0') THEN
            next_state <= write_data;
         ELSE
            next_state <= ack_1;
         END IF;
      WHEN add_read_or_write =>
         IF (tx = '1' AND unsigned(slave_add)=add AND add_read_bit = '0') THEN
            next_state <= ack_1;
         ELSIF (tx = '1' AND unsigned(slave_add) = add AND add_read_bit = '1') THEN
            next_state <= ack_1;
         ELSIF (tx = '1' AND unsigned(slave_add) /= add) THEN
            next_state <= idle;
         ELSE
            next_state <= add_read_or_write;
         END IF;
      WHEN read_data =>
         IF (tx = '1' AND cnt > 0) THEN
            next_state <= read_data;
         ELSIF (tx = '1' AND cnt = 0) THEN
            next_state <= idle;
         ELSE
            next_state <= read_data;
         END IF;
      WHEN write_data =>
         IF (rx = '1' AND cnt > 0) THEN
            next_state <= write_data;
         ELSIF (tx = '1' AND cnt = 0) THEN
            next_state <= ack_3;
         ELSE
            next_state <= write_data;
         END IF;
      WHEN ack_3 =>
         IF (tx = '1') THEN
            next_state <= idle;
         ELSE
            next_state <= ack_3;
         END IF;
      WHEN OTHERS =>
         next_state <= idle;
      END CASE;


   END PROCESS nextstate_proc;

   data_rw <= data_rw_cld;
   data_tx <= data_tx_cld;


END behave;


-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY i2c_master_wbone_interface IS
  GENERIC(
      base_board_clk     : natural := 40000000;
      i2c_clk_speed     : natural := 100000;
      i2c_buffer_depth  : natural := 4;
      wish_addr_width   : natural := 8;
      wish_data_width   : natural := 16);
  PORT(
    clk           : IN     std_logic;
    async_reset      : IN     std_logic;
    adr_i             : IN     std_logic_vector (wish_addr_width-1 DOWNTO 0); -- address bits
    dat_i             : IN     std_logic_vector (wish_data_width-1 DOWNTO 0); -- databus input
    dat_o             : OUT    std_logic_vector (wish_data_width-1 DOWNTO 0); -- databus output
    we_i              : IN     std_logic; -- write enable input
    stb_i             : IN     std_logic; -- strobe signals / core SELECT SIGNAL
    cyc_i             : IN     std_logic; -- valid BUS cycle input
    ack_o             : OUT    std_logic; -- BUS cycle acknowledge output
    start_add      : OUT  std_logic := '0';
    start_data       : OUT  std_logic := '0';
    stop            : OUT std_logic := '0';
    r_nw            : OUT std_logic := '0';
    add           : OUT std_logic_vector(6 DOWNTO 0) := (OTHERS => '0');
    data_w         : OUT  std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    data_r         : IN std_logic_vector(7 DOWNTO 0);
    ack           : IN  std_logic;
    idle            : IN  std_logic;
    mid_trans      : IN std_logic;
    en_i2c_sm      : OUT  std_logic := '0');
END ENTITY i2c_master_wbone_interface;

ARCHITECTURE behave OF i2c_master_wbone_interface IS

  -- Registers
  SIGNAL add_reg      : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0'); --RW
  SIGNAL data_reg     : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0'); --RW 
  SIGNAL status_reg   : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0'); --R 

    SIGNAL ack_failed           : std_logic;
  SIGNAL error_bus_not_free : std_logic;
  SIGNAL start_add_pending  : std_logic;
  SIGNAL start_data_pending : std_logic;
  SIGNAL int_start_add    : std_logic;
  SIGNAL int_start_data   : std_logic;

  -- Ensures wishbone cycle only takes 1 clk period.
  SIGNAL wish     : std_logic;

    -- JJ October 2005
    -- Have modified core AND 'tacked-on' BUFFER system so that full transaction takes place IN one go unless it fails
    TYPE i2c_buffer_type is RECORD
        data        : std_logic_vector(8 DOWNTO 0); 
        --stop        : std_logic;
        addr_ndata  : std_logic;
        --r_nw        : std_logic;
        ack_check   : std_logic;        
    END RECORD;

    TYPE i2c_buffer_array is ARRAY (integer RANGE <>) OF i2c_buffer_type;

    -- length OF transaction (up TO eight by default)
    SIGNAL transaction_length : natural RANGE 8 DOWNTO 0 := 0;
    SIGNAL i2c_buffer : i2c_buffer_array(8 DOWNTO 0);

    SIGNAL transaction_enable : std_logic := '0';
    SIGNAL transaction_active : std_logic := '0';
    
BEGIN

  ack_o <= wish AND stb_i;

  wishbone: PROCESS(clk, async_reset)
  BEGIN

    IF (async_reset = '1') THEN
        
      -- Clear error_bus_not_free status
      error_bus_not_free <= '0';
      -- Clear wishbone data output BUS
      dat_o <= (OTHERS => '0');
      wish <= '0';

            transaction_length <= 0;
            transaction_enable <= '0';

    ELSIF (clk'event AND clk = '1') THEN

      IF ((cyc_i AND stb_i)= '1') THEN

                dat_o <= (OTHERS => '0');

        -- First clk cycle IN wishbone cycle.
        IF (wish ='0') THEN

          wish <= '1';

                    IF (we_i = '1') THEN

                        -- Wishbone write
                        CASE adr_i(3 DOWNTO 0) IS
                            WHEN "0000" =>

                                IF ( (transaction_active OR transaction_enable) = '0' ) THEN
                                    
                                    -- resets the BUFFER
                                    transaction_length <= 0;

                                ELSE

                                    -- i2c busy.
                                    -- user shuld check i2c status before sending data.
                                    -- hence flag user error.
                                    error_bus_not_free <= '1';

                                END IF;

                            WHEN "0001" =>

                                -- sets data FOR byte we're ON AND increments the BUFFER pointer
                                    
                                IF ( (transaction_active OR transaction_enable) = '0' ) THEN
                                    
                                    i2c_buffer(transaction_length).data(8 DOWNTO 0) <= dat_i(8 DOWNTO 0);
                                    i2c_buffer(transaction_length).addr_ndata <= dat_i(9);
                                    i2c_buffer(transaction_length).ack_check <= dat_i(10);

                                    -- increment the transaction length
                                    transaction_length <= transaction_length + 1;

                                ELSE

                                    -- i2c busy
                                    -- user shuld check i2c status before sending data.
                                    -- hence flag user error
                                    error_bus_not_free <= '1';

                                END IF;

                            WHEN "0010" =>

                                -- trigger transaction - also resets errors
                                IF ( (transaction_active OR transaction_enable) = '0' ) THEN
                                    
                                    -- enable the transaction AND clear errors
                                    transaction_enable <= '1';
                                    error_bus_not_free <= '0';

                                ELSE
                                    
                                    -- i2c busy.
                                    -- user shuld check i2c status before sending data.
                                    -- hence flag user error.
                                    error_bus_not_free <= '1';

                                END IF;

                            WHEN OTHERS =>

                        END CASE;
                        
                    ELSE

                        -- Wisbone read
                        CASE adr_i(3 DOWNTO 0) IS

                            WHEN "0010" =>
                                dat_o <= status_reg;

                            WHEN OTHERS =>
                                dat_o <= (OTHERS => '0');  -- spare registers
                        
                        END CASE;

                    END IF; -- END OF read/write IF statement

                END IF;
            
            ELSE  -- clk cycle without wishbone transaction
                        
                wish <= '0';
        
            END IF; -- END 

            -- Transaction active, clear enable strobe
            IF (transaction_active = '1') THEN
                transaction_enable <= '0';
            END IF;

    END IF;
  END PROCESS wishbone;



  store_status_regs : PROCESS(clk, async_reset)
  BEGIN
    IF (async_reset = '1') THEN
      status_reg <= (OTHERS => '0');
    ELSIF ( rising_edge(clk) ) THEN
      IF (cyc_i = '0') THEN
        status_reg <= transaction_enable & transaction_active & error_bus_not_free & ack_failed & int_start_add & int_start_data & idle & mid_trans & data_r;
      END IF;
    END IF;
  END PROCESS store_status_regs;



  enable_i2c_state_machine : PROCESS(clk, async_reset)
    VARIABLE speed_factor_cnt : natural;
        VARIABLE transaction_index : natural;
        VARIABLE mid_trans_delay : std_logic := '0';
        VARIABLE pending_delay : std_logic := '0';
  BEGIN

    IF (async_reset = '1') THEN
      
            en_i2c_sm <= '0'; --??? JJ shouldn't this be 0?
      speed_factor_cnt := BASE_BOARD_CLK / (I2C_CLK_SPEED * 4);
            transaction_active <= '0';
            transaction_index := 0;
            ack_failed <= '0';
            mid_trans_delay := '0';
            pending_delay := '0';
            
            -- Clear slave address transmit OR data transmit pending.
      start_add_pending <= '0';
      start_data_pending <= '0';

        stop <= '0';
        r_nw <= '0';

        add <= (OTHERS => '0');
        data_w <= (OTHERS => '0');

    ELSIF ( rising_edge(clk) ) THEN

            IF ( (start_data_pending OR start_add_pending) = '1' ) THEN

                IF ( pending_delay = '1' ) THEN

                    pending_delay := '0';
                    start_data_pending <= '0';
                    start_add_pending <= '0';

                ELSE

                    pending_delay := '1';

                END IF;

            END IF;

            -- Activation strobe detection
            IF ( (transaction_enable = '1') AND (transaction_active = '0') ) THEN
                transaction_active <= '1';
                ack_failed <= '0';
                transaction_index := 0;
            END IF;
             
            -- Enable counter (controls i2c speed)
            IF (speed_factor_cnt = 0) THEN

                en_i2c_sm <= '1';

                IF ( transaction_active = '1' ) THEN

                    IF ( (transaction_index = transaction_length) ) THEN

                        -- WAIT FOR the END
                        IF ( (idle OR mid_trans) = '1' ) THEN
                         
                            -- stop IF we're ON the last transaction AND inactive
                            transaction_active <= '0';
                            mid_trans_delay := '0';

                            IF (transaction_length /= 0) THEN

                                -- Check FOR acknowledge IF looking FOR it
                                IF ( (i2c_buffer(transaction_index - 1).ack_check = '1') AND (ack = '0') ) THEN

                                    ack_failed <= '1';

                                END IF;

                            END IF;

                        END IF;

                    -- The bit that does the work
                    ELSE

                        -- Choose between address AND data transactions
                        IF ( i2c_buffer(transaction_index).addr_ndata = '1' ) THEN

                            IF ( (idle OR mid_trans) = '1' ) THEN

                                IF ( mid_trans_delay = '1' ) THEN

                                    mid_trans_delay := '0';

                                    add <= i2c_buffer(transaction_index).data(7 DOWNTO 1);
                                    r_nw <= i2c_buffer(transaction_index).data(0);
                                    stop <= i2c_buffer(transaction_index).data(8);

                                    transaction_index := transaction_index + 1;
                                    start_add_pending <= '1';

                                    --IF ( transaction_index = transaction_length ) THEN
                                    --    transaction_active <= '0';
                                    --END IF;

                                ELSE

                                    mid_trans_delay := '1';

                                END IF;

                            END IF;

                        ELSE

                            IF ( mid_trans = '1' ) THEN

                                -- clock cycle delay ON mid-cycle stuff
                                IF ( mid_trans_delay = '1' ) THEN

                                    mid_trans_delay := '0';

                                    -- Check FOR acknowledge IF looking FOR it
                                    IF ( ((i2c_buffer(transaction_index - 1).ack_check = '1') AND (ack = '1')) OR (i2c_buffer(transaction_index - 1).ack_check = '0') ) THEN

                                        -- Good transaction OR don't care
                                        data_w <= i2c_buffer(transaction_index).data(7 DOWNTO 0);
                                        stop <= i2c_buffer(transaction_index).data(8);

                                        transaction_index := transaction_index + 1;
                                        start_data_pending <= '1';

                                        -- Stop IF we're through the BUFFER
                                        --IF ( transaction_index = transaction_length ) THEN
                                        --    transaction_active <= '0';
                                        --END IF;

                                    ELSE

                                        -- Failed transaction - release state machine AND die
                                        ack_failed <= '1';
                                        transaction_active <= '0';

                                    END IF;

                                ELSE

                                    mid_trans_delay := '1';

                                END IF;

                            END IF;

                        END IF;

                    END IF;

                END IF;

                speed_factor_cnt := BASE_BOARD_CLK / (I2C_CLK_SPEED * 4);
            ELSE
                speed_factor_cnt := speed_factor_cnt - 1;
                en_i2c_sm <= '0';
            END IF;

    END IF;
  END PROCESS enable_i2c_state_machine;

  int_start_add <= start_add_pending AND (idle OR mid_trans);
  int_start_data <= start_data_pending AND mid_trans;

  start_add <= int_start_add;
  start_data <= int_start_data;

END ARCHITECTURE behave;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;
USE work.package_i2c.ALL;

ENTITY i2c_master_top IS
   GENERIC( 
      module:           type_mod_define;
      base_board_clk:   natural := 40000000;
      i2c_clk_speed:    natural := 100000);
   PORT( 
      clk:            IN std_logic;
      reset_b:          IN std_logic;
      comm_cntrl:       IN type_comm_cntrl;
      comm_reply:       OUT type_comm_reply;
      scl:              INOUT  std_logic;
      sda:              INOUT  std_logic);
END i2c_master_top ;

ARCHITECTURE behave OF i2c_master_top IS

   SIGNAL ack        : std_logic;
   SIGNAL add        : std_logic_vector(6 DOWNTO 0);
   SIGNAL data_r     : std_logic_vector(7 DOWNTO 0);
   SIGNAL data_w     : std_logic_vector(7 DOWNTO 0);
   SIGNAL en_i2c_sm  : std_logic;
   SIGNAL idle       : std_logic;
   SIGNAL mid_trans  : std_logic;
   SIGNAL r_nw       : std_logic;
   SIGNAL ack_inv    : std_logic;
   SIGNAL scl_o      : std_logic;
   SIGNAL sda_o      : std_logic;
   SIGNAL start_add  : std_logic;
   SIGNAL start_data : std_logic;
   SIGNAL stop       : std_logic;
   SIGNAL reset      : std_logic;

begin

   reset <= NOT reset_b;

   control: i2c_master_control
   PORT MAP (
      add         => add,
      async_reset => reset,
      clk         => clk,
      data_w      => data_w,
      enable      => en_i2c_sm,
      r_nw        => r_nw,
      ack_inv     => ack_inv,
      scl_i       => scl,
      sda_i       => sda,
      start_add   => start_add,
      start_data  => start_data,
      stop        => stop,
      ack         => ack,
      data_r      => data_r,
      idle        => idle,
      mid_trans   => mid_trans,
      scl_o       => scl_o,
      sda_o       => sda_o);

   comm_interface: i2c_master_comm_interface
   GENERIC MAP (
      module => module,
      base_board_clk => base_board_clk,
      i2c_clk_speed => i2c_clk_speed)
   PORT MAP (
      reset_b       => reset_b, 
      clk         => clk,
      comm_cntrl    => comm_cntrl,
      comm_reply    => comm_reply,
      start_add     => start_add,
      start_data    => start_data,
      stop          => stop,
      r_nw          => r_nw,
      ack_inv       => ack_inv,
      add           => add,
      data_w        => data_w,
      data_r        => data_r,
      ack           => ack,
      idle          => idle,
      mid_trans     => mid_trans,
      en_i2c_sm     => en_i2c_sm);

   output: i2c_master_output
   PORT MAP (
      scl   => scl,
      sda   => sda,
      scl_o => scl_o,
      sda_o => sda_o);

END behave;


-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY i2c_master_output IS
   PORT( 
      scl   : OUT    std_logic;
      sda   : OUT    std_logic;
      scl_o : IN     std_logic;
      sda_o : IN     std_logic);
END i2c_master_output ;

ARCHITECTURE behave OF i2c_master_output IS
begin
  scl <= '0' WHEN scl_o = '0' ELSE 'Z';
  sda <= '0' WHEN sda_o = '0' ELSE 'Z';
END behave;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY i2c_master_control IS
   PORT( 
      add         : IN     std_logic_vector (6 DOWNTO 0);
      async_reset : IN     std_logic;
      clk         : IN     std_logic;
      data_w      : IN     std_logic_vector (7 DOWNTO 0);
      enable      : IN     std_logic;
      r_nw        : IN     std_logic;
      ack_inv     : IN     std_logic;
      scl_i       : IN     std_logic;
      sda_i       : IN     std_logic;
      start_add   : IN     std_logic;
      start_data  : IN     std_logic;
      stop        : IN     std_logic;
      ack         : OUT    std_logic;
      data_r      : OUT    std_logic_vector (7 DOWNTO 0);
      idle        : OUT    std_logic;
      mid_trans   : OUT    std_logic;
      scl_o       : OUT    std_logic;
      sda_o       : OUT    std_logic);
END i2c_master_control ;

ARCHITECTURE behave OF i2c_master_control IS

   SIGNAL i : natural RANGE 0 TO 15;

   TYPE state_type IS (
      idle_state,
      mid_trans_state,
      start_1,
      start_2,
      start_3,
      add_1,
      add_2,
      add_3,
      add_4,
      buf_1,
      buf_2,
      buf_3,
      write_1,
      write_2,
      write_3,
      write_4,
      stop_1,
      stop_2,
      stop_3,
      read_1,
      read_2,
      read_3,
      read_4
   );

   -- State vector declaration
   ATTRIBUTE state_vector : string;
   ATTRIBUTE state_vector OF behave : ARCHITECTURE is "current_state" ;

   -- Declare current AND NEXT state signals
   SIGNAL current_state : state_type ;
   SIGNAL next_state : state_type ;

   -- Declare any pre-registered internal signals
   SIGNAL ack_cld : std_logic  ;
   SIGNAL data_r_cld : std_logic_vector (7 DOWNTO 0) ;
   SIGNAL idle_cld : std_logic  ;
   SIGNAL mid_trans_cld : std_logic  ;
   SIGNAL scl_o_cld, sda_o_cld : std_logic  ;
   SIGNAL scl_i_cld, sda_i_cld : std_logic  ;

begin

   clk_inputs : PROCESS(clk, async_reset)
   BEGIN
      IF (async_reset = '1') THEN
         sda_i_cld <= '1';
         scl_i_cld <= '1';
      ELSIF rising_edge(clk) THEN
        sda_i_cld <= sda_i;
        scl_i_cld <= scl_i;
      END IF;
   END PROCESS clk_inputs;

   clocked : PROCESS(clk, async_reset)
   BEGIN
      IF (async_reset = '1') THEN
         current_state <= idle_state;
         -- Reset Values
         ack_cld <= '0';
         data_r_cld <= "00000000";
         idle_cld <= '1';
         mid_trans_cld <= '0';
         scl_o_cld <= '1';
         sda_o_cld <= '1';
         i <= 0;
      ELSIF rising_edge(clk) THEN
         IF (enable = '1') THEN
            current_state <= next_state;
            -- Transition Actions FOR internal signals only
            CASE current_state IS
            WHEN idle_state =>
               scl_o_cld <= '1';
               sda_o_cld <= '1';
               idle_cld <= '1';
               IF (start_add= '1') THEN
                  idle_cld <= '0';
                  ack_cld <= '0';
                  -- ASSERT buf state between frames (stop-start AND repeated start)
                  -- Comprises max 1us rise AND min 4.7us hold
                  -- Note this seems very odd as 1 + 4.7 = 5.7us
                  -- I2C standard IN general is based ON a period time OF 5us.
                  --sda_o_cld <= '1';
                  --scl_o_cld <= '1';
               END IF;
            WHEN mid_trans_state =>
               IF (start_add = '1') THEN
                  mid_trans_cld <= '0';
                  -- ASSERT buf state between frames (stop-start AND repeated start)
                  -- Comprises max 1us rise AND min 4.7us hold
                  -- Note this seems very odd as 1 + 4.7 = 5.7us
                  -- I2C standard IN general is based ON a period time OF 5us.
                  sda_o_cld <= '1';
                  scl_o_cld <= '1';
               ELSIF (start_data = '1' AND r_nw = '0') THEN
                  mid_trans_cld <= '0';
                  ack_cld <= '0';
                  sda_o_cld <= data_w(7);
                  i <= 8;
               ELSIF (start_data = '1' AND r_nw = '1') THEN
                  mid_trans_cld <= '0';
                  sda_o_cld <= '1';
                  i <= 8;
               ELSE
                  mid_trans_cld <= '1';
               END IF;
            WHEN start_2 =>
               scl_o_cld <= '0';
            WHEN start_3 =>
               sda_o_cld <= add(6);
               i <= 8;
            WHEN add_1 =>
               scl_o_cld <= '1';
            WHEN add_3 =>
               scl_o_cld<= '0';
               IF (i=0) THEN
                 ack_cld <= NOT sda_i;
               END IF;
            WHEN add_4 =>
               IF (i = 0) THEN
                  mid_trans_cld <= '1';
               ELSIF (i > 0) THEN
                  IF (i > 2) THEN
                     sda_o_cld <= add(i-3);
                  ELSIF (i = 2) THEN
                     sda_o_cld <= r_nw;
                  ELSE
                     sda_o_cld <= '1'; -- ack_cld
                  END IF;
                  i <= i - 1;
               END IF;
            WHEN buf_3 =>
               -- ASSERT start state THEN WAIT FOR 0.3us sda fall, 4us hold.
               --  As WITH buf this is odd 4 + 0.3 = 4.3us, which IS
               -- NOT equal TO the 5us time period ON which I2c
               -- seems TO be based.
               sda_o_cld <= '0';
            WHEN write_1 =>
               scl_o_cld <= '1';
            WHEN write_3 =>
               scl_o_cld<= '0';
               IF (i=0) THEN
                  ack_cld <= NOT sda_i;
               END IF;
            WHEN write_4 =>
               IF ((i = 0) AND (stop = '1')) THEN
                  sda_o_cld <= '0';
               ELSIF (i = 0) THEN
                  mid_trans_cld <= '1';
               ELSIF (i > 0) THEN
                  IF (i = 1) THEN
                    sda_o_cld <= '1';
                  ELSE
                    sda_o_cld <= data_w(i-2);
                  END IF;
                  i <= i - 1;
               END IF;
            WHEN stop_1 =>
               scl_o_cld <= '1';
            WHEN stop_3 =>
               idle_cld <= '1';
            WHEN read_1 =>
               scl_o_cld <= '1';
            WHEN read_3 =>
               scl_o_cld<= '0';
               IF (i>0) THEN
                 data_r_cld(i-1) <= to_ux01(sda_i);
               END IF;
            WHEN read_4 =>
               IF ((i = 0) AND (stop = '1')) THEN
                  sda_o_cld <= '0';
               ELSIF (i = 0) THEN
                  mid_trans_cld <= '1';
               ELSIF (i > 0) THEN
                  IF (i = 1) THEN
                    -- Send acknowledge (i.e. pull TO gnd normally).
                    -- Receiver sometimes requires ack inverted (i.e. multi byte transactions).
                    sda_o_cld <= ack_inv;
                  END IF;
                  i <= i - 1;
               END IF;
            WHEN OTHERS =>
               NULL;
            END CASE;
         END IF;
      END IF;
   END PROCESS clocked;

   nextstate : PROCESS (
      current_state,
      i,
      r_nw,
      start_add,
      start_data,
      stop)
   BEGIN
      CASE current_state IS
        WHEN idle_state =>
            next_state <= idle_state;
            IF ( start_add = '1' ) THEN
                next_state <= buf_1;
            ELSE
                next_state <= idle_state;
            END IF;
        WHEN mid_trans_state =>
            next_state <= mid_trans_state;
            IF ( start_add = '1' ) THEN
                next_state <= buf_1;
            ELSIF ( start_data = '1' ) THEN
                IF ( r_nw = '0' ) THEN
                    next_state <= write_1;
                ELSE
                    next_state <= read_1;
                END IF;
            END IF;
        WHEN buf_1 =>
            next_state <= buf_2;
        WHEN buf_2 =>
            next_state <= buf_3;
        WHEN buf_3 =>
            next_state <= start_1;
        WHEN start_1 =>
            next_state <= start_2;
        WHEN start_2 =>
            next_state <= start_3;
        WHEN start_3 =>
            next_state <= add_1;
        WHEN add_1 =>
            next_state <= add_2;
        WHEN add_2 =>
            next_state <= add_3;
        WHEN add_3 =>
            next_state <= add_4;
        WHEN add_4 =>
            next_state <= add_4;
            IF ( i = 0 ) THEN
                next_state <= mid_trans_state;
            ELSIF ( i > 0 ) THEN
                next_state <= add_1;
            END IF;
        WHEN write_1 =>
            next_state <= write_2;
        WHEN write_2 =>
            next_state <= write_3;
        WHEN write_3 =>
            next_state <= write_4;
        WHEN write_4 =>
            next_state <= write_4;
            IF ( i = 0 ) THEN
                IF ( stop = '1' ) THEN
                    next_state <= stop_1;
                ELSE
                    next_state <= mid_trans_state;
                END IF;
            ELSIF ( i > 0 ) THEN
                next_state <= write_1;
            END IF;
        WHEN stop_1 =>
            next_state <= stop_2;
        WHEN stop_2 =>
            next_state <= stop_3;
        WHEN stop_3 =>
            next_state <= idle_state;
        WHEN read_1 =>
            next_state <= read_2;
        WHEN read_2 =>
            next_state <= read_3;
        WHEN read_3 =>
            next_state <= read_4;
        WHEN read_4 =>
            next_state <= read_4;
            IF ( i = 0 ) THEN
                IF ( stop = '1' ) THEN
                    next_state <= stop_1;
                ELSE
                    next_state <= mid_trans_state;
                END IF;
            ELSIF ( i > 0 ) THEN
                next_state <= read_1;
            END IF;
        WHEN OTHERS =>
            next_state <= idle_state;
      END CASE;
   END PROCESS nextstate;

   -- Concurrent Statements
   -- Clocked output assignments
   ack <= ack_cld;
   data_r <= data_r_cld;
   idle <= idle_cld;
   mid_trans <= mid_trans_cld;
   scl_o <= scl_o_cld;
   sda_o <= sda_o_cld;


END behave;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;

ENTITY i2c_master_comm_interface IS
   GENERIC(
      module:            type_mod_define;
      base_board_clk:    natural := 40000000;
      i2c_clk_speed:     natural := 100000;
      i2c_buffer_depth:  natural := 4);
   PORT(
      clk:            IN std_logic;
      reset_b:          IN std_logic;
      comm_cntrl:       IN type_comm_cntrl;
      comm_reply:       OUT type_comm_reply;
      start_add:        OUT std_logic := '0';
      start_data:       OUT std_logic := '0';
      stop:             OUT std_logic := '0';
      r_nw:             OUT std_logic := '0';
      ack_inv:           OUT std_logic := '0';
      add:              OUT std_logic_vector(6 DOWNTO 0) := (OTHERS => '0');
      data_w:           OUT std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
      data_r:           IN std_logic_vector(7 DOWNTO 0);
      ack :             IN std_logic;
      idle:             IN std_logic;
      mid_trans:        IN std_logic;
      en_i2c_sm:        OUT std_logic := '0');
END ENTITY i2c_master_comm_interface;

ARCHITECTURE behave OF i2c_master_comm_interface IS

   -- registers
   SIGNAL add_reg       : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0'); --rw
   SIGNAL data_reg         : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0'); --rw 
   SIGNAL status_reg    : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0'); --r 

   SIGNAL ack_failed           : std_logic;
   SIGNAL error_bus_not_free  : std_logic;
   SIGNAL start_add_pending   : std_logic;
   SIGNAL start_data_pending  : std_logic;
   SIGNAL int_start_add    : std_logic;
   SIGNAL int_start_data      : std_logic;

   -- Ensures comm cycle only takes 1 clk period.
   SIGNAL write_once       : std_logic;
   SIGNAL read_once        : std_logic;

    -- jj october 2005
    -- have modified core AND 'tacked-on' BUFFER system so that full transaction takes place IN one go unless it fails
    TYPE i2c_buffer_type is RECORD
        data        : std_logic_vector(8 DOWNTO 0); 
        addr_ndata  : std_logic;
        ack_check   : std_logic;
        ack_inv: std_logic;
    END RECORD;

    TYPE i2c_buffer_array is ARRAY (integer RANGE <>) OF i2c_buffer_type;
    SIGNAL i2c_buffer : i2c_buffer_array(8 DOWNTO 0);
    
    -- ARRAY TO store bytes read back.  At present set TO 2
    TYPE type_rdata_array is ARRAY (integer RANGE <>) OF std_logic_vector(7 DOWNTO 0);
    SIGNAL rdata_array :  type_rdata_array(1 DOWNTO 0);
    
    -- length OF transaction (up TO eight by default)
    SIGNAL transaction_length : natural RANGE 8 DOWNTO 0 := 0;

    SIGNAL transaction_enable : std_logic := '0';
    SIGNAL transaction_active : std_logic := '0';

    -- Is this module selected FOR read/write
    SIGNAL module_en: std_logic;
    SIGNAL r_nw_int: std_logic;

begin

  -- Does module base address match incoming address?
  module_en <= '1' WHEN (comm_cntrl.add AND (NOT module.addr_mask)) = module.addr_base ELSE '0';

  wishbone: PROCESS(clk, reset_b)
  BEGIN
    IF (reset_b = '0') THEN

      -- Clear I2C "error_bus_not_free" status
      error_bus_not_free <= '0';
      -- Clear comm BUS
      write_once <= '0';
      read_once <= '0';
      comm_reply <= comm_reply_null;
      -- I2C Parameters
      transaction_length <= 0;
      transaction_enable <= '0';
    
    ELSIF (clk'event AND clk = '1') THEN
    
      IF (comm_cntrl.stb = '1') AND (module_en = '1') THEN
        -- BUS active AND module selected
        comm_reply.ack <= '1';
        comm_reply.err <= '0';
        IF comm_cntrl.wen = '1' THEN          
          -- Write active
          IF (write_once ='0') THEN
            write_once <= '1';
            CASE comm_cntrl.add(5 DOWNTO 2) IS
              WHEN "0000" =>
                IF ( (transaction_active OR transaction_enable) = '0' ) THEN
                  -- resets the BUFFER
                  transaction_length <= 0;
                ELSE
                  -- i2c busy.
                  -- user shuld check i2c status before sending data.
                  -- hence flag user error.
                  error_bus_not_free <= '1';
                END IF;
              WHEN "0001" =>
                -- sets data FOR byte we're ON AND increments the BUFFER pointer
                IF ( (transaction_active OR transaction_enable) = '0' ) THEN
                  i2c_buffer(transaction_length).data(8 DOWNTO 0) <= comm_cntrl.wdata(8 DOWNTO 0);
                  i2c_buffer(transaction_length).addr_ndata <= comm_cntrl.wdata(9);
                  i2c_buffer(transaction_length).ack_check <= comm_cntrl.wdata(10);
                  i2c_buffer(transaction_length).ack_inv <= comm_cntrl.wdata(11);
                  -- increment the transaction length
                  transaction_length <= transaction_length + 1;
                ELSE
                  -- i2c busy
                  -- user shuld check i2c status before sending data.
                  -- hence flag user error
                  error_bus_not_free <= '1';
                END IF;
              WHEN "0010" =>
                -- trigger transaction - also resets errors
                IF ( (transaction_active OR transaction_enable) = '0' ) THEN
                  -- enable the transaction AND clear errors
                  transaction_enable <= '1';
                  error_bus_not_free <= '0';
                ELSE
                  -- i2c busy.
                  -- user shuld check i2c status before sending data.
                  -- hence flag user error.
                  error_bus_not_free <= '1';
                END IF;
              WHEN OTHERS =>
                NULL;
              END CASE;
          ELSE
            -- Write still active, but NOT first clk cycle
            NULL;
          END IF;
        ELSE
          -- Read active
          IF (read_once ='0') THEN
            read_once <= '1';
            CASE comm_cntrl.add(5 DOWNTO 2) IS
            WHEN "0011" =>
              comm_reply.rdata <= rdata_array(1) & rdata_array(0) & status_reg;
            WHEN OTHERS =>
              comm_reply.rdata <= (OTHERS => '0');  -- spare registers
            END CASE;
          ELSE
            -- Read still active, but NOT first clk cycle
            NULL;
          END IF;
        END IF;
      ELSE
        -- No BUS ACCESS
        write_once <= '0';
        read_once <= '0';
        comm_reply <= comm_reply_null;
      END IF;

      -- transaction active, clear enable strobe
      IF (transaction_active = '1') THEN
        transaction_enable <= '0';
      END IF;

    END IF;
  END PROCESS wishbone;


  store_status_regs : PROCESS(clk, reset_b)
  BEGIN
    IF (reset_b = '0') THEN
       status_reg <= (OTHERS => '0');
    ELSIF ( rising_edge(clk) ) THEN
       IF (comm_cntrl.stb = '0') THEN
          status_reg <= transaction_enable & transaction_active & error_bus_not_free & ack_failed & int_start_add & int_start_data & idle & mid_trans & data_r;
       END IF;
    END IF;
  END PROCESS store_status_regs;


  enable_i2c_state_machine : PROCESS(clk, reset_b)

    VARIABLE speed_factor_cnt : natural;
    VARIABLE transaction_index : natural;
    VARIABLE rdata_index : natural;
    VARIABLE mid_trans_delay : std_logic := '0';
    VARIABLE pending_delay : std_logic := '0';

  BEGIN

    IF (reset_b = '0') THEN
       
       en_i2c_sm <= '0'; --??? jj shouldn't this be 0?
       speed_factor_cnt := base_board_clk / (i2c_clk_speed * 4);
       transaction_active <= '0';
       transaction_index := 0;
       ack_failed <= '0';
       ack_inv <= '0';
       mid_trans_delay := '0';
       pending_delay := '0';
       rdata_array <= (OTHERS => x"00");
       
       -- clear slave address transmit OR data transmit pending.
       start_add_pending <= '0';
       start_data_pending <= '0';

       stop <= '0';
       r_nw_int <= '0';
       ack_inv <= '0';
       add <= (OTHERS => '0');
       data_w <= (OTHERS => '0');

    ELSIF ( rising_edge(clk) ) THEN

          IF ( (start_data_pending OR start_add_pending) = '1' ) THEN
              IF ( pending_delay = '1' ) THEN
                  pending_delay := '0';
                  start_data_pending <= '0';
                  start_add_pending <= '0';
              ELSE
                  pending_delay := '1';
              END IF;
          END IF;

          -- activation strobe detection
          IF ( (transaction_enable = '1') AND (transaction_active = '0') ) THEN
              transaction_active <= '1';
              ack_failed <= '0';
              transaction_index := 0;
              rdata_index := 0;
          END IF;
           
          -- enable counter (controls i2c speed)
          IF (speed_factor_cnt = 0) THEN
              en_i2c_sm <= '1';

              IF ( transaction_active = '1' ) THEN
                  
                  IF ( (transaction_index = transaction_length) ) THEN
                      
                      -- WAIT FOR the END
                      IF ( (idle OR mid_trans) = '1' ) THEN
                          -- stop IF we're ON the last transaction AND inactive
                          transaction_active <= '0';
                          mid_trans_delay := '0';

                          -- Was previous transaction a read.  IF so RECORD byte IN byte ARRAY
                          IF (r_nw_int = '1') AND (i2c_buffer(transaction_index-1).addr_ndata='0') THEN
                            rdata_array(rdata_index) <= data_r;
                            rdata_index := rdata_index + 1;
                          END IF;

                          IF (transaction_length /= 0) THEN
                              -- check FOR acknowledge IF looking FOR it
                              IF ( (i2c_buffer(transaction_index - 1).ack_check = '1') AND (ack = '0') ) THEN
                                  ack_failed <= '1';
                              END IF;
                          END IF;
                      END IF;

                  -- the bit that does the work
                  ELSE

                      -- choose between address AND data transactions
                      IF ( i2c_buffer(transaction_index).addr_ndata = '1' ) THEN
                          
                          IF ( (idle OR mid_trans) = '1' ) THEN
                              IF ( mid_trans_delay = '1' ) THEN
                                  mid_trans_delay := '0';
                                  add <= i2c_buffer(transaction_index).data(7 DOWNTO 1);
                                  r_nw_int <= i2c_buffer(transaction_index).data(0);
                                  stop <= i2c_buffer(transaction_index).data(8);
                                  transaction_index := transaction_index + 1;
                                  start_add_pending <= '1';
                              ELSE
                                  mid_trans_delay := '1';
                              END IF;
                          END IF;

                      ELSE
                          
                          IF ( mid_trans = '1' ) THEN
                              -- clock cycle delay ON mid-cycle stuff
                              IF ( mid_trans_delay = '1' ) THEN
                                  mid_trans_delay := '0';
                                  -- Was previous transaction a read.  IF so RECORD byte IN byte ARRAY
                                  IF (r_nw_int = '1') AND (i2c_buffer(transaction_index-1).addr_ndata='0') THEN
                                    rdata_array(rdata_index) <= data_r;
                                    rdata_index := rdata_index + 1;
                                  END IF;
                                  -- check FOR acknowledge IF looking FOR it
                                  IF ( ((i2c_buffer(transaction_index - 1).ack_check = '1') AND (ack = '1')) OR (i2c_buffer(transaction_index - 1).ack_check = '0') ) THEN
                                      -- good transaction OR don't care
                                      data_w <= i2c_buffer(transaction_index).data(7 DOWNTO 0);
                                      stop <= i2c_buffer(transaction_index).data(8);
                                      ack_inv <= i2c_buffer(transaction_index).ack_inv;
                                      transaction_index := transaction_index + 1;
                                      start_data_pending <= '1';
                                  ELSE
                                      -- failed transaction - release state machine AND die
                                      ack_failed <= '1';
                                      transaction_active <= '0';
                                  END IF;
                              ELSE
                                  mid_trans_delay := '1';
                              END IF;
                          END IF;

                      END IF;
                  END IF;
              END IF;

              speed_factor_cnt := base_board_clk / (i2c_clk_speed * 4);
          ELSE
              speed_factor_cnt := speed_factor_cnt - 1;
              en_i2c_sm <= '0';
          END IF;

    END IF;
  END PROCESS enable_i2c_state_machine;

  int_start_add <= start_add_pending AND (idle OR mid_trans);
  int_start_data <= start_data_pending AND mid_trans;

  start_add <= int_start_add;
  start_data <= int_start_data;

  r_nw <= r_nw_int;

END ARCHITECTURE behave;



