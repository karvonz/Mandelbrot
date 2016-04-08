--! @file cbc_logic.vhd
--! @brief Takes delay, trigger-pattern, start signal (go)
--! @author Dave Newbold
--! Institute: University of Bristol
--! @date April 2011
--
-- Modifications:
-- 20/May/2011 , David Cussans, Tidied up, changed to OHWR naming convention, added
--                              cap_trg_o to drive capture buffer start.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity cbc_logic is port(
	clk_i: in std_logic;            --! Rising edge active
	cbc_trg_o  : out std_logic;     --! To CBC trigger pin
        ext_trg_o : out std_logic;      --! To pulse generator
        cap_trg_o : out std_logic;      --! Fires at start of trigger pattern. Used to start capture buffer. 
	go_p_i : in std_logic;          --! Pulses high to start seq.
	delay_i : in unsigned(7 downto 0); --! Delay between ext_trg and cbc_trg
	trg_patt_i: in std_logic_vector(2 downto 0) --! Pattern to transmit to cbc_trg_o. LSB goes out first
	);

end cbc_logic;

architecture rtl of cbc_logic is

	signal s_go_d, s_trg : std_logic;
	signal s_del_ctr: unsigned(7 downto 0);
	signal s_patt_ctr: unsigned(1 downto 0);
	signal s_patt: std_logic_vector(3 downto 0);

begin

	s_patt <= '0' & trg_patt_i;

	process(clk_i)
	begin
          if rising_edge(clk_i) then
            s_go_d <= go_p_i;
          end if;
	end process;

        --! Generate a single-cycle pulse from rising edge of go_p_i ( just in case it isn't a pulse already )
	s_trg <= go_p_i and not s_go_d;

	process(clk_i)
	begin
          if rising_edge(clk_i) then
            
            if s_trg='1' then
              s_del_ctr <= (others=>'0');
            elsif s_del_ctr/=X"ff" then
              s_del_ctr <= s_del_ctr + 1;
            end if;
            
            if s_del_ctr=delay_i then
              s_patt_ctr <= (others=>'0');
              cap_trg_o <= '1';
            elsif s_patt_ctr/="11" then
              s_patt_ctr <= s_patt_ctr + 1;
              cap_trg_o <= '0';
            else
              cap_trg_o <= '0';
            end if;

          end if;
	end process;

	process(clk_i)
	begin
          if falling_edge(clk_i) then
            cbc_trg_o <= not s_patt(to_integer(s_patt_ctr));
          end if;
	end process;

	ext_trg_o <= s_trg;

end rtl;


