----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:52:04 05/20/2016 
-- Design Name: 
-- Module Name:    ADDR_calculator - Behavioral 
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
use WORK.CONSTANTS.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ADDR_calculator is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           data_write : in  STD_LOGIC;
           endcalcul : in  STD_LOGIC;
           ADDRout : out  STD_LOGIC_VECTOR (ADDR_BIT_MUX-1 downto 0));
end ADDR_calculator;

architecture Behavioral of ADDR_calculator is

Signal ADDR : unsigned(ADDR_BIT_MUX-1 downto 0);

begin
ADDRmanagement : process(clk,reset, data_write, endcalcul)
begin
	if reset='1' then
		ADDR<=(others=>'0'); --to_unsigned(15999, 14);
	elsif rising_edge(clk) then
		if endcalcul='1' then
			ADDR<=(others=>'0');
		else
			if data_write = '1' then
				if ADDR = NBR_PIXEL then
						ADDR<=(others=>'0');
				else
				ADDR<=ADDR+1;
				end if;
			end if;
		end if;
	end if;
end process;

ADDRout<=std_logic_vector(ADDR);

end Behavioral;

