library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

library work;
use work.txt_util.all;

entity PCIE_OUT is
	port(
		clk            : IN   std_logic;
        fifo_in_data   : IN   STD_LOGIC_VECTOR (31 DOWNTO 0);
        fifo_compteur  : OUT  STD_LOGIC_VECTOR (31 DOWNTO 0);
        fifo_write_en  : IN   std_logic;
        fifo_full      : OUT  std_logic;
        fifo_valid     : OUT  std_logic
	);
end;

architecture logic of PCIE_OUT is
begin                                                        

	PROCESS
		file ram_valid_file    : TEXT open WRITE_MODE  is "pcie_out.txt";
		variable LineValid     : string(1 to 32);
	BEGIN
		while( true ) LOOP
			wait UNTIL rising_edge( clk );
			if fifo_write_en = '1' then
				LineValid := str( fifo_in_data );
   				print(ram_valid_file, LineValid);
			end if;
		end LOOP;
	END PROCESS;                      

	fifo_valid    <= '0';
	fifo_full     <= '0';
	fifo_compteur <= (OTHERS => '0');

end; --architecture logic
