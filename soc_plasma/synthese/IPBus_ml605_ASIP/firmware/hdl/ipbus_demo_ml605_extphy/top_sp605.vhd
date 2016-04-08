-- Top-level design for ipbus demo
--
-- This version is for xc6vlx240t on Xilinx ML605 eval board
-- Uses the v6 hard EMAC core with GMII interface to an external Gb PHY
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, May 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;
use work.bus_arb_decl.all;
use work.mac_arbiter_decl.all;

library unisim;
use unisim.VComponents.all;

entity top_ml605_extphy is port(
	clk100: in std_logic;
	rst: in std_logic;
	leds: out std_logic_vector(7 downto 0);
   i_uart : in std_logic;
   o_uart : out std_logic
	);
end top_ml605_extphy;

architecture rtl of top_ml605_extphy is
		signal clk50: std_logic;

begin

--	DCM clock generation for internal bus, ethernet
clock_gen : entity work.clkgen
  port map
   (-- Clock in ports
    CLK_IN1 => clk100,
    -- Clock out ports
    CLK_OUT1 => clk50);

		
--	leds(7 downto 0) <= ('0','0','0','0','0','0', locked, onehz);


	Inst_plasma: entity work.plasma
	GENERIC MAP (
		memory_type => "XILINX_16X",
		log_file    => "UNUSED",
      ethernet    => '0',
		eUart       => '1',
      use_cache   => '0'
	)
	PORT MAP(
		clk           => clk50,
		reset         => rst,
		uart_write    => o_uart,
		uart_read     => i_uart,
		fifo_1_out_data  => x"00000000",
		fifo_1_read_en   => open,
		fifo_1_empty     => '0',
		fifo_2_in_data   => open,
		fifo_1_write_en  => open,
		fifo_2_full      => '0',

		fifo_1_full      => '0',
		fifo_1_valid     => '0',
		fifo_2_empty     => '0',
		fifo_2_valid     => '0',
		fifo_1_compteur  => x"00000000",
		fifo_2_compteur  => x"00000000",

		gpio0_out       => open,
		gpioA_in        => x"00000000" --open
	);
	



end rtl;

