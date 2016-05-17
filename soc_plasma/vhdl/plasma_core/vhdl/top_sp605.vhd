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
--use work.ipbus.ALL;
--use work.bus_arb_decl.all;
--use work.mac_arbiter_decl.all;

library unisim;
use unisim.VComponents.all;

entity top_ml605_extphy is port(
	clk100: in std_logic;
	rst: in std_logic;
	sw : in std_logic;
	--led: out std_logic_vector(7 downto 0);
	led: out std_logic;
   i_uart : in std_logic;
   o_uart : out std_logic;
   o_uart2 : out std_logic;

   buttons : in std_logic_vector( 7 downto 0 );

	VGA_hs       : out std_logic;   -- horisontal vga syncr.
   VGA_vs       : out std_logic;   -- vertical vga syncr.
   VGA_red      : out std_logic_vector(3 downto 0);   -- red output
   VGA_green    : out std_logic_vector(3 downto 0);   -- green output
   VGA_blue     : out std_logic_vector(3 downto 0)   -- blue output
	);
end top_ml605_extphy;


architecture rtl of top_ml605_extphy is

component Colorgen 
    Port ( iter : in STD_LOGIC_VECTOR (3 downto 0);
	 VGA_red      : out std_logic_vector(3 downto 0);   -- red output
       VGA_green    : out std_logic_vector(3 downto 0);   -- green output
       VGA_blue     : out std_logic_vector(3 downto 0));   -- blue output
end component;

component VGA_bitmap_640x480 
  port(clk          : in  std_logic;
		 clk_vga      : in  std_logic;
       reset        : in  std_logic;
       VGA_hs       : out std_logic;   -- horisontal vga syncr.
       VGA_vs       : out std_logic;   -- vertical vga syncr.
       iter      : out std_logic_vector(3 downto 0);   -- iter output
       ADDR1         : in  std_logic_vector(17 downto 0);
       data_in1      : in  std_logic_vector(3 downto 0);
       data_write1   : in  std_logic;
		 ADDR2         : in  std_logic_vector(17 downto 0);
       data_in2      : in  std_logic_vector(3 downto 0);
       data_write2   : in  std_logic);
end component;

		signal data_write1, data_write2, clk50, clk100_sig: std_logic;
		signal iterS, data_out1,data_out2 : std_logic_vector(3 downto 0);
		signal  ADDR1, ADDR2 : std_logic_vector(17 downto 0);
		
		--component clk_wiz_0 is -- vivado
--		component clkgen is --ise
--        port
--         (-- Clock in ports
--          clk_in1           : in     std_logic;
--          -- Clock out ports
--          clk_out1          : out    std_logic;
--			 clk_out2          : out    std_logic
--         );
--        end component;

begin

	process(rst, clk50)
	begin
		if(rst='1') then
				--o_uart <= '0';
				led <= '0';
		elsif(clk50'event and clk50='1') then
				--o_uart <= i_uart;
				led <= sw;
		end if;
	end process;

	--	DCM clock generation for internal bus, ethernet
	--clock_gen : clk_wiz_0 -- vivado
	--clock_gen : clkgen -- ise
	--  port map
	--   (-- Clock in ports
	--    CLK_IN1 => clk100,
	--    -- Clock out ports
	--    CLK_OUT1 => clk50,
	--	 CLK_OUT2 => clk100_sig);

			
	clk_div : process(clk100, rst)
	begin
		if(rst='1') then
			clk50 <= '0';
		elsif(clk100'event and clk100 = '1') then
			clk50 <= not(clk50);
		end if;
	end process;
			
			
	--	leds(7 downto 0) <= ('0','0','0','0','0','0', locked, onehz);

	
	Inst_plasma2: entity work.plasma
		GENERIC MAP (
			memory_type => "XILINX_16X",
			log_file    => "UNUSED",
			ethernet    => '0',
			eUart       => '1',
			use_cache   => '0',
			plasma_code => "../code_bin2.txt"
		)
		PORT MAP(
			clk           => clk50,
--			clk_VGA 		=> clk100,
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

			data_enable => data_write2,
			ADDR => ADDR2,
			data_out => data_out2,
			
			gpio0_out       => open,
			gpioA_in        => x"000000" & buttons --open
		);
		
		Inst_plasma1: entity work.plasma
		GENERIC MAP (
			memory_type => "XILINX_16X",
			log_file    => "UNUSED",
			ethernet    => '0',
			eUart       => '1',
			use_cache   => '0',
			plasma_code => "../code_bin.txt"
		)
		PORT MAP(
			clk           => clk50,
		--	clk_VGA 		=> clk100,
			reset         => rst,
			uart_write    => o_uart2,
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

			data_enable => data_write1,
			ADDR => ADDR1,
			data_out => data_out1,
			
			gpio0_out       => open,
			gpioA_in        => x"000000" & buttons --open
		);
	
		
		
		InstVGA: VGA_bitmap_640x480
		port map(clk50,
					clk100,
					rst,
					VGA_hs,
					VGA_vs,
					iterS,
					ADDR1,
					data_out1,
					data_write1,
					ADDR2,
					data_out2,
					data_write2
);
		
		InstColorgen: Colorgen
		port map(iterS,VGA_red,VGA_green,VGA_blue);

end rtl;

