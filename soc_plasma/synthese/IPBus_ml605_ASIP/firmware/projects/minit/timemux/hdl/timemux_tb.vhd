
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library tmcalotrigger_lib;
use tmcalotrigger_lib.linkinterface.all;

library std;
use std.textio.all;

entity timemux_tb is
  generic(
    det_pp_links : integer := 10;
    pp_mp_links :integer := 12;
    bits_per_word: integer:= 32;
    words_per_bx : integer := 6);
end entity timemux_tb;


architecture behave of timemux_tb is

  component timemux_top is
    generic(
    det_pp_links : integer := 12;
    pp_mp_links : integer := 14;
    bits_per_word: integer:= 32;
    words_per_bx : integer := 3;
    bx_per_orbit : integer := 32);
  port(
    clk_in          : in std_logic;
    rst_in          : in std_logic := '0';
    bx_cnt_in       : in std_logic_vector(11 downto 0); 
    pp_card_id      : in std_logic_vector(7 downto 0); 
    link_start_in   : in std_logic;
    link_stop_in    : in std_logic;
    link_valid_in   : in std_logic;
    link_data_in    : in all_links((det_pp_links-1) downto 0);
    link_valid_out   : out std_logic_vector((pp_mp_links-1) downto 0);
    link_data_out    : out all_links((pp_mp_links-1) downto 0));
  end component;
  
  component detector_sim is
    generic(
      det_pp_links : integer := 12;
      bits_per_word: integer:= 32;
      words_per_bx : integer := 3);
    port(
      clk_in          : in std_logic;
      rst_in          : in std_logic := '0';
      bx_cnt_out      : out std_logic_vector(11 downto 0);
      link_start_out   : out std_logic;
      link_stop_out    : out std_logic;
      link_valid_out   : out std_logic;
      link_data_out    : out all_links((det_pp_links-1) downto 0));
  end component;

  signal link_start, link_stop, link_valid: std_logic;
  signal link_data : all_links((det_pp_links-1) downto 0);

  signal clk, rst: std_logic := '1';
  signal bx_cnt: std_logic_vector(11 downto 0);

begin

  clk <= not clk after 10 ns;
  rst <= '0' after 100 ns;



  detector_sim_inst:  detector_sim
    generic map(
      det_pp_links => det_pp_links,
      bits_per_word => bits_per_word,
      words_per_bx => words_per_bx)
    port map(
      clk_in            => clk,
      rst_in            => rst,
      bx_cnt_out        => bx_cnt,
      link_start_out    => link_start,
      link_stop_out     => link_stop,
      link_valid_out    => link_valid,
      link_data_out     => link_data);

  timemux_top_inst: timemux_top
    generic map(
      det_pp_links => det_pp_links,
      pp_mp_links => pp_mp_links,
      bits_per_word => bits_per_word,
      words_per_bx => words_per_bx)
    port map(
      clk_in            => clk,
      rst_in            => rst,
      bx_cnt_in         => bx_cnt,
      pp_card_id        => x"55",     
      link_start_in     => link_start,
      link_stop_in      => link_stop,
      link_valid_in     => link_valid,
      link_data_in      => link_data);




end architecture behave;



