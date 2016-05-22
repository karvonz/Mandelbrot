----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:46:34 05/19/2016 
-- Design Name: 
-- Module Name:    RAM_single_port - Behavioral 
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
use IEEE.numeric_std.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM_single_port is
    Port ( clk : in  STD_LOGIC;
           data_write : in  STD_LOGIC;
			  data_in : in STD_LOGIC_VECTOR(11 downto 0);
           ADDR : in  STD_LOGIC_VECTOR (16 downto 0);
           data_out : out  STD_LOGIC_VECTOR (11 downto 0));
end RAM_single_port;

architecture Behavioral of RAM_single_port is
constant ADDR_WIDTH : integer := 16;
constant DATA_WIDTH : integer := 12; 
	-- Graphic RAM type. this object is the content of the displayed image
	type GRAM is array (0 to 76799) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal  screen        : GRAM;-- := ram_function_name("../mandelbrot.bin"); -- the memory representation of the image
begin

	process (clk)
	begin
		if (clk'event and clk = '1') then
				if (data_write = '1') then
					screen(to_integer(unsigned(ADDR))) <= data_in;
					data_out <= data_in;
				else
					data_out <= screen(to_integer(unsigned(ADDR)));
				end if;
		end if;
	end process;

end Behavioral;

