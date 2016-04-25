-- RESOLUTION 160x100
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--
--
--package CONFIG_MANDELBROT is 
--constant XSTART : SIGNED(31 downto 0) :=x"E0000000";
--constant XSTOP : SIGNED(31 downto 0) :=x"10000000";
--constant YSTART : SIGNED(31 downto 0) :=x"F0000000";
--constant YSTOP : SIGNED(31 downto 0) :=x"10000000";
--constant XPAS : SIGNED(31 downto 0) :=x"004D4874";
--constant YPAS : SIGNED(31 downto 0) :=x"0052BF5B";
--constant XRES : integer :=160;
--constant YRES : integer :=100;
--
--
-- end CONFIG_MANDELBROT;
--



-- RESOLUTION 640x480
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


package CONFIG_MANDELBROT is 
constant XSTART : SIGNED(31 downto 0) :=x"E0000000";
constant XSTOP : SIGNED(31 downto 0) :=x"10000000";
constant YSTART : SIGNED(31 downto 0) :=x"F0000000";
constant YSTOP : SIGNED(31 downto 0) :=x"10000000";
constant XPAS : SIGNED(31 downto 0) :=x"00133AE4";
constant YPAS : SIGNED(31 downto 0) :=x"00111A30";
constant XRES : integer :=640;
constant YRES : integer :=480;


 end CONFIG_MANDELBROT;
