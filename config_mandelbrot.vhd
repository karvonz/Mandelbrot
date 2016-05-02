library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


package CONFIG_MANDELBROT is 
constant XSTART : SIGNED(31 downto 0) :=x"CC002C40";
constant XSTOP : SIGNED(31 downto 0) :=x"FC002C60";
constant YSTART : SIGNED(31 downto 0) :=x"F0000000";
constant YSTOP : SIGNED(31 downto 0) :=x"10000000";
constant XINC : SIGNED(31 downto 0) :=x"133AE4";
constant YINC : SIGNED(31 downto 0) :=x"111A30";
constant XRES : integer :="640";
constant YRES : integer :="480";


 end CONFIG_MANDELBROT;
