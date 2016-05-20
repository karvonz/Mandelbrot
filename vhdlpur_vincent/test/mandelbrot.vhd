----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:02:47 05/20/2016 
-- Design Name: 
-- Module Name:    mandelbrot - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.CONSTANTS.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mandelbrot is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           BTNU : in  STD_LOGIC;
           BTNC : in  STD_LOGIC;
           BTND : in  STD_LOGIC;
           BTNL : in  STD_LOGIC;
           BTNR : in  STD_LOGIC;
			  inib : in std_logic;
			  VGA_hs       : out std_logic;   -- horisontal vga syncr.
   VGA_vs       : out std_logic;   -- vertical vga syncr.
   VGA_red      : out std_logic_vector(3 downto 0);   -- red output
   VGA_green    : out std_logic_vector(3 downto 0);   -- green output
   VGA_blue     : out std_logic_vector(3 downto 0));   -- blue output);
end mandelbrot;

architecture Behavioral of mandelbrot is

component TOP_LEVEL is
	 generic( ystart : std_logic_vector(31 downto 0) := x"00000000");
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  inib : in std_logic;
			  bleft : in STD_LOGIC;
           bright : in STD_LOGIC;
           bup : in STD_LOGIC;
           bdwn : in STD_LOGIC;
           bctr : in STD_LOGIC;
			  ADDR : out std_logic_vector( ADDR_BIT-1 downto 0);
			  data_write : out STD_LOGIC;
			  data_out     : out std_logic_vector(ITER_RANGE - 1 downto 0));
end component;

component VGA_bitmap_640x480 
  port(--clk          : in  std_logic;
		 clk_vga      : in  std_logic;
       reset        : in  std_logic;
       VGA_hs       : out std_logic;   -- horisontal vga syncr.
       VGA_vs       : out std_logic;   -- vertical vga syncr.
       iter      : out std_logic_vector(7 downto 0);   -- iter output
       ADDR1         : in  std_logic_vector(15 downto 0);
       data_in1      : in  std_logic_vector(7 downto 0);
       data_write1   : in  std_logic;
		 ADDR2         : in  std_logic_vector(15 downto 0);
       data_in2      : in  std_logic_vector(7 downto 0);
       data_write2   : in  std_logic;
		 ADDR3         : in  std_logic_vector(15 downto 0);
       data_in3      : in  std_logic_vector(7 downto 0);
       data_write3   : in  std_logic;
		 ADDR4         : in  std_logic_vector(15 downto 0);
       data_in4      : in  std_logic_vector(7 downto 0);
       data_write4   : in  std_logic;
		 ADDR5         : in  std_logic_vector(15 downto 0);
       data_in5      : in  std_logic_vector(7 downto 0);
       data_write5   : in  std_logic;
		 ADDR6         : in  std_logic_vector(15 downto 0);
       data_in6      : in  std_logic_vector(7 downto 0);
       data_write6   : in  std_logic;
		 ADDR7         : in  std_logic_vector(15 downto 0);
       data_in7      : in  std_logic_vector(7 downto 0);
       data_write7   : in  std_logic;
		 ADDR8         : in  std_logic_vector(15 downto 0);
       data_in8     : in  std_logic_vector(7 downto 0);
       data_write8   : in  std_logic);
end component;

component Colorgen 
    Port ( iter : in STD_LOGIC_VECTOR (7 downto 0);
	 VGA_red      : out std_logic_vector(3 downto 0);   -- red output
       VGA_green    : out std_logic_vector(3 downto 0);   -- green output
       VGA_blue     : out std_logic_vector(3 downto 0));   -- blue output
end component;

component pulse_filter 
  Generic ( DEBNC_CLOCKS : INTEGER range 2 to (INTEGER'high) := 2**16);
  Port (
    SIGNAL_I : in  STD_LOGIC;
    CLK_I    : in  STD_LOGIC;
    SIGNAL_O : out STD_LOGIC
  );
end component;

signal BTNUB, BTNCB, BTNDB, BTNRB, BTNLB, data_write1, data_write2,data_write3, data_write4,data_write5, data_write6,data_write7, data_write8, clk50, clk100_sig: std_logic;
		signal iterS, data_out1,data_out2, data_out3 ,data_out4, data_out5,data_out6, data_out7 ,data_out8 : std_logic_vector(7 downto 0);
		signal  ADDR1, ADDR2, ADDR3, ADDR4, ADDR5, ADDR6, ADDR7, ADDR8 : std_logic_vector(15 downto 0);

begin


I1: TOP_LEVEL
	generic map(x"F0000000")
	port map( 
				clk,
				reset,
				inib,
				BTNLB,
				BTNRB,
				BTNUB,
				BTNDB,
				BTNCB,
				ADDR1,
				data_write1,
				data_out1);
				
I2: TOP_LEVEL
	generic map(x"F4000000")
	port map( 
				clk,
				reset,
				inib,
				BTNLB,
				BTNRB,
				BTNUB,
				BTNDB,
				BTNCB,
				ADDR2,
				data_write2,
				data_out2);

I3: TOP_LEVEL
	generic map(x"F8000000")
	port map( 
				clk,
				reset,
				inib,
				BTNLB,
				BTNRB,
				BTNUB,
				BTNDB,
				BTNCB,
				ADDR3,
				data_write3,
				data_out3);
				
I4: TOP_LEVEL
	generic map(x"FC000000")
	port map( 
				clk,
				reset,
				inib,
				BTNLB,
				BTNRB,
				BTNUB,
				BTNDB,
				BTNCB,
				ADDR4,
				data_write4,
				data_out4);

I5: TOP_LEVEL
	generic map(x"00000000")
	port map( 
				clk,
				reset,
				inib,
				BTNLB,
				BTNRB,
				BTNUB,
				BTNDB,
				BTNCB,
				ADDR5,
				data_write5,
				data_out5);
				
I6: TOP_LEVEL
	generic map(x"04000000")
	port map( 
				clk,
				reset,
				inib,
				BTNLB,
				BTNRB,
				BTNUB,
				BTNDB,
				BTNCB,
				ADDR6,
				data_write6,
				data_out6);

I7: TOP_LEVEL
	generic map(x"08000000")
	port map( 
				clk,
				reset,
				inib,
				BTNLB,
				BTNRB,
				BTNUB,
				BTNDB,
				BTNCB,
				ADDR7,
				data_write7,
				data_out7);
				
I8: TOP_LEVEL
	generic map(x"0C000000")
	port map( 
				clk,
				reset,
				inib,
				BTNLB,
				BTNRB,
				BTNUB,
				BTNDB,
				BTNCB,
				ADDR8,
				data_write8,
				data_out8);		

				
		InstColorgen: Colorgen
		port map(iterS,VGA_red,VGA_green,VGA_blue);

InstVGA: VGA_bitmap_640x480
		port map(
					clk,
					reset,
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
					data_write4,
					ADDR5,
					data_out5,
					data_write5,
					ADDR6,
					data_out6,
					data_write6,
					ADDR7,
					data_out7,
					data_write7,
					ADDR8,
					data_out8,
					data_write8
					);
					
InstancepulsBTNU: pulse_filter
	port map(BTNU,
				clk,
				BTNUB);
				
	
InstancepulsBTND: pulse_filter
	port map(BTND,
				clk,
				BTNDB);


InstancepulsBTNL: pulse_filter
	port map(BTNL,
				clk,
				BTNLB);
				
InstancepulsBTNR: pulse_filter
	port map(BTNR,
				clk,
				BTNRB);

InstancepulsBTNC: pulse_filter
	port map(BTNC,
				clk,
				BTNCB);


end Behavioral;

