-- Version register, returns a fixed value
--
-- To be replaced by a more coherent versioning mechanism later
--
-- Dave Newbold, August 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;

entity ipbus_ver is
	port(
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus
	);
	
end ipbus_ver;

architecture rtl of ipbus_ver is

begin

  ipbus_out.ipb_rdata <= X"a5c7" & X"200B"; -- Lower 16b are ipbus firmware build ID (temporary arrangement).
  ipbus_out.ipb_ack   <= ipbus_in.ipb_strobe;
  ipbus_out.ipb_err   <= '0';

end rtl;

-- Build log
--
-- build 0x1000 : 22/08/11 : Starting build ID
-- build 0x1001 : 29/08/11 : Version for SPI testing
-- build 0x1002 : 27/09/11 : Bug fixes, new transactor code; v1.3 candidate

