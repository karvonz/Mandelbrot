--
-- VHDL Architecture TMCaloTrigger_lib.Comparitor.Comparitor
--
-- Created:
--          by - awr01.UNKNOWN (SINBADPC)
--          at - 15:06:56 24/02/2010
--
-- using Mentor Graphics HDL Designer(TM) 2006.1 (Build 72)
--
LIBRARY ieee;
LIBRARY TMCaloTrigger_lib;

USE ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use TMCaloTrigger_lib.constants.all;
use TMCaloTrigger_lib.types.all;

ENTITY Comparitor IS
	PORT(
		async_reset:		IN	STD_LOGIC := '1';
		clk:			IN	STD_LOGIC := '0';
		threshold:		IN	STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 ) := (others=>'0');
		data_in:		IN	STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 ) := (others=>'0');
		data_out:		OUT	STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 ) := (others=>'0')
	);
END ENTITY Comparitor;

--
ARCHITECTURE Comparitor OF Comparitor IS
BEGIN

	PROCESS ( async_reset , clk ) 
	BEGIN
		IF ( async_reset='1' ) THEN
				data_out <= (others=>'0');
		ELSIF ( rising_edge(clk) ) THEN
			IF ( data_in >= threshold ) THEN
				data_out <= data_in;
			ELSE
				data_out <= (others=>'0');
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE Comparitor;

