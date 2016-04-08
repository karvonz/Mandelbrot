----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:03:26 02/20/2011 
-- Design Name: 
-- Module Name:    hamming_encoder_26bit - Behavioral 
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hamming_encoder_26b is
	port (
		INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
end hamming_encoder_26b;

architecture Behavioral of hamming_encoder_26b is

	SUBTYPE parity_ham_26bit IS std_logic_vector(5 DOWNTO 0);
	SUBTYPE data_ham_26bit   IS std_logic_vector(25 DOWNTO 0);
	SUBTYPE coded_ham_26bit  IS std_logic_vector(31 DOWNTO 0);

---------------------
-- HAMMING ENCODER --
---------------------
FUNCTION hamming_encoder_26bit(data_in:data_ham_26bit) RETURN parity_ham_26bit  IS
	VARIABLE parity: parity_ham_26bit;
BEGIN

	parity(5)	:=	data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR data_in(15) XOR 
					data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25);
   
					
	parity(4)	:=	data_in(4) XOR data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25);
   
					
	parity(3)	:=	data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(14) XOR data_in(15) XOR data_in(16) XOR 
					data_in(17) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25);
   
					
	parity(2)	:=	data_in(0) XOR data_in(2) XOR data_in(3) XOR data_in(5) XOR data_in(6) XOR 
					data_in(9) XOR data_in(10) XOR data_in(12) XOR data_in(13) XOR data_in(16) XOR 
					data_in(17) XOR data_in(20) XOR data_in(21) XOR data_in(24) XOR data_in(25);
   
					
	parity(1)	:=	data_in(0) XOR data_in(1) XOR data_in(3) XOR data_in(4) XOR data_in(6) XOR 
					data_in(8) XOR data_in(10) XOR data_in(11) XOR data_in(13) XOR data_in(15) XOR 
					data_in(17) XOR data_in(19) XOR data_in(21) XOR data_in(23) XOR data_in(25);
   
					
	parity(0)	:=	data_in(0) XOR data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(4) XOR 
					data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR data_in(9) XOR 
					data_in(10) XOR data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR 
					data_in(15) XOR data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR 
					data_in(20) XOR data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR 
					data_in(25) XOR parity(1) XOR parity(2) XOR parity(3) XOR parity(4) XOR 
					parity(5) ;


	RETURN parity;
END;

begin

	PROCESS(INPUT_1)
	BEGIN
		OUTPUT_1 <= hamming_encoder_26bit( INPUT_1(25 downto 0) ) & INPUT_1(25 downto 0);
	end process;
	
end Behavioral;
