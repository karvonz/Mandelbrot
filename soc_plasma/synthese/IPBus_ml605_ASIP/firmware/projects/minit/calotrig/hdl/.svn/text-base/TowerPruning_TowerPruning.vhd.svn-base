----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:50:09 03/10/2010 
-- Design Name: 
-- Module Name:    TowerPruning - TowerPruning 
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

entity TowerPruning is
	port(
		async_reset:		IN	STD_LOGIC 										:= '1';
		clk:				IN	STD_LOGIC 										:= '0';
		threshold:			IN	STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 )	:= (OTHERS=>'0');	
		filterMask:			IN	tFilterMask										:= (OTHERS=>'0');
		north1x1:			IN	tEHSums											:= (OTHERS=>(OTHERS=>'0'));	
		south1x1:			IN	tEHSums											:= (OTHERS=>(OTHERS=>'0'));	
		north2x1:			IN	STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 )	:= (OTHERS=>'0');	
		south2x1:			IN	STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 )	:= (OTHERS=>'0');	
		filteredCluster:	OUT	tFilteredCluster								:= ( '0' , (OTHERS=>'0') , "0" )
	);
end TowerPruning;



architecture TowerPruning of TowerPruning is
	signal north:	STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 )	:=	(OTHERS=>'0');	
	signal south:	STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 )	:=	(OTHERS=>'0');	
	signal cluster:	STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 )	:=	(OTHERS=>'0');	
	signal maxima:	STD_LOGIC	:=	'0';		
	signal reset:	STD_LOGIC	:=	'0';		
begin

	north	<= 		north2x1				when	(filterMask.NW='0' and filterMask.NE='0')
			else	('0'&north1x1.TOWERA)	when	(filterMask.NW='0' and filterMask.NE='1')
			else	('0'&north1x1.TOWERB)	when	(filterMask.NW='1' and filterMask.NE='0')
			else (OTHERS=>'0');
	south	<=		south2x1				when	(filterMask.SW='0' and filterMask.SE='0')
			else	('0'&south1x1.TOWERA)	when	(filterMask.SW='0' and filterMask.SE='1')
			else	('0'&south1x1.TOWERB)	when	(filterMask.SW='1' and filterMask.SE='0')	
			else (OTHERS=>'0');

			
	blah: ETAdder
	generic map( inputwidth	=>	(cLinearizedWidth+2) )
	port map (
		async_reset	=>	async_reset,
		clk			=>	clk,
		ET1in		=>	north,
		ET2in		=>	south,
		data_out	=>	cluster
	);		
	maxima <= not ( filterMask.NW or filterMask.NE or filterMask.SW or filterMask.SE ) when rising_edge(clk);

	reset <= async_reset when rising_edge(clk);
	
	PROCESS ( reset , clk ) 
	BEGIN
		IF ( reset='1' ) THEN
			filteredCluster.MAXIMA <= '0';
			filteredCluster.CLUSTER <= (OTHERS=>'0');
			filteredCluster.COUNT <= "0";
		ELSIF ( rising_edge(clk) ) THEN
			filteredCluster.MAXIMA <= maxima;
			IF ( cluster >= threshold ) THEN
				filteredCluster.CLUSTER <=cluster;
				filteredCluster.COUNT <= "1";
			ELSE
				filteredCluster.CLUSTER <=(OTHERS=>'0');
				filteredCluster.COUNT <= "0";
			END IF;
		END IF;
	END PROCESS;

end TowerPruning;

