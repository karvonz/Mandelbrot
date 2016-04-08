-- Simple ripple counter divider for flashing lights, etc
--
-- Dave Newbold, 2010


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity div24 is
    Port (clk125 : in std_logic;
          onehz: out std_logic);
end div24;

architecture rtl of div24 is

	signal ictr : unsigned(26 downto 0) := (others => '0');

begin

	process(clk125)
	begin
		if rising_edge(clk125) then
			ictr <= ictr + 1;
		end if;
	end process;
	
	onehz <= ictr(26);

end rtl;

