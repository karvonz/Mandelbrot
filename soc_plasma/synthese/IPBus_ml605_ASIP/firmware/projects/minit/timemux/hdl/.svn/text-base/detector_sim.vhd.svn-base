
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library tmcalotrigger_lib;
use tmcalotrigger_lib.linkinterface.all;

library std;
use std.textio.all;

entity detector_sim is
  generic(
    det_pp_links : integer := 12;
    bits_per_word: integer:= 32;
    words_per_bx : integer := 3;
    bx_per_orbit: integer := 3564);
  port(
    clk_in          : in std_logic;
    rst_in          : in std_logic := '0';
    bx_cnt_out      : out std_logic_vector(11 downto 0);
    link_start_out   : out std_logic;
    link_stop_out    : out std_logic;
    link_valid_out   : out std_logic;
    link_data_out    : out all_links((det_pp_links-1) downto 0));
end entity detector_sim;


architecture behave of detector_sim is

  signal word_index: integer range words_per_bx-1 downto 0;
  signal event_index: integer range bx_per_orbit-1 downto 0;

begin

  detector_control: process(rst_in, clk_in)
  begin

    if rst_in = '1' then
      event_index <= 0;
      word_index <= 0;
    elsif (clk_in = '1') and (clk_in'event) then
      if word_index < words_per_bx-1 then
        -- Same event, but next data word.
        word_index <= word_index+1;
      else
        -- Start data from new event.
        word_index <= 0;
        if event_index < bx_per_orbit-1 then
          event_index <= event_index+1;
        else
          event_index <= 0;
        end if;
      end if;
    end if;
  end process;


detector_data: process(rst_in, clk_in)
  variable link_temp: link_type;
begin

  if rst_in = '1' then
    link_start_out <= '0';
    link_stop_out <= '0';
    link_clear: for i in 0 to det_pp_links-1 loop
      link_data_out(i) <=  (others => (others =>'0'));
    end loop;
  elsif (clk_in = '1') and (clk_in'event) then
    -- Link DATA
    for i in 0 to det_pp_links-1 loop
      link_temp.data := std_logic_vector(to_unsigned(i, 8) & to_unsigned(word_index, 8) & to_unsigned(event_index, 16));
      link_data_out(i) <= link_temp;
    end loop;
	 -- Event STOP
    if word_index = words_per_bx-1 then
      link_stop_out <= '1';
    else
      link_stop_out <= '0';
    end if;
	 -- Event START
    if word_index = 0 then
      link_start_out <= '1';
    else
      link_start_out <= '0';
    end if;
	 -- Event VALID
	 -- Stop events immediately before BC0
    if event_index > bx_per_orbit - 3 then
      link_valid_out <= '0';
    else
      link_valid_out <= '1';
    end if;	 
  end if;
end process;

bx_cnt_out <= std_logic_vector(to_unsigned(event_index, 12));

end architecture behave;
