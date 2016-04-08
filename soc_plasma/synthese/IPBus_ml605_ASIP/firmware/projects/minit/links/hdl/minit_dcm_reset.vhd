LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY minit_dcm_reset IS
PORT (
    clk_in                    : IN  std_logic;
    reset_in              : IN  std_logic;
    dcm_lock_in                : IN std_logic;
    dcm_reset_out            : OUT std_logic);
END minit_dcm_reset;

ARCHITECTURE rtl OF minit_dcm_reset IS

begin

   -- IN sim gtp6_plllkdet -> '1' before txoutclk_ch0 exists.
   -- Nence large WAIT before taking dcm OUT OF reset.
   dcm_rst: PROCESS(reset_in, clk_in)
      VARIABLE delay_counter: integer RANGE 0 TO 255 := 255;
   BEGIN
      IF reset_in = '1' THEN
          dcm_reset_out <= '1';
      ELSIF (clk_in = '1') AND (clk_in'event) THEN
        -- Count period OF PLL lock
        IF dcm_lock_in /= '1' THEN
          delay_counter := 255;
        ELSE 
          IF delay_counter /= 0 THEN
            delay_counter := delay_counter - 1;
          END IF;
        END IF;
        -- WAIT UNTIL lock counter reaches zero before coming OUT OF reset_in.
        IF delay_counter = 0 THEN
          dcm_reset_out <= '0';
        ELSE
          dcm_reset_out <= '1';
        END IF;  
      END IF;
   END PROCESS;

END rtl;

