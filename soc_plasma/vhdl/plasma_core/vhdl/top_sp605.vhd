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

   buttons : in std_logic_vector( 2 downto 0 );
	BTNU : in std_logic;
	BTNC : in std_logic;
	BTND : in std_logic;
	BTNL : in std_logic;
	BTNR : in std_logic;
					

	VGA_hs       : out std_logic;   -- horisontal vga syncr.
   VGA_vs       : out std_logic;   -- vertical vga syncr.
   VGA_red      : out std_logic_vector(3 downto 0);   -- red output
   VGA_green    : out std_logic_vector(3 downto 0);   -- green output
   VGA_blue     : out std_logic_vector(3 downto 0)   -- blue output
	);
end top_ml605_extphy;


architecture rtl of top_ml605_extphy is

component pulse_filter 
  Generic ( DEBNC_CLOCKS : INTEGER range 2 to (INTEGER'high) := 2**16);
  Port (
    SIGNAL_I : in  STD_LOGIC;
    CLK_I    : in  STD_LOGIC;
    SIGNAL_O : out STD_LOGIC
  );
end component;

component Colorgen 
    Port ( iter : in STD_LOGIC_VECTOR (11 downto 0);
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
       iter      : out std_logic_vector(11 downto 0);   -- iter output
       ADDR1         : in  std_logic_vector(16 downto 0);
       data_in1      : in  std_logic_vector(11 downto 0);
       data_write1   : in  std_logic;
		 ADDR2         : in  std_logic_vector(16 downto 0);
       data_in2      : in  std_logic_vector(11 downto 0);
       data_write2   : in  std_logic;
		 ADDR3         : in  std_logic_vector(16 downto 0);
       data_in3      : in  std_logic_vector(11 downto 0);
       data_write3   : in  std_logic;
		 ADDR4         : in  std_logic_vector(16 downto 0);
       data_in4      : in  std_logic_vector(11 downto 0);
       data_write4   : in  std_logic);
end component;

		signal BTNUB, BTNCB, BTNDB, BTNRB, BTNLB, data_write1, data_write2,data_write3, data_write4,data_write5, data_write6,data_write7, data_write8, clk50, clk100_sig: std_logic;
		signal iterS, data_out1,data_out2, data_out3 ,data_out4, data_out5,data_out6, data_out7 ,data_out8 : std_logic_vector(11 downto 0);
		signal  ADDR1, ADDR2, ADDR3, ADDR4, ADDR5, ADDR6, ADDR7, ADDR8 : std_logic_vector(16 downto 0);
		
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


			
	clk_div : process(clk100, rst)
	begin
		if(rst='1') then
			clk50 <= '0';
		elsif(clk100'event and clk100 = '1') then
			clk50 <= not(clk50);
		end if;
	end process;
			
			
	--	leds(7 downto 0) <= ('0','0','0','0','0','0', locked, onehz);
	
--	Inst_plasma8: entity work.plasma
--		GENERIC MAP (
--			memory_type => "XILINX_16X",
--			log_file    => "UNUSED",
--			ethernet    => '0',
--			eUart       => '1',
--			use_cache   => '0',
--			plasma_code => "../code_bin8.txt"
--		)
--		PORT MAP(
--			clk           => clk50,
----			clk_VGA 		=> clk100,
--			reset         => rst,
--			uart_write    => open,
--			uart_read     => i_uart,
--			fifo_1_out_data  => x"00000000",
--			fifo_1_read_en   => open,
--			fifo_1_empty     => '0',
--			fifo_2_in_data   => open,
--			fifo_1_write_en  => open,
--			fifo_2_full      => '0',
--
--			fifo_1_full      => '0',
--			fifo_1_valid     => '0',
--			fifo_2_empty     => '0',
--			fifo_2_valid     => '0',
--			fifo_1_compteur  => x"00000000",
--			fifo_2_compteur  => x"00000000",
--
--			data_enable => data_write8,
--			ADDR => ADDR8,
--			data_out => data_out8,
--			
--			gpio0_out       => open,
--			gpioA_in        => x"000000" & buttons & BTNDB & BTNRB & BTNLB & BTNUB & BTNCB
--		);
		
--Inst_plasma7: entity work.plasma
--		GENERIC MAP (
--			memory_type => "XILINX_16X",
--			log_file    => "UNUSED",
--			ethernet    => '0',
--			eUart       => '1',
--			use_cache   => '0',
--			plasma_code => "../code_bin7.txt"
--		)
--		PORT MAP(
--			clk           => clk50,
----			clk_VGA 		=> clk100,
--			reset         => rst,
--			uart_write    => open,
--			uart_read     => i_uart,
--			fifo_1_out_data  => x"00000000",
--			fifo_1_read_en   => open,
--			fifo_1_empty     => '0',
--			fifo_2_in_data   => open,
--			fifo_1_write_en  => open,
--			fifo_2_full      => '0',
--
--			fifo_1_full      => '0',
--			fifo_1_valid     => '0',
--			fifo_2_empty     => '0',
--			fifo_2_valid     => '0',
--			fifo_1_compteur  => x"00000000",
--			fifo_2_compteur  => x"00000000",
--
--			data_enable => data_write7,
--			ADDR => ADDR7,
--			data_out => data_out7,
--			
--			gpio0_out       => open,
--			gpioA_in        => x"000000" & buttons & BTNDB & BTNRB & BTNLB & BTNUB & BTNCB --open
--		);
--		
		
--		
--		Inst_plasma5: entity work.plasma
--		GENERIC MAP (
--			memory_type => "XILINX_16X",
--			log_file    => "UNUSED",
--			ethernet    => '0',
--			eUart       => '1',
--			use_cache   => '0',
--			plasma_code => "../code_bin5.txt"
--		)
--		PORT MAP(
--			clk           => clk50,
--		--	clk_VGA 		=> clk100,
--			reset         => rst,
--			uart_write    => open,
--			uart_read     => i_uart,
--			fifo_1_out_data  => x"00000000",
--			fifo_1_read_en   => open,
--			fifo_1_empty     => '0',
--			fifo_2_in_data   => open,
--			fifo_1_write_en  => open,
--			fifo_2_full      => '0',
--
--			fifo_1_full      => '0',
--			fifo_1_valid     => '0',
--			fifo_2_empty     => '0',
--			fifo_2_valid     => '0',
--			fifo_1_compteur  => x"00000000",
--			fifo_2_compteur  => x"00000000",
--
--			data_enable => data_write5,
--			ADDR => ADDR5,
--			data_out => data_out5,
--			
--			gpio0_out       => open,
--			gpioA_in        => x"000000" & buttons & BTNDB & BTNRB & BTNLB & BTNUB & BTNCB--open
--		);
	
	Inst_plasma4: entity work.plasma
		GENERIC MAP (
			memory_type => "XILINX_16X",
			log_file    => "UNUSED",
			ethernet    => '0',
			eUart       => '1',
			use_cache   => '0',
			plasma_code => "../code_bin4.txt"
		)
		PORT MAP(
			clk           => clk50,
--			clk_VGA 		=> clk100,
			reset         => rst,
			uart_write    => open,
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

			data_enable => data_write4,
			ADDR => ADDR4,
			data_out => data_out4,
			
			gpio0_out       => open,
			gpioA_in        => x"000000" & buttons & BTNDB & BTNRB & BTNLB & BTNUB & BTNCB
		);
--		
Inst_plasma3: entity work.plasma
		GENERIC MAP (
			memory_type => "XILINX_16X",
			log_file    => "UNUSED",
			ethernet    => '0',
			eUart       => '1',
			use_cache   => '0',
			plasma_code => "../code_bin3.txt"
		)
		PORT MAP(
			clk           => clk50,
--			clk_VGA 		=> clk100,
			reset         => rst,
			uart_write    => open,
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

			data_enable => data_write3,
			ADDR => ADDR3,
			data_out => data_out3,
			
			gpio0_out       => open,
			gpioA_in        => x"000000" & buttons & BTNDB & BTNRB & BTNLB & BTNUB & BTNCB --open
		);
		
--				Inst_plasma6: entity work.plasma
--		GENERIC MAP (
--			memory_type => "XILINX_16X",
--			log_file    => "UNUSED",
--			ethernet    => '0',
--			eUart       => '1',
--			use_cache   => '0',
--			plasma_code => "../code_bin6.txt"
--		)
--		PORT MAP(
--			clk           => clk50,
----			clk_VGA 		=> clk100,
--			reset         => rst,
--			uart_write    => open,
--			uart_read     => i_uart,
--			fifo_1_out_data  => x"00000000",
--			fifo_1_read_en   => open,
--			fifo_1_empty     => '0',
--			fifo_2_in_data   => open,
--			fifo_1_write_en  => open,
--			fifo_2_full      => '0',
--
--			fifo_1_full      => '0',
--			fifo_1_valid     => '0',
--			fifo_2_empty     => '0',
--			fifo_2_valid     => '0',
--			fifo_1_compteur  => x"00000000",
--			fifo_2_compteur  => x"00000000",
--
--			data_enable => data_write6,
--			ADDR => ADDR6,
--			data_out => data_out6,
--			
--			gpio0_out       => open,
--			gpioA_in        => x"000000" & buttons & BTNDB & BTNRB & BTNLB & BTNUB & BTNCB --open
--		);

		
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
			gpioA_in        => x"000000" & buttons & BTNDB & BTNRB & BTNLB & BTNUB & BTNCB --open
		);
		
		
		Inst_plasma1: entity work.plasma
		GENERIC MAP (
			memory_type => "XILINX_16X",
			log_file    => "UNUSED",
			ethernet    => '0',
			eUart       => '1',
			use_cache   => '0',
			plasma_code => "../code_bin1.txt"
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
			gpioA_in        => x"000000" & buttons & BTNDB & BTNRB & BTNLB & BTNUB & BTNCB--open
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
					data_write2,
					ADDR3,
					data_out3,
					data_write3,
					ADDR4,
					data_out4,
					data_write4
					);
		
		InstColorgen: Colorgen
		port map(iterS,VGA_red,VGA_green,VGA_blue);
		
InstancepulsBTNU: pulse_filter
	port map(BTNU,
				clk50,
				BTNUB);
				
	
InstancepulsBTND: pulse_filter
	port map(BTND,
				clk50,
				BTNDB);


InstancepulsBTNL: pulse_filter
	port map(BTNL,
				clk50,
				BTNLB);
				
InstancepulsBTNR: pulse_filter
	port map(BTNR,
				clk50,
				BTNRB);

InstancepulsBTNC: pulse_filter
	port map(BTNC,
				clk50,
				BTNCB);


end rtl;

