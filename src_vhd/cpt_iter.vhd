----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:50:17 04/04/2016 
-- Design Name: 
-- Module Name:    cpt_iter - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.CONSTANTS.all;
use work.CONFIG_MANDELBROT.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpt_iter is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  inib : in std_logic;
           endcalcul : in  STD_LOGIC;
           iter : out  STD_LOGIC_VECTOR(ITER_RANGE-1 downto 0));
end cpt_iter;

architecture Behavioral of cpt_iter is

Signal iterS : unsigned(ITER_RANGE-1 downto 0);

begin

process(reset,clock)
begin
	if reset='1' then
		iterS<=to_unsigned(5,ITER_RANGE);
	elsif rising_edge(clock) then
	if inib = '1' then
		if endcalcul ='1' then
			if iterS < (ITER_MAX-10) then
				iterS<=iterS+1;
			else
				iterS<=to_unsigned(10,ITER_RANGE);
			end if;
		end if;
	end if;
	end if;
end process;

iter<=std_logic_vector(iterS);


end Behavioral;