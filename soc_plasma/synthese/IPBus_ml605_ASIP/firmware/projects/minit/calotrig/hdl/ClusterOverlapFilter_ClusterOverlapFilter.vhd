----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:50:09 03/10/2010 
-- Design Name: 
-- Module Name:    ClusterOverlapFilter - ClusterOverlapFilter 
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
LIBRARY TMCaloTrigger_lib;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use TMCaloTrigger_lib.constants.all;
use TMCaloTrigger_lib.types.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ClusterOverlapFilter is
	port(
		async_reset:		IN	STD_LOGIC := '1';
		clk:				IN	STD_LOGIC := '0';
		filterRegion:		IN	tFilterRegion	:= (OTHERS=>(OTHERS=>'0'));
		filterMask:			OUT	tFilterMask		:= (OTHERS=>'0')
	);
end ClusterOverlapFilter;

architecture ClusterOverlapFilter of ClusterOverlapFilter is
	
begin

	-- PROCESS ( async_reset , clk ) 
	-- BEGIN
		-- IF ( async_reset='1' ) THEN
			-- filterMask <= (others=>'0');
		-- ELSIF ( rising_edge(clk) ) THEN
			-- if (filterRegion.NW		>	filterRegion.centre) then filterMask.NW	<=	'1'	;	else filterMask.NW	<=	'0'; end if;
			-- if (filterRegion.W		>	filterRegion.centre) then filterMask.W	<=	'1'	;	else filterMask.W	<=	'0'; end if;
			-- if (filterRegion.SW		>	filterRegion.centre) then filterMask.SW	<=	'1' ;	else filterMask.SW	<=	'0'; end if;
			-- if (filterRegion.S		>	filterRegion.centre) then filterMask.S	<=	'1'	;	else filterMask.S	<=	'0'; end if;
		-- END IF;
	-- END PROCESS;

	filterMask.NW	<= '0'	when	(async_reset='1')	else	'1'	when (	(filterRegion.N>=filterRegion.centre)	or (filterRegion.NW> filterRegion.centre)	or	(filterRegion.W> filterRegion.centre)	)	else '0';
	filterMask.NE	<= '0'	when	(async_reset='1')	else	'1'	when (	(filterRegion.N>=filterRegion.centre)	or (filterRegion.NE>=filterRegion.centre)	or	(filterRegion.E>=filterRegion.centre)	)	else '0';
	filterMask.SW	<= '0'	when	(async_reset='1')	else	'1'	when (	(filterRegion.S> filterRegion.centre)	or (filterRegion.SW> filterRegion.centre)	or	(filterRegion.W> filterRegion.centre)	)	else '0';
	filterMask.SE	<= '0'	when	(async_reset='1')	else	'1'	when (	(filterRegion.S> filterRegion.centre)	or (filterRegion.SE>=filterRegion.centre)	or	(filterRegion.E>=filterRegion.centre)	)	else '0';

end ClusterOverlapFilter;

