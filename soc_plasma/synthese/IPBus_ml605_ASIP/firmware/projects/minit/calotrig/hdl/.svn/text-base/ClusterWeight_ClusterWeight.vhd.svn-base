----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:22:58 04/14/2010 
-- Design Name: 
-- Module Name:    ClusterWeight - ClusterWeight 
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
use ieee.numeric_std.all; 

use TMCaloTrigger_lib.constants.all;
use TMCaloTrigger_lib.components.all;
use TMCaloTrigger_lib.types.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ClusterWeight is
	port(
		async_reset:		IN	STD_LOGIC 										:= '1';
		clk:				IN	STD_LOGIC 										:= '0';
		north_or_west:		IN	STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 )	:= (OTHERS=>'0');	
		south_or_east:		IN	STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 )	:= (OTHERS=>'0');	
		region2x2:			IN	STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 )	:= (OTHERS=>'0');	
		weight:				OUT	STD_LOGIC_VECTOR( 1 DOWNTO 0 )	:= (OTHERS=>'0')
	);
end ClusterWeight;

architecture ClusterWeight of ClusterWeight is
begin

	weight(1) <= '1' when (south_or_east>north_or_west) else '0';
	weight(0) <= '1' when ( ('0'&region2x2>north_or_west&"00") or ('0'&region2x2>south_or_east&"00") ) else '0';

end ClusterWeight;

