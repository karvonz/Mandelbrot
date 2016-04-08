----------------------------------------------------------------------------------
-- Company: Imperial College London

-- Engineer: Greg Iles

-- Description: Test bench for Uc to FPGA interface.  Based on 25LC640A
-- EEPROM.

-- Revision : 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

library work;
use work.package_txt_util.all;

entity spi_interface_tb is
end spi_interface_tb;

architecture Behavioral of spi_interface_tb is

  component spi_interface is
  port(
      clk:                in std_logic;
      rst:                in std_logic;
      so:                 out std_logic;
      si:                 in std_logic;
      sck:                in std_logic;
      cs_b:               in std_logic);
  end component;

  -- Read two bytes from  address x013A
  constant rd_instr: std_logic_vector(0 to 7) :=  "00000011";
  constant rd_add: std_logic_vector(15 downto 0) :=  x"013A";
  constant rd_dat: std_logic_vector(0 to 15) :=  x"54" & x"19";


  -- Write two bytes to address x023A
  constant wt_seq: std_logic_vector(0 to 39) :=  "00000011" & x"023A" & x"55" & x"AA";

  signal clk, rst, mosi, miso, cs_b, sck: std_logic:= '1';

begin

  -- Assume min clk speed = 125MHz
  clk <= not clk after 8 ns;
  rst <= '0' after 100 ns;
  
  test_rd: process
  begin
    sck <= '0';
    cs_b <= '1';
    wait for 200 ns;    
    cs_b <= '0';
    wait for 70 ns;  -- min spec
    for i in rd_instr'low to rd_instr'high loop
      mosi <= rd_instr(i);
      wait for 30 ns;
      sck <= '1';
      wait for 50 ns;   -- min spec
      sck <= '0';
      wait for 20 ns;   -- min spec
    end loop;
    for i in rd_add'high downto rd_add'low loop
      mosi <= rd_add(i);
      wait for 30 ns;
      sck <= '1';
      wait for 50 ns;   -- min spec
      sck <= '0';
      wait for 20 ns;   -- min spec
    end loop;
    for i in rd_dat'low to rd_dat'high loop
      report "Add index = " &  str(i);
      mosi <= '0';
      wait for 30 ns;
      sck <= '1';
      wait for 50 ns;   -- min spec
      sck <= '0';
      wait for 20 ns;   -- min spec
    end loop;    
    cs_b <= '1';
    wait for 1 ms;
  end process;
  
   
  spi_interface_inst: spi_interface
  port map(
      clk    => clk,
      rst    => rst,
      so     => miso,
      si     => mosi,
      sck    => sck,
      cs_b   => cs_b);

end Behavioral;

