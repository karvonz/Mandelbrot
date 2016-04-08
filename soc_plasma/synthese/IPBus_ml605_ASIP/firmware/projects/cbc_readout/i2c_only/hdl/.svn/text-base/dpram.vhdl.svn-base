--! @file
--! @brief A Dual-Port RAM with configurable width and number of entries. No Xilinx specific entities.
--! @author David Cussans
--! Institute: University of Bristol
--! @date 26 April 2011

library ieee;
use ieee.std_logic_1164.all; 

use ieee.numeric_std.all;

entity dpram is
  generic (
    DATA_WIDTH : integer := 32;          --! Width of word
    RAM_ADDRESS_WIDTH  : integer := 9            --! size of RAM = 2^ram_address_width
    );         -- default is 512 locations deep
  port (
    clk : in std_logic;                 --! rising edge active
    -- read/write port
    wren_a : in std_logic;                  --! write enable, active high
    address_a : in std_logic_vector(ram_address_width-1 downto 0);  --! write (port-A) address
    data_a : in std_logic_vector(DATA_WIDTH-1 downto 0);  --! data input -port A
    q_a : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! data output - port A
    -- secondary port
    address_b : in std_logic_vector(ram_address_width-1 downto 0);  --! read (port-B) address
    q_b : out std_logic_vector(DATA_WIDTH-1 downto 0) --! Data output - port B
    ); 
end dpram; 

architecture syn of dpram is

  type ram_type is array (2**ram_address_width - 1 downto 0) of std_logic_vector (DATA_WIDTH-1 downto 0); 
  signal RAM : ram_type;
  signal read_dpra : std_logic_vector(ram_address_width-1 downto 0);
  signal read_dprb : std_logic_vector(ram_address_width-1 downto 0);

begin

  process (clk)
  begin 
    if (clk'event and clk = '1') then
      if (wren_a = '1') then
        RAM(TO_INTEGER(unsigned(address_a))) <= data_a;
      end if;
		      
  end if;
  end process;

  read_dprb <= address_b;
  read_dpra <= address_a;

  q_b <= RAM(to_integer(unsigned(read_dprb)));
  q_a <= RAM(to_integer(unsigned(read_dpra)));
  
end syn;
