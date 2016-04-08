
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY main_pbus IS
  PORT(
    rst_async                  : IN std_logic;
    clk                        : IN std_logic;
    -- Parallel BUS
    pbus_write_in              : IN std_logic;
    pbus_en_in                 : IN std_logic;
    pbus_wdata_in              : IN std_logic_vector(31 DOWNTO 0);
    pbus_add_in                : IN std_logic_vector(31 DOWNTO 0);
    pbus_rdata_out             : OUT std_logic_vector(31 DOWNTO 0);
    pbus_ack_out               : OUT std_logic;
    -- Local funcuionality
    led_out                    : OUT std_logic_vector(3 DOWNTO 0));
END main_pbus;

ARCHITECTURE behave OF main_pbus IS

  SIGNAL rst_sync: std_logic := '1';
  SIGNAL reg: std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ack_delay: std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');

begin

  misc_proc : PROCESS(clk)
  BEGIN
    IF (clk'event AND clk = '1') THEN
      rst_sync <= rst_async;
    END IF;
  END PROCESS;

  ack_delay_proc : PROCESS(clk)
  BEGIN
    IF (clk'event AND clk = '1') THEN
      ack_delay(7 DOWNTO 1) <= ack_delay(6 DOWNTO 0);
    END IF;
  END PROCESS;

  pbus_ack_out <= ack_delay(7);

  pbus : PROCESS(clk)
  BEGIN
    IF (clk'event AND clk = '1') THEN
      IF (rst_sync = '1') THEN
        pbus_rdata_out <= (OTHERS => '0');
        ack_delay(0) <= '0';
        reg <= x"BEEF";
      ELSE
        -- Don't forget TO add code so that slave only excutes 
        -- once no matter how long master asserts pbus_en.
        -- Helpful FOR write only commands
        IF pbus_write_in = '0' THEN
          -- Read
          CASE pbus_add_in IS
          WHEN x"0000100C" => 
            ack_delay(0) <= pbus_en_in;
            pbus_rdata_out <= reg & x"0000";
          WHEN OTHERS =>
            ack_delay(0) <= '0';
            pbus_rdata_out <= x"00000000";
          END CASE;
        ELSE
          -- Write
          CASE pbus_add_in IS
          WHEN x"0000100C" => 
            ack_delay(0) <= pbus_en_in;
            reg <= pbus_wdata_in(31 DOWNTO 16);
          WHEN OTHERS =>
            ack_delay(0) <= '0';
          END CASE;
        END IF;  -- read OR write
      END IF;  -- reset
    END IF; -- clked
  END PROCESS;

  led_out <= reg(3 DOWNTO 0);

END behave;

