--
-- VHDL Architecture TMCaloTrigger_lib.ETAdder.ETAdder
--
-- Created:
--          by - awr01.UNKNOWN (SINBADPC)
--          at - 11:42:28 25/02/2010
--
-- using Mentor Graphics HDL Designer(TM) 2006.1 (Build 72)
--
LIBRARY ieee;
LIBRARY TMCaloTrigger_lib;

USE ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

use TMCaloTrigger_lib.constants.all;
use TMCaloTrigger_lib.types.all;

ENTITY ETAdder IS
	GENERIC(
		inputwidth:		INTEGER
	);
	PORT(
		async_reset:	IN	STD_LOGIC := '1';
		clk:			IN	STD_LOGIC := '0';
		ET1in:			IN	STD_LOGIC_VECTOR( inputwidth-1 DOWNTO 0 ) := (others =>'0');
		ET2in:			IN	STD_LOGIC_VECTOR( inputwidth-1 DOWNTO 0 ) := (others =>'0');
		data_out:		OUT	STD_LOGIC_VECTOR( inputwidth DOWNTO 0 ) := (others =>'0')
	);
END ENTITY ETAdder;

--
ARCHITECTURE ETAdder OF ETAdder IS

	-- COMPONENT AddSub IS
		-- GENERIC(
			-- inputwidth:		INTEGER
		-- );
		-- PORT(
			-- a: IN std_logic_VECTOR( inputwidth-1 DOWNTO 0 );--(9 downto 0);
			-- b: IN std_logic_VECTOR( inputwidth-1 DOWNTO 0 );--(9 downto 0);
			-- clk: IN std_logic;
			-- sclr: IN std_logic;
			-- s: OUT std_logic_VECTOR( inputwidth DOWNTO 0 )--(10 downto 0));
		-- );
	-- END COMPONENT AddSub;


BEGIN


	PROCESS ( async_reset , clk ) 
	BEGIN
		IF ( async_reset='1' ) THEN
			data_out <= (others=>'0');
		ELSIF ( rising_edge(clk) ) THEN
			data_out <= std_logic_vector( to_unsigned( to_integer(unsigned(ET1in))+to_integer(unsigned(ET2in)) , inputwidth+1 ) );			
		END IF;
	END PROCESS;

		-- Adder: AddSub
		-- generic map( inputwidth	=>	inputwidth )
		-- port map (
			-- a		=>	ET1in,
			-- b		=>	ET2in,
			-- clk		=>	clk,
			-- sclr	=>	async_reset,
			-- s		=>	data_out
		-- );

	
	
END ARCHITECTURE ETAdder;

